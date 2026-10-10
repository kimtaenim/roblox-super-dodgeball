-- 소리 : 던지기, 맞기(oof!), 캐치, 능력, 상자, 카운트다운, 승리 효과음과 판 도중 배경 음악.
-- 효과음은 로블록스에 기본으로 들어 있는 소리(rbxasset://)를 쓴다. 숫자와 소리 주소는 Config.Sounds에 있다.

local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local S = Config.Sounds

local SoundFx = {}

local music -- 배경 음악 소리
local musicReady = false -- 배경 음악을 불러왔는지

-- 소리 하나를 만든다.
local function make(name, parent)
	local info = S.Effects[name]
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = info.id
	sound.Volume = info.volume
	sound.PlaybackSpeed = info.pitch or 1
	sound.RollOffMaxDistance = S.HearDistance
	sound.Parent = parent
	return sound
end

-- 그 자리에서 들리는 효과음 (공·사람 몸에서 난다).
function SoundFx.playAt(name, part)
	if not part or not part.Parent or not S.Effects[name] then
		return
	end
	local sound = make(name, part)
	sound:Play()
	Debris:AddItem(sound, S.EffectLifetime)
end

-- 모두에게 똑같이 들리는 효과음 (카운트다운, 승리).
function SoundFx.playGlobal(name)
	if not S.Effects[name] then
		return
	end
	local sound = make(name, workspace)
	sound:Play()
	Debris:AddItem(sound, S.EffectLifetime)
end

-- 배경 음악을 불러온다 : 목록의 곡을 차례로 시도해서 처음 불러와지는 곡을 쓴다.
local function loadMusic()
	music = Instance.new("Sound")
	music.Name = "Music"
	music.Looped = true
	music.Volume = S.MusicVolume
	music.PlaybackSpeed = S.MusicSpeed
	music.Parent = workspace
	for _, id in S.MusicIds do
		music.SoundId = id
		pcall(ContentProvider.PreloadAsync, ContentProvider, { music })
		if music.TimeLength > 0 then
			musicReady = true
			return
		end
		warn("배경 음악을 불러오지 못했어요: " .. id)
	end
end

-- 배경 음악을 켜거나 끈다 (판 도중에만 켠다).
function SoundFx.setMusic(on)
	if not musicReady then
		return
	end
	if on and not music.IsPlaying then
		music.TimePosition = 0
		music:Play()
	elseif not on then
		music:Stop()
	end
end

-- 배경 음악을 미리 불러온다 (시간이 걸리니 따로 돌린다).
function SoundFx.start()
	task.spawn(loadMusic)
end

return SoundFx
