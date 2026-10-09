-- 게임에 참가하는 모두(사람 플레이어 + NPC)를 한 목록으로 관리한다.
-- 다른 서비스는 Player 대신 이 "참가자" 표를 쓴다. 그래서 NPC도 사람과 똑같이 놀 수 있다.
--
-- 참가자 표 :
--   name      = 화면에 보이는 이름
--   player    = 사람이면 Player, NPC면 nil
--   isNpc     = NPC면 true
--   character = 지금 몸(Model)
--   inRound   = 이번 판에 참가 중이면 true
--   state     = 설계서 1.3장 PlayerState

local Participants = {}

local list = {} -- 모든 참가자
local byPlayer = {} -- Player → 참가자

-- 새 상태 표를 만든다 (설계서 1.3장 PlayerState + 능력 효과 시간).
function Participants.newState()
	return {
		status = "Alive", -- "Alive" 또는 "Sitting"
		killedBy = nil, -- 나를 아웃시킨 참가자
		kills = {}, -- 내가 아웃시킨 참가자 목록 (부활 연쇄용)
		totalKills = 0, -- 이번 판에 아웃시킨 총 횟수 (순위용)
		gauge = 0, -- 능력 게이지 0-100
		ability = nil, -- 능력 id
		shieldUntil = 0, -- 방패가 끝나는 시각
		slowUntil = 0, -- 느려짐이 끝나는 시각
		invisibleUntil = 0, -- 투명이 끝나는 시각
		lastCatchPress = -math.huge, -- 캐치 버튼을 마지막으로 누른 시각
		nextThrow = {}, -- 다음 던지기에 붙는 능력 (double, fast, homing)
	}
end

-- 목록에 참가자를 넣는다.
local function add(p)
	table.insert(list, p)
	return p
end

-- 사람 플레이어를 참가자로 등록한다.
function Participants.addPlayer(player)
	local p = add({
		name = player.DisplayName,
		player = player,
		isNpc = false,
		character = player.Character,
		inRound = false,
		state = Participants.newState(),
	})
	byPlayer[player] = p
	return p
end

-- NPC를 참가자로 등록한다.
function Participants.addNpc(name, model)
	return add({
		name = name,
		player = nil,
		isNpc = true,
		character = model,
		inRound = false,
		state = Participants.newState(),
	})
end

-- 참가자를 목록에서 뺀다.
function Participants.remove(p)
	local index = table.find(list, p)
	if index then
		table.remove(list, index)
	end
	if p.player then
		byPlayer[p.player] = nil
	end
end

-- 모든 참가자 목록을 돌려준다 (복사본이라 돌면서 지워도 안전하다).
function Participants.all()
	return table.clone(list)
end

-- Player로 참가자를 찾는다.
function Participants.fromPlayer(player)
	return byPlayer[player]
end

-- 부품(Part)이 어느 참가자의 몸인지 찾는다.
function Participants.fromPart(part)
	for _, p in list do
		if p.character and part:IsDescendantOf(p.character) then
			return p
		end
	end
	return nil
end

-- 몸 중심(HumanoidRootPart)을 찾는다.
function Participants.getRoot(p)
	return p.character and p.character:FindFirstChild("HumanoidRootPart")
end

-- Humanoid를 찾는다.
function Participants.getHumanoid(p)
	return p.character and p.character:FindFirstChildOfClass("Humanoid")
end

-- 오른손을 찾는다 (R15는 RightHand, R6는 Right Arm).
function Participants.getHand(p)
	local character = p.character
	return character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))
end

-- 몸이 멀쩡히 있는지 알려준다 (Humanoid 체력이 0보다 크다).
function Participants.hasBody(p)
	local humanoid = Participants.getHumanoid(p)
	return humanoid ~= nil and humanoid.Health > 0 and Participants.getRoot(p) ~= nil
end

-- 화면(HUD)에서 읽을 수 있게 속성을 적는다. 사람은 Player에, NPC는 몸에 적는다.
function Participants.setAttribute(p, name, value)
	local target = p.player or p.character
	if target and target:GetAttribute(name) ~= value then
		target:SetAttribute(name, value)
	end
end

return Participants
