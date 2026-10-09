-- 게임을 시작하는 곳. 코트와 공을 준비하고 플레이어를 코트에 세운다.
-- (로비·라운드·타이머는 나중 단계에서 여기에 추가한다)

local Players = game:GetService("Players")

local CourtService = require(script.Parent.CourtService)
local BallService = require(script.Parent.BallService)

CourtService.start()
BallService.start()

-- 캐릭터가 생기면 코트 안에 세우고, 죽거나 사라지면 공을 떨어뜨린다.
local function onCharacterAdded(player, character)
	CourtService.placeInside(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		BallService.dropBall(player)
	end)
end

-- 플레이어가 들어오면 캐릭터 이벤트를 연결하고 공 개수를 맞춘다.
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	player.CharacterRemoving:Connect(function()
		BallService.dropBall(player)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, player, player.Character)
	end
	BallService.updateBallCount(#Players:GetPlayers())
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

-- 플레이어가 나가면 공 개수를 다시 맞춘다 (나가는 사람은 아직 목록에 있어서 1을 뺀다).
Players.PlayerRemoving:Connect(function()
	BallService.updateBallCount(#Players:GetPlayers() - 1)
end)

BallService.updateBallCount(#Players:GetPlayers())
