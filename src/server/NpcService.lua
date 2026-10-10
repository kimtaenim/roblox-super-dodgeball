-- NPC를 만들고, 움직이고, 공을 던지고 잡게 한다 (설계서 9장).
-- 생김새는 NPC 8명이 한 명 한 명 다르다 (체형·얼굴·머리·옷은 NpcLooks.lua가 만든다).
-- NPC도 사람과 똑같은 참가자라서 규칙은 다른 서비스가 똑같이 적용한다.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Participants = require(script.Parent.Participants)
local BallService = require(script.Parent.BallService)
local CourtService = require(script.Parent.CourtService)
local AbilityService = require(script.Parent.AbilityService)
local AbilityBoxService = require(script.Parent.AbilityBoxService)
local PlayerStateService = require(script.Parent.PlayerStateService)
local NpcLooks = require(script.Parent.NpcLooks)
local ArenaService = require(script.Parent.ArenaService)

local N = Config.Npc
local Anim = Config.Animation

local NpcService = {}

local folder -- NPC 몸을 넣어 두는 폴더
local brains = {} -- NPC 참가자 → 생각 기록
local active = false -- 판이 진행 중일 때만 움직인다
local aimDelayScale = 1 -- 공을 들고 던지기까지 기다리는 시간 배수 (튜토리얼은 더 느리다)
local catchChance = N.CatchChance -- 날아오는 공을 잡을 확률 (튜토리얼은 0)
local nextSpeechAt = 0 -- 이 시각 전에는 어느 NPC도 말하지 않는다 (한 번에 한 명만)
local thrownAt = {} -- 대상 → NPC들이 그 대상에게 던진 시각 목록 (집중 공격 막기용)

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

