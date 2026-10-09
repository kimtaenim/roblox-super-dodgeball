-- 텔레포트 : 바라보는 방향으로 순간이동한다 (코트 밖이면 경계에서 멈춘다).

local Config = require(script.Parent.Parent.Config)
local C = Config.Abilities.Teleport

return {
	id = "teleport",
	name = "텔레포트",

	-- 살아 있을 때만 쓸 수 있다.
	canUse = function(_who, state)
		return state.status == "Alive"
	end,

	-- 보는 방향으로 몸을 옮긴다.
	activate = function(who, _state, services)
		local root = services.Participants.getRoot(who)
		if not root then
			return
		end
		local look = root.CFrame.LookVector
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude < 1e-3 then
			return
		end
		local target = services.Court.clampInside(root.Position + flat.Unit * C.Distance, C.EdgeMargin)
		root.CFrame = CFrame.new(target) * root.CFrame.Rotation
	end,
}
