-- 화면 표시 : 남은 시간, 살아남은 사람 수, 내 상태, 갖고 있는 능력, 파워 막대, 알림.
-- 투명 능력을 쓰면 내 화면에서는 내 몸이 반쯤 보이게 한다.
-- 서버가 적어 둔 속성(GameState, 내 Player)을 읽어서 보여주기만 한다.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Abilities = require(ReplicatedStorage.Shared.Abilities)

local player = Players.LocalPlayer
local gameState = ReplicatedStorage:WaitForChild("GameState")

local ABILITY_COLOR = Color3.fromRGB(80, 200, 255) -- 능력 칸 색
local POWER_COLOR = Color3.fromRGB(255, 120, 60) -- 파워 막대 색
local DARK = Color3.fromRGB(20, 20, 30) -- 배경 색
local WHITE = Color3.new(1, 1, 1)

-- 글자 칸을 하나 만든다.
local function makeLabel(parent, position, size, textSize)
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = textSize
	label.TextColor3 = WHITE
	label.TextStrokeTransparency = 0.4
	label.Text = ""
	label.Parent = parent
	return label
end

-- 막대(배경 + 채워지는 부분)를 하나 만든다.
local function makeBar(parent, position, size, color)
	local back = Instance.new("Frame")
	back.AnchorPoint = Vector2.new(0.5, 0.5)
	back.Position = position
	back.Size = size
	back.BackgroundColor3 = DARK
	back.BackgroundTransparency = 0.3
	back.BorderSizePixel = 0
	back.Parent = parent
	Instance.new("UICorner").Parent = back

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = back
	Instance.new("UICorner").Parent = fill
	return back, fill
end

-- 화면 틀
local gui = Instance.new("ScreenGui")
gui.Name = "HUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local topLabel = makeLabel(gui, UDim2.new(0.5, 0, 0, 50), UDim2.new(0.8, 0, 0, 40), 30)
local statusLabel = makeLabel(gui, UDim2.new(0.5, 0, 0, 95), UDim2.new(0.9, 0, 0, 30), 22)
local messageLabel = makeLabel(gui, UDim2.new(0.5, 0, 0.35, 0), UDim2.new(0.9, 0, 0, 50), 34)
local bigLabel = makeLabel(gui, UDim2.new(0.5, 0, 0.45, 0), UDim2.new(0.9, 0, 0, 90), 72)
local warningLabel = makeLabel(gui, UDim2.new(0.5, 0, 0.55, 0), UDim2.new(0.9, 0, 0, 40), 30)
warningLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
local tutorialLabel = makeLabel(gui, UDim2.new(0.5, 0, 1, -150), UDim2.new(0.9, 0, 0, 36), 26)
tutorialLabel.TextColor3 = Color3.fromRGB(255, 230, 120)

-- 능력 칸 : 화면 아래에 가로로 늘어선 버튼. 누르면(또는 숫자 키) 그 능력을 쓴다.
local H = Config.Hud
local slotRow = Instance.new("Frame")
slotRow.AnchorPoint = Vector2.new(0.5, 1)
slotRow.Position = UDim2.new(0.5, 0, 1, -H.AbilitySlotGap * 2)
slotRow.Size = UDim2.new(1, 0, 0, H.AbilitySlotHeight)
slotRow.BackgroundTransparency = 1
slotRow.Parent = gui
local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rowLayout.Padding = UDim.new(0, H.AbilitySlotGap)
rowLayout.Parent = slotRow

local abilityRemote = Remotes.get("UseAbility")
local slotButtons = {}
for slot = 1, Config.AbilityBox.MaxSlots do
	local button = Instance.new("TextButton")
	button.LayoutOrder = slot
	button.Size = UDim2.fromOffset(H.AbilitySlotWidth, H.AbilitySlotHeight)
	button.BackgroundColor3 = ABILITY_COLOR
	button.BackgroundTransparency = 0.15
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.TextColor3 = DARK
	button.Visible = false
	button.Parent = slotRow
	Instance.new("UICorner").Parent = button
	button.Activated:Connect(function()
		abilityRemote:FireServer(slot)
	end)
	slotButtons[slot] = button
end
local powerBack, powerFill = makeBar(gui, UDim2.new(0.5, 0, 1, -100), UDim2.new(0, 200, 0, 14), POWER_COLOR)

local messageHideAt = 0 -- 알림 글자를 지울 시각

