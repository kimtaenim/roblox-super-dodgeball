-- 경기장 : 판마다 무작위로 장소가 바뀐다 (운동장, 체육관, 교실, 거인 교실, 안방, 식당, 침실, 도서관, 박물관).
-- 튜토리얼은 체육관. 도서관·박물관은 "조용한 곳"이라 NPC가 속삭인다.
-- 장소마다 방(바닥·벽·천장·전등), 가구, 조명이 다르다. 규칙과 코트는 어디서나 같다.
-- 모양 정보는 전부 Config.Arenas(장소)와 Config.Prefabs(가구 조립법)에 있고, 여기서는 그대로 짓기만 한다.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CourtService = require(script.Parent.CourtService)
local Scenery = require(script.Parent.Scenery)

local A = Config.Arena
local C = Config.Court

local ArenaService = {}

local folder -- 지금 경기장 부품을 넣어 두는 폴더
local current -- 지금 경기장 정보

-- 이름으로 Lighting 안의 효과를 찾고, 없으면 새로 만든다.
local function lightingEffect(className)
	local effect = Lighting:FindFirstChildOfClass(className)
	if not effect then
		effect = Instance.new(className)
		effect.Parent = Lighting
	end
	return effect
end

-- 경기장에 맞게 햇빛·실내 밝기·색감을 바꾼다.
local function applyLighting(light)
	Lighting.ClockTime = light.clockTime
	Lighting.Brightness = light.brightness
	Lighting.Ambient = light.ambient
	Lighting.OutdoorAmbient = light.outdoorAmbient
	Lighting.GlobalShadows = true

	local atmosphere = lightingEffect("Atmosphere")
	atmosphere.Density = light.atmosphereDensity
	atmosphere.Haze = A.AtmosphereHaze
	atmosphere.Color = A.AtmosphereColor

	local bloom = lightingEffect("BloomEffect")
	bloom.Intensity = A.BloomIntensity
	bloom.Size = A.BloomSize
	bloom.Threshold = A.BloomThreshold

	local color = lightingEffect("ColorCorrectionEffect")
	color.Saturation = A.Saturation
	color.Contrast = A.Contrast
	color.TintColor = light.tint

	local rays = lightingEffect("SunRaysEffect")
	rays.Intensity = A.SunRaysIntensity
end

-- 부품 하나를 만든다. spec.kind : "block"(상자), "ball"(공·타원), "column"(세운 원기둥, size = 지름·높이·지름).
local function makePart(spec, cframe, scale, color)
	local part = Instance.new("Part")
	part.Name = spec.name or "Prop"
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = spec.mat or Enum.Material.SmoothPlastic
	part.Color = color or spec.color or A.DefaultColor
	part.Transparency = spec.transparency or 0
	part.Reflectance = spec.reflectance or 0
	part.CanCollide = spec.collide ~= false
	part.CastShadow = spec.shadow ~= false

	local size = spec.size * scale
	local rotation = CFrame.identity
	if spec.rot then
		rotation = CFrame.Angles(math.rad(spec.rot.X), math.rad(spec.rot.Y), math.rad(spec.rot.Z))
	end
	if spec.kind == "ball" then
		part.Size = size
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = part
	elseif spec.kind == "column" then
		-- 원기둥은 옆으로 누운 모양이라 세워서 쓴다 (높이 = size.Y)
		part.Shape = Enum.PartType.Cylinder
		part.Size = Vector3.new(size.Y, size.X, size.Z)
		rotation *= CFrame.Angles(0, 0, math.rad(90))
	else
		part.Size = size
	end
	part.CFrame = cframe * CFrame.new(spec.at * scale) * rotation

	if spec.text then
		local gui = Instance.new("SurfaceGui")
		gui.Face = spec.text.face or Enum.NormalId.Front
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = A.TextPixelsPerStud
		gui.Parent = part
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBlack
		label.TextScaled = true
		label.TextColor3 = spec.text.color or A.TextColor
		label.Text = spec.text.text
		label.Parent = gui
	end
	if spec.light then
		local light = Instance.new(if spec.light.surface then "SurfaceLight" else "PointLight")
		light.Brightness = spec.light.brightness
		light.Range = spec.light.range
		light.Color = spec.light.color or Color3.new(1, 1, 1)
		if spec.light.surface then
			light.Face = spec.light.surface
		end
		light.Parent = part
	end
	part.Parent = folder
	return part
end

-- 가구 하나(조립법 = 부품 목록)를 cframe 자리에 짓는다. tint 부품은 color로 칠한다.
local function buildPrefab(parts, cframe, scale, tint)
	for _, spec in parts do
		makePart(spec, cframe, scale, if spec.tint then tint else nil)
	end
end

-- 놓을 자리 목록을 만든다 : 한 자리, 줄지어 여러 자리(repeat), 코트를 둘러싼 원(ring).
local function placements(item)
	local list = {}
	local baseRotation = CFrame.Angles(0, math.rad(item.rotY or 0), 0)
	local lift = Vector3.new(0, item.y or 0, 0) -- 식탁 위처럼 바닥에서 띄우기
	if item.ring then
		local R = item.ring
		for i = 1, R.count do
			local angle = math.rad(R.startDeg or 0) + (i - 1) / R.count * math.pi * 2
			local position = C.Center + Vector3.new(math.cos(angle), 0, math.sin(angle)) * R.radius + lift
			-- 앞(-Z)이 코트 가운데를 보게 세운다
			local facing = CFrame.lookAt(position, Vector3.new(C.Center.X, position.Y, C.Center.Z))
			table.insert(list, facing * baseRotation)
		end
	else
		local count = item.repeatCount or 1
		local step = item.step or Vector3.zero
		for i = 1, count do
			table.insert(list, CFrame.new(C.Center + item.pos + lift + step * (i - 1)) * baseRotation)
		end
	end
	return list
