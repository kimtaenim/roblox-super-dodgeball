-- 슈퍼강속구 : 다음 던지기가 3배 빠르고, 중력을 받지 않고, 불꽃이 붙는다.
-- (속도·중력·불꽃 처리는 BallService.throw가 한다)

return {
	id = "superfastball",
	name = "슈퍼강속구",

	-- 살아 있고, 아직 준비해 둔 게 없을 때 쓸 수 있다.
	canUse = function(_who, state)
		return state.status == "Alive" and not state.nextThrow.fast
	end,

	-- 다음 던지기에 "슈퍼강속구" 표시를 붙인다.
	activate = function(_who, state, _services)
		state.nextThrow.fast = true
	end,
}
