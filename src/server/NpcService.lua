-- NPC를 만들고, 움직이고, 공을 던지고 잡게 한다 (설계서 9장).
-- 생김새는 도플갱어 호텔의 동물 인형(shared/Animals.lua)이다.
-- NPC도 사람과 똑같은 참가자라서 규칙은 다른 서비스가 똑같이 적용한다.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Animals = require(ReplicatedStorage.Shared.Animals)
local Participants = require(script.Parent.Participants)
local BallService = require(script.Parent.BallService)
local CourtService = require(script.Parent.CourtService)
local AbilityService = require(script.Parent.AbilityService)
local PlayerStateService = require(script.Parent.PlayerStateService)

local N = Config.Npc
local Anim = Config.Animation

local NpcService = {}

local folder -- NPC 몸을 넣어 두는 폴더
local brains = {} -- NPC 참가자 → 생각 기록
local active = false -- 판이 진행 중일 때만 움직인다

-- 두 숫자 사이의 아무 숫자를 고른다.
local function randomBetween(low, high)
	return low + math.random() * (high - low)
end

-- 몸에 서 있기·걷기·앉기 애니메이션을 붙인다 (NPC와 분신이 쓴다).
function NpcService.setupAnimation(model)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	-- 애니메이션 id로 재생 준비를 한다
	local function load(id)
		local animation = Instance.new("Animation")
		animation.AnimationId = id
		local track = animator:LoadAnimation(animation)
		track.Looped = true
		return track
	end
	local idle, walk, sit = load(Anim.Idle), load(Anim.Walk), load(Anim.Sit)

	local current = nil
	-- 지금 동작을 멈추고 새 동작을 튼다
	local function play(track)
		if current == track then
			return
		end
		if current then
			current:Stop(Anim.FadeSeconds)
		end
		current = track
		track:Play(Anim.FadeSeconds)
	end

	humanoid.Running:Connect(function(speed)
		if humanoid.Sit then
			return
		end
		play(if speed > Anim.WalkThreshold then walk else idle)
	end)
	humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
		play(if humanoid.Sit then sit else idle)
	end)
	play(idle)
end

-- 인형 팔에 붙는 부품 이름
local ARM_PARTS = { Sleeve = true, Cuff = true, Hand = true, Watch = true }

