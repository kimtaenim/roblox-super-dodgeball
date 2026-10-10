-- NPC 한 명 한 명의 생김새를 만든다 : 체형, 몸, 얼굴, 머리 모양, 꾸밈, 옷, 등번호 (설계서 9장).
-- 요즘 아바타처럼 보이게 로블록스 카탈로그 부품(몸 번들, 다이내믹 헤드, 머리카락, 얼굴)을 먼저 쓰고,
-- 확인되지 않은 부품만 직접 만든 모습(둥근 몸, 부품 머리카락, 기본 얼굴)으로 채운다.
-- 생김새 정보는 Config.Npc.Personas, 부품 크기·위치 비율은 Config.Looks에 있다.
-- 덧붙인 부품은 모두 공 판정에 안 걸린다 (공 판정은 원래 R15 몸으로만 한다).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local AvatarCatalog = require(script.Parent.AvatarCatalog)

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

-- 원기둥 하나를 세워서 만든다 (둥근 몸 조각용). 길이는 위아래(Y) 방향.
local function upright(folder, base, offset, diameter, length, color, material)
	local part = piece(folder, base, offset * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(length, diameter, diameter), color, "block")
	part.Shape = Enum.PartType.Cylinder
	part.Material = material
	return part
end

-- 한 덩어리처럼 이어지는 원기둥. 끝마다 모양을 고른다 :
--   "round"  = 모서리를 둥글게 (어깨, 몸통 맨 위·아래)
--   "flat"   = 마디 경계에서 딱 끝난다 (다음 마디와 맞닿는 곳, 관절 공이 틈을 메운다)
--   "extend" = 곧게 조금 더 늘려서 이웃(몸통·손·신발) 속으로 들어간다
-- topTrim : 위쪽을 이만큼 잘라 낮춘다 (팔이 몸통 꼭대기보다 아래에서 시작하게)
local function joinedCylinder(folder, base, inset, diameter, top, bottom, color, material, topTrim)
	local height = base.Size.Y
	local overlap = L.Body.JointOverlap
	local extTop = if top == "extend" then overlap else 0
	local extBottom = if bottom == "extend" then overlap else 0
	local edge = math.min(diameter * L.Body.EdgeRatio, height / 2)
	local edgeTop = if top == "round" then edge else 0
	local edgeBottom = if bottom == "round" then edge else 0

	-- 곧은 원기둥 부분 (둥근 모서리 자리는 빼고)
	local upper = height / 2 + extTop - (topTrim or 0) - edgeTop
	local lower = -height / 2 - extBottom + edgeBottom
	local length = math.max(upper - lower, L.Body.MinLength)
	upright(folder, base, CFrame.new(inset, (upper + lower) / 2, 0), diameter, length, color, material)

	-- 둥근 모서리 : 납작한 타원
	for _, cap in { { edgeTop, upper }, { edgeBottom, lower } } do
		if cap[1] > 0 then
			local part = piece(folder, base, CFrame.new(inset, cap[2], 0), Vector3.new(diameter, cap[1] * 2, diameter), color, "ball")
			part.Material = material
		end
	end
end

-- 관절 공 : 팔꿈치·무릎에 원기둥과 같은 굵기의 공을 넣어 굽혀도 틈이 안 보이게 한다.
local function jointBall(folder, base, inset, diameter, color, material)
	local part = piece(folder, base, CFrame.new(inset, -base.Size.Y / 2, 0), Vector3.one * diameter * L.Body.InnerShrink, color, "ball")
	part.Material = material
end

-- 팔다리 굵기 (윗마디 기준, 아랫마디도 같은 굵기로 이어진다).
local function limbDiameter(base)
	return math.min(base.Size.X, base.Size.Z) * L.Body.LimbRoundness
end

-- 몸통 원기둥 지름 (윗몸 너비에 대한 비율, 아랫몸도 같은 굵기).
local function torsoDiameter(upperTorso)
	return upperTorso.Size.X * L.Body.TorsoDiameterRatio
end

-- 팔을 몸통 쪽으로 얼마나 붙일지 구한다 (어깨에서 몸통 가장자리까지 남는 틈만큼, 몸통 쪽 방향으로).
local function armInset(upperTorso, upperArm)
	local side = upperTorso.CFrame:PointToObjectSpace(upperArm.Position).X
	local gap = math.abs(side) - torsoDiameter(upperTorso) / 2 - limbDiameter(upperArm) / 2 + L.Body.ArmTouch
	return -math.sign(side) * math.max(gap, 0)
end

-- 손과 신발 : 둥근 타원 (신발은 앞으로 조금 나온다).
local function roundedEnd(folder, base, ratio, forward, lift, inset, color, material)
	local size = base.Size
	local offset = CFrame.new(inset, size.Y * lift, -size.Z * forward)
	local part = piece(folder, base, offset, Vector3.new(size.X * ratio.X, size.Y * ratio.Y, size.Z * ratio.Z), color, "ball")
	part.Material = material
