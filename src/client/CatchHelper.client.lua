-- 캐치 도우미 : 공이 나에게 날아오면 "지금 잡아!"를 띄우고,
-- 캐치 버튼을 누르면 잡을 수 있는 동안 "캐치 준비!"를 보여 준다 (내 화면에만).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local K = Config.Catch
local player = Players.LocalPlayer

-- 화면 가운데 아래쪽 큰 글자
local gui = Instance.new("ScreenGui")
gui.Name = "CatchHelper"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = UDim2.fromScale(0.5, K.TextHeight)
label.Size = UDim2.fromScale(1, 0.1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBlack
label.TextSize = K.TextSize
label.TextStrokeTransparency = 0
label.Visible = false
label.Parent = gui

-- 살아 있는 공 중 곧 나에게 닿을 공이 있는지 알려준다.
local function ballComing(root)
	local folder = workspace:FindFirstChild("Balls")
	if not folder then
		return false
	end
	for _, ball in folder:GetChildren() do
		if ball:IsA("BasePart") and ball:GetAttribute("Live") then
			local toMe = root.Position - ball.Position
			local distance = toMe.Magnitude
			local closing = ball.AssemblyLinearVelocity:Dot(toMe.Unit) -- 나에게 다가오는 빠르기
			if closing >= K.PromptMinSpeed and distance / closing <= K.PromptSeconds then
				return true
			end
		end
	end
	return false
end

-- 매 프레임 : 캐치 준비 중이면 초록 글자, 공이 오면 노란 글자, 아니면 숨긴다.
RunService.Heartbeat:Connect(function()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local pressedAt = player:GetAttribute("CatchPressedAt")
	if pressedAt and os.clock() - pressedAt <= K.Window then
		label.Text = K.ReadyText
		label.TextColor3 = K.ReadyColor
		label.Visible = true
	elseif root and player:GetAttribute("InRound") and ballComing(root) then
		label.Text = K.PromptText
		label.TextColor3 = K.PromptColor
		label.Visible = true
	else
		label.Visible = false
	end
end)
