-- 게임 전체 흐름 : 로비 → 카운트다운 → 플레이 → 승자 표시 → 로비 (설계서 5장).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

-- 화면(HUD)이 읽는 게임 상태. 다른 서비스보다 먼저 만든다.
local gameState = Instance.new("Folder")
gameState.Name = "GameState"
gameState.Parent = ReplicatedStorage

local Participants = require(script.Parent.Participants)
local PlayerStateService = require(script.Parent.PlayerStateService)
local CourtService = require(script.Parent.CourtService)
local BallService = require(script.Parent.BallService)
local AbilityService = require(script.Parent.AbilityService)
local NpcService = require(script.Parent.NpcService)

local R = Config.Round
local C = Config.Court
local B = Config.Ball

local phase = "Lobby" -- "Lobby", "Countdown", "Playing", "Result"

-- 능력 모듈에 넘겨줄 서비스 모음
local services = {
	Config = Config,
	Participants = Participants,
	States = PlayerStateService,
	Court = CourtService,
	Balls = BallService,
	Npcs = NpcService,
}

-- 지금 단계와 끝나는 시각을 화면에 알린다.
local function setPhase(name, seconds)
	phase = name
	gameState:SetAttribute("Phase", name)
	gameState:SetAttribute("PhaseEndsAt", workspace:GetServerTimeNow() + (seconds or 0))
end

-- 판 진행 중인지를 모든 서비스에 알린다.
local function setRoundActive(on)
	BallService.setRoundActive(on)
	CourtService.setRoundActive(on)
	AbilityService.setActive(on)
	NpcService.setActive(on)
end

-- 이번 판에서 살아 있는 참가자 목록.
local function aliveParticipants()
	local alive = {}
	for _, p in Participants.all() do
		if p.inRound and p.state.status == "Alive" then
			table.insert(alive, p)
		end
	end
	return alive
end

-- 캐릭터가 생기면 : 판 중에 새로 온 사람은 구경 자리로, 아니면 코트 안으로.
local function onCharacterAdded(p, character)
	p.character = character
	local humanoid = character:WaitForChild("Humanoid")
	character:WaitForChild("HumanoidRootPart")
	if phase ~= "Lobby" and not p.inRound then
		CourtService.placeOutside(character)
	else
		CourtService.placeInside(character)
	end
	PlayerStateService.applyBody(p)
	PlayerStateService.sync(p)
	humanoid.Died:Connect(function()
		BallService.dropBall(p)
	end)
end

-- 플레이어가 들어오면 참가자로 등록하고 캐릭터 이벤트를 연결한다.
local function onPlayerAdded(player)
	local p = Participants.addPlayer(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(p, character)
	end)
	player.CharacterRemoving:Connect(function()
		BallService.dropBall(p)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, p, player.Character)
	end
	PlayerStateService.sync(p)
end

-- 플레이어가 나가면 공·부활·기록을 정리하고 참가자에서 뺀다.
local function onPlayerRemoving(player)
	local p = Participants.fromPlayer(player)
	if not p then
		return
	end
	BallService.forget(p)
	CourtService.forget(p)
	PlayerStateService.onLeave(p)
	Participants.remove(p)
end

-- 로비 : 20초 기다린다. 사람이 아무도 없으면 계속 기다린다.
local function runLobby()
	setPhase("Lobby", R.LobbySeconds)
	local endTime = os.clock() + R.LobbySeconds
	while os.clock() < endTime or #Players:GetPlayers() == 0 do
		if #Players:GetPlayers() == 0 then
			endTime = os.clock() + R.LobbySeconds
			setPhase("Lobby", R.LobbySeconds)
		end
		task.wait(R.TickSeconds)
	end
end

