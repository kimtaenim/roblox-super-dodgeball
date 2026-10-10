-- 복수 대상 : 같은 상대에게 짧은 시간에 여러 번 맞아 아웃되면, 그 상대 머리 위에 "복수 대상!"이 뜬다.
-- 표시는 당한 사람 화면에만 보인다. 그 상대를 아웃시키면 보너스 능력을 하나 받는다.
-- (한 사람만 계속 노림당하는 억울함을 재미로 바꾸려는 규칙. 사람만 복수 대상을 갖는다)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local PlayerStateService = require(script.Parent.PlayerStateService)

local V = Config.Revenge

local RevengeService = {}

local outTimes = {} -- 당한 사람 → { 때린 사람 → 아웃된 시각 목록 }
local marks = {} -- 당한 사람 → { 복수 대상 → 머리 위 표시(BillboardGui) }

-- 이름 뒤에 받침에 맞는 조사(이/가)를 붙인다.
local function subject(name)
	local code = utf8.codepoint(name, utf8.offset(name, -1))
	local hasFinal = code >= 0xAC00 and code <= 0xD7A3 and (code - 0xAC00) % 28 ~= 0
	return name .. (if hasFinal then "이" else "가")
end

-- 당한 사람 화면에만 보이게, 복수 대상 머리 위에 표시를 단다.
local function addMark(victim, target)
	local head = target.character and target.character:FindFirstChild("Head")
	if not head then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "RevengeMark"
	gui.Adornee = head
	gui.Size = UDim2.fromOffset(V.MarkWidth, V.MarkTextSize * 2)
	gui.StudsOffset = Vector3.new(0, V.MarkHeight, 0)
	gui.AlwaysOnTop = true
	gui.ResetOnSpawn = false
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextSize = V.MarkTextSize
	label.TextColor3 = V.MarkColor
	label.TextStrokeTransparency = 0
	label.Text = V.MarkText
	label.Parent = gui
	gui.Parent = victim.player:FindFirstChildOfClass("PlayerGui") -- PlayerGui 안이라 그 사람 화면에만 보인다

	marks[victim] = marks[victim] or {}
	marks[victim][target] = gui
end

-- 최근 몇 초 안에 by에게 맞아 아웃된 횟수를 센다 (오래된 기록은 지운다).
local function recordOut(victim, by)
	outTimes[victim] = outTimes[victim] or {}
	local list = outTimes[victim][by] or {}
	outTimes[victim][by] = list
	local now = os.clock()
	table.insert(list, now)
	while list[1] and list[1] < now - V.WindowSeconds do
		table.remove(list, 1)
	end
	return #list
end

-- 복수 성공 : 표시를 없애고 보너스 능력을 준다 (능력 칸이 꽉 차 있으면 칭찬만).
local function revengeDone(avenger, target)
	marks[avenger][target]:Destroy()
	marks[avenger][target] = nil
	if outTimes[avenger] then
		outTimes[avenger][target] = nil
	end
	local abilities = avenger.state.abilities
	if #abilities < Config.AbilityBox.MaxSlots then
		local id = Abilities.randomId(Config.AbilityBox.Weights)
		table.insert(abilities, id)
		PlayerStateService.notify(avenger, "복수 성공! 보너스 능력: " .. Abilities.get(id).name)
	else
		PlayerStateService.notify(avenger, "복수 성공!")
	end
	PlayerStateService.sync(avenger)
end

-- 누가 아웃될 때마다 불린다 : 복수 성공인지, 새 복수 대상이 생겼는지 본다.
local function onKnockOut(victim, by, how)
	if not by or by == victim then
		return
	end
	-- 내 복수 대상을 내가 아웃시켰다
	if marks[by] and marks[by][victim] then
		revengeDone(by, victim)
	end
	-- 맞아서 아웃된 사람만 센다 (사람만 복수 대상을 갖는다)
	if how ~= "hit" or not victim.player then
		return
	end
	local alreadyMarked = marks[victim] and marks[victim][by]
	if not alreadyMarked and recordOut(victim, by) >= V.OutsToMark then
		addMark(victim, by)
		PlayerStateService.notify(victim, "😠 " .. subject(by.name) .. " 또 나를 아웃시켰어요! 복수 대상!")
	end
end

-- 판이 끝나면 기록과 표시를 모두 지운다.
function RevengeService.reset()
	for _, list in marks do
		for _, gui in list do
			gui:Destroy()
		end
	end
	marks = {}
	outTimes = {}
end

-- 아웃 소식을 받도록 연결한다.
function RevengeService.start()
	PlayerStateService.addKnockOutListener(onKnockOut)
end

return RevengeService
