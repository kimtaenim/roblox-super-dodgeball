-- 키보드·마우스·터치 입력을 받아 서버에 보낸다. 판정은 서버가 한다 (설계서 3장).
--   던지기 : 마우스 왼쪽 꾹 누르기 (모바일 : 던지기 버튼)
--   캐치   : F 또는 마우스 오른쪽 (모바일 : 캐치 버튼)
--   능력   : Q (모바일 : 능력 버튼)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local throwRemote = Remotes.get("Throw")
local catchRemote = Remotes.get("Catch")
local abilityRemote = Remotes.get("UseAbility")

local pressStartTime = nil -- 던지기 버튼을 누르기 시작한 시각

-- 카메라에서 마우스 커서 쪽으로 쏜 선이 닿는 곳(조준점)을 구한다.
local function getMouseAimPoint()
	local camera = workspace.CurrentCamera
	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * Config.Throw.AimDistance, params)
	if result then
		return result.Position
	end
	return ray.Origin + ray.Direction * Config.Throw.AimDistance
end

-- 모바일 조준점 : 캐릭터가 바라보는 쪽 앞.
local function getFacingAimPoint()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	return root.Position + root.CFrame.LookVector * Config.Throw.TouchAimDistance
end

-- 던지기 : 누르면 시간 재기 시작, 떼면 누른 시간과 조준점을 서버에 보낸다.
local function onThrow(_actionName, inputState, input)
	if inputState == Enum.UserInputState.Begin then
		pressStartTime = os.clock()
		player:SetAttribute("ChargeStart", pressStartTime) -- 화면 파워 막대용 (내 화면에만)
	elseif inputState == Enum.UserInputState.End and pressStartTime then
		local holdSeconds = os.clock() - pressStartTime
		pressStartTime = nil
		player:SetAttribute("ChargeStart", nil)
		local aimPoint
		if input.UserInputType == Enum.UserInputType.Touch then
			aimPoint = getFacingAimPoint()
		else
			aimPoint = getMouseAimPoint()
		end
		if aimPoint then
			throwRemote:FireServer(aimPoint, holdSeconds)
		end
	end
	return Enum.ContextActionResult.Sink
end

-- 캐치 : 누르는 순간 서버에 알린다. (오른쪽 버튼은 카메라 돌리기에도 쓰이게 넘겨준다)
local function onCatch(_actionName, inputState, _input)
	if inputState == Enum.UserInputState.Begin then
		catchRemote:FireServer()
	end
	return Enum.ContextActionResult.Pass
end

-- 능력 : 누르는 순간 서버에 알린다.
local function onAbility(_actionName, inputState, _input)
	if inputState == Enum.UserInputState.Begin then
		abilityRemote:FireServer()
	end
	return Enum.ContextActionResult.Sink
end

-- 입력을 연결한다. 세 번째 값 true = 모바일 화면 버튼도 만든다.
ContextActionService:BindAction("Throw", onThrow, true, Enum.UserInputType.MouseButton1)
ContextActionService:BindAction("Catch", onCatch, true, Enum.KeyCode.F, Enum.UserInputType.MouseButton2)
ContextActionService:BindAction("Ability", onAbility, true, Enum.KeyCode.Q)
ContextActionService:SetTitle("Throw", "던지기")
ContextActionService:SetTitle("Catch", "캐치")
ContextActionService:SetTitle("Ability", "능력")
