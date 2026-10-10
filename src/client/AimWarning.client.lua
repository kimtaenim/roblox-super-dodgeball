-- 노림 경고 : NPC가 공을 들고 나를 노리면 내 화면에만 알려준다 (그래야 피하거나 캐치를 준비한다).
-- NPC 머리 위 빨간 ❗, NPC 몸 둘레 빨간 테두리, 화면 위쪽 "⚠ 빨강이 나를 노려요!" 글자, 경고음 한 번.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local W = Config.AimWarning
local player = Players.LocalPlayer

-- 화면 위쪽 경고 글자
local gui = Instance.new("ScreenGui")
gui.Name = "AimWarning"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")
local warningText = Instance.new("TextLabel")
warningText.AnchorPoint = Vector2.new(0.5, 0)
warningText.Position = UDim2.new(0.5, 0, 0, 130)
warningText.Size = UDim2.new(0.9, 0, 0, 40)
warningText.BackgroundTransparency = 1
warningText.Font = Enum.Font.GothamBlack
warningText.TextSize = W.TextSize
warningText.TextColor3 = W.TextColor
warningText.TextStrokeTransparency = 0.3
warningText.Text = ""
warningText.Parent = gui

local warnSound = Instance.new("Sound")
warnSound.SoundId = W.SoundId
warnSound.Volume = W.SoundVolume
warnSound.PlaybackSpeed = W.SoundPitch
warnSound.Parent = SoundService

local marked = {} -- 지금 경고를 띄운 NPC 몸 → 붙인 표시들

-- NPC에게 ❗와 빨간 테두리를 붙인다 (내 화면에만 보인다).
local function addMarks(model)
	local head = model:FindFirstChild("Head")
	local mark = Instance.new("BillboardGui")
	mark.Size = UDim2.fromOffset(W.MarkSize, W.MarkSize)
	mark.StudsOffset = Vector3.new(0, W.MarkHeight, 0)
	mark.AlwaysOnTop = true
	mark.Adornee = head
	mark.Parent = gui
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = W.MarkColor
	label.Text = W.Mark
	label.Parent = mark

	local outline = Instance.new("Highlight")
	outline.FillTransparency = 1
	outline.OutlineColor = W.OutlineColor
	outline.Adornee = model
	outline.Parent = gui
	return { mark, outline }
end

-- 이 NPC가 나를 노리는지.
local function aimsAtMe(model)
	return model.Parent ~= nil and model:GetAttribute("AimingAt") == player.UserId
end

-- 매 프레임 : 나를 노리는 NPC마다 표시를 붙이고, 그만 노리면 뗀다.
RunService.RenderStepped:Connect(function()
	local npcs = workspace:FindFirstChild("Npcs")
	local names = {}
	if npcs then
		for _, model in npcs:GetChildren() do
			if aimsAtMe(model) then
				table.insert(names, model.Name)
				if not marked[model] then
					marked[model] = addMarks(model)
					warnSound:Play() -- 새로 노리기 시작할 때 한 번
				end
			end
		end
	end
	for model, marks in marked do
		if not aimsAtMe(model) then
			for _, thing in marks do
				thing:Destroy()
			end
			marked[model] = nil
		end
	end
	warningText.Text = if #names > 0 then "⚠ " .. table.concat(names, ", ") .. " 나를 노려요!" else ""
end)
