-- NPC를 만들고, 움직이고, 공을 던지고 잡게 한다 (설계서 9장).
-- NPC도 사람과 똑같은 참가자라서 규칙은 다른 서비스가 똑같이 적용한다.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Participants = require(script.Parent.Participants)
local BallService = require(script.Parent.BallService)
local CourtService = require(script.Parent.CourtService)
local AbilityService = require(script.Parent.AbilityService)

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

-- NPC 생김새(피부색·옷 색)를 정한다.
local function makeDescription()
	local description = Instance.new("HumanoidDescription")
	local skin = N.SkinColors[math.random(1, #N.SkinColors)]
	local shirt = Color3.fromHSV(math.random(), N.ShirtSaturation, N.ShirtBrightness)
	description.HeadColor = skin
	description.LeftArmColor = skin
	description.RightArmColor = skin
	description.TorsoColor = shirt
	description.LeftLegColor = N.PantsColor
	description.RightLegColor = N.PantsColor
	return description
end

-- n번째 NPC 이름을 정한다 (이름이 모자라면 숫자를 붙인다).
local function npcName(index)
	local count = #N.Names
	local name = N.Names[(index - 1) % count + 1]
	local round = math.floor((index - 1) / count)
	if round > 0 then
		name ..= tostring(round + 1)
	end
	return name
end

-- NPC를 count명 만들어 코트 안에 세운다.
function NpcService.spawn(count)
	for index = 1, count do
		local name = npcName(index)
		local ok, model = pcall(function()
			return Players:CreateHumanoidModelFromDescription(makeDescription(), Enum.HumanoidRigType.R15)
		end)
		if not ok then
			warn("NPC를 만들지 못했어요: " .. tostring(model))
			continue
		end
		model.Name = name
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		humanoid.DisplayName = name
		humanoid.BreakJointsOnDeath = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false) -- NPC는 죽지 않는다
		model.Parent = folder
		model.HumanoidRootPart:SetNetworkOwner(nil) -- NPC 움직임은 서버가 계산한다
		CourtService.placeInside(model)
		NpcService.setupAnimation(model)

		local p = Participants.addNpc(name, model)
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

-- NPC 폴더를 만들고 매 프레임 움직임을 연결한다.
function NpcService.start()
	folder = Instance.new("Folder")
	folder.Name = "Npcs"
	folder.Parent = workspace
	RunService.Heartbeat:Connect(update)
end

return NpcService
