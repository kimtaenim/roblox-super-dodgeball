-- 공을 만들고, 줍고, 던지고, 맞았는지·잡았는지 판정하고, 다시 살려낸다.
-- 설계서 1.4장(판정 순서), 1.5장(공) 규칙이 여기 들어 있다.

local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Participants = require(script.Parent.Participants)
local PlayerStateService = require(script.Parent.PlayerStateService)
local CourtService = require(script.Parent.CourtService)

local B = Config.Ball
local T = Config.Throw
local A = Config.Abilities

local BALL_GROUP = "Balls" -- 공끼리는 서로 부딪히지 않게 하는 충돌 그룹 이름

local BallService = {}

local folder -- 공들을 넣어 두는 폴더
local decoyFolder -- 분신들을 넣어 두는 폴더
local balls = {} -- 공 Part → BallState
local holding = {} -- 참가자 → 들고 있는 공 Part
local lastThrowTime = {} -- 참가자 → 마지막으로 던진 시각
local roundActive = false -- 판이 진행 중이면 true (그때만 아웃 판정)
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

-- 공 상태 표 하나를 만든다 (설계서 1.3장 BallState).
local function newBallState(temporary)
	return {
		thrower = nil, -- 던진 참가자 (nil이면 죽은 공)
		live = false, -- 바닥에 닿기 전이면 true
		flags = {}, -- 능력 효과 (fast, homing)
		holder = nil, -- 지금 들고 있는 참가자
		outsideSince = nil, -- 코트 밖에 나간 시각
		thrownAt = 0, -- 던진 시각
		temporary = temporary, -- "공 두 개"로 생긴 복제 공이면 true (바닥에 닿으면 사라짐)
	}
end

-- 판 진행 여부를 바꾼다. 판이 아닐 때는 맞아도 아웃이 아니다 (로비 연습).
function BallService.setRoundActive(on)
	roundActive = on
end

-- 분신을 넣는 폴더를 돌려준다 (분신술 능력이 쓴다).
function BallService.getDecoyFolder()
	return decoyFolder
end

-- 공을 들어 올리는 힘을 맞춘다. fraction 1이면 중력을 완전히 없앤다.
local function setLift(ball, fraction)
	local lift = ball:FindFirstChild("Lift")
	if fraction <= 0 then
		lift.Enabled = false
		return
	end
	lift.Force = Vector3.new(0, ball:GetMass() * workspace.Gravity * fraction, 0)
	lift.Enabled = true
end

-- 공을 죽은 공으로 만든다. 복제 공이면 없앤다.
local function makeDead(ball)
	local state = balls[ball]
	if not state then
		return
	end
	state.live = false
	state.thrower = nil
	state.flags = {}
	setLift(ball, 0)
	if state.temporary then
		balls[ball] = nil
		ball:Destroy()
	end
end

-- 공을 코트 중앙 근처로 되돌린다.
local function respawnBall(ball)
	local state = balls[ball]
	makeDead(ball)
	if not balls[ball] then
		return
	end
	state.outsideSince = nil
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
	local ratio = math.min(1, B.RespawnSpread / CourtService.getRadius())
	ball.CFrame = CFrame.new(CourtService.randomPointInside(ratio, B.RespawnHeight))
end

-- 공이 무언가에 닿았을 때 : 바닥(캐릭터·공·분신이 아닌 것)이면 죽은 공이 된다.
local function onBallTouched(ball, otherPart)
	local state = balls[ball]
	if not state or not state.live then
		return
	end
	if balls[otherPart] or otherPart:IsDescendantOf(decoyFolder) then
		return
	end
	local model = otherPart:FindFirstAncestorOfClass("Model")
	if model and model:FindFirstChildOfClass("Humanoid") then
		return
	end
	makeDead(ball)
end

