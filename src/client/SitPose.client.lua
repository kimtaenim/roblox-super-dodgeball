-- 아웃돼서 앉아 있어야 할 때 내 캐릭터를 확실히 앉힌다 (설계서 1.2장).
-- 내 몸은 내 컴퓨터가 움직이므로, 서버가 앉으라고 해도 몸이 일어서 버릴 수 있다.
-- 그래서 서버가 적어 둔 내 상태(Status)를 보고 여기서 앉는 동작을 직접 튼다.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local humanoid = nil -- 지금 내 캐릭터의 Humanoid
local sitTrack = nil -- 앉는 동작

-- 새 캐릭터가 생기면 앉는 동작을 준비한다.
local function onCharacter(character)
	humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	local animation = Instance.new("Animation")
	animation.AnimationId = Config.Animation.Sit
	sitTrack = animator:LoadAnimation(animation)
	sitTrack.Looped = true
	sitTrack.Priority = Enum.AnimationPriority.Action -- 걷기·서 있기 동작보다 앞선다
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then
	task.spawn(onCharacter, player.Character)
end

-- 매 프레임 : 아웃 상태면 앉히고, 살아 있으면 일으킨다.
RunService.Heartbeat:Connect(function()
	if not humanoid or not sitTrack or not humanoid.Parent then
		return
	end
	if player:GetAttribute("Status") == "Sitting" then
		if not humanoid.Sit then
			humanoid.Sit = true
		end
		if not sitTrack.IsPlaying then
			sitTrack:Play(Config.Animation.FadeSeconds)
		end
	else
		if sitTrack.IsPlaying then
			sitTrack:Stop(Config.Animation.FadeSeconds)
		end
		if humanoid.Sit and not humanoid.SeatPart then
			humanoid.Sit = false -- 의자 없이 앉아 있던 거면 일어난다
		end
	end
end)