-- 초를 "분:초" 글자로 바꾼다.
local function formatTime(seconds)
	local whole = math.ceil(seconds)
	return string.format("%d:%02d", whole // 60, whole % 60)
end

-- 맨 위 글자 : 지금 단계에 맞는 안내.
local function updateTop(phaseName, remaining)
	bigLabel.Text = ""
	if phaseName == "Lobby" then
		topLabel.Text = "곧 시작해요! " .. math.ceil(remaining) .. "초"
	elseif phaseName == "Countdown" then
		local hush = if gameState:GetAttribute("ArenaQuiet") then "쉿! " else "준비! "
		topLabel.Text = hush .. "이번 경기장은 " .. (gameState:GetAttribute("ArenaName") or "")
		bigLabel.Text = tostring(math.max(1, math.ceil(remaining)))
	elseif phaseName == "Demo" then
		topLabel.Text = "잘 봐요!"
	elseif phaseName == "Playing" then
		local alive = gameState:GetAttribute("AliveCount") or 0
		topLabel.Text = "남은 시간 " .. formatTime(remaining) .. "   살아남은 사람 " .. alive .. "명"
	elseif phaseName == "Result" then
		local winner = gameState:GetAttribute("Winner") or ""
		topLabel.Text = "다음 판을 준비해요"
		bigLabel.Text = if winner ~= "" then winner .. " 승리!" else "무승부!"
	else
		topLabel.Text = ""
	end
end

-- 내 상태 글자 : 앉았는지, 구경 중인지.
local function updateStatus(phaseName)
	local status = player:GetAttribute("Status")
	local inRound = player:GetAttribute("InRound")
	local kills = player:GetAttribute("Kills") or 0
	if phaseName == "Playing" and not inRound then
		statusLabel.Text = "구경 중이에요. 다음 판부터 같이 해요!"
	elseif status == "Sitting" then
		statusLabel.Text = "앉았어요! 날아오는 공을 캐치(F / 오른쪽 클릭)하면 부활!"
	elseif inRound then
		statusLabel.Text = "아웃시킨 수 " .. kills
	else
		statusLabel.Text = ""
	end
end

-- 내가 갖고 있는 능력 id 목록을 읽는다 (서버가 "superwings,slow"처럼 적어 둔다).
local function myAbilityIds()
	local text = player:GetAttribute("Abilities") or ""
	if text == "" then
		return {}
	end
	return string.split(text, ",")
end

-- 능력 칸 : 갖고 있는 능력마다 "번호 이름" 버튼을 보여준다.
local function updateAbilities()
	local ids = myAbilityIds()
	for slot, button in slotButtons do
		local ability = Abilities.get(ids[slot])
		button.Visible = ability ~= nil
		if ability then
			button.Text = slot .. " " .. ability.name
		end
	end
end

-- 투명 중에는 내 화면에서만 내 몸을 반쯤 보이게 한다 (다른 사람 화면에는 거의 안 보인다).
local function updateSelfVisibility()
	local character = player.Character
	if not character or not player:GetAttribute("Invisible") then
		return
	end
	local half = Config.Abilities.Invisible.SelfTransparency
	for _, part in character:GetDescendants() do
		local seeThrough = (part:IsA("BasePart") or part:IsA("Decal")) and part.Transparency > half
		if seeThrough and part.Transparency < 1 then
			part.Transparency = half -- 이 바꿈은 내 화면에만 보인다
		end
	end
end

-- 파워 막대 : 던지기 버튼을 누르고 있는 동안 차오른다.
local function updatePower(now)
	local chargeStart = player:GetAttribute("ChargeStart")
	powerBack.Visible = chargeStart ~= nil
	if chargeStart then
		local hold = math.clamp(now - chargeStart, Config.Throw.MinHold, Config.Throw.MaxHold)
		powerFill.Size = UDim2.fromScale(hold / Config.Throw.MaxHold, 1)
	end
end

-- 코트 밖 경고 : 몇 초 안에 돌아가야 하는지.
local function updateWarning(serverNow)
	local deadline = player:GetAttribute("OutsideDeadline")
	if deadline then
		warningLabel.Text = "코트 밖이에요! " .. math.max(0, math.ceil(deadline - serverNow)) .. "초 안에 돌아가요"
	else
		warningLabel.Text = ""
	end
end

-- 튜토리얼 안내 : 지금 내 상황에 맞는 다음 할 일을 한 줄로 알려준다.
local function updateTutorial(phaseName)
	if not gameState:GetAttribute("Tutorial") or not player:GetAttribute("InRound") then
		tutorialLabel.Text = ""
		return
	end
	if phaseName == "Countdown" then
		tutorialLabel.Text = "연습 판이에요! 친구 2명과 피구를 배워 봐요"
	elseif phaseName == "Demo" then
		tutorialLabel.Text = "날아오는 공을 잡으면, 던진 사람이 아웃돼요"
	elseif phaseName ~= "Playing" then
		tutorialLabel.Text = ""
	elseif player:GetAttribute("Status") == "Sitting" then
		tutorialLabel.Text = "공이 날아올 때 F(오른쪽 클릭)를 누르면 잡고 다시 일어나요"
	elseif player:GetAttribute("HoldingBall") then
		tutorialLabel.Text = "친구를 마우스로 가리키고, 왼쪽 클릭을 꾹 눌렀다 떼면 던져요"
	elseif #myAbilityIds() > 0 then
		tutorialLabel.Text = "빨간 공 가까이 가면 저절로 주워요. 아래 능력 칸(숫자 키)도 눌러 봐요"
	else
		tutorialLabel.Text = "빨간 공 가까이 걸어가면 저절로 주워요"
	end
end

-- 서버가 보낸 알림 글자를 잠깐 띄운다.
Remotes.get("Notify").OnClientEvent:Connect(function(text)
	messageLabel.Text = text
	messageHideAt = os.clock() + Config.Hud.MessageSeconds
end)

-- 매 프레임 화면을 새로 그린다.
RunService.RenderStepped:Connect(function()
	local now = os.clock()
	local serverNow = workspace:GetServerTimeNow()
	local phaseName = gameState:GetAttribute("Phase")
	local remaining = math.max(0, (gameState:GetAttribute("PhaseEndsAt") or serverNow) - serverNow)

	updateTop(phaseName, remaining)
	updateStatus(phaseName)
	updateAbilities()
	updateSelfVisibility()
	updatePower(now)
	updateWarning(serverNow)
	updateTutorial(phaseName)
	if now >= messageHideAt then
		messageLabel.Text = ""
	end
end)