-- 새 공을 하나 만든다. temporary면 바닥에 닿을 때 사라지는 복제 공.
local function createBall(temporary)
	local ball = Instance.new("Part")
	ball.Name = if temporary then "ExtraBall" else "Ball"
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.one * B.Diameter
	ball.Color = B.Color
	ball.Material = Enum.Material.SmoothPlastic
	ball.CustomPhysicalProperties = PhysicalProperties.new(B.Density, B.Friction, B.Elasticity)
	ball.CollisionGroup = BALL_GROUP

	-- 중력을 줄이는 힘 (날아갈 때만 켠다)
	local attachment = Instance.new("Attachment")
	attachment.Parent = ball
	local lift = Instance.new("VectorForce")
	lift.Name = "Lift"
	lift.Attachment0 = attachment
	lift.RelativeTo = Enum.ActuatorRelativeTo.World
	lift.ApplyAtCenterOfMass = true
	lift.Enabled = false
	lift.Parent = ball

	ball.Parent = folder
	ball:SetNetworkOwner(nil) -- 공의 물리는 서버가 계산한다

	balls[ball] = newBallState(temporary)
	ball.Touched:Connect(function(otherPart)
		onBallTouched(ball, otherPart)
	end)
	if not temporary then
		respawnBall(ball)
	end
	return ball
end

-- 참가자 손에 공을 붙인다.
local function attachToHand(p, ball)
	local hand = Participants.getHand(p)
	if not hand then
		return
	end
	local state = balls[ball]
	makeDead(ball)
	if state.temporary then
		return -- 복제 공은 잡으면 사라진다
	end
	state.holder = p
	state.outsideSince = nil
	holding[p] = ball
	Participants.setAttribute(p, "HoldingBall", true) -- 튜토리얼 안내용

	ball.CanCollide = false
	ball.Massless = true
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.CFrame = hand.CFrame
	local weld = Instance.new("WeldConstraint")
	weld.Name = "HandWeld"
	weld.Part0 = ball
	weld.Part1 = hand
	weld.Parent = ball
end

-- 손에서 공을 떼어 낸다 (던지기·떨어뜨리기 공통).
local function detachFromHand(p)
	local ball = holding[p]
	if not ball then
		return nil
	end
	holding[p] = nil
	balls[ball].holder = nil
	Participants.setAttribute(p, "HoldingBall", nil)

	local weld = ball:FindFirstChild("HandWeld")
	if weld then
		weld:Destroy()
	end
	ball.CanCollide = true
	ball.Massless = false
	ball:SetNetworkOwner(nil)
	return ball
end

-- 들고 있던 공을 그 자리에 떨어뜨린다 (아웃되거나 몸이 사라질 때).
function BallService.dropBall(p)
	detachFromHand(p)
end

-- 참가자가 공을 들고 있는지 알려준다.
function BallService.isHolding(p)
	return holding[p] ~= nil
end

-- 나간 참가자가 던진 공은 죽은 공으로 만든다.
function BallService.forget(p)
	BallService.dropBall(p)
	lastThrowTime[p] = nil
	for ball, state in balls do
		if state.thrower == p then
			makeDead(ball)
		end
	end
end

-- 홀드 시간을 공 속도로 바꾼다 (0.3초 이하 = 최소, 1초 이상 = 최대 80).
local function holdToSpeed(holdSeconds)
	local hold = math.clamp(holdSeconds, T.MinHold, T.MaxHold)
	return T.MaxSpeed * hold / T.MaxHold
end

-- 조준점으로 갈 방향을 구한다. 가까우면 떨어지는 만큼 위로 보정한다 (조준 도움).
local function aimDirection(start, aimPoint, speed, gravityLeft)
	local toAim = aimPoint - start
	local distance = toAim.Magnitude
	if gravityLeft > 0 and distance <= T.AssistMaxDistance then
		local flightTime = distance / speed
		local drop = 0.5 * workspace.Gravity * gravityLeft * flightTime * flightTime
		toAim += Vector3.new(0, drop, 0)
	end
	return toAim.Unit
end

-- 공을 출발시킨다.
local function launch(ball, p, start, velocity, flags, lift)
	local state = balls[ball]
	ball.CFrame = CFrame.new(start)
	ball.AssemblyAngularVelocity = Vector3.zero
	ball.AssemblyLinearVelocity = velocity
	state.thrower = p
	state.live = true
	state.flags = flags
	state.thrownAt = os.clock()
	setLift(ball, lift)
end

