-- 방패 : 5초 동안 몸 둘레에 푸른 공 모양 방패가 생기고, 맞아도 아웃되지 않고 공은 튕겨 나간다.
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

	-- 방패 시간을 적고, 몸 둘레에 눈에 잘 보이는 푸른 방패 공을 씌운다.
	activate = function(who, state, services)
		state.shieldUntil = os.clock() + C.Seconds
		local root = services.Participants.getRoot(who)
		if not root then
			return
		end
		local bubble = Instance.new("Part")
		bubble.Name = "ShieldEffect"
		bubble.Shape = Enum.PartType.Ball
		bubble.Size = Vector3.one * C.BubbleSize
		bubble.Color = C.BubbleColor
		bubble.Material = Enum.Material.ForceField
		bubble.Transparency = C.BubbleTransparency
		bubble.CanCollide = false
		bubble.CanQuery = false -- 공 판정에는 안 걸린다 (판정은 몸으로)
		bubble.CanTouch = false
		bubble.Massless = true
		bubble.CastShadow = false
		bubble.CFrame = root.CFrame
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = bubble
		weld.Parent = bubble
		bubble.Parent = who.character
		task.delay(C.Seconds, function()
			bubble:Destroy()
		end)
	end,
}
