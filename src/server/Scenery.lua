-- 코트 무늬 : 가운데 원과 "SUPER DODGEBALL" 글자. (조명과 둘레 꾸미기는 ArenaService가 경기장마다 한다)
-- 숫자는 Config.Scenery에 있다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local S = Config.Scenery
local C = Config.Court

local Scenery = {}

local centerFill -- 가운데 원 안쪽 (코트 색과 같게 칠한다)

-- 바닥에 눕힌 얇은 원판을 만든다 (밟아도 걸리지 않게).
local function flatDisc(folder, name, radius, height, color)
	local disc = Instance.new("Part")
	disc.Name = name
	disc.Shape = Enum.PartType.Cylinder
	disc.Anchored = true
	disc.CanCollide = false
	disc.CanQuery = false
	disc.Size = Vector3.new(S.MarkThickness, radius * 2, radius * 2)
	disc.CFrame = CFrame.new(C.Center + Vector3.new(0, height, 0)) * CFrame.Angles(0, 0, math.rad(90))
	disc.Color = color
	disc.Material = Enum.Material.SmoothPlastic
	disc.Parent = folder
	return disc
end

-- 코트 가운데 원과 글자를 만든다 (서버 시작 때 한 번).
function Scenery.build()
	local folder = Instance.new("Folder")
	folder.Name = "CourtMarks"
	folder.Parent = workspace

	local floorTop = C.RaiseHeight * 2
	flatDisc(folder, "CenterCircleLine", S.CenterCircleRadius, floorTop + S.MarkThickness, C.LineColor)
	centerFill = flatDisc(folder, "CenterCircleFill", S.CenterCircleRadius - S.CenterLineWidth, floorTop + S.MarkThickness * 2, C.Color)

	local logo = Instance.new("Part")
	logo.Name = "Logo"
	logo.Anchored = true
	logo.CanCollide = false
	logo.CanQuery = false
	logo.Transparency = 1
	logo.Size = Vector3.new(S.LogoSize.X, S.MarkThickness, S.LogoSize.Y)
	logo.CFrame = CFrame.new(C.Center + Vector3.new(0, floorTop + S.MarkThickness * 3, 0))
	logo.Parent = folder
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

-- 코트 색이 바뀌면 가운데 원 안쪽도 같은 색으로 칠한다.
function Scenery.setCourtColor(color)
	if centerFill then
		centerFill.Color = color
	end
end

return Scenery
