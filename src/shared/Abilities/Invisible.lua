-- 투명 : 4초 동안 몸이 거의 안 보인다 (손에 든 공은 보인다).

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

		local saved = {} -- 원래 투명도를 기억해 둔다
		for _, part in character:GetDescendants() do
			local isBody = part:IsA("BasePart") and part.Name ~= "HumanoidRootPart"
			if isBody or part:IsA("Decal") then
				saved[part] = part.Transparency
				part.Transparency = C.Transparency
			end
		end
		-- 이름표도 숨긴다
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
		end)
	end,
}