end

-- 경기장 목록의 가구(item) 하나를 모든 자리에 짓는다.
local function buildItem(item)
	local parts = item.parts or Config.Prefabs[item.prefab]
	assert(parts, "Config.Prefabs에 없는 가구: " .. tostring(item.prefab))
	for index, cframe in placements(item) do
		local tint = item.colors and item.colors[(index - 1) % #item.colors + 1]
		buildPrefab(parts, cframe, item.scale or 1, tint)
	end
end

-- 방 껍데기를 짓는다 : 바닥, 네 벽, 걸레받이, 천장, 천장 전등.
local function buildRoom(room)
	local half, height = room.half, room.height
	local center = C.Center
	local wall = A.WallThickness

	local floor = makePart({ kind = "block", size = Vector3.new(half * 2, wall, half * 2), at = Vector3.zero, mat = room.floorMat },
		CFrame.new(center + Vector3.new(0, A.FloorLift - wall / 2, 0)), 1, room.floorColor)
	floor.Name = "RoomFloor"

	-- 네 벽 (앞뒤, 좌우)
	local sides = {
		{ Vector3.new(0, 0, half + wall / 2), Vector3.new(half * 2 + wall * 2, height, wall) },
		{ Vector3.new(0, 0, -half - wall / 2), Vector3.new(half * 2 + wall * 2, height, wall) },
		{ Vector3.new(half + wall / 2, 0, 0), Vector3.new(wall, height, half * 2) },
		{ Vector3.new(-half - wall / 2, 0, 0), Vector3.new(wall, height, half * 2) },
	}
	for _, side in sides do
		local position = center + side[1] + Vector3.new(0, height / 2, 0)
		makePart({ kind = "block", size = side[2], at = Vector3.zero, mat = room.wallMat, name = "Wall" }, CFrame.new(position), 1, room.wallColor)
		-- 걸레받이 : 벽 아래쪽 띠
		local trimSize = side[2] + Vector3.new(A.TrimDepth, 0, A.TrimDepth)
		trimSize = Vector3.new(trimSize.X, A.TrimHeight, trimSize.Z)
		local trimPosition = center + side[1] + Vector3.new(0, A.TrimHeight / 2, 0)
		makePart({ kind = "block", size = trimSize, at = Vector3.zero, name = "Trim" }, CFrame.new(trimPosition), 1, room.trimColor)
	end

	-- 천장
	makePart({ kind = "block", size = Vector3.new(half * 2 + wall * 2, wall, half * 2 + wall * 2), at = Vector3.zero, name = "Ceiling" },
		CFrame.new(center + Vector3.new(0, height + wall / 2, 0)), 1, room.ceilingColor)

	-- 천장 전등 : 바둑판처럼 고르게
	local n = room.lightGrid
	local gap = half * 2 / n
	for i = 1, n do
		for j = 1, n do
			local x = -half + gap * (i - 0.5)
			local z = -half + gap * (j - 0.5)
			makePart({
				kind = "block", size = A.LampSize, at = Vector3.zero, mat = Enum.Material.Neon, name = "CeilingLamp", collide = false,
				light = { surface = Enum.NormalId.Bottom, brightness = room.lampBrightness, range = A.LampRange, color = room.lampColor },
			}, CFrame.new(center + Vector3.new(x, height - A.LampSize.Y / 2, z)), 1, room.lampColor)
		end
	end
end

-- 경기장 이름으로 정보를 찾는다.
local function find(id)
	for _, arena in Config.Arenas do
		if arena.id == id then
			return arena
		end
	end
	return nil
end

-- 경기장을 짓는다 (전에 있던 경기장은 치운다).
function ArenaService.build(id)
	local arena = find(id) or Config.Arenas[1]
	if folder then
		folder:Destroy()
	end
	folder = Instance.new("Folder")
	folder.Name = "Arena"
	folder.Parent = workspace
	current = arena

	applyLighting(arena.light)
	CourtService.setFloorColor(arena.courtColor or C.Color)
	Scenery.setCourtColor(arena.courtColor or C.Color)
	if arena.room then
		buildRoom(arena.room)
	end
	for _, item in arena.items do
		buildItem(item)
	end
	return arena
end

-- 이번 판 경기장을 고른다 : 튜토리얼은 체육관, 아니면 무작위 (방금 판과 같은 곳은 피한다).
function ArenaService.pick(tutorial)
	if tutorial then
		return A.TutorialArena
	end
	local choices = {}
	for _, arena in Config.Arenas do
		if not current or arena.id ~= current.id then
			table.insert(choices, arena.id)
		end
	end
	return choices[math.random(1, #choices)]
end

-- 지금 경기장이 조용해야 하는 곳(도서관·박물관)인지 알려준다.
function ArenaService.isQuiet()
	return current ~= nil and current.quiet == true
end

-- 지금 경기장 이름 (화면 표시용).
function ArenaService.currentName()
	return current and current.name or ""
end

return ArenaService
