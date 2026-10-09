-- 능력 목록 : id → 능력 모듈.
-- 새 능력을 추가하려면 파일 하나를 만들고 아래 목록에 한 줄을 넣는다.

local list = {
	require(script.SuperWings),
	require(script.DoubleBall),
	require(script.Clone),
	require(script.Shield),
	require(script.SuperCatch),
	require(script.SuperFastball),
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

-- 아무 능력 id를 하나 고른다. weights(id → 숫자)가 있으면 숫자가 큰 능력이 더 자주 나온다.
function Abilities.randomId(weights)
	local total = 0
	for _, ability in list do
		total += if weights then weights[ability.id] or 0 else 1
	end
	local roll = math.random() * total
	for _, ability in list do
		roll -= if weights then weights[ability.id] or 0 else 1
		if roll <= 0 then
			return ability.id
		end
	end
	return list[#list].id
end

return Abilities
