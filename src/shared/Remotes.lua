-- RemoteEvent(서버와 클라이언트가 주고받는 신호) 이름을 모아 둔다.
-- 서버가 만들고, 클라이언트는 만들어질 때까지 기다렸다가 쓴다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FOLDER_NAME = "Remotes"

local Remotes = {}

-- 신호 이름 목록
Remotes.Names = {
	Throw = "Throw", -- 클라이언트 → 서버 : 공 던지기 (조준점, 홀드 시간)
}

-- 이름으로 RemoteEvent를 찾는다. 서버에서는 없으면 새로 만든다.
function Remotes.get(name)
	assert(Remotes.Names[name], "Remotes.lua에 없는 이름: " .. tostring(name))

	if RunService:IsServer() then
		local folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = FOLDER_NAME
			folder.Parent = ReplicatedStorage
		end
		local remote = folder:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
		return remote
	end

	local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME)
	return folder:WaitForChild(name)
end

return Remotes
