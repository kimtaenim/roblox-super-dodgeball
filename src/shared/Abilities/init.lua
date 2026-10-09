-- 능력 목록 : id → 능력 모듈.
-- 새 능력을 추가하려면 파일 하나를 만들고 아래 목록에 한 줄을 넣는다.

local list = {
	require(script.Teleport),
	require(script.DoubleBall),
	require(script.Clone),
	require(script.Shield),
	require(script.Magnet),
	require(script.Fastball),
	require(script.Homing),
	require(script.Invisible),
	require(script.Slow),
}

local Abilities = {}

local byId = {}
for _, ability in list do
	byId[ability.id] = ability
end

-- id로 능력 모듈을 찾는다 (없으면 nil).
function Abilities.get(id)
	return id and byId[id]
end

-- 아무 능력 id를 하나 고른다.
function Abilities.randomId()
	return list[math.random(1, #list)].id
end

return Abilities