end

-- 네모난 R15 몸을 숨기고 둥근 몸으로 덮는다 (공 판정은 숨긴 원래 몸으로 한다).
-- 몸통·팔·다리가 마디마다 따로 놀지 않고 한 덩어리처럼 이어지게 만든다. 반팔 : 윗팔만 윗옷 색, 반바지 : 종아리는 피부색.
local function roundBody(folder, model, persona)
	local clothes, skin = Enum.Material.Fabric, Enum.Material.SmoothPlastic
	local function hide(name)
		local part = model:FindFirstChild(name)
		if part then
			part.Transparency = 1
		end
		return part
	end
	-- 몸통 : 윗몸(윗옷)과 아랫몸(바지)이 같은 굵기로 이어진 원기둥 하나처럼. 맨 위와 맨 아래만 둥글다.
	local upper = hide("UpperTorso")
	local lower = hide("LowerTorso")
	if not upper then
		return
	end
	local bodyDiameter = torsoDiameter(upper)
	joinedCylinder(folder, upper, 0, bodyDiameter, "round", "flat", persona.shirt, clothes)
	if lower then
		joinedCylinder(folder, lower, 0, bodyDiameter * L.Body.InnerShrink, "extend", "round", persona.pants, clothes)
	end

	for _, side in { "Left", "Right" } do
		local upperArm = hide(side .. "UpperArm")
		local lowerArm = hide(side .. "LowerArm")
		local hand = hide(side .. "Hand")
		local upperLeg = hide(side .. "UpperLeg")
		local lowerLeg = hide(side .. "LowerLeg")
		local foot = hide(side .. "Foot")

		-- 팔 : 둥근 어깨 → 윗팔(윗옷 색) → 팔꿈치 공 → 아랫팔(피부색) → 손 속으로
		if upperArm then
			local inset = armInset(upper, upperArm)
			local armDiameter = limbDiameter(upperArm)
			local drop = upperArm.Size.Y * L.Body.ShoulderDrop -- 어깨는 몸통 꼭대기보다 조금 아래
			joinedCylinder(folder, upperArm, inset, armDiameter, "round", "flat", persona.shirt, clothes, drop)
			jointBall(folder, upperArm, inset, armDiameter, persona.skin, skin)
			if lowerArm then
				joinedCylinder(folder, lowerArm, inset, armDiameter, "flat", "extend", persona.skin, skin)
			end
			if hand then
				roundedEnd(folder, hand, L.Body.HandRatio, 0, 0, inset, persona.skin, skin)
			end
		end

		-- 다리 : 몸통 속에서 시작 → 허벅지(바지) → 무릎 공 → 종아리(바지 또는 피부) → 신발 속으로
		if upperLeg then
			local legDiameter = limbDiameter(upperLeg)
			local shin = if persona.legs == "shorts" then persona.skin else persona.pants
			local shinMaterial = if persona.legs == "shorts" then skin else clothes
			joinedCylinder(folder, upperLeg, 0, legDiameter, "extend", "flat", persona.pants, clothes)
			jointBall(folder, upperLeg, 0, legDiameter, shin, shinMaterial)
			if lowerLeg then
				joinedCylinder(folder, lowerLeg, 0, legDiameter, "flat", "extend", shin, shinMaterial)
			end
		end
		if foot then
			roundedEnd(folder, foot, L.Body.ShoeRatio, L.Body.ShoeForward, L.Body.ShoeLift, 0, persona.shoes, skin)
		end
	end
	local head = model:FindFirstChild("Head")
	if head then
		head.Color = persona.skin
	end
end

-- 윗옷 목둘레와 등번호를 단다. 등번호는 등에 붙인 투명한 판에 쓴다 (둥근 몸통에서도 똑바로 보이게).
-- catalogBody : 카탈로그 몸이면 목둘레는 빼고, 등번호 판은 그 몸통 등판에 맞춘다.
local function addJersey(folder, upperTorso, persona, catalogBody)
	local width = if catalogBody then upperTorso.Size.X * L.CatalogJerseyWidth else torsoDiameter(upperTorso)
	local depth = if catalogBody then upperTorso.Size.Z else width
	local round = Vector3.new(width, upperTorso.Size.Y, width)
	if not catalogBody then
		local collar = persona.shirt:Lerp(Color3.new(0, 0, 0), L.CollarDarken)
		piece(folder, upperTorso, CFrame.new(0, upperTorso.Size.Y / 2, 0), scaled(round, L.CollarSize), collar, "ball")
	end

	local card = piece(folder, upperTorso, CFrame.new(0, 0, depth / 2 + L.NumberCardGap), scaled(round, L.NumberCardSize), persona.shirt, "block")
	card.Name = "NumberCard"
	card.Transparency = 1
	local gui = Instance.new("SurfaceGui")
	gui.Name = "JerseyNumber"
	gui.Face = Enum.NormalId.Back
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = L.NumberPixelsPerStud
	gui.Parent = card
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

