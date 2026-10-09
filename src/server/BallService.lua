-- 공을 만들고, 줍고, 던지고, 다시 살려낸다.
-- (맞으면 아웃, 캐치는 다음 단계 ②에서 만든다)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CourtService = require(script.Parent.CourtService)

local B = Config.Ball
local T = Config.Throw

local BallService = {}

local folder -- 공들을 넣어 두는 폴더
local balls = {} -- 공 Part → BallState
local holding = {} -- 플레이어 → 들고 있는 공 Part
local lastThrowTime = {} -- 플레이어 → 마지막으로 던진 시각

-- 공 상태 표 하나를 만든다 (설계서 1.3장 BallState).
local function newBallState()
	return {
		thrower = nil, -- 던진 사람 (nil이면 죽은 공)
		live = false, -- 바닥에 닿기 전이면 true
		flags = {}, -- 능력 효과 (④단계부터 사용)
		holder = nil, -- 지금 들고 있는 사람
		outsideSince = nil, -- 코트 밖에 나간 시각
	}
end

-- 공이 닿은 부품이 누군가의 캐릭터인지 알려준다.
local function isCharacterPart(part)
	local model = part:FindFirstAncestorOfClass("Model")
	return model ~= nil and Players:GetPlayerFromCharacter(model) ~= nil
end

-- 공을 죽은 공으로 만든다 (던진 사람 기록을 지운다).
local function makeDead(state)
	state.live = false
	state.thrower = nil
end

-- 공이 무언가에 닿았을 때 : 바닥(캐릭터·공이 아닌 것)이면 죽은 공이 된다.
local function onBallTouched(ball, otherPart)
	local state = balls[ball]
	if not state or not state.live then
		return
	end
	if balls[otherPart] or isCharacterPart(otherPart) then
		return
	end
	makeDead(state)
end

-- 공을 코트 중앙 근처로 되돌린다.
local function respawnBall(ball)
	local state = balls[ball]
	makeDead(state)
	state.outsideSince = nil
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
	ball.CFrame = CFrame.new(CourtService.randomPointInside(B.RespawnSpread / Config.Court.Radius, B.RespawnHeight))
end

-- 새 공을 하나 만든다.
local function createBall()
	local ball = Instance.new("Part")
	ball.Name = "Ball"
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.one * B.Diameter
	ball.Color = B.Color
	ball.Material = Enum.Material.SmoothPlastic
	ball.CustomPhysicalProperties = PhysicalProperties.new(B.Density, B.Friction, B.Elasticity)
	ball.Parent = folder
	ball:SetNetworkOwner(nil) -- 공의 물리는 서버가 계산한다

	balls[ball] = newBallState()
	ball.Touched:Connect(function(otherPart)
		onBallTouched(ball, otherPart)
	end)
	respawnBall(ball)
	return ball
end

-- 캐릭터의 오른손을 찾는다 (R15는 RightHand, R6는 Right Arm).
local function findHand(character)
	return character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
end

