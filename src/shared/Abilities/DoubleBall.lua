-- 공 두 개 : 다음 던지기에 공이 하나 더 옆으로 날아간다.
-- (실제로 공을 하나 더 만드는 일은 BallService.throw가 한다)

return {
	id = "doubleball",
	name = "공 두 개",

	-- 살아 있고, 아직 준비해 둔 게 없을 때 쓸 수 있다.
	canUse = function(_who, state)
		return state.status == "Alive" and not state.nextThrow.double
	end,

	-- 다음 던지기에 "공 두 개" 표시를 붙인다.
	activate = function(_who, state, _services)
		state.nextThrow.double = true
	end,
}
