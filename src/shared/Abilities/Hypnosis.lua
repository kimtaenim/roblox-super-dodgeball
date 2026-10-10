-- 최면 : 공을 들고 있는 가장 가까운 NPC에게 최면을 건다.
-- 최면에 걸린 NPC는 "네… 공 갖다 드릴게요…" 하고 걸어와서 내 앞에 공을 내려놓고 간다.
-- (NPC는 아웃되지 않는다. 아웃은 공으로만. 걷고 내려놓는 일은 NpcService가 한다)

-- 공을 들고 있는 NPC 중 나와 가장 가까운 NPC를 찾는다.
local function findTarget(who, services)
	local myRoot = services.Participants.getRoot(who)
	if not myRoot then
		return nil
	end
	local best, bestDistance = nil, math.huge
	for _, other in services.Participants.all() do
		local root = services.Participants.getRoot(other)
		local ready = other.isNpc and other ~= who and other.inRound and other.state.status == "Alive"
		if ready and root and services.Balls.isHolding(other) then
			local distance = (root.Position - myRoot.Position).Magnitude
			if distance < bestDistance then
				best, bestDistance = other, distance
			end
		end
	end
	return best
end

return {
	id = "hypnosis",
	name = "최면",
	duration = 0, -- 걸고 나면 바로 다른 능력도 쓸 수 있다
	cantUseText = "공을 든 NPC가 없어요", -- 못 쓸 때 보여 줄 말

	-- 사람만, 살아 있고, 공을 든 NPC가 있을 때만 쓸 수 있다.
	canUse = function(who, state, services)
		return not who.isNpc and state.status == "Alive" and findTarget(who, services) ~= nil
	end,

	-- 가장 가까운 공 든 NPC에게 최면을 건다.
	activate = function(who, _state, services)
		local npc = findTarget(who, services)
		if npc then
			services.Npcs.hypnotize(npc, who)
		end
	end,
}
