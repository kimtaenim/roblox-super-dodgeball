-- 원형 코트를 만들고, 플레이어를 코트 안에 있게 한다.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local C = Config.Court

local CourtService = {}

local outsideSince = {} -- 플레이어 → 코트 밖으로 나간 시각

-- 바닥 위에 눕힌 원판(실린더)을 하나 만든다.
local function makeDisc(name, radius, height, color)
	local disc = Instance.new("Part")
	disc.Name = name
	disc.Shape = Enum.PartType.Cylinder
	disc.Anchored = true
	disc.Size = Vector3.new(C.Thickness, radius * 2, radius * 2)
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
	local line = makeDisc("CourtLine", C.Radius + C.LineWidth, C.RaiseHeight, C.LineColor)
	line.Parent = folder
	local floor = makeDisc("CourtFloor", C.Radius, C.RaiseHeight * 2, C.Color)
	floor.Parent = folder
end

-- 위치가 코트 중심에서 옆으로 얼마나 떨어졌는지 잰다 (높이는 무시).
function CourtService.distanceFromCenter(position)
	local offset = position - C.Center
	return Vector3.new(offset.X, 0, offset.Z).Magnitude
end

-- 위치가 코트 안인지 알려준다.
function CourtService.isInside(position)
	return CourtService.distanceFromCenter(position) <= C.Radius
end

-- 코트 안의 아무 위치를 하나 고른다.
function CourtService.randomPointInside(radiusRatio, height)
	local angle = math.random() * math.pi * 2
	local dist = math.sqrt(math.random()) * C.Radius * radiusRatio
	return C.Center + Vector3.new(math.cos(angle) * dist, height, math.sin(angle) * dist)
end

-- 캐릭터를 코트 안 아무 곳으로 옮긴다.
function CourtService.placeInside(character)
	local root = character:WaitForChild("HumanoidRootPart")
	local point = CourtService.randomPointInside(C.SpawnRadiusRatio, C.SpawnHeight)
	root.CFrame = CFrame.new(point)
end

-- 코트 밖 캐릭터를 가장 가까운 코트 안쪽으로 옮긴다.
local function pullBackInside(root)
	local offset = root.Position - C.Center
	local flat = Vector3.new(offset.X, 0, offset.Z)
	local inner = C.Radius - C.ReturnMargin
	local target = C.Center + flat.Unit * inner + Vector3.new(0, C.SpawnHeight, 0)
	root.CFrame = CFrame.new(target) * root.CFrame.Rotation
end

-- 매 프레임 플레이어가 코트 밖에 오래 있는지 확인한다.
local function checkPlayers()
	local now = os.clock()
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and CourtService.isInside(root.Position) then
			outsideSince[player] = nil
		elseif root then
			outsideSince[player] = outsideSince[player] or now
			if now - outsideSince[player] >= C.OutsideLimitSeconds then
				pullBackInside(root)
				outsideSince[player] = nil
			end
		end
	end
end

-- 코트를 만들고 경계 검사를 시작한다.
function CourtService.start()
	CourtService.build()
	RunService.Heartbeat:Connect(checkPlayers)
	Players.PlayerRemoving:Connect(function(player)
		outsideSince[player] = nil
	end)
end

return CourtService