-- 목록에서 아무거나 하나 고른다.
local function pick(list)
	return list[math.random(1, #list)]
end

-- 머리 위에 이름표(윗옷 색 이름)를 단다. 글자는 검은색이고, 아웃되면 "(아웃)"이 붙는다.
local function addNameTag(model, text)
	local tag = Instance.new("BillboardGui")
	tag.Name = "NameTag"
	tag.Size = UDim2.fromOffset(N.NameTagWidth, N.NameTagTextSize * 2)
	tag.StudsOffset = Vector3.new(0, N.NameTagHeight, 0)
	tag.AlwaysOnTop = true
	tag.MaxDistance = N.SpeechMaxDistance
	tag.Parent = model.Head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = N.NameTagTextSize
	label.TextColor3 = N.NameTagTextColor
	label.TextStrokeTransparency = 0.3
	label.Text = text
	label.Parent = tag

	-- 아웃되면 이름 옆에 "(아웃)"을 붙인다 (색은 그대로)
	model:GetAttributeChangedSignal("Status"):Connect(function()
		local out = model:GetAttribute("Status") == "Sitting"
		label.Text = if out then text .. " (아웃)" else text
	end)
end

-- NPC 머리 위에 말풍선을 잠깐 띄운다. 누가 방금 말했으면 조용히 넘어간다 (force면 꼭 말한다).
local function say(model, text, force)
	local head = model:FindFirstChild("Head")
	local now = os.clock()
	if not head or (now < nextSpeechAt and not force) then
		return
	end
	local loud = ArenaService.isQuiet()
	nextSpeechAt = now + (if loud then N.LoudSpeechGap else N.SpeechGap)
	local old = head:FindFirstChild("Speech")
	if old then
		old:Destroy()
	end

	local bubble = Instance.new("BillboardGui")
	bubble.Name = "Speech"
	local scale = if loud then N.LoudBubbleScale else 1 -- 시끄러운 곳에서는 말풍선도 크게
	bubble.Size = UDim2.fromOffset(N.NameTagWidth * scale, N.NameTagTextSize * 2 * scale)
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

-- 대사 목록을 고른다 : 조용해야 하는 경기장(도서관·박물관)에서는 오히려 시끄럽게 떠드는 대사.
local function linesFor(kind)
	if ArenaService.isQuiet() and N.LoudLines[kind] then
		return N.LoudLines[kind]
	end
	return N.Lines[kind]
end

-- 사건이 생기면 NPC가 가끔 한마디 한다.
local function onReaction(p, kind)
	local lines = linesFor(kind)
	local chance = if ArenaService.isQuiet() then N.LoudSpeechChance else N.SpeechChance
	if brains[p] and lines and p.character and math.random() < chance then
		say(p.character, pick(lines))
	end
end

-- NPC 8명 목록을 섞어서 돌려준다 (판마다 다른 친구들이 나오게).
local function shuffledPersonas()
	local personas = table.clone(N.Personas)
	for i = #personas, 2, -1 do
		local j = math.random(1, i)
		personas[i], personas[j] = personas[j], personas[i]
	end
	return personas
end

-- NPC를 count명 만들어 코트 안에 세운다. tutorial이면 천천히 던지고 캐치를 안 한다.
function NpcService.spawn(count, tutorial)
	aimDelayScale = if tutorial then Config.Tutorial.AimDelayScale else 1
	catchChance = if tutorial then Config.Tutorial.CatchChance else N.CatchChance
	local personas = shuffledPersonas()
	for index = 1, count do
		-- 이름은 윗옷 색 이름 (8명이 모자라면 "빨강2"처럼 숫자를 붙인다)
		local persona = personas[(index - 1) % #personas + 1]
		local round = math.floor((index - 1) / #personas)
		local name = if round > 0 then persona.name .. tostring(round + 1) else persona.name
		local description, used = NpcLooks.describe(persona)
		local ok, model = pcall(function()
			return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
		end)
		if not ok then
			warn("NPC를 만들지 못했어요: " .. tostring(model))
			continue
		end
		model.Name = name
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None -- 이름은 이름표로 보여준다
		humanoid.BreakJointsOnDeath = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false) -- NPC는 죽지 않는다
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) -- 맞아도 눕지 않고 앉는다
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		NpcLooks.dress(model, persona, used)
		addNameTag(model, name)

		model.Parent = folder
		BallService.protectBody(model)
		model.HumanoidRootPart:SetNetworkOwner(nil) -- NPC 움직임은 서버가 계산한다
		CourtService.placeInside(model)
		NpcService.setupAnimation(model)

		local p = Participants.addNpc(name, model)
		p.inRound = true
		brains[p] = {
			nextThinkAt = 0,
			throwAt = nil,
			target = nil,
			wanderAt = 0,
			triedCatch = {},
			chatAt = os.clock() + randomBetween(N.ChatIntervalMin, N.ChatIntervalMax),
		}
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
	thrownAt = {}
end

-- NPC 움직임 여부를 바꾼다.
function NpcService.setActive(on)
	active = on
end

-- 노릴 대상의 몸 중심을 찾는다. 대상은 참가자이거나 분신(Model)이다.
local function targetRoot(target)
	if typeof(target) == "Instance" then
		return target.Parent and target:FindFirstChild("HumanoidRootPart")
	end
	return Participants.getRoot(target)
end

-- 대상이 아직 노릴 만한지 확인한다. 투명한 상대는 안 보여서 못 노린다.
local function isGoodTarget(target)
	if target == nil then
		return false
	end
	if typeof(target) == "Instance" then
		return targetRoot(target) ~= nil -- 분신은 터지기 전까지 진짜처럼 보인다
	end
	return target.inRound
		and target.state.status == "Alive"
		and target.state.invisibleUntil <= os.clock()
		and Participants.getRoot(target) ~= nil
end

-- 최근에 NPC들이 이 대상에게 공을 몇 번 던졌는지 센다 (오래된 기록은 지운다).
local function recentThrowsAt(target)
	local list = thrownAt[target]
	if not list then
		return 0
	end
	local since = os.clock() - N.FocusMemorySeconds
	while list[1] and list[1] < since do
		table.remove(list, 1)
	end
	return #list
end

-- 노릴 상대를 고른다 : 사거리 안에 보이는 상대 중 최근에 공을 덜 받은 상대 (방금 던진 상대는 피한다).
-- 한 사람만 계속 노리지 않게 골고루 돌아간다. 분신도 진짜인 줄 알고 노린다 (내 분신은 빼고).
local function chooseTarget(p, brain, myRoot)
	local candidates = {}
	for _, other in Participants.all() do
		if other ~= p then
			table.insert(candidates, other)
		end
	end
	for _, decoy in BallService.getDecoyFolder():GetChildren() do
		if decoy:GetAttribute("DecoyOf") ~= p.name then
			table.insert(candidates, decoy)
		end
	end

	local inRange, nearest, nearestDistance = {}, nil, math.huge
	for _, target in candidates do
		if isGoodTarget(target) then
			local distance = (targetRoot(target).Position - myRoot.Position).Magnitude
			if distance <= N.ThrowRange then
				table.insert(inRange, target)
			end
			if distance < nearestDistance then
				nearest, nearestDistance = target, distance
			end
		end
	end
	if #inRange == 0 then
		return nearest
	end

	-- 공을 덜 받은 상대일수록 점수가 낮다. 점수가 가장 낮은 상대들 중 아무나
	local best, bestScore = {}, math.huge
	for _, target in inRange do
		local score = recentThrowsAt(target)
		if target == brain.lastTarget then
			score += N.SameTargetPenalty
		end
		if score < bestScore then
			best, bestScore = { target }, score
		elseif score == bestScore then
			table.insert(best, target)
		end
	end
	return best[math.random(1, #best)]
end

-- 코트 안쪽으로 걸어가게 한다.
local function walkTo(humanoid, position)
	humanoid:MoveTo(CourtService.clampInside(position, N.MoveMargin))
end

-- 공을 들고 있을 때 : 상대를 골라 다가가서 잠깐 뒤 던진다.
local function thinkWithBall(p, brain, root, humanoid, now)
	if not isGoodTarget(brain.target) then
		brain.target = chooseTarget(p, brain, root)
	end
	brain.throwAt = brain.throwAt or now + randomBetween(N.AimDelayMin, N.AimDelayMax) * aimDelayScale
	local target = brain.target
	if not target then
		return
	end

	local aimRoot = targetRoot(target)
	local distance = (aimRoot.Position - root.Position).Magnitude
	if distance > N.ThrowRange then
		walkTo(humanoid, aimRoot.Position)
		return
	end
	humanoid:MoveTo(root.Position) -- 사거리 안이면 멈춰 선다

	if now >= brain.throwAt then
		local lead = aimRoot.AssemblyLinearVelocity * N.LeadFactor
		local miss = Vector3.new(randomBetween(-1, 1), randomBetween(-1, 1), randomBetween(-1, 1)) * N.AimError
		BallService.throw(p, aimRoot.Position + lead + miss, randomBetween(N.HoldMin, N.HoldMax))
		onReaction(p, "throw")
		thrownAt[target] = thrownAt[target] or {}
		table.insert(thrownAt[target], now)
		brain.lastTarget = target
		brain.throwAt = nil
		brain.target = nil
	end
end

-- 빈손일 때 : 능력 칸에 빈자리가 있고 상자가 바로 옆(공보다 가까움)이면 상자로, 아니면 가까운 공으로 간다. 둘 다 없으면 돌아다닌다.
local function thinkEmptyHanded(p, brain, root, humanoid, now)
	brain.throwAt = nil
	brain.target = nil
	local ball = BallService.nearestFreeBall(root.Position)
	local box = #p.state.abilities < Config.AbilityBox.MaxSlots and AbilityBoxService.nearestBox(root.Position)
	local boxDistance = box and (box.Position - root.Position).Magnitude
	local boxIsNear = box and boxDistance <= N.BoxInterestDistance
	local boxIsCloser = boxIsNear and (not ball or boxDistance < (ball.Position - root.Position).Magnitude)
	if boxIsCloser then
		walkTo(humanoid, box.Position)
	elseif ball then
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
	if not root or not humanoid or brain.demo then
		return -- 시범 중인 NPC는 시범 순서대로만 움직인다
	end
	if p.state.status ~= "Alive" then
		humanoid:MoveTo(root.Position) -- 아웃되면 걷던 것을 멈추고 그 자리에 앉아 있는다
		return
	end
	-- 능력은 아주 가끔만 하나씩 쓴다 (20-40초에 한 번)
	if #p.state.abilities == 0 then
		brain.abilityAt = nil
	elseif not brain.abilityAt then
		brain.abilityAt = now + randomBetween(N.AbilityDelayMin, N.AbilityDelayMax)
	elseif now >= brain.abilityAt then
		brain.abilityAt = nil
		for slot = 1, #p.state.abilities do
			if AbilityService.use(p, slot) then
				break -- 지금 쓸 수 있는 것 하나만 쓴다
			end
		end
	end
	if BallService.isHolding(p) then
		thinkWithBall(p, brain, root, humanoid, now)
	else
		thinkEmptyHanded(p, brain, root, humanoid, now)
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
			if math.random() < catchChance then
				BallService.pressCatch(p)
			end
		end
	end
end

-- 가끔 혼잣말을 한다 (살아 있을 때와 앉아 있을 때 하는 말이 다르다).
local function chat(p, brain, now)
	if now < brain.chatAt or not p.character then
		return
	end
	local gap = randomBetween(N.ChatIntervalMin, N.ChatIntervalMax)
	brain.chatAt = now + gap * (if ArenaService.isQuiet() then N.LoudChatScale else 1) -- 시끄러운 곳에서는 더 자주 떠든다
	local lines = linesFor(if p.state.status == "Sitting" then "sittingChat" else "chat")
	say(p.character, pick(lines))
end

-- 매 프레임 모든 NPC를 움직인다.
local function update()
	if not active then
		return
	end
	local now = os.clock()
	for p, brain in brains do
		if not brain.demo then
			tryCatch(p, brain)
			chat(p, brain, now)
		end
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

-- 이름 뒤에 받침에 맞는 조사를 붙인다 (예: 빨강 + 이/가 → "빨강이", 보라 → "보라가").
local function withJosa(name, withFinal, withoutFinal)
	local code = utf8.codepoint(name, utf8.offset(name, -1))
	local isHangul = code >= 0xAC00 and code <= 0xD7A3
	local hasFinal = isHangul and (code - 0xAC00) % 28 ~= 0
	return name .. (if hasFinal then withFinal else withoutFinal)
end

-- 캐릭터를 코트 한가운데 기준 offset 자리에 세우고 lookAt 쪽을 보게 한다.
local function standAt(p, offset, lookAt)
	local up = Vector3.new(0, Config.Court.SpawnHeight, 0)
	local center = Config.Court.Center
	if p.character then
		p.character:PivotTo(CFrame.lookAt(center + offset + up, center + lookAt + up))
	end
	local humanoid = Participants.getHumanoid(p)
	local root = Participants.getRoot(p)
	if humanoid and root then
		humanoid:MoveTo(root.Position) -- 걷던 것을 멈춘다
	end
end

-- 튜토리얼 캐치 시범 : NPC 하나가 던지고 다른 NPC가 잡으면, 던진 NPC가 아웃된다.
-- viewers는 구경하는 사람 참가자 목록. 시범이 끝날 때까지 기다렸다가 돌아온다.
function NpcService.playCatchDemo(viewers)
	local T = Config.Tutorial
	local npcs = {}
	for p in brains do
		table.insert(npcs, p)
	end
	if #npcs < 2 then
		return
	end
	local thrower, catcher = npcs[1], npcs[2]
	brains[thrower].demo = true
	brains[catcher].demo = true

	-- 자리 잡기 : NPC 둘은 마주 보고, 사람은 앞에서 구경한다
	local half = T.DemoGap / 2
	standAt(thrower, Vector3.new(-half, 0, 0), Vector3.new(half, 0, 0))
	standAt(catcher, Vector3.new(half, 0, 0), Vector3.new(-half, 0, 0))
	for i, viewer in viewers do
		local side = (i - (#viewers + 1) / 2) * T.DemoViewSpacing
		standAt(viewer, Vector3.new(side, 0, -T.DemoViewDistance), Vector3.zero)
	end
	PlayerStateService.notifyAll("잘 봐요! " .. withJosa(thrower.name, "이", "가") .. " " .. catcher.name .. "에게 공을 던져요")
	task.wait(T.DemoReadySeconds)

	-- 던지기
	if BallService.giveNearestBall(thrower) then
		task.wait(T.DemoAimSeconds)
		local catcherRoot = Participants.getRoot(catcher)
		if catcherRoot then
			say(thrower.character, "받아라!", true)
			BallService.throw(thrower, catcherRoot.Position, T.DemoHold)
		end

		-- 공이 가까이 오면 꼭 잡는다
		local deadline = os.clock() + T.DemoCatchTimeout
		while os.clock() < deadline and thrower.state.status == "Alive" do
			local root = Participants.getRoot(catcher)
			for _, info in BallService.liveBalls() do
				local near = root and (info.ball.Position - root.Position).Magnitude <= N.CatchReactDistance
				if info.thrower == thrower and near then
					BallService.pressCatch(catcher)
				end
			end
			task.wait()
		end
	end

	-- 설명
	if thrower.state.status == "Sitting" then
		say(catcher.character, "잡았다!", true)
		PlayerStateService.notifyAll(withJosa(catcher.name, "이", "가") .. " 잡았어요! 공을 잡히면 던진 " .. withJosa(thrower.name, "이", "가") .. " 아웃!")
		task.wait(T.DemoAfterSeconds)
		PlayerStateService.notifyAll(withJosa(catcher.name, "을", "를") .. " 맞히면 " .. withJosa(thrower.name, "이", "가") .. " 다시 일어나요. 시작!")
	end
	brains[thrower].demo = false
	brains[catcher].demo = false
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
