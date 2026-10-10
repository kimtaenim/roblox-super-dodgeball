-- 부활 : 아웃돼서 앉아 있을 때 쓰면 그 자리에서 바로 일어난다.
-- (나를 아웃시킨 사람은 그대로, 내가 다시 살아날 뿐이다)

return {
	id = "revive",
	name = "부활",
	duration = 0, -- 바로 끝나는 능력
	cantUseText = "부활은 아웃돼서 앉아 있을 때 써요", -- 살아 있을 때 누르면 보여 줄 말

	-- 앉아 있을 때만 쓸 수 있다.
	canUse = function(_who, state)
		return state.status == "Sitting"
	end,

	-- 그 자리에서 일어선다.
	activate = function(who, _state, services)
		services.States.revive(who)
	end,
}
