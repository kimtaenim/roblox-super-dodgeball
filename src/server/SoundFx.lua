-- 소리 신호 : 서버는 "이 소리를 여기서 내!"라는 신호만 보내고, 실제 소리는 각자 화면(SoundPlayer.client.lua)이 튼다.
-- (로블록스 서버는 소리를 불러오지 않아서, 소리는 화면 쪽에서 트는 게 확실하다)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local SoundFx = {}

local soundRemote = Remotes.get("Sound")

-- 그 자리에서 들리는 효과음 (공·사람 몸 위치).
function SoundFx.playAt(name, part)
	if part and part.Parent then
		soundRemote:FireAllClients(name, part.Position)
	end
end

-- 모두에게 똑같이 들리는 효과음 (카운트다운, 승리).
function SoundFx.playGlobal(name)
	soundRemote:FireAllClients(name, nil)
end

return SoundFx