-- 참가자가 조준점을 향해 공을 던진다. 능력(강속구·유도탄·공 두 개)도 여기서 붙는다.
function BallService.throw(p, aimPoint, holdSeconds)
	if p.state.status ~= "Alive" or not holding[p] then
		return false
	end
	if roundActive and not p.inRound then
		return false
	end
	local root = Participants.getRoot(p)
	if not root or not Participants.hasBody(p) then
		return false
	end

	-- 공이 출발할 곳 : 몸 앞쪽, 가슴 높이
	local chest = root.Position + Vector3.new(0, T.HandHeight, 0)
	local toAim = aimPoint - chest
	if toAim.Magnitude < 1e-3 then
		return false
	end
	local start = chest + toAim.Unit * T.ForwardOffset

	-- 능력으로 붙은 효과를 꺼내 쓴다 (한 번 쓰면 없어진다)
	local nextThrow = p.state.nextThrow
	p.state.nextThrow = {}

	local speed = holdToSpeed(holdSeconds)
	local lift = 1 - B.GravityScale
	local flags = { homing = nextThrow.homing }
	if nextThrow.fast then
		speed *= A.Fastball.SpeedMultiplier
		lift = 1 -- 강속구는 중력을 받지 않는다
		flags.fast = true
	end
	local direction = aimDirection(start, aimPoint, speed, 1 - lift)

	local ball = detachFromHand(p)
	launch(ball, p, start, direction * speed, flags, lift)

	-- 공 두 개 : 옆으로 벌어진 복제 공을 하나 더 던진다
	if nextThrow.double then
		local turn = CFrame.Angles(0, math.rad(A.DoubleBall.SpreadDegrees), 0)
		local extraDirection = turn:VectorToWorldSpace(direction)
		local side = extraDirection:Cross(Vector3.yAxis)
		local extraStart = start
		if side.Magnitude > 1e-3 then
			extraStart = start - side.Unit * B.Diameter
		end
		local extra = createBall(true)
		launch(extra, p, extraStart, extraDirection * speed, table.clone(flags), lift)
	end

	lastThrowTime[p] = os.clock()
	return true
end

-- 클라이언트가 보낸 던지기 요청을 확인하고 처리한다.
local function onThrowRequest(player, aimPoint, holdSeconds)
	local p = Participants.fromPlayer(player)
	if not p or typeof(aimPoint) ~= "Vector3" or typeof(holdSeconds) ~= "number" then
		return
	end
	-- NaN·무한대 같은 이상한 숫자는 무시한다
	local values = { aimPoint.X, aimPoint.Y, aimPoint.Z, holdSeconds }
	for _, n in values do
		if n ~= n or math.abs(n) == math.huge then
			return
		end
	end
	BallService.throw(p, aimPoint, holdSeconds)
end

-- 캐치 버튼을 누른 시각을 적어 둔다 (1초에 한 번만).
function BallService.pressCatch(p)
	local now = os.clock()
	if now - p.state.lastCatchPress >= Config.Catch.Cooldown then
		p.state.lastCatchPress = now
	end
end

-- 분신이 공에 맞으면 펑 터진다.
local function popDecoy(part)
	local decoy = part
	while decoy.Parent ~= decoyFolder do
		decoy = decoy.Parent
	end
	local explosion = Instance.new("Explosion")
	explosion.BlastPressure = 0
	explosion.DestroyJointRadiusPercent = 0
	explosion.Position = decoy:GetPivot().Position
	explosion.Parent = workspace
	decoy:Destroy()
end