-- 캐릭터가 살아 있는지 알려준다.
local function isCharacterAlive(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

-- 플레이어 손에 공을 붙인다.
local function attachToHand(player, ball, hand)
	local state = balls[ball]
	state.holder = player
	state.outsideSince = nil
	makeDead(state)
	holding[player] = ball

	ball.CanCollide = false
	ball.Massless = true
	ball.CFrame = hand.CFrame
	local weld = Instance.new("WeldConstraint")
	weld.Name = "HandWeld"
	weld.Part0 = ball
	weld.Part1 = hand
	weld.Parent = ball
end

-- 손에서 공을 떼어 낸다 (던지기·떨어뜨리기 공통).
local function detachFromHand(player)
	local ball = holding[player]
	if not ball then
		return nil
	end
	holding[player] = nil
	balls[ball].holder = nil

	local weld = ball:FindFirstChild("HandWeld")
	if weld then
		weld:Destroy()
	end
	ball.CanCollide = true
	ball.Massless = false
	ball:SetNetworkOwner(nil)
	return ball
end

-- 들고 있던 공을 그 자리에 떨어뜨린다 (캐릭터가 사라질 때 등).
function BallService.dropBall(player)
	detachFromHand(player)
end

-- 플레이어가 공을 들고 있는지 알려준다.
function BallService.isHolding(player)
	return holding[player] ~= nil
end

-- 홀드 시간을 공 속도로 바꾼다 (0.3초 이하 = 최소, 1초 이상 = 최대 80).
local function holdToSpeed(holdSeconds)
	local hold = math.clamp(holdSeconds, T.MinHold, T.MaxHold)
	return T.MaxSpeed * hold / T.MaxHold
end

-- 숫자가 정상인지 확인한다 (NaN, 무한대 막기).
local function isFiniteNumber(n)
	return typeof(n) == "number" and n == n and math.abs(n) ~= math.huge
end

-- 클라이언트가 보낸 던지기 요청을 처리한다.
local function onThrowRequest(player, aimPoint, holdSeconds)
	-- 보낸 값이 이상하면 무시한다
	if typeof(aimPoint) ~= "Vector3" or not isFiniteNumber(holdSeconds) then
		return
	end
	if not (isFiniteNumber(aimPoint.X) and isFiniteNumber(aimPoint.Y) and isFiniteNumber(aimPoint.Z)) then
		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not isCharacterAlive(character) or not holding[player] then
		return
	end

	-- 공이 출발할 곳 : 몸 앞쪽, 가슴 높이
	local chest = root.Position + Vector3.new(0, T.HandHeight, 0)
	local toAim = aimPoint - chest
	if toAim.Magnitude < 1e-3 then
		return
	end
	local direction = toAim.Unit
	local start = chest + direction * T.ForwardOffset

	local ball = detachFromHand(player)
	local state = balls[ball]
	ball.CFrame = CFrame.new(start)
	ball.AssemblyAngularVelocity = Vector3.zero
	ball.AssemblyLinearVelocity = direction * holdToSpeed(holdSeconds)
	state.thrower = player
	state.live = true
	lastThrowTime[player] = os.clock()
end

-- 빈손인 근처 플레이어가 죽은 공을 자동으로 줍게 한다.
local function tryPickups()
	local now = os.clock()
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local hand = character and findHand(character)
		local cooledDown = now - (lastThrowTime[player] or 0) >= B.PickupCooldown
		if root and hand and cooledDown and not holding[player] and isCharacterAlive(character) then
			for ball, state in balls do
				local free = not state.live and state.holder == nil
				if free and (ball.Position - root.Position).Magnitude <= B.PickupRadius then
					attachToHand(player, ball, hand)
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

-- 공을 하나 없앤다 (아무도 안 들고 있는 공만).
local function removeFreeBall()
	for ball, state in balls do
		if state.holder == nil then
			balls[ball] = nil
			ball:Destroy()
			return true
		end
	end
	return false
end

-- 인원수에 맞게 공 개수를 맞춘다 (플레이어 ÷ 2, 최소 2개).
function BallService.updateBallCount(playerCount)
	local wanted = math.max(B.MinCount, math.floor(playerCount / B.PlayersPerBall))
	local count = 0
	for _ in balls do
		count += 1
	end
	while count < wanted do
		createBall()
		count += 1
	end
	while count > wanted and removeFreeBall() do
		count -= 1
	end
end

-- 공 폴더를 만들고, 던지기 신호와 매 프레임 검사를 연결한다.
function BallService.start()
	folder = Instance.new("Folder")
	folder.Name = "Balls"
	folder.Parent = workspace

	Remotes.get("Throw").OnServerEvent:Connect(onThrowRequest)
	RunService.Heartbeat:Connect(function()
		tryPickups()
		checkRespawns()
	end)
	Players.PlayerRemoving:Connect(function(player)
		BallService.dropBall(player)
		lastThrowTime[player] = nil
	end)
end

return BallService
