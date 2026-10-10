-- 슈퍼캐치 : 10초 동안 몸에 닿는 공을 버튼 없이 저절로 잡는다. 몸이 초록빛으로 빛난다.
-- (잡는 판정은 BallService가 superCatchUntil을 보고 한다)

local Config = require(script.Parent.Parent.Config)
local C = Config.Abilities.SuperCatch

return {
	id = "supercatch",
	name = "슈퍼캐치",
	duration = C.Seconds, -- 효과가 이어지는 시간 (이 동안은 다른 능력을 못 쓴다)

	-- 언제든 쓸 수 있다 (아웃돼서 앉아 있을 때도).
	canUse = function(_who, _state)
		return true
	end,

	-- 슈퍼캐치 시간을 적고, 몸을 빛나게 한다.
	activate = function(who, state, _services)
		state.superCatchUntil = os.clock() + C.Seconds
		if not who.character then
			return
		end
		local glow = Instance.new("Highlight")
		glow.Name = "SuperCatchEffect"
		glow.FillColor = C.Color
		glow.OutlineColor = C.Color
		glow.Parent = who.character
		task.delay(C.Seconds, function()
			glow:Destroy()
		end)
	end,
}
