-- 시간 느림 : 주변의 살아 있는 상대가 3초 동안 반 속도로 걷는다 (나는 빼고).
-- (실제 속도 바꾸기는 PlayerStateService.applyBody가 slowUntil을 보고 한다)

local Config = require(script.Parent.Parent.Config)
local C = Config.Abilities.Slow

return {
	id = "slow",
	name = "시간 느림",
	duration = C.Seconds, -- 효과가 이어지는 시간 (이 동안은 다른 능력을 못 쓴다)

	-- 살아 있을 때만 쓸 수 있다.
	canUse = function(_who, state)
		return state.status == "Alive"
	end,

	-- 반경 안 상대들에게 느려짐 시간을 적는다.
	activate = function(who, _state, services)
		local myRoot = services.Participants.getRoot(who)
		if not myRoot then
			return
		end
		local untilTime = os.clock() + C.Seconds
		for _, other in services.Participants.all() do
			local root = services.Participants.getRoot(other)
			local isEnemy = other ~= who and other.inRound and other.state.status == "Alive"
			if root and isEnemy and (root.Position - myRoot.Position).Magnitude <= C.Radius then
				other.state.slowUntil = untilTime
				services.States.notify(other, who.name .. " 님의 시간 느림! 느려졌어요")
			end
		end
	end,
}
