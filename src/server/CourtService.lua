-- 원형 코트를 만들고, 줄이고, 참가자를 코트 안에 있게 한다 (설계서 4장).

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Participants = require(script.Parent.Participants)

local C = Config.Court

local CourtService = {}

local radius = C.StartRadius -- 지금 코트 반지름
local floorDisc, lineDisc -- 코트 바닥, 흰 테두리
local roundActive = false -- 판이 진행 중이면 true
local outsideSince = {} -- 참가자 → 코트 밖으로 나간 시각

-- 반지름에 맞는 원판 크기를 구한다.
local function discSize(r)
	return Vector3.new(C.Thickness, r * 2, r * 2)
end

-- 바닥 위에 눕힌 원판(실린더)을 하나 만든다.
local function makeDisc(name, r, height, color)
	local disc = Instance.new("Part")
	disc.Name = name
	disc.Shape = Enum.PartType.Cylinder
	disc.Anchored = true
	disc.Size = discSize(r)
	-- 실린더는 옆으로 누워 있어서 90도 돌려 세운다
	disc.CFrame = CFrame.new(C.Center + Vector3.new(0, height - C.Thickness / 2, 0)) * CFrame.Angles(0, 0, math.rad(90))
	disc.Color = color
	disc.Material = Enum.Material.SmoothPlastic
	disc.TopSurface = Enum.SurfaceType.Smooth
	disc.BottomSurface = Enum.SurfaceType.Smooth
	return disc
end

-- 코트(테두리 + 바닥)와, 필요하면 바깥 평지를 만든다.
function CourtService.build()
	local folder = Instance.new("Folder")
	folder.Name = "Court"
	folder.Parent = workspace

	-- Baseplate가 없으면 바깥 평지를 직접 만든다 (밖으로 나가도 떨어지지 않게)
	if not workspace:FindFirstChild("Baseplate") then
		local ground = Instance.new("Part")
		ground.Name = "Ground"
		ground.Anchored = true
		ground.Size = Vector3.new(C.GroundSize, C.Thickness, C.GroundSize)
		ground.Position = C.Center - Vector3.new(0, C.Thickness / 2, 0)
		ground.Color = C.GroundColor
		ground.Material = Enum.Material.Grass
		ground.Parent = folder
	end

	-- 흰 테두리를 조금 크게 깔고, 그 위에 파란 코트를 올린다
	lineDisc = makeDisc("CourtLine", radius + C.LineWidth, C.RaiseHeight, C.LineColor)
	lineDisc.Parent = folder
	floorDisc = makeDisc("CourtFloor", radius, C.RaiseHeight * 2, C.Color)
	floorDisc.Parent = folder
end

-- 지금 코트 반지름을 알려준다.
function CourtService.getRadius()
	return radius
end

-- 코트 반지름을 바꾼다. animate면 천천히 줄어드는 모습을 보여준다.
function CourtService.setRadius(newRadius, animate)
	radius = newRadius
	local floorSize = discSize(newRadius)
	local lineSize = discSize(newRadius + C.LineWidth)
	if animate then
		local info = TweenInfo.new(C.ShrinkTweenSeconds)
		TweenService:Create(floorDisc, info, { Size = floorSize }):Play()
		TweenService:Create(lineDisc, info, { Size = lineSize }):Play()
	else
		floorDisc.Size = floorSize
		lineDisc.Size = lineSize
	end
	ReplicatedStorage.GameState:SetAttribute("CourtRadius", newRadius)
end

-- 판 진행 여부를 바꾼다. 판 중에는 참가하지 않은 사람을 코트 밖으로 내보낸다.
function CourtService.setRoundActive(on)
	roundActive = on
end

-- 위치가 코트 중심에서 옆으로 얼마나 떨어졌는지 잰다 (높이는 무시).
function CourtService.distanceFromCenter(position)
	local offset = position - C.Center
	return Vector3.new(offset.X, 0, offset.Z).Magnitude
end

-- 위치가 코트 안인지 알려준다.
function CourtService.isInside(position)
	return CourtService.distanceFromCenter(position) <= radius
end

