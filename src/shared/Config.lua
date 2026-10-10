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
	StartRadius = 42, -- 처음 코트 반지름 (스터드, 6명 기준)
	ShrinkInterval = 90, -- 이 시간마다 코트가 줄어든다 (초)
	ShrinkStep = 8, -- 한 번에 줄어드는 반지름
	MinRadius = 18, -- 이보다 작아지지는 않는다
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
	GravityScale = 0.15, -- 날아가는 공이 받는 중력 비율 (작을수록 멀리 날아간다)
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
	MaxSpeed = 100, -- 최대 속도 (스터드/초)
	HandHeight = 1.5, -- 공이 출발하는 높이 (몸 중심에서 위로)
	ForwardOffset = 3, -- 공이 출발하는 거리 (몸 중심에서 앞으로)
	AimDistance = 1000, -- 마우스가 하늘을 가리킬 때 조준점 거리
	TouchAimDistance = 45, -- 모바일 던지기 버튼 : 보는 방향으로 이만큼 앞을 조준
	AssistMaxDistance = 90, -- 이 거리 안의 조준점은 떨어지는 만큼 위로 보정 (코트 끝에서 끝까지)
}

-- 캐치 (설계서 1.4장)
Config.Catch = {
	Window = 0.5, -- 공이 닿기 전 이 시간 안에 눌렀으면 캐치
	Cooldown = 1.0, -- 캐치 버튼은 이 시간에 한 번만
}

-- 능력 상자 (설계서 2.1장) : 판 시작 때 능력 몇 개를 갖고, 판 도중 상자를 주우면 하나 더 생긴다
Config.AbilityBox = {
	StartCount = 3, -- 판 시작 때 갖고 시작하는 능력 수
	MaxSlots = 5, -- 한 번에 가질 수 있는 능력 수 (꽉 차면 상자를 못 줍는다)
	FirstDelay = 5, -- 판이 시작되고 첫 상자가 떨어지기까지 (초)
	Interval = 8, -- 상자가 떨어지는 간격 (초)
	MaxOnCourt = 3, -- 코트에 동시에 있을 수 있는 상자 수
	PickupRadius = 4, -- 이 거리 안에 오면 줍는다
	Size = 2.5, -- 상자 크기
	Color = Color3.fromRGB(255, 200, 60), -- 상자 색
	SpawnRadiusRatio = 0.8, -- 떨어지는 위치 : 반지름의 몇 배 안쪽
	Height = 2, -- 바닥에서 떠 있는 높이
	SpinDegreesPerSecond = 90, -- 빙글빙글 도는 빠르기
	-- 능력이 나올 비율 (숫자가 클수록 자주 나온다)
	Weights = {
		superwings = 3,
		doubleball = 3,
		clone = 3,
		shield = 3,
		supercatch = 3,
		superfastball = 2,
		homing = 2,
		invisible = 3,
		slow = 3,
	},
}

-- 능력 9종 (설계서 2.2장)
Config.Abilities = {
	SuperWings = { -- 슈퍼날개
		Seconds = 6, -- 날아다니는 시간
		Height = 12, -- 코트 바닥에서 떠오르는 높이
		Responsiveness = 15, -- 그 높이로 올라가는 빠르기
		WingSize = Vector3.new(2.4, 1.2, 0.2), -- 날개 한 쪽 크기
		WingOffset = Vector3.new(1.3, 0.8, 0.7), -- 등에서 날개가 붙는 자리 (옆, 위, 뒤)
		WingTiltDegrees = 20, -- 날개가 위로 들린 각도
		WingColor = Color3.fromRGB(255, 255, 255), -- 날개 색
	},
	DoubleBall = { SpreadDegrees = 15 }, -- 두 번째 공이 벌어지는 각도
	Clone = { Count = 3, Seconds = 5, WanderRadius = 15, WanderInterval = 1, EdgeMargin = 2 },
	Shield = { Seconds = 3, BounceSpeed = 30, BounceUp = 15 }, -- 튕겨 나가는 속도
	SuperCatch = { Seconds = 5, Color = Color3.fromRGB(120, 255, 160) }, -- 자동으로 잡는 시간, 몸이 빛나는 색
	SuperFastball = { SpeedMultiplier = 3, FireSize = 4 }, -- 속도 몇 배, 불꽃 크기
	Homing = { Seconds = 2, TurnDegreesPerSecond = 240 }, -- 추적 시간, 1초에 꺾는 최대 각도
	Invisible = { Seconds = 4, Transparency = 0.9, SelfTransparency = 0.5 }, -- 남이 볼 때, 내 화면에서 볼 때
	Slow = { Radius = 30, Seconds = 3, SpeedFactor = 0.5 },
}

