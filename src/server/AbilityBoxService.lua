-- 능력 상자 : 판 도중 코트에 상자가 떨어지고, 주우면 능력 하나를 갖는다 (설계서 2.1장).
-- 능력은 한 번에 하나만 가질 수 있고, Q(모바일은 능력 버튼)로 쓰면 없어진다.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local Participants = require(script.Parent.Participants)
local CourtService = require(script.Parent.CourtService)
local PlayerStateService = require(script.Parent.PlayerStateService)

local X = Config.AbilityBox

local AbilityBoxService = {}

local folder -- 상자를 넣어 두는 폴더
local boxes = {} -- 코트 위의 상자 목록
local active = false -- 판이 진행 중일 때만 상자가 떨어진다
local nextSpawnAt = math.huge -- 다음 상자가 떨어지는 시각

-- 코트 안 아무 곳에 상자를 하나 떨어뜨린다.
local function spawnBox()
	local box = Instance.new("Part")
	box.Name = "AbilityBox"
	box.Size = Vector3.one * X.Size
	box.Color = X.Color
	box.Material = Enum.Material.Neon
	box.Anchored = true
	box.CanCollide = false
	box.CanQuery = false
	box.CanTouch = false
	box.CFrame = CFrame.new(CourtService.randomPointInside(X.SpawnRadiusRatio, X.Height))

	-- 상자 위에 "?" 표시
	local mark = Instance.new("BillboardGui")
	mark.Size = UDim2.fromScale(X.Size, X.Size)
	mark.AlwaysOnTop = false
	mark.Parent = box
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Text = "?"
	label.Parent = mark

	box.Parent = folder
	table.insert(boxes, box)
end

-- 상자를 모두 치운다.
local function clearBoxes()
	for _, box in boxes do
		box:Destroy()
	end
	boxes = {}
end

-- 참가자가 상자를 주울 수 있는지 알려준다 (판에 참가 중, 살아 있음, 능력을 안 갖고 있음).
local function canPickUp(p)
	return p.inRound and p.state.status == "Alive" and p.state.ability == nil
end

-- 상자를 주운 참가자에게 아무 능력이나 하나 준다.
local function giveAbility(p)
	p.state.ability = Abilities.randomId(X.Weights)
	local ability = Abilities.get(p.state.ability)
	PlayerStateService.notify(p, "능력 상자! " .. ability.name .. " (Q로 써요)")
	PlayerStateService.sync(p)
end

-- 매 프레임 : 상자를 돌리고, 줍기를 확인하고, 때가 되면 새 상자를 떨어뜨린다.
local function update(dt)
	local spin = CFrame.Angles(0, math.rad(X.SpinDegreesPerSecond) * dt, 0)
	for index = #boxes, 1, -1 do
		local box = boxes[index]
		box.CFrame *= spin
		for _, p in Participants.all() do
			local root = Participants.getRoot(p)
			if root and canPickUp(p) and (root.Position - box.Position).Magnitude <= X.PickupRadius then
				giveAbility(p)
				box:Destroy()
				table.remove(boxes, index)
				break
			end
		end
	end

	local now = os.clock()
	if active and now >= nextSpawnAt then
		nextSpawnAt = now + X.Interval
		if #boxes < X.MaxOnCourt then
			spawnBox()
		end
	end
end

-- 위치에서 가장 가까운 상자를 찾는다 (NPC가 쓴다).
function AbilityBoxService.nearestBox(position)
	local best, bestDistance = nil, math.huge
	for _, box in boxes do
		local distance = (box.Position - position).Magnitude
		if distance < bestDistance then
			best, bestDistance = box, distance
		end
	end
	return best
end

-- 판이 시작되면 상자를 떨어뜨리기 시작하고, 끝나면 모두 치운다.
function AbilityBoxService.setActive(on)
	active = on
	if on then
		nextSpawnAt = os.clock() + X.FirstDelay
	else
		nextSpawnAt = math.huge
		clearBoxes()
	end
end

-- 상자 폴더를 만들고 매 프레임 확인을 연결한다.
function AbilityBoxService.start()
	folder = Instance.new("Folder")
	folder.Name = "AbilityBoxes"
	folder.Parent = workspace
	RunService.Heartbeat:Connect(update)
end

return AbilityBoxService