-- 위치가 코트 밖이면 경계에서 margin만큼 안쪽으로 끌어온다 (높이는 그대로).
function CourtService.clampInside(position, margin)
	local offset = position - C.Center
	local flat = Vector3.new(offset.X, 0, offset.Z)
	local limit = math.max(0, radius - margin)
	if flat.Magnitude <= limit then
		return position
	end
	local inside = C.Center + flat.Unit * limit
	return Vector3.new(inside.X, position.Y, inside.Z)
end

-- 코트 안의 아무 위치를 하나 고른다.
function CourtService.randomPointInside(radiusRatio, height)
	local angle = math.random() * math.pi * 2
	local distance = math.sqrt(math.random()) * radius * radiusRatio
	return C.Center + Vector3.new(math.cos(angle) * distance, height, math.sin(angle) * distance)
end

-- 캐릭터를 코트 안 아무 곳으로 옮긴다.
function CourtService.placeInside(character)
	local point = CourtService.randomPointInside(C.SpawnRadiusRatio, C.SpawnHeight)
	character:PivotTo(CFrame.new(point))
end

-- 캐릭터를 코트 바깥 구경 자리로 옮긴다.
function CourtService.placeOutside(character)
	local angle = math.random() * math.pi * 2
	local distance = radius + C.SpectatorGap
	local point = C.Center + Vector3.new(math.cos(angle) * distance, C.SpawnHeight, math.sin(angle) * distance)
	character:PivotTo(CFrame.new(point, C.Center + Vector3.new(0, C.SpawnHeight, 0)))
end

-- 몸을 코트 안쪽 경계로 옮긴다 (보는 방향은 그대로).
local function pullBackInside(root, height)
	local target = CourtService.clampInside(root.Position, C.ReturnMargin)
	target = Vector3.new(target.X, height, target.Z)
	root.CFrame = CFrame.new(target) * root.CFrame.Rotation
end

-- 코트 밖 경고 시간을 적거나 지운다 (화면에 "코트 밖!" 표시용).
local function setOutsideDeadline(p, deadline)
	Participants.setAttribute(p, "OutsideDeadline", deadline)
end

-- 참가자 한 명이 코트 규칙을 지키는지 확인한다.
local function checkParticipant(p, now)
	local root = Participants.getRoot(p)
	if not root then
		return
	end
	local inside = CourtService.isInside(root.Position)
	local playing = p.inRound or (not roundActive and not p.isNpc)

	if not playing then
		-- 판 중에 구경하는 사람은 코트 밖에 있어야 한다
		if CourtService.distanceFromCenter(root.Position) < radius + C.ReturnMargin then
			CourtService.placeOutside(p.character)
		end
		outsideSince[p] = nil
		setOutsideDeadline(p, nil)
	elseif p.state.status == "Sitting" then
		-- 앉은 사람이 코트 밖에 남으면 가장자리로 옮겨 앉힌다
		if not inside then
			pullBackInside(root, root.Position.Y)
		end
		outsideSince[p] = nil
		setOutsideDeadline(p, nil)
	elseif inside then
		outsideSince[p] = nil
		setOutsideDeadline(p, nil)
	else
		-- 살아 있는 사람이 밖에 3초 넘게 있으면 안으로 되돌린다
		if not outsideSince[p] then
			outsideSince[p] = now
			setOutsideDeadline(p, workspace:GetServerTimeNow() + C.OutsideLimitSeconds)
		end
		if now - outsideSince[p] >= C.OutsideLimitSeconds then
			pullBackInside(root, C.Center.Y + C.SpawnHeight)
			outsideSince[p] = nil
			setOutsideDeadline(p, nil)
		end
	end
end

-- 매 프레임 모든 참가자가 코트 규칙을 지키는지 확인한다.
local function checkAll()
	local now = os.clock()
	for _, p in Participants.all() do
		checkParticipant(p, now)
	end
end

-- 나간 참가자 기록을 지운다.
function CourtService.forget(p)
	outsideSince[p] = nil
end

-- 코트를 만들고 경계 검사를 시작한다.
function CourtService.start()
	CourtService.build()
	RunService.Heartbeat:Connect(checkAll)
end

return CourtService
