-- 공 두 개 : 다음 던지기에 공이 하나 더 옆으로 날아간다.
-- (실제로 공을 하나 더 만드는 일은 BallService.throw가 한다)

return {
	id = "doubleball",
	name = "공 두 개",

	-- 아직 준비해 둔 게 없을 때 쓸 수 있다 (앉아 있을 때 걸어 두면 부활한 뒤 첫 공에 붙는다).
	canUse = function(_who, state)
		return not state.nextThrow.double
	end,

	-- 다음 던지기에 "공 두 개" 표시를 붙인다.
	activate = function(_who, state, _services)
		state.nextThrow.double = true
	end,
}
