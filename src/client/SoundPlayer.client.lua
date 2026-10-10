-- 소리를 내 컴퓨터에서 튼다 : 서버가 보낸 효과음 신호와, 판 도중 배경 음악.
-- 효과음은 로블록스 기본 소리, 배경 음악은 Config.Sounds.MusicIds의 곡을 차례로 불러와 보고 되는 곡을 쓴다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local S = Config.Sounds
local gameState = ReplicatedStorage:WaitForChild("GameState")

-- 효과음 하나를 만든다.
local function makeEffect(name, parent)
	local info = S.Effects[name]
	local sound = Instance.new("Sound")
	sound.SoundId = info.id
	sound.Volume = info.volume
	sound.PlaybackSpeed = info.pitch or 1
	sound.RollOffMaxDistance = S.HearDistance
	sound.Parent = parent
	return sound
end

-- 서버가 보낸 효과음 신호 : 위치가 있으면 그 자리에서, 없으면 모두에게 똑같이.
Remotes.get("Sound").OnClientEvent:Connect(function(name, position)
	if not S.Effects[name] then
		return
	end
	if position then
		local spot = Instance.new("Attachment") -- 그 자리에 소리를 붙일 점
		spot.WorldPosition = position
		spot.Parent = workspace.Terrain
		local sound = makeEffect(name, spot)
		sound:Play()
		Debris:AddItem(spot, S.EffectLifetime)
	else
		local sound = makeEffect(name, SoundService)
		sound:Play()
		Debris:AddItem(sound, S.EffectLifetime)
	end
end)

-- 배경 음악 : 목록의 곡을 차례로 불러와 보고, 처음으로 불러와지는 곡을 쓴다.
local music = Instance.new("Sound")
music.Name = "Music"
music.Looped = true
music.Volume = S.MusicVolume
music.PlaybackSpeed = S.MusicSpeed
music.Parent = SoundService
local musicReady = false

-- 배경 음악 곡을 고른다.
local function loadMusic()
	for _, id in S.MusicIds do
		music.SoundId = id
		pcall(ContentProvider.PreloadAsync, ContentProvider, { music })
		if music.IsLoaded and music.TimeLength > 0 then
			musicReady = true
			return
		end
		warn("배경 음악을 불러오지 못했어요: " .. id)
	end
end

-- 판 도중(Playing)에만 배경 음악을 튼다.
local function updateMusic()
	if not musicReady then
		return
	end
	local playing = gameState:GetAttribute("Phase") == "Playing"
	if playing and not music.IsPlaying then
		music.TimePosition = 0
		music:Play()
	elseif not playing and music.IsPlaying then
		music:Stop()
	end
end

task.spawn(function()
	loadMusic()
	updateMusic()
end)
gameState:GetAttributeChangedSignal("Phase"):Connect(updateMusic)
