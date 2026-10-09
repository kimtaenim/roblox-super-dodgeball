-- 슈퍼날개 : 6초 동안 등에 날개가 생기고 코트 위로 떠올라 날아다닌다. 시간이 끝나면 내려온다.
-- 높이만 붙잡아 두고 앞뒤옆 움직임은 평소처럼 조작한다. 날다가 아웃되면 바로 떨어져 앉는다.

local RunService = game:GetService("RunService")

local Config = require(script.Parent.Parent.Config)
local C = Config.Abilities.SuperWings

-- 등에 날개 두 개를 붙인다 (공 판정에는 안 걸리게).
local function addWings(root, folder)
	for _, side in { -1, 1 } do
		local wing = Instance.new("Part")
		wing.Name = "Wing"
		wing.Size = C.WingSize
		wing.Color = C.WingColor
		wing.Material = Enum.Material.Neon
		wing.CanCollide = false
		wing.CanQuery = false
		wing.CanTouch = false
		wing.Massless = true
		local offset = Vector3.new(side * C.WingOffset.X, C.WingOffset.Y, C.WingOffset.Z)
		wing.CFrame = root.CFrame * CFrame.new(offset) * CFrame.Angles(0, 0, side * math.rad(C.WingTiltDegrees))
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = wing
		weld.Parent = wing
		wing.Parent = folder
	end
end

return {
	id = "superwings",
	name = "슈퍼날개",

	-- 살아 있을 때만 쓸 수 있다.
	canUse = function(_who, state)
		return state.status == "Alive"
	end,

	-- 날개를 달고, 정해진 시간 동안 몸을 코트 위 높이에 띄워 둔다.
	activate = function(who, state, services)
		local root = services.Participants.getRoot(who)
		if not root then
			return
		end
		local folder = Instance.new("Folder")
		folder.Name = "SuperWingsEffect"
		folder.Parent = who.character
		local attachment = Instance.new("Attachment")
		attachment.Name = "SuperWingsAttachment"
		attachment.Parent = root

		-- 높이(Y)만 붙잡는 힘
		local hold = Instance.new("AlignPosition")
		hold.Mode = Enum.PositionAlignmentMode.OneAttachment
		hold.Attachment0 = attachment
		hold.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		hold.MaxAxesForce = Vector3.new(0, math.huge, 0)
		hold.Responsiveness = C.Responsiveness
		hold.Position = root.Position
		hold.Parent = folder
		addWings(root, folder)

		task.spawn(function()
			local flyY = Config.Court.Center.Y + C.Height
			local endTime = os.clock() + C.Seconds
			-- 시간이 끝나거나, 아웃되거나, 판이 바뀌면(state가 새로 만들어지면) 내려온다
			while os.clock() < endTime and folder.Parent and root.Parent and who.state == state and state.status == "Alive" do
				hold.Position = Vector3.new(root.Position.X, flyY, root.Position.Z)
				RunService.Heartbeat:Wait()
			end
			folder:Destroy()
			attachment:Destroy()
		end)
	end,
}
