-- NPC 한 명 한 명의 생김새를 만든다 : 체형, 얼굴(눈·눈썹·코·입·볼), 머리 모양, 옷, 등번호 (설계서 9장).
-- 생김새 정보는 Config.Npc.Personas, 부품 크기·위치 비율은 Config.Looks에 있다.
-- 덧붙인 부품은 모두 공 판정에 안 걸린다 (공 판정은 원래 R15 몸으로만 한다).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local L = Config.Looks

local NpcLooks = {}

-- 머리 크기에 대한 비율을 실제 크기로 바꾼다.
local function scaled(baseSize, ratio)
	return Vector3.new(baseSize.X * ratio.X, baseSize.Y * ratio.Y, baseSize.Z * ratio.Z)
end

-- 공 모양 비율(숫자 하나)을 실제 크기로 바꾼다.
local function round(baseSize, ratio)
	return scaled(baseSize, Vector3.one * ratio)
end

-- 머리 기준 비율 위치를 실제 위치(CFrame)로 바꾼다.
local function at(baseSize, x, y, z)
	return CFrame.new(baseSize.X * x, baseSize.Y * y, baseSize.Z * z)
end

-- 꾸밈 부품 하나를 만들어 base(몸 부위)에 붙인다. shape는 "ball"(둥근 타원) 또는 "block".
local function piece(folder, base, offset, size, color, shape)
	local part = Instance.new("Part")
	part.Name = "Look"
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = false
	part.CanQuery = false -- 공 판정에 안 걸리게
	part.CanTouch = false
	part.Massless = true
	part.CastShadow = false
	if shape == "ball" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = part
	end
	part.CFrame = base.CFrame * offset
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = base
	weld.Part1 = part
	weld.Parent = part
	part.Parent = folder
	return part
end

-- 두 점을 잇는 방향으로 기울어진 조각의 각도(라디안)를 구한다 (머리 크기 비율 고려).
local function slope(headSize, dx, dy)
	return math.atan2(dy * headSize.Y, dx * headSize.X)
end

-- 눈 : 흰자 + 눈동자 + 반짝임. "happy"는 ^ ^ 모양, "sleepy"는 눈꺼풀이 반쯤 덮는다.
local function addEyes(folder, head, style, skin)
	local size = head.Size
	local E = L.Eyes[style]
	local z = L.FaceDepth
	for _, side in { -1, 1 } do
		local x = side * E.gapX
		if E.arc then
			for _, half in { -1, 1 } do
				local tilt = CFrame.Angles(0, 0, -half * math.rad(E.arcTiltDegrees))
				local offset = at(size, x + half * E.arc.X * E.arcSpread, E.y, z) * tilt
				piece(folder, head, offset, scaled(size, E.arc), L.PupilColor, "block")
			end
			continue
		end
		piece(folder, head, at(size, x, E.y, z), scaled(size, E.white), L.EyeWhiteColor, "ball")
		local pupilZ = z - E.white.Z / 2
		piece(folder, head, at(size, x, E.y, pupilZ), scaled(size, E.pupil), L.PupilColor, "ball")
		local shine = at(size, x + L.ShineOffset.X, E.y + L.ShineOffset.Y, pupilZ - E.pupil.Z / 2)
		piece(folder, head, shine, round(size, L.ShineSize), L.EyeWhiteColor, "ball")
		if E.lid then
			-- 졸린 눈꺼풀 : 흰자 위쪽을 피부색으로 덮는다
			local lidOffset = at(size, x, E.y + E.white.Y * E.lidRaise, pupilZ - E.pupil.Z)
			piece(folder, head, lidOffset, scaled(size, E.white * E.lid), skin, "ball")
		end
	end
end

-- 눈썹 : brave(씩씩, 안쪽이 내려감) / calm(일자) / happy(올라감).
local function addBrows(folder, head, style, hairColor)
	local size = head.Size
	local B = L.Brows
	local tilt = math.rad(B.tiltDegrees[style] or 0)
	for _, side in { -1, 1 } do
		local offset = at(size, side * B.gapX, B.y, L.FaceDepth - L.LayerStep) * CFrame.Angles(0, 0, side * tilt)
		piece(folder, head, offset, scaled(size, B.size), hairColor, "block")
	end
end

-- 코 : 피부보다 조금 진한 작은 동그라미.
local function addNose(folder, head, skin)
	local size = head.Size
	local color = skin:Lerp(Color3.new(0, 0, 0), L.NoseDarken)
	piece(folder, head, at(size, 0, L.NoseY, L.FaceDepth - L.NoseSize.Z), scaled(size, L.NoseSize), color, "ball")
