-- 유도탄 : 다음 공이 가장 가까운 상대를 2초 동안 따라간다.
-- (방향 꺾기는 BallService가 매 프레임 한다)

return {
	id = "homing",
	name = "유도탄",

	-- 아직 준비해 둔 게 없을 때 쓸 수 있다 (앉아 있을 때 걸어 두면 부활한 뒤 첫 공에 붙는다).
	canUse = function(_who, state)
		return not state.nextThrow.homing
	end,

	-- 다음 던지기에 "유도탄" 표시를 붙인다.
	activate = function(_who, state, _services)
		state.nextThrow.homing = true
	end,
}