-- 날아가는 공이 참가자에게 닿았을 때 판정한다 (설계서 1.4장). 공이 멈추면 true.
local function judgeContact(ball, state, part)
	if part:IsDescendantOf(decoyFolder) then
		popDecoy(part)
		makeDead(ball)
		return true
	end

	local p = Participants.fromPart(part)
	if not p or p == state.thrower then
		return false
	end
	if not roundActive or not p.inRound then
		return false -- 로비 연습이나 구경꾼은 판정하지 않는다
	end

	local now = os.clock()
	local thrower = state.thrower

	-- ① 닿기 전 0.5초 안에 캐치 버튼을 눌렀으면 캐치 (Alive·Sitting 모두)
	if now - p.state.lastCatchPress <= Config.Catch.Window then
		p.state.lastCatchPress = -math.huge
		PlayerStateService.catch(p, thrower)
		if thrower and thrower.state.status == "Sitting" then
			BallService.dropBall(thrower)
		end
		if holding[p] then
			makeDead(ball)
		else
			attachToHand(p, ball)
		end
		return true
	end

	-- 앉아 있는 사람은 맞아도 그냥 지나간다
	if p.state.status ~= "Alive" then
		return false
	end

	-- 머리에 맞으면 아웃 아님. 공은 튕겨서 죽은 공
	if part.Name == "Head" then
		makeDead(ball)
		return true
	end

	-- 방패 : 아웃 안 되고 공은 튕겨 나간다
	if p.state.shieldUntil > now then
		local back = -ball.AssemblyLinearVelocity
		if back.Magnitude > 1e-3 then
			back = back.Unit
		end
		makeDead(ball)
		ball.AssemblyLinearVelocity = back * A.Shield.BounceSpeed + Vector3.new(0, A.Shield.BounceUp, 0)
		return true
	end

	-- ② 피격 : 아웃
	PlayerStateService.knockOut(p, thrower, "hit")
	BallService.dropBall(p)
	makeDead(ball)
	return true
end

-- 날아가는 공마다 주변에 참가자·분신 몸이 있는지 확인한다.
local function checkHits()
	local targets = { decoyFolder }
	for _, p in Participants.all() do
		if p.character then
			table.insert(targets, p.character)
		end
	end
	overlapParams.FilterDescendantsInstances = targets

	local radius = B.Diameter / 2 + B.HitPadding
	for ball, state in balls do
		if state.live then
			-- 몸통을 먼저 보고 머리는 나중에 본다 (머리와 몸통에 같이 닿으면 몸통 판정)
			local parts = workspace:GetPartBoundsInRadius(ball.Position, radius, overlapParams)
			table.sort(parts, function(x, y)
				return x.Name ~= "Head" and y.Name == "Head"
			end)
			for _, part in parts do
				if judgeContact(ball, state, part) then
					break
				end
			end
		end
	end
end

-- 가장 가까운 살아 있는 상대를 찾는다 (유도탄용).
local function nearestTarget(position, except)
	local best, bestDistance = nil, math.huge
	for _, p in Participants.all() do
		local root = Participants.getRoot(p)
		if root and p ~= except and p.inRound and p.state.status == "Alive" then
			local distance = (root.Position - position).Magnitude
			if distance < bestDistance then
				best, bestDistance = root, distance
			end
		end
	end
	return best
end

-- 유도탄 : 공이 날아가는 방향을 상대 쪽으로 조금씩 꺾는다.
local function steerHoming(ball, state, dt)
	if not state.flags.homing or os.clock() - state.thrownAt > A.Homing.Seconds then
		return
	end
	local target = nearestTarget(ball.Position, state.thrower)
	local velocity = ball.AssemblyLinearVelocity
	local speed = velocity.Magnitude
	if not target or speed < 1 then
		return
	end
	local current = velocity.Unit
	local wanted = (target.Position - ball.Position).Unit
	local angle = math.acos(math.clamp(current:Dot(wanted), -1, 1))
	local maxTurn = math.rad(A.Homing.TurnDegreesPerSecond) * dt
	local newDirection = wanted
	if angle > maxTurn then
		newDirection = current:Lerp(wanted, maxTurn / angle).Unit
	end
	ball.AssemblyLinearVelocity = newDirection * speed
end

-- 날아가는 공을 돌본다 : 유도탄 꺾기, 너무 오래 날면 죽은 공.
local function updateFlyingBalls(dt)
	local now = os.clock()
	for ball, state in balls do
		if state.live then
			if now - state.thrownAt > B.MaxLiveSeconds then
				makeDead(ball)
			else
				steerHoming(ball, state, dt)
			end
		end
	end
end

-- 공이 주울 수 있는 상태인지 알려준다 (죽은 공이고 아무도 안 들고 있음).
local function isFree(state)
	return not state.live and state.holder == nil
end

