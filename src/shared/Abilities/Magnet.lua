-- 자석 : 주변의 죽은 공을 내 쪽으로 끌어온다.

local Config = require(script.Parent.Parent.Config)
local C = Config.Abilities.Magnet

return {
	id = "magnet",
	name = "자석",

	-- 살아 있을 때만 쓸 수 있다.
	canUse = function(_who, state)
		return state.status == "Alive"
	end,

	-- 반경 안의 죽은 공을 내 쪽으로 날린다.
	activate = function(who, _state, services)
		services.Balls.pullFreeBalls(who, C.Radius, C.PullSpeed, C.PullUp)
	end,
}
