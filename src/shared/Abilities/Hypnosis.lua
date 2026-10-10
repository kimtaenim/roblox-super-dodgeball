-- 최면 : 공을 들고 있는 가장 가까운 NPC에게 최면을 건다.
-- 최면에 걸린 NPC는 "네… 공 드릴게요…" 하고 공을 나에게 살살 던져 주고, 공은 내 손에 들어온다.
-- (선물로 받는 것이라 NPC는 아웃되지 않는다. 아웃은 공으로만)

local Config = require(script.Parent.Parent.Config)
local C = Config.Abilities.Hypnosis

-- 공을 들고 있는 NPC 중 나와 가장 가까운 NPC를 찾는다.
local function findTarget(who, services)
	local myRoot = services.Participants.getRoot(who)
	if not myRoot then
		return nil
	end
	local best, bestDistance = nil, math.huge
	for _, other in services.Participants.all() do
		local root = services.Participants.getRoot(other)
		if other.isNpc and other ~= who and other.inRound and root and services.Balls.isHolding(other) then
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
	duration = C.FlySeconds, -- 공이 날아오는 동안
	cantUseText = "공을 든 NPC가 없거나, 내 손에 이미 공이 있어요", -- 못 쓸 때 보여 줄 말

	-- 사람만, 살아 있고, 내 손이 비어 있고, 공을 든 NPC가 있을 때만 쓸 수 있다.
	canUse = function(who, state, services)
		return not who.isNpc
			and state.status == "Alive"
			and not services.Balls.isHolding(who)
			and findTarget(who, services) ~= nil
	end,

	-- NPC가 보라색으로 빛나며 말하고, 공을 나에게 건넨다.
	activate = function(who, _state, services)
		local npc = findTarget(who, services)
		if not npc then
			return
		end
		if npc.character then
			local glow = Instance.new("Highlight")
			glow.Name = "HypnosisEffect"
			glow.FillColor = C.Color
			glow.OutlineColor = C.Color
			glow.Parent = npc.character
			task.delay(C.GlowSeconds, function()
				glow:Destroy()
			end)
		end
		services.Npcs.say(npc, C.Line)
		services.States.notify(npc, who.name .. " 님의 최면! 공을 줬어요")
		services.Balls.handOver(npc, who, C.FlySeconds, C.ArcHeight)
	end,
}
