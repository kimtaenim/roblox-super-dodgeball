-- 키보드·마우스 입력을 받아 서버에 보낸다. 판정은 서버가 한다.
-- 지금은 던지기만 : 마우스 왼쪽을 꾹 누를수록 세게 던진다.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local throwRemote = Remotes.get("Throw")
local pressStartTime = nil -- 왼쪽 버튼을 누르기 시작한 시각

-- 카메라에서 마우스 커서 쪽으로 쏜 선이 닿는 곳(조준점)을 구한다.
local function getAimPoint()
	local camera = workspace.CurrentCamera
	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { Players.LocalPlayer.Character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * Config.Throw.AimDistance, params)
	if result then
		return result.Position
	end
	return ray.Origin + ray.Direction * Config.Throw.AimDistance
end

-- 왼쪽 버튼을 누르면 시간 재기를 시작한다.
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		pressStartTime = os.clock()
	end
end)

-- 왼쪽 버튼을 떼면 누른 시간과 조준점을 서버에 보낸다.
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and pressStartTime then
		local holdSeconds = os.clock() - pressStartTime
		pressStartTime = nil
		throwRemote:FireServer(getAimPoint(), holdSeconds)
	end
end)