-- NPC (설계서 9장)
Config.Npc = {
	TargetTotal = 6, -- 한 판 참가자가 이 수가 되도록 NPC를 채운다 (너무 많으면 정신없다)
	ThinkInterval = 0.25, -- NPC가 다음 행동을 고르는 간격
	AimDelayMin = 0.6, -- 공을 들고 던지기까지 최소 시간
	AimDelayMax = 1.6, -- 공을 들고 던지기까지 최대 시간
	ThrowRange = 50, -- 이 거리 안의 상대를 노린다
	FocusMemorySeconds = 20, -- 이 시간 동안 NPC 공을 많이 받은 상대는 덜 노린다 (한 사람만 집중 공격하지 않게)
	SameTargetPenalty = 2, -- 방금 던진 상대를 또 노리지 않게 하는 정도 (공 2번 받은 것으로 친다)
	AimError = 4, -- 조준이 빗나가는 정도 (스터드)
	LeadFactor = 0.3, -- 움직이는 상대 앞쪽을 노리는 정도
	HoldMin = 0.5, -- 던지기 홀드 시간 최소
	HoldMax = 1.0, -- 던지기 홀드 시간 최대
	CatchReactDistance = 12, -- 날아오는 공이 이 거리 안에 오면 캐치를 시도
	CatchChance = 0.25, -- 캐치 시도가 성공할 확률
	AbilityDelayMin = 20, -- 능력을 한 번 쓰고 다음에 쓰기까지 최소 시간 (초, 아주 가끔만 쓴다)
	AbilityDelayMax = 40, -- 능력을 한 번 쓰고 다음에 쓰기까지 최대 시간 (초)
	BoxInterestDistance = 6, -- 능력 상자가 이 거리 안에 있을 때만 주우러 간다 (상자에 큰 관심 없음)
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
	-- 윗옷 색. NPC 이름이 이 색 이름이 된다
	-- 이름은 쉬운 색 이름, 실제 색은 눈이 편한 부드러운 색 (괄호 안이 실제 색)
	Shirts = {
		{ name = "빨강", color = Color3.fromRGB(240, 95, 70) }, -- 다홍
		{ name = "청록", color = Color3.fromRGB(40, 180, 170) }, -- 터콰즈
		{ name = "민트", color = Color3.fromRGB(130, 220, 180) }, -- 민트
		{ name = "하늘", color = Color3.fromRGB(120, 190, 240) }, -- 하늘
		{ name = "분홍", color = Color3.fromRGB(250, 130, 130) }, -- 코랄핑크
		{ name = "노랑", color = Color3.fromRGB(255, 240, 100) }, -- 레몬옐로우
		{ name = "주황", color = Color3.fromRGB(255, 180, 120) }, -- 피치 오렌지
		{ name = "보라", color = Color3.fromRGB(170, 140, 220) }, -- 라벤더
	},
	PantsColor = Color3.fromRGB(50, 60, 90), -- 바지 색
	NameTagHeight = 2, -- 이름표가 머리 위로 뜨는 높이
	NameTagWidth = 160, -- 이름표 너비 (픽셀)
	NameTagTextSize = 18, -- 이름표 글자 크기
	NameTagTextColor = Color3.new(0, 0, 0), -- 이름표 글자 색 (검은색)
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
	CourtRadius = 30, -- 튜토리얼 판 코트 반지름 (3명이라 더 작게)
	-- 캐치 시범 : 판이 시작되면 NPC 둘이 "공을 잡히면 던진 사람이 아웃"을 보여준다
	DemoGap = 14, -- 시범하는 NPC 둘 사이 거리
	DemoViewDistance = 16, -- 구경하는 사람이 시범 한가운데에서 떨어져 서는 거리
	DemoViewSpacing = 3, -- 구경하는 사람이 여럿이면 옆으로 벌려 서는 간격
	DemoReadySeconds = 1.5, -- 자리 잡고 공을 쥐기까지 기다리는 시간
	DemoAimSeconds = 1.5, -- 공을 쥐고 던지기까지 기다리는 시간
	DemoHold = 0.5, -- 시범 던지기 홀드 시간 (천천히 날아가게)
	DemoCatchTimeout = 3, -- 이 시간 안에 캐치가 안 되면 시범을 그냥 끝낸다
	DemoAfterSeconds = 3, -- 캐치 뒤 설명을 읽을 시간
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
	AbilitySlotWidth = 110, -- 능력 칸 하나 너비 (픽셀)
	AbilitySlotHeight = 40, -- 능력 칸 높이 (픽셀)
	AbilitySlotGap = 8, -- 능력 칸 사이 간격 (픽셀)
}

return Config