-- 빈손인 근처 참가자가 죽은 공을 자동으로 줍게 한다.
local function tryPickups()
	local now = os.clock()
	for _, p in Participants.all() do
		local root = Participants.getRoot(p)
		local canPlay = p.inRound or not roundActive
		local cooledDown = now - (lastThrowTime[p] or 0) >= B.PickupCooldown
		if root and canPlay and cooledDown and not holding[p] and p.state.status == "Alive" and Participants.hasBody(p) then
			for ball, state in balls do
				if isFree(state) and (ball.Position - root.Position).Magnitude <= B.PickupRadius then
					attachToHand(p, ball)
					break
				end
			end
		end
	end
end

-- 코트 밖에 오래 있거나 떨어진 죽은 공을 중앙으로 되돌린다.
local function checkRespawns()
	local now = os.clock()
	for ball, state in balls do
		if state.holder == nil then
			if ball.Position.Y < B.FallLimitY then
				respawnBall(ball)
			elseif not state.live and not CourtService.isInside(ball.Position) then
				state.outsideSince = state.outsideSince or now
				if now - state.outsideSince >= B.RespawnDelay then
					respawnBall(ball)
				end
			else
				state.outsideSince = nil
			end
		end
	end
end

-- 위치에서 가장 가까운, 코트 안의 주울 수 있는 공을 찾는다 (NPC가 쓴다).
function BallService.nearestFreeBall(position)
	local best, bestDistance = nil, math.huge
	for ball, state in balls do
		if isFree(state) and CourtService.isInside(ball.Position) then
			local distance = (ball.Position - position).Magnitude
			if distance < bestDistance then
				best, bestDistance = ball, distance
			end
		end
	end
	return best
end

-- 날아가는 공 목록을 돌려준다 (NPC가 캐치할지 고를 때 쓴다).
function BallService.liveBalls()
	local result = {}
	for ball, state in balls do
		if state.live then
			table.insert(result, { ball = ball, thrower = state.thrower, thrownAt = state.thrownAt })
		end
	end
	return result
end

-- 자석 : 주변의 죽은 공을 참가자 쪽으로 끌어온다.
function BallService.pullFreeBalls(p, radius, speed, up)
	local root = Participants.getRoot(p)
	if not root then
		return
	end
	for ball, state in balls do
		local toRoot = root.Position - ball.Position
		if isFree(state) and toRoot.Magnitude <= radius and toRoot.Magnitude > 1e-3 then
			ball.AssemblyLinearVelocity = toRoot.Unit * speed + Vector3.new(0, up, 0)
		end
	end
end

-- 공 개수를 맞춘다 (복제 공은 세지 않는다).
function BallService.setBallCount(wanted)
	local count = 0
	for _, state in balls do
		if not state.temporary then
			count += 1
		end
	end
	while count < wanted do
		createBall(false)
		count += 1
	end
	for ball, state in balls do
		if count <= wanted then
			break
		end
		if not state.temporary and state.holder == nil then
			balls[ball] = nil
			ball:Destroy()
			count -= 1
		end
	end
end

-- 모든 공을 손에서 떼고 중앙으로 되돌린다 (판 시작·끝).
function BallService.resetAll()
	for p in holding do
		detachFromHand(p)
	end
	for ball in balls do
		respawnBall(ball)
	end
end

-- 공 폴더·충돌 그룹을 만들고, 신호와 매 프레임 검사를 연결한다.
function BallService.start()
	PhysicsService:RegisterCollisionGroup(BALL_GROUP)
	PhysicsService:CollisionGroupSetCollidable(BALL_GROUP, BALL_GROUP, false)

	folder = Instance.new("Folder")
	folder.Name = "Balls"
	folder.Parent = workspace
	decoyFolder = Instance.new("Folder")
	decoyFolder.Name = "Decoys"
	decoyFolder.Parent = workspace

	Remotes.get("Throw").OnServerEvent:Connect(onThrowRequest)
	Remotes.get("Catch").OnServerEvent:Connect(function(player)
		local p = Participants.fromPlayer(player)
		if p then
			BallService.pressCatch(p)
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		checkHits()
		updateFlyingBalls(dt)
		tryPickups()
		checkRespawns()
	end)
end

return BallService