-- 목록에서 아무거나 하나 고른다.
local function pick(list)
	return list[math.random(1, #list)]
end

-- 인형 부품이 어느 몸 부위(R15 뼈)에 붙을지 정한다. 오른쪽 손은 공을 드는 손으로 이름을 바꾼다.
local function boneFor(part, feet)
	if part:FindFirstAncestor("HeadGroup") then
		return "Head"
	end
	local side = if feet:PointToObjectSpace(part.Position).X >= 0 then "Right" else "Left"
	local name = part.Name
	if name == "Hand" and side == "Right" then
		part.Name = "DollRightHand"
	end
	if name == "Leg" then
		return side .. "UpperLeg"
	elseif name == "Shoe" then
		return side .. "Foot"
	elseif ARM_PARTS[name] then
		return side .. "UpperArm"
	elseif name == "Tail" or name == "TailTip" then
		return "LowerTorso"
	end
	return "UpperTorso"
end

-- 보이지 않는 R15 몸에 도플갱어 호텔 동물 인형을 입힌다. 인형은 뼈를 따라 움직인다.
local function dress(model, data)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")

	-- R15 몸은 숨긴다 (공 판정은 이 몸으로 한다)
	for _, child in model:GetChildren() do
		if child:IsA("BasePart") then
			child.Transparency = 1
		end
	end
	local face = model.Head:FindFirstChildOfClass("Decal")
	if face then
		face:Destroy()
	end

	-- 인형을 발밑에 맞춰 세운다
	local doll = Animals.build(data, nil)
	doll.Name = "Doll"
	local feet = root.CFrame * CFrame.new(0, -(humanoid.HipHeight + root.Size.Y / 2), 0)
	doll:PivotTo(feet)
	if doll.PrimaryPart then
		doll.PrimaryPart:Destroy() -- 발밑 기준 부품은 이제 필요 없다
	end

	-- 인형 부품마다 맞는 뼈에 붙인다
	for _, part in doll:GetDescendants() do
		if part:IsA("BasePart") then
			local bone = model:FindFirstChild(boneFor(part, feet))
			part.Anchored = false
			part.CanCollide = false
			part.CanQuery = false -- 공 판정은 숨은 R15 몸으로만 한다
			part.CanTouch = false
			part.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = bone
			weld.Part1 = part
			weld.Parent = part
		end
	end
	doll.Parent = model
	return doll
end

-- 인형 머리 위에 이름표를 단다. 아웃되면 회색으로 바뀐다.
local function addNameTag(model, doll, text)
	local head = doll.HeadGroup.PrimaryPart
	local tag = Instance.new("BillboardGui")
	tag.Name = "NameTag"
	tag.Size = UDim2.fromOffset(N.NameTagWidth, N.NameTagTextSize * 2)
	tag.StudsOffset = Vector3.new(0, N.NameTagHeight, 0)
	tag.AlwaysOnTop = true
	tag.MaxDistance = N.SpeechMaxDistance
	tag.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = N.NameTagTextSize
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	label.Text = text
	label.Parent = tag

	model:GetAttributeChangedSignal("Status"):Connect(function()
		local out = model:GetAttribute("Status") == "Sitting"
		label.TextColor3 = if out then N.OutNameColor else Color3.new(1, 1, 1)
		label.Text = if out then text .. " (아웃)" else text
	end)
end

-- NPC 머리 위에 말풍선을 잠깐 띄운다 (도플갱어 호텔 Npc.say와 같은 모양).
local function say(model, text)
	local doll = model:FindFirstChild("Doll")
	local head = doll and doll.HeadGroup.PrimaryPart
	if not head then
		return
	end
	local old = head:FindFirstChild("Speech")
	if old then
		old:Destroy()
	end

	local bubble = Instance.new("BillboardGui")
	bubble.Name = "Speech"
	bubble.Size = UDim2.fromOffset(N.NameTagWidth, N.NameTagTextSize * 2)
	bubble.StudsOffset = Vector3.new(0, N.SpeechHeight, 0)
	bubble.AlwaysOnTop = true
	bubble.MaxDistance = N.SpeechMaxDistance
	bubble.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.new(1, 1, 1)
	label.TextColor3 = Color3.fromRGB(20, 20, 20)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = text
	label.Parent = bubble
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = label

	task.delay(N.SpeechSeconds, function()
		if bubble.Parent then
			bubble:Destroy()
		end
	end)
end

-- 사건이 생기면 NPC가 가끔 한마디 한다.
local function onReaction(p, kind)
	local lines = N.Lines[kind]
	if brains[p] and lines and p.character and math.random() < N.SpeechChance then
		say(p.character, pick(lines))
	end
end

-- n번째 NPC의 이름과 인형 정보를 정한다 (예: "고양이 민준").
local function makeDollData(index)
	local animal = pick(Animals.List)
	local kind = Animals.Types[animal]
	local kidName = N.Names[(index - 1) % #N.Names + 1]
	return {
		id = math.random(1, 1000000), -- 넥타이·모자 같은 소품이 이 숫자로 정해진다
		name = kind.name .. " " .. kidName,
		animal = animal,
		fur = pick(kind.furs),
		cloth = pick(Animals.Clothes),
	}
end

-- NPC를 count명 만들어 코트 안에 세운다.
function NpcService.spawn(count)
	for index = 1, count do
		local data = makeDollData(index)
		local ok, model = pcall(function()
			return Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
		end)
		if not ok then
			warn("NPC를 만들지 못했어요: " .. tostring(model))
			continue
		end
		model.Name = data.name
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None -- 이름은 인형 이름표로 보여준다
		humanoid.BreakJointsOnDeath = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false) -- NPC는 죽지 않는다
		local doll = dress(model, data)
		addNameTag(model, doll, data.name)

		model.Parent = folder
		model.HumanoidRootPart:SetNetworkOwner(nil) -- NPC 움직임은 서버가 계산한다
		CourtService.placeInside(model)
		NpcService.setupAnimation(model)

		local p = Participants.addNpc(data.name, model)
		p.inRound = true
		brains[p] = { nextThinkAt = 0, throwAt = nil, target = nil, wanderAt = 0, triedCatch = {} }
	end
end

-- 모든 NPC를 없앤다 (판이 끝날 때).
function NpcService.despawnAll()
	for p in brains do
		BallService.forget(p)
		CourtService.forget(p)
		Participants.remove(p)
		if p.character then
			p.character:Destroy()
		end
	end
	brains = {}
end

-- NPC 움직임 여부를 바꾼다.
function NpcService.setActive(on)
	active = on
end

-- 노릴 상대를 고른다 : 사거리 안의 살아 있는 상대 중 아무나 (투명한 상대는 빼고).
local function chooseTarget(p, myRoot)
	local now = os.clock()
	local inRange, nearest, nearestDistance = {}, nil, math.huge
	for _, other in Participants.all() do
		local root = Participants.getRoot(other)
		local visible = other.state.invisibleUntil <= now
		if root and other ~= p and other.inRound and other.state.status == "Alive" and visible then
			local distance = (root.Position - myRoot.Position).Magnitude
			if distance <= N.ThrowRange then
				table.insert(inRange, other)
			end
			if distance < nearestDistance then
				nearest, nearestDistance = other, distance
			end
		end
	end
	if #inRange > 0 then
		return inRange[math.random(1, #inRange)]
	end
	return nearest
end

-- 상대가 아직 노릴 만한지 확인한다.
local function isGoodTarget(target)
	return target ~= nil
		and target.inRound
		and target.state.status == "Alive"
		and target.state.invisibleUntil <= os.clock()
		and Participants.getRoot(target) ~= nil
end

-- 코트 안쪽으로 걸어가게 한다.
local function walkTo(humanoid, position)
	humanoid:MoveTo(CourtService.clampInside(position, N.MoveMargin))
end

-- 공을 들고 있을 때 : 상대를 골라 다가가서 잠깐 뒤 던진다.
local function thinkWithBall(p, brain, root, humanoid, now)
	if not isGoodTarget(brain.target) then
		brain.target = chooseTarget(p, root)
	end
	brain.throwAt = brain.throwAt or now + randomBetween(N.AimDelayMin, N.AimDelayMax)
	local target = brain.target
	if not target then
		return
	end

	local targetRoot = Participants.getRoot(target)
	local distance = (targetRoot.Position - root.Position).Magnitude
	if distance > N.ThrowRange then
		walkTo(humanoid, targetRoot.Position)
		return
	end
	humanoid:MoveTo(root.Position) -- 사거리 안이면 멈춰 선다

	if now >= brain.throwAt then
		local lead = targetRoot.AssemblyLinearVelocity * N.LeadFactor
		local miss = Vector3.new(randomBetween(-1, 1), randomBetween(-1, 1), randomBetween(-1, 1)) * N.AimError
		BallService.throw(p, targetRoot.Position + lead + miss, randomBetween(N.HoldMin, N.HoldMax))
		brain.throwAt = nil
		brain.target = nil
	end
end

-- 빈손일 때 : 가까운 공으로 가고, 공이 없으면 돌아다닌다.
local function thinkEmptyHanded(brain, root, humanoid, now)
	brain.throwAt = nil
	brain.target = nil
	local ball = BallService.nearestFreeBall(root.Position)
	if ball then
		walkTo(humanoid, ball.Position)
	elseif now >= brain.wanderAt then
		local angle = math.random() * math.pi * 2
		walkTo(humanoid, root.Position + Vector3.new(math.cos(angle), 0, math.sin(angle)) * N.WanderRadius)
		brain.wanderAt = now + N.WanderInterval
	end
end

-- NPC 한 명이 다음에 할 일을 고른다.
local function think(p, brain, now)
	local root = Participants.getRoot(p)
	local humanoid = Participants.getHumanoid(p)
	if not root or not humanoid or p.state.status ~= "Alive" then
		return
	end
	if p.state.gauge >= Config.Gauge.Max then
		AbilityService.use(p)
	end
	if BallService.isHolding(p) then
		thinkWithBall(p, brain, root, humanoid, now)
	else
		thinkEmptyHanded(brain, root, humanoid, now)
	end
end

-- 날아오는 공이 가까우면 확률로 캐치 버튼을 누른다 (공 하나에 한 번만 시도).
local function tryCatch(p, brain)
	local root = Participants.getRoot(p)
	if not root then
		return
	end
	for _, info in BallService.liveBalls() do
		local ball = info.ball
		local toMe = root.Position - ball.Position
		local coming = ball.AssemblyLinearVelocity:Dot(toMe) > 0
		local alreadyTried = brain.triedCatch[ball] == info.thrownAt
		if info.thrower ~= p and coming and not alreadyTried and toMe.Magnitude <= N.CatchReactDistance then
			brain.triedCatch[ball] = info.thrownAt
			if math.random() < N.CatchChance then
				BallService.pressCatch(p)
			end
		end
	end
end

-- 매 프레임 모든 NPC를 움직인다.
local function update()
	if not active then
		return
	end
	local now = os.clock()
	for p, brain in brains do
		tryCatch(p, brain)
		if now >= brain.nextThinkAt then
			brain.nextThinkAt = now + N.ThinkInterval
			think(p, brain, now)
		end
		-- 바닥 아래로 떨어지면 코트 안에 다시 세운다
		local root = Participants.getRoot(p)
		if root and root.Position.Y < N.FallLimitY then
			CourtService.placeInside(p.character)
		end
	end
end

-- NPC 폴더를 만들고 매 프레임 움직임과 말풍선을 연결한다.
function NpcService.start()
	folder = Instance.new("Folder")
	folder.Name = "Npcs"
	folder.Parent = workspace
	RunService.Heartbeat:Connect(update)
	PlayerStateService.setReactionHandler(onReaction)
end

return NpcService
