-- 참가자의 상태(Alive/Sitting)를 바꾼다 : 아웃, 캐치, 부활 연쇄.
-- 설계서 1.2장, 1.4장 규칙이 여기 들어 있다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Participants = require(script.Parent.Participants)
local SoundFx = require(script.Parent.SoundFx)

local PlayerStateService = {}

local notifyRemote = Remotes.get("Notify")
local reactionHandler = nil -- 사건이 생기면 부를 함수 (NPC 말풍선용)
local knockOutListeners = {} -- 누가 아웃될 때마다 부를 함수들 (복수 대상용)

-- 누가 아웃될 때마다 부를 함수를 더한다. 함수는 (아웃된 사람, 아웃시킨 사람, "hit" 또는 "catch")를 받는다.
function PlayerStateService.addKnockOutListener(listener)
	table.insert(knockOutListeners, listener)
end

-- 사건(아웃·캐치·부활 등)이 생기면 부를 함수를 정한다.
function PlayerStateService.setReactionHandler(handler)
	reactionHandler = handler
end

-- 참가자에게 사건이 생겼다고 알린다. kind는 "out", "kill", "catch", "revive", "ability".
function PlayerStateService.react(p, kind)
	if reactionHandler and p then
		reactionHandler(p, kind)
	end
end

-- 사람 참가자 화면에 알림 글자를 띄운다 (NPC는 화면이 없어서 건너뛴다).
function PlayerStateService.notify(p, text)
	if p.player then
		notifyRemote:FireClient(p.player, text)
	end
end

-- 모든 사람 화면에 알림 글자를 띄운다.
function PlayerStateService.notifyAll(text)
	notifyRemote:FireAllClients(text)
end

-- 상태를 화면(HUD)에서 볼 수 있게 속성으로 적어 둔다.
function PlayerStateService.sync(p)
	local state = p.state
	Participants.setAttribute(p, "Status", state.status)
	Participants.setAttribute(p, "Abilities", table.concat(state.abilities, ",")) -- 예: "superwings,shield"
	Participants.setAttribute(p, "Kills", state.totalKills)
	Participants.setAttribute(p, "InRound", p.inRound)
end

-- 상태에 맞게 몸을 맞춘다 : 앉아 있으면 못 움직이고, 느려지면 반 속도.
function PlayerStateService.applyBody(p)
	local humanoid = Participants.getHumanoid(p)
	if not humanoid then
		return
	end
	local sitting = p.state.status == "Sitting"

	local speed = Config.Player.WalkSpeed
	if sitting then
		speed = 0
	elseif p.state.slowUntil > os.clock() then
		speed *= Config.Abilities.Slow.SpeedFactor
	end
	if humanoid.WalkSpeed ~= speed then
		humanoid.WalkSpeed = speed
	end

	local jump = if sitting then 0 else Config.Player.JumpHeight
	humanoid.UseJumpPower = false
	if humanoid.JumpHeight ~= jump then
		humanoid.JumpHeight = jump
	end

	-- 앉은 사람이 점프로 일어나도 다시 앉힌다
	if sitting and not humanoid.Sit then
		humanoid.Sit = true
	end
end

-- 그 자리에서 일어선다 (Alive로 바꾼다).
local function standUp(p)
	p.state.status = "Alive"
	p.state.killedBy = nil
	local humanoid = Participants.getHumanoid(p)
	if humanoid then
		humanoid.Sit = false
	end
	PlayerStateService.applyBody(p)
	PlayerStateService.sync(p)
end

-- 목록에서 참가자 하나를 뺀다.
local function removeFrom(list, p)
	local index = table.find(list, p)
	if index then
		table.remove(list, index)
	end
end

-- p가 아웃시킨 사람들을 전부 부활시키고 목록을 비운다 (설계서 1.2장 ④, 한 단계만).
local function reviveKillsOf(p)
	for _, revived in p.state.kills do
		if revived.state.status == "Sitting" and revived.state.killedBy == p then
			standUp(revived)
			PlayerStateService.notify(revived, "부활! " .. p.name .. " 아웃돼서 다시 일어났어요")
			PlayerStateService.react(revived, "revive")
		end
	end
	p.state.kills = {}
end

-- 참가자를 아웃시킨다 (Sitting). how는 "hit"(맞음) 또는 "catch"(공이 잡힘).
function PlayerStateService.knockOut(victim, by, how)
	if victim.state.status ~= "Alive" then
		return false
	end
	victim.state.status = "Sitting"
	victim.state.killedBy = by
	PlayerStateService.applyBody(victim)

	if by then
		table.insert(by.state.kills, victim)
		by.state.totalKills += 1
		PlayerStateService.notify(by, victim.name .. " 아웃!")
		PlayerStateService.sync(by)
		if how ~= "catch" then
			PlayerStateService.react(by, "kill")
		end
	end
	PlayerStateService.react(victim, "out")
	if how == "hit" then
		SoundFx.playAt("Hit", Participants.getRoot(victim)) -- oof!
	end

	local byName = by and by.name or "?"
	if how == "catch" then
		PlayerStateService.notify(victim, "아웃! 내 공을 " .. byName .. " 님이 잡았어요")
	else
		PlayerStateService.notify(victim, "아웃! " .. byName .. " 님 공에 맞았어요")
	end

	-- 내가 앉으면 내가 아웃시킨 사람들은 일어난다
	reviveKillsOf(victim)
	PlayerStateService.sync(victim)
	for _, listener in knockOutListeners do
		listener(victim, by, how)
	end
	return true
end

-- 캐치 성공 : 캐처는 Alive가 되고, 던진 사람은 아웃 (설계서 1.2장 ③).
function PlayerStateService.catch(catcher, thrower)
	local state = catcher.state
	if state.status == "Sitting" then
		local killer = state.killedBy
		if killer then
			removeFrom(killer.state.kills, catcher)
		end
		standUp(catcher)
	end
	PlayerStateService.notify(catcher, "캐치 성공!")
	PlayerStateService.react(catcher, "catch")
	SoundFx.playAt("Catch", Participants.getRoot(catcher))
	if thrower and thrower ~= catcher then
		PlayerStateService.knockOut(thrower, catcher, "catch")
	end
	PlayerStateService.sync(catcher)
end

-- 새 판을 위해 상태를 처음으로 되돌리고, 시작 능력 목록을 준다.
function PlayerStateService.resetForRound(p, abilityIds)
	p.state = Participants.newState()
	p.state.abilities = abilityIds
	p.inRound = true
	standUp(p)
end

-- 로비로 돌아갈 때 상태를 처음으로 되돌린다.
function PlayerStateService.resetForLobby(p)
	p.state = Participants.newState()
	p.inRound = false
	standUp(p)
end

-- 참가자가 게임을 나갈 때 : 그 사람이 아웃시킨 사람들을 부활시키고, 다른 목록에서도 뺀다.
function PlayerStateService.onLeave(p)
	reviveKillsOf(p)
	for _, other in Participants.all() do
		removeFrom(other.state.kills, p)
	end
end

-- 매 프레임 : 몸 상태를 맞추고 화면용 속성을 적는다.
function PlayerStateService.tick()
	for _, p in Participants.all() do
		PlayerStateService.applyBody(p)
		PlayerStateService.sync(p)
	end
end

return PlayerStateService
