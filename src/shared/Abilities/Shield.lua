-- 방패 : 3초 동안 맞아도 아웃되지 않고 공은 튕겨 나간다.
-- (튕겨 내는 판정은 BallService가 shieldUntil을 보고 한다)

local Config = require(script.Parent.Parent.Config)
local C = Config.Abilities.Shield

return {
	id = "shield",
	name = "방패",
	duration = C.Seconds, -- 효과가 이어지는 시간 (이 동안은 다른 능력을 못 쓴다)

	-- 살아 있을 때만 쓸 수 있다.
	canUse = function(_who, state)
		return state.status == "Alive"
	end,

	-- 방패 시간을 적고, 몸에 빛나는 방어막을 씌운다.
	activate = function(who, state, _services)
		state.shieldUntil = os.clock() + C.Seconds
		if not who.character then
			return
		end
		local effect = Instance.new("ForceField")
		effect.Name = "ShieldEffect"
		effect.Parent = who.character
		task.delay(C.Seconds, function()
			effect:Destroy()
		end)
	end,
}