end

-- 입 : smile(웃음) / grin(이 보이는 웃음) / open(벌린 입) / o(동그란 입) / small(작은 입).
local function addMouth(folder, head, style)
	local size = head.Size
	local M = L.Mouths[style]
	local z = L.FaceDepth - L.LayerStep
	if style == "smile" then
		piece(folder, head, at(size, 0, M.y, z), scaled(size, M.segment), L.MouthColor, "block")
		local angle = slope(size, M.spreadX, M.liftY)
		for _, side in { -1, 1 } do
			local offset = at(size, side * M.spreadX, M.y + M.liftY, z) * CFrame.Angles(0, 0, side * angle)
			piece(folder, head, offset, scaled(size, M.segment), L.MouthColor, "block")
		end
		return
	end
	local shape = if style == "small" then "block" else "ball"
	piece(folder, head, at(size, 0, M.y, z), scaled(size, M.size), L.MouthColor, shape)
	if M.teeth then
		local teeth = at(size, 0, M.y + M.size.Y * M.shift, z - M.size.Z / 2)
		piece(folder, head, teeth, scaled(size, M.teeth), L.TeethColor, "block")
	end
	if M.tongue then
		local tongue = at(size, 0, M.y + M.size.Y * M.shift, z - M.size.Z / 2)
		piece(folder, head, tongue, scaled(size, M.tongue), L.TongueColor, "ball")
	end
end

-- 볼터치 : 발그레한 분홍 동그라미.
local function addBlush(folder, head)
	local size = head.Size
	local B = L.Blush
	for _, side in { -1, 1 } do
		local part = piece(folder, head, at(size, side * B.gapX, B.y, L.FaceDepth), scaled(size, B.size), B.color, "ball")
		part.Transparency = B.transparency
	end
end

-- 주근깨 : 볼마다 작은 점 세 개.
local function addFreckles(folder, head)
	local size = head.Size
	local F = L.Freckles
	local dots = { Vector2.new(-1, 0), Vector2.new(1, 0), Vector2.new(0, -1) }
	for _, side in { -1, 1 } do
		for _, dot in dots do
			local offset = at(size, side * F.gapX + dot.X * F.spread, F.y + dot.Y * F.spread, L.FaceDepth - L.LayerStep)
			piece(folder, head, offset, round(size, F.size), F.color, "ball")
		end
	end
end

-- 안경 : 네모 테 두 개 + 투명한 알 + 코 다리.
local function addGlasses(folder, head)
	local size = head.Size
	local G = L.Glasses
	local z = L.FaceDepth - G.front
	for _, side in { -1, 1 } do
		local x = side * G.gapX
		local lens = piece(folder, head, at(size, x, G.y, z), scaled(size, G.lens), G.lensColor, "block")
		lens.Transparency = G.lensTransparency
		-- 테 : 위·아래·양옆 네 조각
		local w, h = G.lens.X + G.rim, G.lens.Y + G.rim
		local bars = {
			{ Vector3.new(w, G.rim, G.lens.Z), Vector3.new(0, h / 2, 0) },
			{ Vector3.new(w, G.rim, G.lens.Z), Vector3.new(0, -h / 2, 0) },
			{ Vector3.new(G.rim, h, G.lens.Z), Vector3.new(w / 2, 0, 0) },
			{ Vector3.new(G.rim, h, G.lens.Z), Vector3.new(-w / 2, 0, 0) },
		}
		for _, bar in bars do
			local offset = at(size, x + bar[2].X, G.y + bar[2].Y, z)
			piece(folder, head, offset, scaled(size, bar[1]), G.frameColor, "block")
		end
	end
	piece(folder, head, at(size, 0, G.y, z), scaled(size, G.bridge), G.frameColor, "block")
end

-- 정수리를 덮는 머리카락 (모든 머리 모양의 바탕).
local function addHairCap(folder, head, color)
	local size = head.Size
	local C = L.HairCap
	piece(folder, head, at(size, C.offset.X, C.offset.Y, C.offset.Z), scaled(size, C.size), color, "ball")
end