-- 카탈로그 몸을 이름 색 옷으로 칠한다 : 몸에 붙어 있던 무늬(텍스처)와 옷을 지우고 부위마다 색을 칠한다.
-- 윗몸·윗팔 = 윗옷 색(반팔), 아랫팔·손 = 피부, 아랫몸·허벅지 = 바지, 종아리 = 바지(반바지면 피부), 발 = 신발.
local function paintCatalogBody(model, persona)
	local shin = if persona.legs == "shorts" then persona.skin else persona.pants
	local colors = {
		UpperTorso = persona.shirt,
		LowerTorso = persona.pants,
		LeftUpperArm = persona.shirt,
		RightUpperArm = persona.shirt,
		LeftLowerArm = persona.skin,
		RightLowerArm = persona.skin,
		LeftHand = persona.skin,
		RightHand = persona.skin,
		LeftUpperLeg = persona.pants,
		RightUpperLeg = persona.pants,
		LeftLowerLeg = shin,
		RightLowerLeg = shin,
		LeftFoot = persona.shoes,
		RightFoot = persona.shoes,
	}
	-- 몸 색 고정과 옷(셔츠·바지 그림)을 치운다 (그대로 두면 직접 칠한 색을 덮는다)
	for _, child in model:GetChildren() do
		if child:IsA("BodyColors") or child:IsA("Clothing") or child:IsA("ShirtGraphic") then
			child:Destroy()
		end
	end
	for name, color in colors do
		local part = model:FindFirstChild(name)
		if part then
			if part:IsA("MeshPart") then
				pcall(function()
					part.TextureID = "" -- 몸에 그려진 무늬를 지운다
				end)
			end
			for _, child in part:GetChildren() do
				if child:IsA("SurfaceAppearance") then
					child:Destroy()
				end
			end
			part.Color = color
		end
	end
end

-- 카탈로그 번들 차림에서 몸 부위(몸통·팔·다리)나 머리(다이내믹 헤드·표정)를 옮겨 온다.
local BODY_FIELDS = { "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }
local HEAD_FIELDS = { "Head", "Face", "MoodAnimation" }
local function copyFields(target, source, fields)
	for _, field in fields do
		target[field] = source[field]
	end
end

-- 생김새 정보로 HumanoidDescription(체형·색·카탈로그 부품)을 만든다.
-- 실제로 쓴 카탈로그 부품을 used 표로 함께 돌려준다 (body, head, hair, face).
function NpcLooks.describe(persona)
	local description = Instance.new("HumanoidDescription")
	local catalog = persona.catalog or {}
	local used = {}

	local body = AvatarCatalog.bundle(catalog.body)
	if body then
		copyFields(description, body, BODY_FIELDS)
		used.body = true
	end
	local head = AvatarCatalog.bundle(catalog.head)
	if head then
		copyFields(description, head, HEAD_FIELDS)
		used.head = true
	end
	if AvatarCatalog.hasAsset(catalog.hair) then
		description.HairAccessory = tostring(catalog.hair.id)
		used.hair = true
	end
	if not used.head and AvatarCatalog.hasAsset(catalog.face) then
		description.Face = catalog.face.id
		used.face = true
	end

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
	return description, used
end

-- 만들어진 몸에 부족한 부분을 채운다 : 카탈로그 몸이 아니면 둥근 몸, 카탈로그 머리카락이 아니면 부품 머리카락,
-- 다이내믹 헤드가 아니면 볼터치·주근깨·안경. 등번호는 늘 단다.
function NpcLooks.dress(model, persona, used)
	used = used or {}
	local head = model:FindFirstChild("Head")
	if not head then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "Looks"
	folder.Parent = model
	if used.body then
		paintCatalogBody(model, persona)
	else
		-- 몸 색 고정을 치운다 (둥근 몸에 직접 칠한 색을 쓴다)
		local bodyColors = model:FindFirstChildOfClass("BodyColors")
		if bodyColors then
			bodyColors:Destroy()
		end
		roundBody(folder, model, persona)
	end
	if not used.hair then
		HAIR[persona.hair](folder, head, persona.hairColor)
	end
	for _, extra in persona.extras do
		local onFace = extra == "blush" or extra == "freckles" or extra == "glasses"
		if onFace and used.head then
			continue -- 다이내믹 헤드는 얼굴 모양이 달라서 얼굴 꾸밈을 붙이지 않는다
		end
		if extra == "blush" then
			addBlush(folder, head)
		elseif extra == "freckles" then
			addFreckles(folder, head)
		elseif extra == "glasses" then
			addGlasses(folder, head)
		elseif extra == "hairclip" and not used.hair then
			addHairClip(folder, head)
		end
	end
	local upperTorso = model:FindFirstChild("UpperTorso")
	if upperTorso then
		addJersey(folder, upperTorso, persona, used.body)
	end
end

return NpcLooks
