-- 투명 : 4초 동안 몸이 거의 안 보인다 (손에 든 공은 보인다). NPC도 못 보고 안 노린다.
-- 내 화면에서는 내 몸이 반쯤 보인다 (HUD가 Invisible 속성을 보고 바꾼다).

local Config = require(script.Parent.Parent.Config)
local C = Config.Abilities.Invisible

return {
	id = "invisible",
	name = "투명",

	-- 살아 있을 때만 쓸 수 있다.
	canUse = function(_who, state)
		return state.status == "Alive"
	end,

	-- 몸과 얼굴을 투명하게 하고, 시간이 지나면 되돌린다.
	activate = function(who, state, services)
		local character = who.character
		if not character then
			return
		end
		state.invisibleUntil = os.clock() + C.Seconds
		services.Participants.setAttribute(who, "Invisible", true)

		local saved = {} -- 원래 투명도를 기억해 둔다
		for _, part in character:GetDescendants() do
			-- 원래 안 보이던 부품(NPC의 숨은 R15 몸 등)은 건드리지 않는다
			local isBody = part:IsA("BasePart") and part.Transparency < 1
			if isBody or part:IsA("Decal") then
				saved[part] = part.Transparency
				part.Transparency = C.Transparency
			end
		end
		-- 이름표도 숨긴다 (NPC 이름표는 BillboardGui)
		local tags = {}
		for _, gui in character:GetDescendants() do
			if gui:IsA("BillboardGui") and gui.Enabled then
				gui.Enabled = false
				table.insert(tags, gui)
			end
		end
		local humanoid = services.Participants.getHumanoid(who)
		local oldNameDisplay = humanoid and humanoid.DisplayDistanceType
		if humanoid then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end

		task.delay(C.Seconds, function()
			for part, transparency in saved do
				if part.Parent then
					part.Transparency = transparency
				end
			end
			if humanoid and humanoid.Parent then
				humanoid.DisplayDistanceType = oldNameDisplay
			end
			for _, gui in tags do
				gui.Enabled = true
			end
			services.Participants.setAttribute(who, "Invisible", nil)
		end)
	end,
}