-- 머리 모양마다 덧붙이는 부분을 만든다.
local HAIR = {
	-- 삐죽삐죽 : 정수리 둘레에 바깥으로 뻗은 머리카락
	spiky = function(folder, head, color)
		local size = head.Size
		local H = L.Hair.spiky
		addHairCap(folder, head, color)
		for i = 1, H.count do
			local angle = (i - 1) / H.count * math.pi * 2
			local out = Vector3.new(math.cos(angle), 0, math.sin(angle))
			local up = (Vector3.yAxis + out * math.tan(math.rad(H.tiltDegrees))).Unit
			local right = up:Cross(Vector3.zAxis)
			if right.Magnitude < 1e-3 then
				right = Vector3.xAxis
			end
			local position = at(size, out.X * H.radius, H.y, out.Z * H.radius).Position
			local offset = CFrame.fromMatrix(position, right.Unit, up)
			piece(folder, head, offset, scaled(size, H.spike), color, "ball")
		end
	end,
	-- 옆 가르마 : 이마 한쪽으로 넘긴 앞머리
	sidepart = function(folder, head, color)
		local size = head.Size
		local H = L.Hair.sidepart
		addHairCap(folder, head, color)
		local offset = at(size, H.offset.X, H.offset.Y, H.offset.Z) * CFrame.Angles(0, 0, math.rad(H.tiltDegrees))
		piece(folder, head, offset, scaled(size, H.fringe), color, "ball")
	end,
	-- 포니테일 : 뒤통수에 묶은 머리
	ponytail = function(folder, head, color)
		local size = head.Size
		local H = L.Hair.ponytail
		addHairCap(folder, head, color)
		piece(folder, head, at(size, H.knotOffset.X, H.knotOffset.Y, H.knotOffset.Z), round(size, H.knot), color, "ball")
		piece(folder, head, at(size, H.tailOffset.X, H.tailOffset.Y, H.tailOffset.Z), scaled(size, H.tail), color, "ball")
	end,
	-- 야구모자 : 모자 + 챙 + 꼭지 단추 (색은 hairColor)
	cap = function(folder, head, color)
		local size = head.Size
		local H = L.Hair.cap
		piece(folder, head, at(size, H.topOffset.X, H.topOffset.Y, H.topOffset.Z), scaled(size, H.top), color, "ball")
		piece(folder, head, at(size, H.brimOffset.X, H.brimOffset.Y, H.brimOffset.Z), scaled(size, H.brim), color, "ball")
		local buttonY = H.topOffset.Y + H.top.Y / 2
		piece(folder, head, at(size, 0, buttonY, H.topOffset.Z), round(size, H.button), color, "ball")
	end,
	-- 양갈래 똥머리
	buns = function(folder, head, color)
		local size = head.Size
		local H = L.Hair.buns
		addHairCap(folder, head, color)
		for _, side in { -1, 1 } do
			piece(folder, head, at(size, side * H.gapX, H.y, H.z), round(size, H.bun), color, "ball")
		end
	end,
	-- 곱슬머리 : 작은 동그라미가 정수리 가득
	curly = function(folder, head, color)
		local size = head.Size
		local H = L.Hair.curly
		addHairCap(folder, head, color)
		local golden = math.pi * (3 - math.sqrt(5)) -- 고르게 흩뿌리는 각도
		for i = 1, H.count do
			local rise = i / H.count -- 0(둘레) ~ 1(꼭대기)
			local ring = math.sqrt(1 - rise * rise) * H.radius
			local angle = i * golden
			local offset = at(size, math.cos(angle) * ring, H.y + rise * H.radius * H.rise, math.sin(angle) * ring + H.backZ)
			piece(folder, head, offset, round(size, H.curl), color, "ball")
		end
	end,
	-- 짧은 머리 + 이마에 두른 머리띠
	headband = function(folder, head, color)
		local size = head.Size
		local H = L.Hair.headband
		addHairCap(folder, head, color)
		piece(folder, head, at(size, 0, H.y, 0), scaled(size, H.band), H.color, "ball")
	end,
	-- 긴 머리 : 등까지 내려오는 뒷머리 + 양옆 머리
	long = function(folder, head, color)
		local size = head.Size
		local H = L.Hair.long
		addHairCap(folder, head, color)
		piece(folder, head, at(size, H.backOffset.X, H.backOffset.Y, H.backOffset.Z), scaled(size, H.back), color, "ball")
		for _, side in { -1, 1 } do
			piece(folder, head, at(size, side * H.sideGapX, H.sideY, 0), scaled(size, H.side), color, "ball")
		end
	end,
}

-- 별 핀 : 머리 옆의 작은 노란 마름모.
local function addHairClip(folder, head)
	local size = head.Size
	local C = L.HairClip
	local offset = at(size, C.offset.X, C.offset.Y, C.offset.Z) * CFrame.Angles(0, 0, math.rad(45))
	piece(folder, head, offset, round(size, C.size), C.color, "block")
