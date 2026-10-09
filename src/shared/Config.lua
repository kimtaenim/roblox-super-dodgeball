-- 게임에 나오는 모든 숫자를 여기 모아 둔다.
-- 숫자를 바꾸고 싶으면 이 파일만 고치면 된다.

local Config = {}

-- 캐릭터
Config.Player = {
	WalkSpeed = 16, -- 걷는 속도 (로블록스 기본값)
	JumpHeight = 7.2, -- 점프 높이 (로블록스 기본값)
}

-- 게임 흐름 (설계서 5장)
Config.Round = {
	LobbySeconds = 20, -- 로비에서 기다리는 시간
	CountdownSeconds = 3, -- 시작 전 카운트다운
	PlaySeconds = 240, -- 한 판 최대 시간 (4분)
	ResultSeconds = 5, -- 승자 보여주는 시간
	MinParticipants = 2, -- 한 판에 필요한 최소 인원 (NPC 포함)
	TickSeconds = 0.1, -- 게임 진행을 확인하는 간격
}

-- 코트 (설계서 4장)
Config.Court = {
	Center = Vector3.new(0, 0, 0), -- 코트 한가운데 (바닥 높이)
	StartRadius = 70, -- 처음 코트 반지름 (스터드)
	ShrinkInterval = 90, -- 이 시간마다 코트가 줄어든다 (초)
	ShrinkStep = 14, -- 한 번에 줄어드는 반지름
	MinRadius = 28, -- 이보다 작아지지는 않는다
	ShrinkTweenSeconds = 2, -- 줄어드는 모습이 보이는 시간
	Thickness = 1, -- 코트 바닥 두께
	RaiseHeight = 0.1, -- 바닥판 위로 살짝 띄우는 높이 (겹쳐서 깜빡이지 않게)
	GroundSize = 600, -- 바깥 평지 크기 (Baseplate가 없을 때만 만든다)
	GroundColor = Color3.fromRGB(110, 170, 90), -- 바깥 평지 색
	OutsideLimitSeconds = 3, -- 코트 밖에서 버틸 수 있는 시간
	ReturnMargin = 3, -- 되돌릴 때 경계에서 안쪽으로 들어오는 거리
	SpawnRadiusRatio = 0.8, -- 등장 위치 : 반지름의 몇 배 안쪽에서 고를지
	SpawnHeight = 3, -- 등장할 때 바닥에서 띄우는 높이
	SpectatorGap = 8, -- 구경하는 사람이 코트 밖에 서는 거리
	Color = Color3.fromRGB(70, 140, 220), -- 코트 색
	LineColor = Color3.fromRGB(255, 255, 255), -- 코트 테두리 색
	LineWidth = 1, -- 테두리 두께
}

-- 공 (설계서 1.5장)
Config.Ball = {
	Diameter = 2, -- 공 지름
	Color = Color3.fromRGB(230, 60, 60), -- 공 색
	MinCount = 2, -- 공은 최소 2개
	PlayersPerBall = 2, -- 참가자 2명당 공 1개
	PickupRadius = 4, -- 이 거리 안의 죽은 공은 자동으로 줍는다
	PickupCooldown = 0.5, -- 던진 직후 이 시간 동안은 다시 줍지 않는다
	HitPadding = 0.6, -- 맞았는지 볼 때 공 둘레에 더하는 여유
	GravityScale = 0.3, -- 날아가는 공이 받는 중력 비율
	MaxLiveSeconds = 5, -- 이보다 오래 날면 죽은 공이 된다
	RespawnDelay = 3, -- 코트 밖 죽은 공이 중앙으로 돌아오기까지 시간
	RespawnHeight = 3, -- 리스폰할 때 바닥에서 띄우는 높이
	RespawnSpread = 8, -- 리스폰할 때 중앙에서 흩어지는 거리
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
	TouchAimDistance = 30, -- 모바일 던지기 버튼 : 보는 방향으로 이만큼 앞을 조준
	AssistMaxDistance = 60, -- 이 거리 안의 조준점은 떨어지는 만큼 위로 보정
}

-- 캐치 (설계서 1.4장)
Config.Catch = {
	Window = 0.5, -- 공이 닿기 전 이 시간 안에 눌렀으면 캐치
	Cooldown = 1.0, -- 캐치 버튼은 이 시간에 한 번만
}

-- 능력 게이지 (설계서 2.1장)
Config.Gauge = {
	Max = 100, -- 가득 찬 게이지
	PerSecond = 4, -- 살아 있으면 1초마다 늘어나는 양
	KillBonus = 25, -- 아웃시키면 더하는 양
	CatchBonus = 30, -- 캐치하면 더하는 양
}

-- 능력 9종 (설계서 2.2장)
Config.Abilities = {
	Teleport = { Distance = 20, EdgeMargin = 2 }, -- 이동 거리, 코트 끝에서 남기는 여유
	DoubleBall = { SpreadDegrees = 15 }, -- 두 번째 공이 벌어지는 각도
	Clone = { Count = 3, Seconds = 5, WanderRadius = 15, WanderInterval = 1, EdgeMargin = 2 },
	Shield = { Seconds = 3, BounceSpeed = 30, BounceUp = 15 }, -- 튕겨 나가는 속도
	Magnet = { Radius = 25, PullSpeed = 40, PullUp = 10 }, -- 끌어오는 범위·속도
	Fastball = { SpeedMultiplier = 2 }, -- 속도 몇 배
	Homing = { Seconds = 2, TurnDegreesPerSecond = 240 }, -- 추적 시간, 1초에 꺾는 최대 각도
	Invisible = { Seconds = 4, Transparency = 0.9 },
	Slow = { Radius = 30, Seconds = 3, SpeedFactor = 0.5 },
}

