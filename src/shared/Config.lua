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

-- 복수 대상 (설계서 1.6장) : 같은 상대에게 자꾸 아웃되면 그 상대 머리 위에 표시 (당한 사람 화면에만)
Config.Revenge = {
	OutsToMark = 2, -- 이 횟수만큼 같은 상대 공에 맞아 아웃되면 복수 대상이 된다
	WindowSeconds = 90, -- 이 시간 안에 맞은 것만 센다 (초)
	MarkText = "😠 복수 대상!", -- 머리 위 글자
	MarkColor = Color3.fromRGB(255, 80, 60), -- 글자 색
	MarkTextSize = 22, -- 글자 크기
	MarkWidth = 200, -- 표시 너비 (픽셀)
	MarkHeight = 4.5, -- 머리 위로 뜨는 높이 (이름표보다 위)
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
	-- NPC 8명 : 한 명 한 명 생김새가 정해져 있다 (판마다 섞어서 겹치지 않게 나온다)
	-- name = 이름 (윗옷 색 이름), shirt = 윗옷 색 (이름은 쉬운 색, 실제 색은 눈이 편한 색)
	-- body = 체형 (키, 어깨 너비, 몸 두께, 머리 크기), skin = 피부색
	-- hair = 머리 모양, hairColor = 머리 색, eyes/brows/mouth = 눈·눈썹·입 모양 (Config.Looks에 있는 이름)
	-- extras = 덧붙이는 것 (blush 볼터치, freckles 주근깨, glasses 안경, hairclip 별 핀)
	-- legs = "pants" 긴바지 / "shorts" 반바지, pants = 바지 색, shoes = 신발 색, number = 등번호
	Personas = {
		{
			name = "빨강", shirt = Color3.fromRGB(240, 95, 70), -- 다홍 : 키 크고 듬직한 대장
			body = { height = 1.08, width = 1.12, depth = 1.05, head = 1.0 },
			skin = Color3.fromRGB(241, 194, 125),
			hair = "spiky", hairColor = Color3.fromRGB(35, 30, 30),
			eyes = "normal", brows = "brave", mouth = "grin", extras = {},
			legs = "shorts", pants = Color3.fromRGB(40, 45, 60), shoes = Color3.fromRGB(230, 60, 50), number = 7,
		},
		{
			name = "청록", shirt = Color3.fromRGB(40, 180, 170), -- 터콰즈 : 키 크고 마른 안경잡이
			body = { height = 1.1, width = 0.88, depth = 0.9, head = 0.98 },
			skin = Color3.fromRGB(255, 224, 189),
			hair = "sidepart", hairColor = Color3.fromRGB(90, 60, 40),
			eyes = "normal", brows = "calm", mouth = "smile", extras = { "glasses" },
			legs = "pants", pants = Color3.fromRGB(60, 70, 110), shoes = Color3.fromRGB(245, 245, 245), number = 4,
		},
		{
			name = "민트", shirt = Color3.fromRGB(130, 220, 180), -- 민트 : 주근깨 포니테일
			body = { height = 0.98, width = 0.95, depth = 0.95, head = 1.02 },
			skin = Color3.fromRGB(250, 214, 175),
			hair = "ponytail", hairColor = Color3.fromRGB(150, 90, 50),
			eyes = "normal", brows = "happy", mouth = "open", extras = { "freckles" },
			legs = "shorts", pants = Color3.fromRGB(70, 90, 140), shoes = Color3.fromRGB(255, 255, 255), number = 11,
		},
		{
			name = "하늘", shirt = Color3.fromRGB(120, 190, 240), -- 하늘 : 작고 눈 큰 야구모자
			body = { height = 0.9, width = 0.95, depth = 0.95, head = 1.08 },
			skin = Color3.fromRGB(224, 172, 105),
			hair = "cap", hairColor = Color3.fromRGB(40, 50, 90),
			eyes = "big", brows = "happy", mouth = "o", extras = {},
			legs = "shorts", pants = Color3.fromRGB(230, 230, 230), shoes = Color3.fromRGB(40, 50, 90), number = 2,
		},
		{
			name = "분홍", shirt = Color3.fromRGB(250, 130, 130), -- 코랄핑크 : 양갈래 똥머리, 볼이 발그레
			body = { height = 0.95, width = 0.94, depth = 0.95, head = 1.04 },
			skin = Color3.fromRGB(255, 228, 205),
			hair = "buns", hairColor = Color3.fromRGB(30, 25, 30),
			eyes = "happy", brows = "happy", mouth = "smile", extras = { "blush" },
			legs = "pants", pants = Color3.fromRGB(250, 240, 245), shoes = Color3.fromRGB(240, 110, 150), number = 9,
		},
		{
			name = "노랑", shirt = Color3.fromRGB(255, 240, 100), -- 레몬옐로우 : 통통한 곱슬머리
			body = { height = 0.96, width = 1.22, depth = 1.18, head = 1.05 },
			skin = Color3.fromRGB(198, 134, 66),
			hair = "curly", hairColor = Color3.fromRGB(60, 35, 20),
			eyes = "normal", brows = "happy", mouth = "grin", extras = { "blush" },
			legs = "pants", pants = Color3.fromRGB(90, 70, 50), shoes = Color3.fromRGB(250, 200, 60), number = 5,
		},
		{
			name = "주황", shirt = Color3.fromRGB(255, 180, 120), -- 피치 오렌지 : 머리띠 한 운동 선수
			body = { height = 1.02, width = 1.02, depth = 1.0, head = 0.97 },
			skin = Color3.fromRGB(141, 85, 36),
			hair = "headband", hairColor = Color3.fromRGB(25, 20, 20),
			eyes = "normal", brows = "brave", mouth = "smile", extras = {},
			legs = "shorts", pants = Color3.fromRGB(35, 35, 40), shoes = Color3.fromRGB(255, 140, 40), number = 23,
		},
		{
			name = "보라", shirt = Color3.fromRGB(170, 140, 220), -- 라벤더 : 긴 머리, 졸린 눈, 별 핀
			body = { height = 1.03, width = 0.92, depth = 0.92, head = 1.0 },
			skin = Color3.fromRGB(255, 220, 200),
			hair = "long", hairColor = Color3.fromRGB(45, 30, 55),
			eyes = "sleepy", brows = "calm", mouth = "small", extras = { "hairclip" },
			legs = "pants", pants = Color3.fromRGB(50, 45, 70), shoes = Color3.fromRGB(170, 140, 220), number = 3,
		},
	},
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

-- NPC 얼굴·머리·옷 모양 (server/NpcLooks.lua가 쓴다)
-- 얼굴 부품 크기와 위치는 머리 크기에 대한 비율이다 : x = 머리 너비, y = 머리 높이, z = 머리 두께 배.
-- 위치의 z가 음수면 얼굴 앞쪽이다.
Config.Looks = {
	FaceDepth = -0.47, -- 얼굴 부품이 붙는 깊이 (머리 앞면)
	LayerStep = 0.02, -- 겹치는 부품을 앞으로 조금씩 내미는 정도 (깜빡이지 않게)
	Eyes = {
		normal = { white = Vector3.new(0.2, 0.24, 0.06), pupil = Vector3.new(0.11, 0.14, 0.04), gapX = 0.2, y = 0.06 },
		big = { white = Vector3.new(0.25, 0.3, 0.06), pupil = Vector3.new(0.14, 0.18, 0.04), gapX = 0.21, y = 0.05 },
		sleepy = { -- 눈꺼풀(lid, 흰자 크기의 배)이 위쪽을 덮는다
			white = Vector3.new(0.2, 0.18, 0.06), pupil = Vector3.new(0.11, 0.1, 0.04), gapX = 0.2, y = 0.04,
			lid = Vector3.new(1.15, 0.6, 1), lidRaise = 0.32,
		},
		happy = { arc = Vector3.new(0.12, 0.035, 0.04), arcTiltDegrees = 30, arcSpread = 0.4, gapX = 0.2, y = 0.06 }, -- ^ ^ 웃는 눈
	},
	ShineSize = 0.045, -- 눈동자 반짝임 크기
	ShineOffset = Vector2.new(0.025, 0.035), -- 반짝임이 눈동자 가운데에서 떨어진 정도 (옆, 위)
	PupilColor = Color3.fromRGB(35, 25, 20),
	EyeWhiteColor = Color3.fromRGB(255, 255, 255),
	Brows = {
		size = Vector3.new(0.17, 0.04, 0.04), y = 0.22, gapX = 0.2,
		tiltDegrees = { brave = 18, calm = 0, happy = -10 }, -- + 면 안쪽이 내려간다 (씩씩한 눈썹)
	},
	NoseSize = Vector3.new(0.08, 0.07, 0.06), NoseY = -0.06, NoseDarken = 0.12,
	Mouths = {
		smile = { y = -0.2, segment = Vector3.new(0.09, 0.035, 0.04), spreadX = 0.08, liftY = 0.025 }, -- 세 조각으로 만든 웃는 입
		grin = { y = -0.2, size = Vector3.new(0.3, 0.12, 0.05), teeth = Vector3.new(0.24, 0.045, 0.02), shift = 0.22 }, -- 이가 보이는 큰 웃음 (이는 위쪽)
		open = { y = -0.21, size = Vector3.new(0.2, 0.13, 0.05), tongue = Vector3.new(0.11, 0.05, 0.02), shift = -0.22 }, -- 혀는 아래쪽
		o = { y = -0.21, size = Vector3.new(0.1, 0.11, 0.05) },
		small = { y = -0.2, size = Vector3.new(0.12, 0.03, 0.04) },
	},
	MouthColor = Color3.fromRGB(90, 30, 35),
	TeethColor = Color3.fromRGB(255, 255, 250),
	TongueColor = Color3.fromRGB(240, 120, 130),
	Blush = { size = Vector3.new(0.14, 0.07, 0.03), gapX = 0.3, y = -0.08, color = Color3.fromRGB(255, 130, 150), transparency = 0.35 },
	Freckles = { size = 0.025, color = Color3.fromRGB(150, 90, 60), y = -0.07, gapX = 0.28, spread = 0.05 },
	Glasses = {
		lens = Vector3.new(0.27, 0.24, 0.02), gapX = 0.2, y = 0.06, front = 0.08, lensColor = Color3.fromRGB(200, 230, 255), lensTransparency = 0.6,
		bridge = Vector3.new(0.1, 0.025, 0.02), frameColor = Color3.fromRGB(30, 30, 35), rim = 0.03,
	},
	-- 머리카락 : 모든 머리 모양은 정수리를 덮는 "모자" 부분을 먼저 깔고 모양마다 덧붙인다
	HairCap = { size = Vector3.new(1.1, 0.78, 1.1), offset = Vector3.new(0, 0.28, 0.06) },
	Hair = {
		spiky = { count = 6, spike = Vector3.new(0.16, 0.32, 0.16), radius = 0.3, y = 0.6, tiltDegrees = 25 },
		sidepart = { fringe = Vector3.new(0.55, 0.2, 0.3), offset = Vector3.new(-0.15, 0.4, -0.36), tiltDegrees = 12 },
		ponytail = { knot = 0.32, knotOffset = Vector3.new(0, 0.3, 0.58), tail = Vector3.new(0.22, 0.6, 0.22), tailOffset = Vector3.new(0, -0.05, 0.68) },
		cap = { brim = Vector3.new(0.8, 0.06, 0.6), brimOffset = Vector3.new(0, 0.33, -0.62), top = Vector3.new(1.14, 0.62, 1.14), topOffset = Vector3.new(0, 0.38, 0.03), button = 0.1 },
		buns = { bun = 0.38, gapX = 0.4, y = 0.5, z = 0.1 },
		curly = { count = 14, curl = 0.3, radius = 0.5, y = 0.42, rise = 0.5, backZ = 0.05 },
		headband = { band = Vector3.new(1.12, 0.12, 1.12), y = 0.2, color = Color3.fromRGB(255, 255, 255) },
		long = { back = Vector3.new(1.0, 1.25, 0.32), backOffset = Vector3.new(0, -0.2, 0.42), side = Vector3.new(0.18, 0.9, 0.5), sideGapX = 0.5, sideY = -0.1 },
	},
	HairClip = { size = 0.16, offset = Vector3.new(0.42, 0.32, -0.25), color = Color3.fromRGB(255, 220, 60) },
	-- 옷
	CollarSize = Vector3.new(0.75, 0.12, 0.7), -- 윗옷 목둘레 (윗몸 크기에 대한 비율)
	CollarDarken = 0.15, -- 목둘레는 윗옷보다 조금 진하게
	NumberColor = Color3.fromRGB(255, 255, 255), -- 등번호 색
	NumberPixelsPerStud = 50, -- 등번호 글자 선명도
	NumberStrokeTransparency = 0.5, -- 등번호 테두리 진하기
}

-- 경기장 꾸미기 (server/Scenery.lua가 쓴다)
Config.Scenery = {
	-- 조명
	ClockTime = 14.5, -- 오후 2시 반 (해가 높고 그림자가 짧다)
	Brightness = 2.5,
	OutdoorAmbient = Color3.fromRGB(140, 140, 150),
	AtmosphereDensity = 0.28, AtmosphereHaze = 1.2, AtmosphereColor = Color3.fromRGB(200, 220, 255),
	BloomIntensity = 0.4, BloomSize = 24, BloomThreshold = 1.4,
	Saturation = 0.15, Contrast = 0.08, -- 색을 조금 더 진하고 또렷하게
	SunRaysIntensity = 0.06,
	-- 코트 무늬
	MarkThickness = 0.05, -- 바닥 무늬 두께
	CenterCircleRadius = 6, -- 가운데 원 반지름
	CenterLineWidth = 0.6, -- 가운데 원 선 두께
	LogoText = "SUPER DODGEBALL", -- 코트 가운데 글자
	LogoSize = Vector2.new(26, 5), -- 글자판 크기 (스터드)
	LogoColor = Color3.fromRGB(255, 255, 255),
	LogoTransparency = 0.25,
	-- 둘레
	Distance = 58, -- 코트 가운데에서 관중석·나무가 놓이는 거리
	StandCount = 4, -- 관중석 수 (둘레에 고르게)
	StandWidth = 24, StandStepDepth = 3, StandStepHeight = 1.4, StandSteps = 4,
	StandColor = Color3.fromRGB(200, 200, 210),
	SeatHeight = 0.4, SeatDepthRatio = 0.6, -- 계단 위 의자 줄 높이, 계단 깊이에 대한 비율
	SeatColors = { -- 관중석 의자 색 (줄마다 바뀐다)
		Color3.fromRGB(240, 95, 70), Color3.fromRGB(40, 180, 170), Color3.fromRGB(255, 240, 100), Color3.fromRGB(170, 140, 220),
	},
	TreeCount = 12, TreeTrunk = Vector3.new(1.4, 7, 1.4), TreeLeaves = 8, TreeExtraDistance = 6,
	LeafOffsets = { Vector3.new(0, 2, 0), Vector3.new(2, 0, 1), Vector3.new(-1.5, 0.5, -1.5) }, -- 잎 덩이 위치 (줄기 꼭대기 기준)
	LeafScales = { 1, 0.75, 0.7 }, -- 잎 덩이 크기 (TreeLeaves에 곱한다)
	TrunkColor = Color3.fromRGB(110, 75, 50), LeafColors = { Color3.fromRGB(80, 160, 80), Color3.fromRGB(110, 180, 90), Color3.fromRGB(70, 140, 100) },
	FlagCount = 8, FlagPoleHeight = 12, FlagSize = Vector3.new(0.2, 2.2, 3.5), PoleColor = Color3.fromRGB(230, 230, 235),
	PoleThickness = 0.4,
	FlagDistance = 50, -- 깃대가 놓이는 거리
	-- 공 꼬리 (날아갈 때만)
	BallTrailLifetime = 0.25,
	BallTrailWidth = 0.8, -- 꼬리 굵기 (스터드)
	BallTrailColor = Color3.fromRGB(255, 255, 255),
	BallTrailTransparency = NumberSequence.new(0.3, 1),
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