-- 카운트다운 : NPC를 채우고, 모두 초기화하고, 능력과 공을 나눈다.
local function runCountdown()
	setPhase("Countdown", R.CountdownSeconds)
	CourtService.setRadius(C.StartRadius, false)

	-- 이번 판에 들어갈 사람 수를 세고, 모두 처음 온 사람이면 튜토리얼 판이 된다
	local humans, allNew = 0, true
	for _, player in Players:GetPlayers() do
		local p = Participants.fromPlayer(player)
		if p then
			humans += 1
			allNew = allNew and p.roundsPlayed == 0
		end
	end
	local tutorial = humans > 0 and allNew
	gameState:SetAttribute("Tutorial", tutorial)
	local target = if tutorial then Config.Tutorial.TargetTotal else Config.Npc.TargetTotal
	local npcCount = math.max(target - humans, R.MinParticipants - humans, 0)
	NpcService.spawn(npcCount, tutorial)

	local total = 0
	for _, p in Participants.all() do
		PlayerStateService.resetForRound(p, AbilityService.randomId())
		if p.character then
			CourtService.placeInside(p.character)
		end
		total += 1
	end

	BallService.setBallCount(math.max(B.MinCount, math.floor(total / B.PlayersPerBall)))
	BallService.resetAll()
	gameState:SetAttribute("AliveCount", total)
	setPhase("Countdown", R.CountdownSeconds) -- NPC 만드는 데 걸린 시간만큼 다시 맞춘다
	task.wait(R.CountdownSeconds)
end

-- 플레이 : 한 명만 남거나 시간이 끝날 때까지. 90초마다 코트가 줄어든다.
local function runPlaying()
	setPhase("Playing", R.PlaySeconds)
	setRoundActive(true)
	local startTime = os.clock()
	local nextShrink = startTime + C.ShrinkInterval
	while true do
		local now = os.clock()
		local alive = aliveParticipants()
		gameState:SetAttribute("AliveCount", #alive)
		if #alive <= 1 or now - startTime >= R.PlaySeconds then
			break
		end
		if now >= nextShrink then
			nextShrink += C.ShrinkInterval
			local newRadius = math.max(C.MinRadius, CourtService.getRadius() - C.ShrinkStep)
			if newRadius < CourtService.getRadius() then
				CourtService.setRadius(newRadius, true)
				PlayerStateService.notifyAll("코트가 줄어들어요!")
			end
		end
		task.wait(R.TickSeconds)
	end
	setRoundActive(false)
end

-- 승자 고르기 : 살아 있는 사람 중 아웃을 가장 많이 시킨 사람.
local function pickWinner()
	local winner = nil
	for _, p in aliveParticipants() do
		if not winner or p.state.totalKills > winner.state.totalKills then
			winner = p
		end
	end
	return winner
end

-- 결과 : 승자 이름을 5초 보여준다.
local function runResult()
	local winner = pickWinner()
	gameState:SetAttribute("Winner", winner and winner.name or "")
	setPhase("Result", R.ResultSeconds)
	task.wait(R.ResultSeconds)
end

-- 판 정리 : 능력 효과·NPC를 치우고, 모두 로비 상태로 되돌린다.
local function cleanupRound()
	AbilityService.cleanup()
	NpcService.despawnAll()
	for _, p in Participants.all() do
		if p.inRound and not p.isNpc then
			p.roundsPlayed += 1 -- 한 판을 끝까지 했으니 다음 판부터는 튜토리얼이 아니다
		end
		PlayerStateService.resetForLobby(p)
	end
	CourtService.setRadius(C.StartRadius, true)
	BallService.setBallCount(B.MinCount)
	BallService.resetAll()
	gameState:SetAttribute("Winner", "")
	gameState:SetAttribute("Tutorial", false)
end

-- 시작 : 서비스를 켜고 플레이어 이벤트를 연결한다.
CourtService.start()
BallService.start()
AbilityService.start(services)
NpcService.start()
CourtService.setRadius(C.StartRadius, false)
BallService.setBallCount(B.MinCount)

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

RunService.Heartbeat:Connect(function(dt)
	PlayerStateService.tick(dt, phase == "Playing")
end)

-- 게임은 이 순서를 계속 되풀이한다
while true do
	runLobby()
	runCountdown()
	runPlaying()
	runResult()
	cleanupRound()
end
