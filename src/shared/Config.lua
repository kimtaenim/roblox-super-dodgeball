-- 게임에 나오는 모든 숫자를 여기 모아 둔다.
-- 숫자를 바꾸고 싶으면 이 파일만 고치면 된다.

local Config = {}

-- 코트 (설계서 4장)
Config.Court = {
	Center = Vector3.new(0, 0, 0), -- 코트 한가운데 (바닥 높이)
	Radius = 40, -- 코트 반지름 (스터드)
	Thickness = 1, -- 코트 바닥 두께
	RaiseHeight = 0.1, -- 바닥판 위로 살짝 띄우는 높이 (겹쳐서 깜빡이지 않게)
	GroundSize = 400, -- 바깥 평지 크기 (Baseplate가 없을 때만 만든다)
	GroundColor = Color3.fromRGB(110, 170, 90), -- 바깥 평지 색
	OutsideLimitSeconds = 3, -- 코트 밖에서 버틸 수 있는 시간
	ReturnMargin = 3, -- 되돌릴 때 경계에서 안쪽으로 들어오는 거리
	SpawnRadiusRatio = 0.7, -- 등장 위치 : 반지름의 몇 배 안쪽에서 고를지
	SpawnHeight = 3, -- 등장할 때 바닥에서 띄우는 높이
	Color = Color3.fromRGB(70, 140, 220), -- 코트 색
	LineColor = Color3.fromRGB(255, 255, 255), -- 코트 테두리 색
	LineWidth = 1, -- 테두리 두께
}

-- 공 (설계서 1.5장)
Config.Ball = {
	Diameter = 2, -- 공 지름
	Color = Color3.fromRGB(230, 60, 60), -- 공 색
	MinCount = 2, -- 공은 최소 2개
	PlayersPerBall = 2, -- 플레이어 2명당 공 1개
	PickupRadius = 4, -- 이 거리 안의 죽은 공은 자동으로 줍는다
	PickupCooldown = 0.5, -- 던진 직후 이 시간 동안은 다시 줍지 않는다
	RespawnDelay = 3, -- 코트 밖 죽은 공이 중앙으로 돌아오기까지 시간
	RespawnHeight = 3, -- 리스폰할 때 바닥에서 띄우는 높이
	RespawnSpread = 5, -- 리스폰할 때 중앙에서 흩어지는 거리
	FallLimitY = -50, -- 이보다 아래로 떨어진 공은 바로 리스폰
	Density = 0.3, -- 공 무게 (가벼울수록 잘 튄다)
	Friction = 0.5, -- 공 마찰
	Elasticity = 0.5, -- 공 탄성 (튀는 정도)
}

-- 던지기 (설계서 3장)
Config.Throw = {
	MinHold = 0.3, -- 최소 파워가 되는 홀드 시간 (초)
	MaxHold = 1.0, -- 최대 파워가 되는 홀드 시간 (초)
	MaxSpeed = 80, -- 최대 속도 (스터드/초)
	HandHeight = 1.5, -- 공이 출발하는 높이 (몸 중심에서 위로)
	ForwardOffset = 3, -- 공이 출발하는 거리 (몸 중심에서 앞으로)
	AimDistance = 1000, -- 마우스가 하늘을 가리킬 때 조준점 거리
}

return Config
