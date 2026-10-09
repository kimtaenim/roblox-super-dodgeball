-- 분신술 : 내 모습의 분신 3개가 5초 동안 돌아다닌다. 공에 맞으면 펑 터진다.
-- (터지는 판정은 BallService가 한다. 분신은 참가자가 아니라서 아웃되지 않는다)

local Config = require(script.Parent.Parent.Config)
local C = Config.Abilities.Clone

-- 분신 하나를 5초 동안 이리저리 걷게 하고, 시간이 끝나면 없앤다.
local function wander(decoy, services)
	local humanoid = decoy:FindFirstChildOfClass("Humanoid")
	local root = decoy:FindFirstChild("HumanoidRootPart")
	local endTime = os.clock() + C.Seconds
	while decoy.Parent and os.clock() < endTime do
		local angle = math.random() * math.pi * 2
		local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * C.WanderRadius
		humanoid:MoveTo(services.Court.clampInside(root.Position + offset, C.EdgeMargin))
		task.wait(C.WanderInterval)
	end
	if decoy.Parent then
		decoy:Destroy()
	end
end

return {
	id = "clone",
	name = "분신술",

	-- 살아 있을 때만 쓸 수 있다.
	canUse = function(_who, state)
		return state.status == "Alive"
	end,

	-- 내 몸을 복사해서 분신을 만든다.
	activate = function(who, _state, services)
		local character = who.character
		if not character then
			return
		end
		local wasArchivable = character.Archivable
		character.Archivable = true -- 이게 켜져 있어야 복사할 수 있다

		for _ = 1, C.Count do
			local decoy = character:Clone()
			-- 복사본 안의 스크립트·방어막은 지운다
			for _, child in decoy:GetDescendants() do
				if child:IsA("LuaSourceContainer") or child:IsA("ForceField") then
					child:Destroy()
				end
			end
			decoy.Parent = services.Balls.getDecoyFolder()
			local root = decoy:FindFirstChild("HumanoidRootPart")
			if root then
				root:SetNetworkOwner(nil)
				services.Npcs.setupAnimation(decoy)
				task.spawn(wander, decoy, services)
			else
				decoy:Destroy()
			end
		end

		character.Archivable = wasArchivable
	end,
}
