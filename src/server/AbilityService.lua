-- 능력을 쓰게 해 준다 : 상자에서 주운 능력 실행, 판 끝 정리 (설계서 2장).
-- 능력마다 하는 일은 shared/Abilities/ 모듈에 들어 있다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local Participants = require(script.Parent.Participants)
local PlayerStateService = require(script.Parent.PlayerStateService)
local SoundFx = require(script.Parent.SoundFx)

local AbilityService = {}

local services -- 능력 모듈에 넘겨줄 서비스 모음
local active = false -- 판이 진행 중일 때만 능력을 쓸 수 있다

-- 능력 사용 가능 여부를 바꾼다.
function AbilityService.setActive(on)
	active = on
end

-- 능력 효과가 아직 이어지고 있는지 알려준다 (효과 시간이 남았거나, 다음 던지기에 붙은 능력이 있으면).
local function isBusy(state)
	return state.abilityBusyUntil > os.clock() or next(state.nextThrow) ~= nil
end

-- 참가자가 slot번째 능력을 쓴다. 쓰면 true (쓴 능력은 목록에서 빠진다).
-- 능력은 한 번에 하나만 : 앞서 쓴 능력의 효과가 끝나야 다음 능력을 쓸 수 있다.
function AbilityService.use(p, slot)
	if not active or not p.inRound then
		return false
	end
	local state = p.state
	local ability = Abilities.get(state.abilities[slot])
	if not ability then
		return false
	end
	if not ability.canUse(p, state, services) then
		if ability.cantUseText and not p.isNpc then
			PlayerStateService.notify(p, ability.cantUseText) -- 왜 안 되는지 알려 준다
		end
		return false
	end
	if isBusy(state) then
		PlayerStateService.notify(p, "앞의 능력이 끝나면 쓸 수 있어요")
		return false
	end
	table.remove(state.abilities, slot)
	state.abilityBusyUntil = os.clock() + (ability.duration or 0)
	ability.activate(p, state, services)
	PlayerStateService.sync(p)
	PlayerStateService.notify(p, ability.name .. "!")
	PlayerStateService.react(p, "ability")
	SoundFx.playAt("Ability", Participants.getRoot(p))
	return true
end

-- 판이 끝나면 남은 능력 효과를 모두 치운다.
function AbilityService.cleanup()
	services.Balls.getDecoyFolder():ClearAllChildren()
	for _, p in Participants.all() do
		for _, name in { "ShieldEffect", "SuperCatchEffect", "SuperWingsEffect", "SuperWingsAttachment" } do
			local effect = p.character and p.character:FindFirstChild(name, true)
			if effect then
				effect:Destroy()
			end
		end
	end
end

-- 서비스 모음을 받아 두고 능력 버튼 신호를 연결한다.
function AbilityService.start(serviceTable)
	services = serviceTable
	Remotes.get("UseAbility").OnServerEvent:Connect(function(player, slot)
		local p = Participants.fromPlayer(player)
		if p and typeof(slot) == "number" and slot == math.floor(slot) then
			AbilityService.use(p, slot)
		end
	end)
end

return AbilityService