-- NPC (설계서 9장)
Config.Npc = {
	TargetTotal = 6, -- 한 판 참가자가 이 수가 되도록 NPC를 채운다 (너무 많으면 정신없다)
	ThinkInterval = 0.25, -- NPC가 다음 행동을 고르는 간격
	AimDelayMin = 0.6, -- 공을 들고 던지기까지 최소 시간
	AimDelayMax = 1.6, -- 공을 들고 던지기까지 최대 시간
	ThrowRange = 35, -- 이 거리 안의 상대를 노린다
	AimError = 4, -- 조준이 빗나가는 정도 (스터드)
	LeadFactor = 0.3, -- 움직이는 상대 앞쪽을 노리는 정도
	HoldMin = 0.5, -- 던지기 홀드 시간 최소
	HoldMax = 1.0, -- 던지기 홀드 시간 최대
	CatchReactDistance = 12, -- 날아오는 공이 이 거리 안에 오면 캐치를 시도
	CatchChance = 0.25, -- 캐치 시도가 성공할 확률
	WanderRadius = 12, -- 할 일이 없을 때 돌아다니는 거리
	WanderInterval = 2, -- 돌아다닐 곳을 새로 고르는 간격
	MoveMargin = 4, -- 코트 끝에서 이만큼 안쪽으로만 다닌다
	FallLimitY = -50, -- 이보다 아래로 떨어지면 코트에 다시 세운다
	-- 생김새 : 평범한 사람 (피부색과 옷 색만 NPC마다 다르다)
	SkinColors = {
		Color3.fromRGB(255, 224, 189),
		Color3.fromRGB(241, 194, 125),
		Color3.fromRGB(224, 172, 105),
		Color3.fromRGB(198, 134, 66),
		Color3.fromRGB(141, 85, 36),
	},
	-- 윗옷 색. NPC 이름이 이 색 이름이 된다 (이름표 글자도 이 색)
	Shirts = {
		{ name = "빨강", color = Color3.fromRGB(230, 50, 50) },
		{ name = "주황", color = Color3.fromRGB(255, 140, 30) },
		{ name = "노랑", color = Color3.fromRGB(255, 220, 40) },
		{ name = "초록", color = Color3.fromRGB(60, 190, 70) },
		{ name = "파랑", color = Color3.fromRGB(40, 100, 230) },
		{ name = "보라", color = Color3.fromRGB(150, 70, 210) },
		{ name = "분홍", color = Color3.fromRGB(255, 120, 190) },
		{ name = "하늘", color = Color3.fromRGB(100, 200, 255) },
	},
	PantsColor = Color3.fromRGB(50, 60, 90), -- 바지 색
	NameTagHeight = 2, -- 이름표가 머리 위로 뜨는 높이
	NameTagWidth = 160, -- 이름표 너비 (픽셀)
	NameTagTextSize = 18, -- 이름표 글자 크기
	SpeechHeight = 3.6, -- 말풍선이 머리 위로 뜨는 높이
	SpeechSeconds = 2, -- 말풍선이 떠 있는 시간
	SpeechChance = 0.3, -- 사건이 생겼을 때 말할 확률 (너무 시끄럽지 않게)
	SpeechGap = 3, -- 한 NPC가 말하면 이 시간 동안 다른 NPC는 말하지 않는다 (초)
	SpeechMaxDistance = 80, -- 이보다 멀면 말풍선이 안 보인다
	ChatIntervalMin = 20, -- 혼잣말 사이 최소 시간 (초)
	ChatIntervalMax = 40, -- 혼잣말 사이 최대 시간 (초)
	-- 사건마다 NPC가 하는 말
	Lines = {
		out = { "으악!", "아야!", "잡혔다…", "다음엔 안 맞아!" },
		kill = { "맞았다!", "나이스!", "하하, 아웃!", "명중!" },
		catch = { "잡았다!", "캐치!", "내 거야!" },
		revive = { "살았다!", "다시 간다!", "고마워!" },
		ability = { "받아라!", "능력 발동!", "이번엔 내 차례!" },
		throw = { "간다!", "피해 봐!", "슛!", "이거나 받아라!" },
		-- 살아 있을 때 가끔 하는 혼잣말
		chat = { "공 어디 있지?", "나 잡아 봐라~", "오늘 컨디션 좋다!", "누가 제일 잘하나 보자!", "조심조심…" },
		-- 앉아 있을 때 가끔 하는 혼잣말
		sittingChat = { "누가 나 좀 살려 줘~", "공만 오면 잡는다!", "아깝다…", "다음엔 꼭 피할 거야" },
	},
}

-- 튜토리얼 : 처음 온 사람의 첫 판은 NPC 몇 명과만 천천히 한다
Config.Tutorial = {
	TargetTotal = 3, -- 튜토리얼 판 참가자 수 (나 + NPC 2명)
	AimDelayScale = 2, -- NPC가 공을 들고 던지기까지 이 배수만큼 더 기다린다
	CatchChance = 0, -- 튜토리얼 NPC는 캐치를 안 한다 (맞히는 재미를 먼저)
}

-- NPC·분신 애니메이션 (로블록스 기본 R15 애니메이션)
Config.Animation = {
	Idle = "rbxassetid://507766388",
	Walk = "rbxassetid://507777826",
	Sit = "rbxassetid://2506281703",
	WalkThreshold = 0.5, -- 이보다 빠르면 걷는 동작
	FadeSeconds = 0.2, -- 동작이 바뀔 때 부드럽게 섞는 시간
}

-- 화면 표시
Config.Hud = {
	MessageSeconds = 2.5, -- 알림 글자가 떠 있는 시간
	FlashSpeed = 6, -- 게이지가 가득 찼을 때 깜빡이는 빠르기
}

return Config
