-- 경기장을 꾸민다 : 햇빛·하늘빛·색감, 코트 가운데 원과 로고, 둘레의 관중석·나무·깃발.
-- 게임 규칙과는 상관없는 보기 좋은 것들만 여기 있다. 숫자는 Config.Scenery에 있다.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local S = Config.Scenery
local C = Config.Court

local Scenery = {}

-- 이름으로 Lighting 안의 효과를 찾고, 없으면 새로 만든다.
local function lightingEffect(className)
	local effect = Lighting:FindFirstChildOfClass(className)
	if not effect then
		effect = Instance.new(className)
		effect.Parent = Lighting
	end
	return effect
end

-- 햇빛과 색감을 맞춘다 (밝은 오후, 살짝 뿌연 하늘, 또렷한 색).
local function setupLighting()
	Lighting.ClockTime = S.ClockTime
	Lighting.Brightness = S.Brightness
	Lighting.OutdoorAmbient = S.OutdoorAmbient
	Lighting.GlobalShadows = true

	local atmosphere = lightingEffect("Atmosphere")
	atmosphere.Density = S.AtmosphereDensity
	atmosphere.Haze = S.AtmosphereHaze
	atmosphere.Color = S.AtmosphereColor

	local bloom = lightingEffect("BloomEffect")
	bloom.Intensity = S.BloomIntensity
	bloom.Size = S.BloomSize
	bloom.Threshold = S.BloomThreshold

	local color = lightingEffect("ColorCorrectionEffect")
	color.Saturation = S.Saturation
	color.Contrast = S.Contrast

	local rays = lightingEffect("SunRaysEffect")
	rays.Intensity = S.SunRaysIntensity
end

-- 고정된 부품을 하나 만든다.
local function block(folder, name, size, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = folder
	return part
end

-- 바닥에 눕힌 얇은 원판을 만든다 (코트 무늬용, 밟아도 걸리지 않게).
local function flatDisc(folder, name, radius, height, color)
	local disc = block(folder, name, Vector3.new(S.MarkThickness, radius * 2, radius * 2),
		CFrame.new(C.Center + Vector3.new(0, height, 0)) * CFrame.Angles(0, 0, math.rad(90)), color)
	disc.Shape = Enum.PartType.Cylinder
	disc.CanCollide = false
	disc.CanQuery = false
	return disc
end

-- 코트 가운데 원과 "SUPER DODGEBALL" 글자.
local function addCourtMarks(folder)
	local floorTop = C.RaiseHeight * 2
	flatDisc(folder, "CenterCircleLine", S.CenterCircleRadius, floorTop + S.MarkThickness, C.LineColor)
	flatDisc(folder, "CenterCircleFill", S.CenterCircleRadius - S.CenterLineWidth, floorTop + S.MarkThickness * 2, C.Color)

	local logo = block(folder, "Logo", Vector3.new(S.LogoSize.X, S.MarkThickness, S.LogoSize.Y),
		CFrame.new(C.Center + Vector3.new(0, floorTop + S.MarkThickness * 3, 0)), C.Color)
	logo.Transparency = 1
	logo.CanCollide = false
	logo.CanQuery = false
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.Parent = logo
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = S.LogoColor
	label.TextTransparency = S.LogoTransparency
	label.Text = S.LogoText
	label.Parent = gui
end

-- 코트를 바라보는 계단식 관중석 하나를 만든다. 계단마다 의자 색이 다르다.
local function addStand(folder, angle)
	local out = Vector3.new(math.cos(angle), 0, math.sin(angle))
	for step = 1, S.StandSteps do
		local distance = S.Distance + (step - 0.5) * S.StandStepDepth
		local height = S.StandStepHeight * step
		local center = C.Center + out * distance + Vector3.new(0, height / 2, 0)
		local facing = CFrame.lookAt(center, Vector3.new(C.Center.X, center.Y, C.Center.Z))
		block(folder, "Stand", Vector3.new(S.StandWidth, height, S.StandStepDepth), facing, S.StandColor, Enum.Material.Concrete)
		local seatColor = S.SeatColors[(step - 1) % #S.SeatColors + 1]
		local seat = facing * CFrame.new(0, height / 2 + S.SeatHeight / 2, 0)
		block(folder, "Seat", Vector3.new(S.StandWidth, S.SeatHeight, S.StandStepDepth * S.SeatDepthRatio), seat, seatColor)
	end
end

-- 나무 하나 : 줄기 + 동글동글한 잎 세 덩이.
local function addTree(folder, position, index)
	local trunk = S.TreeTrunk
	block(folder, "TreeTrunk", trunk, CFrame.new(position + Vector3.new(0, trunk.Y / 2, 0)), S.TrunkColor, Enum.Material.Wood)
	for i, offset in S.LeafOffsets do
		local color = S.LeafColors[(index + i) % #S.LeafColors + 1]
		local size = S.TreeLeaves * S.LeafScales[i]
		local leaf = block(folder, "Leaves", Vector3.one * size,
			CFrame.new(position + Vector3.new(0, trunk.Y, 0) + offset), color, Enum.Material.Grass)
		leaf.Shape = Enum.PartType.Ball
	end
end

-- 깃대 하나 : 꼭대기에 NPC 윗옷 색 깃발.
local function addFlag(folder, position, color)
	block(folder, "FlagPole", Vector3.new(S.PoleThickness, S.FlagPoleHeight, S.PoleThickness),
		CFrame.new(position + Vector3.new(0, S.FlagPoleHeight / 2, 0)), S.PoleColor, Enum.Material.Metal)
	local flagCenter = position + Vector3.new(0, S.FlagPoleHeight - S.FlagSize.Y / 2, S.FlagSize.Z / 2)
	block(folder, "Flag", S.FlagSize, CFrame.new(flagCenter), color, Enum.Material.Fabric)
end

-- 코트 둘레에 관중석·나무·깃발을 세운다.
local function addSurroundings(folder)
	for i = 1, S.StandCount do
		addStand(folder, (i - 0.5) / S.StandCount * math.pi * 2)
	end
	for i = 1, S.TreeCount do
		local angle = i / S.TreeCount * math.pi * 2
		local distance = S.Distance + S.StandSteps * S.StandStepDepth + S.TreeExtraDistance
		addTree(folder, C.Center + Vector3.new(math.cos(angle), 0, math.sin(angle)) * distance, i)
	end
	local personas = Config.Npc.Personas
	for i = 1, S.FlagCount do
		local angle = i / S.FlagCount * math.pi * 2
		local color = personas[(i - 1) % #personas + 1].shirt
		addFlag(folder, C.Center + Vector3.new(math.cos(angle), 0, math.sin(angle)) * S.FlagDistance, color)
	end
end

-- 조명을 맞추고 경기장을 꾸민다 (서버 시작 때 한 번).
function Scenery.build()
	setupLighting()
	local folder = Instance.new("Folder")
	folder.Name = "Scenery"
	folder.Parent = workspace
	addCourtMarks(folder)
	addSurroundings(folder)
end

return Scenery