end

-- 몸 부위마다 옷·피부·신발 색을 칠한다. (반팔 : 윗팔만 윗옷 색, 반바지 : 종아리는 피부색)
local function paintBody(model, persona)
	local clothes = Enum.Material.Fabric
	local paint = {
		Head = { persona.skin, Enum.Material.SmoothPlastic },
		UpperTorso = { persona.shirt, clothes },
		LowerTorso = { persona.pants, clothes },
		LeftUpperArm = { persona.shirt, clothes },
		RightUpperArm = { persona.shirt, clothes },
		LeftLowerArm = { persona.skin, Enum.Material.SmoothPlastic },
		RightLowerArm = { persona.skin, Enum.Material.SmoothPlastic },
		LeftHand = { persona.skin, Enum.Material.SmoothPlastic },
		RightHand = { persona.skin, Enum.Material.SmoothPlastic },
		LeftUpperLeg = { persona.pants, clothes },
		RightUpperLeg = { persona.pants, clothes },
		LeftLowerLeg = { if persona.legs == "shorts" then persona.skin else persona.pants, clothes },
		RightLowerLeg = { if persona.legs == "shorts" then persona.skin else persona.pants, clothes },
		LeftFoot = { persona.shoes, Enum.Material.SmoothPlastic },
		RightFoot = { persona.shoes, Enum.Material.SmoothPlastic },
	}
	for name, look in paint do
		local part = model:FindFirstChild(name)
		if part then
			part.Color = look[1]
			part.Material = look[2]
		end
	end
end

-- 윗옷 목둘레와 등번호를 단다.
local function addJersey(folder, model, persona)
	local torso = model:FindFirstChild("UpperTorso")
	if not torso then
		return
	end
	local collar = persona.shirt:Lerp(Color3.new(0, 0, 0), L.CollarDarken)
	piece(folder, torso, CFrame.new(0, torso.Size.Y / 2, 0), scaled(torso.Size, L.CollarSize), collar, "ball")

	local gui = Instance.new("SurfaceGui")
	gui.Name = "JerseyNumber"
	gui.Face = Enum.NormalId.Back
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = L.NumberPixelsPerStud
	gui.Parent = torso
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = L.NumberColor
	label.TextStrokeTransparency = L.NumberStrokeTransparency
	label.Text = tostring(persona.number)
	label.Parent = gui
end

-- 생김새 정보로 HumanoidDescription(체형·피부색)을 만든다.
function NpcLooks.describe(persona)
	local description = Instance.new("HumanoidDescription")
	description.HeightScale = persona.body.height
	description.WidthScale = persona.body.width
	description.DepthScale = persona.body.depth
	description.HeadScale = persona.body.head
	description.HeadColor = persona.skin
	description.LeftArmColor = persona.skin
	description.RightArmColor = persona.skin
	description.TorsoColor = persona.shirt
	description.LeftLegColor = persona.pants
	description.RightLegColor = persona.pants
	return description
end

-- 만들어진 몸에 얼굴·머리·옷을 입힌다.
function NpcLooks.dress(model, persona)
	local head = model:FindFirstChild("Head")
	if not head then
		return
	end
	-- 기본 얼굴 그림과 몸 색 고정을 치운다 (직접 만든 얼굴과 색을 쓴다)
	for _, child in head:GetChildren() do
		if child:IsA("Decal") then
			child:Destroy()
		end
	end
	local bodyColors = model:FindFirstChildOfClass("BodyColors")
	if bodyColors then
		bodyColors:Destroy()
	end
	paintBody(model, persona)

	local folder = Instance.new("Folder")
	folder.Name = "Looks"
	folder.Parent = model
	addEyes(folder, head, persona.eyes, persona.skin)
	addBrows(folder, head, persona.brows, persona.hairColor)
	addNose(folder, head, persona.skin)
	addMouth(folder, head, persona.mouth)
	HAIR[persona.hair](folder, head, persona.hairColor)
	for _, extra in persona.extras do
		if extra == "blush" then
			addBlush(folder, head)
		elseif extra == "freckles" then
			addFreckles(folder, head)
		elseif extra == "glasses" then
			addGlasses(folder, head)
		elseif extra == "hairclip" then
			addHairClip(folder, head)
		end
	end
	addJersey(folder, model, persona)
end

return NpcLooks
