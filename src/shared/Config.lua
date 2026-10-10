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
	StartRadius = 55, -- 처음 코트 반지름 (스터드)
	ShrinkInterval = 90, -- 이 시간마다 코트가 줄어든다 (초)
	ShrinkStep = 10, -- 한 번에 줄어드는 반지름
	MinRadius = 24, -- 이보다 작아지지는 않는다
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
	Count = 1, -- 공은 딱 하나 ("공 두 개" 능력을 쓸 때만 잠깐 하나 더)
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
	TouchAimDistance = 55, -- 모바일 던지기 버튼 : 보는 방향으로 이만큼 앞을 조준
	AssistMaxDistance = 115, -- 이 거리 안의 조준점은 떨어지는 만큼 위로 보정 (코트 끝에서 끝까지)
}

-- 캐치 (설계서 1.4장)
Config.Catch = {
	Window = 0.8, -- 공이 닿기 전 이 시간 안에 눌렀으면 캐치 (넉넉하게, 쉬운 난이도)
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
	LabelWidth = 160, LabelHeight = 36, -- 상자 위 능력 이름표 크기 (픽셀)
	LabelOffset = 2.5, -- 이름표가 상자 위로 뜨는 높이
	LabelMaxDistance = 150, -- 이보다 멀면 이름표가 안 보인다
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
		Seconds = 15, -- 날아다니는 시간 (이 동안은 맞아도 아웃 안 됨)
		Height = 12, -- 코트 바닥에서 떠오르는 높이
		Responsiveness = 15, -- 그 높이로 올라가는 빠르기
		WingSize = Vector3.new(2.4, 1.2, 0.2), -- 날개 한 쪽 크기
		WingOffset = Vector3.new(1.3, 0.8, 0.7), -- 등에서 날개가 붙는 자리 (옆, 위, 뒤)
		WingTiltDegrees = 20, -- 날개가 위로 들린 각도
		WingColor = Color3.fromRGB(255, 255, 255), -- 날개 색
	},
	DoubleBall = { SpreadDegrees = 15 }, -- 두 번째 공이 벌어지는 각도
	Clone = { Count = 3, Seconds = 5, WanderRadius = 15, WanderInterval = 1, EdgeMargin = 2 },
	Shield = { -- 방패 : 몸 둘레 푸른 공 모양 방패, 공을 튕겨 낸다
		Seconds = 5, BounceSpeed = 30, BounceUp = 15, -- 지속 시간, 튕겨 나가는 속도
		BubbleSize = 7, BubbleColor = Color3.fromRGB(90, 180, 255), BubbleTransparency = 0.65, -- 방패 공 크기·색·투명도
	},
	SuperCatch = { Seconds = 10, Color = Color3.fromRGB(120, 255, 160) }, -- 자동으로 잡는 시간 (넉넉하게), 몸이 빛나는 색
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
	AimDelayMin = 1.2, -- 공을 들고 던지기까지 최소 시간 (쉬운 난이도 : 천천히)
	AimDelayMax = 2.5, -- 공을 들고 던지기까지 최대 시간
	ThrowRange = 65, -- 이 거리 안의 상대를 노린다
	FocusMemorySeconds = 20, -- 이 시간 동안 NPC 공을 많이 받은 상대는 덜 노린다 (한 사람만 집중 공격하지 않게)
	SameTargetPenalty = 2, -- 방금 던진 상대를 또 노리지 않게 하는 정도 (공 2번 받은 것으로 친다)
	AimError = 8, -- 조준이 빗나가는 정도 (스터드, 쉬운 난이도 : 자주 빗나감)
	LeadFactor = 0.1, -- 움직이는 상대 앞쪽을 노리는 정도 (낮을수록 움직이면 잘 안 맞는다)
	HoldMin = 0.4, -- 던지기 홀드 시간 최소 (짧을수록 공이 느리다)
	HoldMax = 0.7, -- 던지기 홀드 시간 최대 (쉬운 난이도 : 세게 안 던진다)
	CatchReactDistance = 12, -- 날아오는 공이 이 거리 안에 오면 캐치를 시도
	CatchChance = 0.12, -- 캐치 시도가 성공할 확률 (쉬운 난이도 : 잘 못 잡는다)
	AbilityDelayMin = 20, -- 능력을 한 번 쓰고 다음에 쓰기까지 최소 시간 (초, 아주 가끔만 쓴다)
	AbilityDelayMax = 40, -- 능력을 한 번 쓰고 다음에 쓰기까지 최대 시간 (초)
	BoxInterestDistance = 6, -- 능력 상자가 이 거리 안에 있을 때만 주우러 간다 (상자에 큰 관심 없음)
	WanderRadius = 12, -- 할 일이 없을 때 돌아다니는 거리
	WanderInterval = 2, -- 돌아다닐 곳을 새로 고르는 간격
	MoveMargin = 4, -- 코트 끝에서 이만큼 안쪽으로만 다닌다
	FallLimitY = -50, -- 이보다 아래로 떨어지면 코트에 다시 세운다
	-- NPC 8명 : 한 명 한 명 생김새가 정해져 있다 (판마다 섞어서 겹치지 않게 나온다)
	-- name = 이름 (윗옷 색 이름), shirt = 윗옷 색 (이름은 쉬운 색, 실제 색은 눈이 편한 색)
	-- catalog = 로블록스 카탈로그 부품 (요즘 아바타 느낌) : 번호 + 기대하는 이름. 서버가 이름을 확인하고 맞을 때만 입힌다.
	--   body = 몸 번들 (옷 그림이 없는 몸만 : 윗옷·바지 색을 직접 칠해야 이름과 색이 맞는다),
	--   head = 다이내믹 헤드 번들(얼굴이 움직인다), hair = 머리카락 아이템, face = 얼굴 아이템
	--   확인 안 된 부품은 아래 hair·extras로 직접 만든 모습을 쓴다.
	-- body = 체형 (키, 어깨 너비, 몸 두께, 머리 크기), skin = 피부색
	--   로블록스 허용 범위 : 키 0.9~1.05, 너비 0.7~1.0, 머리 0.95~1.0 (어린이라 어깨는 좁게)
	-- hair = 머리 모양, hairColor = 머리 색 (Config.Looks에 있는 이름)
	-- extras = 덧붙이는 것 (blush 볼터치, freckles 주근깨, glasses 안경, hairclip 별 핀)
	-- legs = "pants" 긴바지 / "shorts" 반바지, pants = 바지 색, shoes = 신발 색, number = 등번호
	Personas = {
		{
			name = "빨강", shirt = Color3.fromRGB(240, 95, 70), -- 다홍 : 키 크고 듬직한 대장, 삐죽머리
			catalog = { body = { id = 986, name = "Base Body - Devin" }, head = { id = 949, name = "Chiseled Good Looks" }, hair = { id = 376548738, name = "Brown Charmer Hair" } },
			body = { height = 1.05, width = 0.84, depth = 0.85, head = 1.0 },
			skin = Color3.fromRGB(241, 194, 125),
			hair = "spiky", hairColor = Color3.fromRGB(35, 30, 30),
			extras = {},
			legs = "shorts", pants = Color3.fromRGB(40, 45, 60), shoes = Color3.fromRGB(230, 60, 50), number = 7,
		},
		{
			name = "청록", shirt = Color3.fromRGB(40, 180, 170), -- 터콰즈 : 키 크고 마른 안경잡이
			catalog = { body = { id = 986, name = "Base Body - Devin" }, head = { id = 945, name = "Dylan Default" }, hair = { id = 63690008, name = "Pal Hair" } },
			body = { height = 1.05, width = 0.72, depth = 0.75, head = 0.97 },
			skin = Color3.fromRGB(255, 224, 189),
			hair = "sidepart", hairColor = Color3.fromRGB(90, 60, 40),
			extras = { "glasses" },
			legs = "pants", pants = Color3.fromRGB(60, 70, 110), shoes = Color3.fromRGB(245, 245, 245), number = 4,
		},
		{
			name = "민트", shirt = Color3.fromRGB(130, 220, 180), -- 민트 : 주근깨 포니테일
			catalog = { body = { id = 986, name = "Base Body - Devin" }, face = { id = 12145366, name = "Freckles" }, hair = { id = 376527350, name = "Black Ponytail" } },
			body = { height = 0.98, width = 0.76, depth = 0.78, head = 1.0 },
			skin = Color3.fromRGB(250, 214, 175),
			hair = "ponytail", hairColor = Color3.fromRGB(150, 90, 50),
			extras = { "freckles" },
			legs = "shorts", pants = Color3.fromRGB(70, 90, 140), shoes = Color3.fromRGB(255, 255, 255), number = 11,
		},
		{
			name = "하늘", shirt = Color3.fromRGB(120, 190, 240), -- 하늘 : 작은 체구, 야구모자
			catalog = { body = { id = 311, name = "Robloxian 2.0" }, face = { id = 7699174, name = "Silly Fun" }, hair = { id = 451221329, name = "True Blue Hair" } },
			body = { height = 0.9, width = 0.74, depth = 0.76, head = 1.0 },
			skin = Color3.fromRGB(224, 172, 105),
			hair = "cap", hairColor = Color3.fromRGB(40, 50, 90),
			extras = {},
			legs = "shorts", pants = Color3.fromRGB(230, 230, 230), shoes = Color3.fromRGB(40, 50, 90), number = 2,
		},
		{
			name = "분홍", shirt = Color3.fromRGB(250, 130, 130), -- 코랄핑크 : 양갈래 똥머리, 볼이 발그레
			catalog = { body = { id = 986, name = "Base Body - Devin" }, head = { id = 948, name = "Makeup Minimalist" }, hair = { id = 5314006793, name = "Black Trendy Messy Buns" } },
			body = { height = 0.95, width = 0.75, depth = 0.77, head = 1.0 },
			skin = Color3.fromRGB(255, 228, 205),
			hair = "buns", hairColor = Color3.fromRGB(30, 25, 30),
			extras = { "blush" },
			legs = "pants", pants = Color3.fromRGB(250, 240, 245), shoes = Color3.fromRGB(240, 110, 150), number = 9,
		},
		{
			name = "노랑", shirt = Color3.fromRGB(255, 240, 100), -- 레몬옐로우 : 통통한 곱슬머리
			catalog = { body = { id = 986, name = "Base Body - Devin" }, head = { id = 945, name = "Dylan Default" }, hair = { id = 5703037305, name = "Black Curly Hair For Amazing People" } },
			body = { height = 0.96, width = 0.92, depth = 0.95, head = 1.0 },
			skin = Color3.fromRGB(198, 134, 66),
			hair = "curly", hairColor = Color3.fromRGB(60, 35, 20),
			extras = { "blush" },
			legs = "pants", pants = Color3.fromRGB(90, 70, 50), shoes = Color3.fromRGB(250, 200, 60), number = 5,
		},
		{
			name = "주황", shirt = Color3.fromRGB(255, 180, 120), -- 피치 오렌지 : 머리띠 한 운동 선수
			catalog = { body = { id = 311, name = "Robloxian 2.0" }, face = { id = 7074786, name = "Check It" } },
			body = { height = 1.0, width = 0.8, depth = 0.8, head = 0.97 },
			skin = Color3.fromRGB(141, 85, 36),
			hair = "headband", hairColor = Color3.fromRGB(25, 20, 20),
			extras = {},
			legs = "shorts", pants = Color3.fromRGB(35, 35, 40), shoes = Color3.fromRGB(255, 140, 40), number = 23,
		},
		{
			name = "보라", shirt = Color3.fromRGB(170, 140, 220), -- 라벤더 : 긴 머리, 별 핀
			catalog = { body = { id = 986, name = "Base Body - Devin" }, face = { id = 7074764, name = "Chill" }, hair = { id = 451220849, name = "Lavender Updo" } },
			body = { height = 1.02, width = 0.73, depth = 0.75, head = 0.98 },
			skin = Color3.fromRGB(255, 220, 200),
			hair = "long", hairColor = Color3.fromRGB(45, 30, 55),
			extras = { "hairclip" },
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
	-- 조용해야 하는 경기장(도서관·박물관)에서는 오히려 시끄럽게 떠든다 (그게 재미)
	LoudLines = {
		out = { "으아아악!!", "아야야야!!", "안 돼애애!!" },
		kill = { "맞았다아아!!", "명중이다!!", "와하하하!!" },
		catch = { "잡았다아아!!", "캐치이이!!" },
		revive = { "살았다아아!!", "부활이다!!" },
		ability = { "능력 발동!!!", "받아라아아!!" },
		throw = { "간다아아!!", "슈우우웃!!", "피해 봐라아!!" },
		chat = { "와아아아!!", "여기 도서관 맞아?!", "쉿은 무슨 쉿이야!!", "야호오오!!" },
		sittingChat = { "살려 줘어어!!", "공 좀 던져 줘어!!" },
	},
	LoudSpeechChance = 0.8, -- 시끄러운 곳에서 사건이 생겼을 때 말할 확률
	LoudSpeechGap = 1, -- 시끄러운 곳에서는 다른 NPC가 금방 또 말한다 (초)
	LoudChatScale = 0.4, -- 시끄러운 곳에서는 혼잣말 간격이 이 배로 짧아진다
	LoudBubbleScale = 1.4, -- 시끄러운 곳 말풍선 크기 배
}

-- 튜토리얼 : 처음 온 사람의 첫 판은 NPC 몇 명과만 천천히 한다
Config.Tutorial = {
	TargetTotal = 3, -- 튜토리얼 판 참가자 수 (나 + NPC 2명)
	AimDelayScale = 2, -- NPC가 공을 들고 던지기까지 이 배수만큼 더 기다린다
	CatchChance = 0, -- 튜토리얼 NPC는 캐치를 안 한다 (맞히는 재미를 먼저)
	CourtRadius = 38, -- 튜토리얼 판 코트 반지름 (3명이라 더 작게)
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

-- NPC 몸·머리·옷 모양 (server/NpcLooks.lua가 쓴다)
-- 머리 꾸밈 부품 크기와 위치는 머리 크기에 대한 비율이다 : x = 머리 너비, y = 머리 높이, z = 머리 두께 배.
-- 위치의 z가 음수면 얼굴 앞쪽이다. 얼굴은 로블록스 기본 얼굴 그림을 쓴다.
Config.Looks = {
	FaceDepth = -0.47, -- 꾸밈 부품이 붙는 깊이 (머리 앞면)
	LayerStep = 0.02, -- 겹치는 부품을 앞으로 조금씩 내미는 정도 (깜빡이지 않게)
	-- 둥근 몸 : 네모난 R15 몸 위에 덮는 둥근 조각
	Body = {
		LimbRoundness = 0.85, -- 팔다리 굵기 (원래 굵기에 대한 비율)
		EdgeRatio = 0.22, -- 원기둥 모서리를 둥글게 하는 정도 (지름에 대한 비율)
		JointOverlap = 0.15, -- 팔다리 마디가 이웃 마디·손·발과 겹치는 길이 (이어져 보이게)
		MinLength = 0.05, -- 원기둥 최소 길이
		TorsoDiameterRatio = 0.7, -- 몸통 원기둥 지름 (몸 너비에 대한 비율, 너무 두껍지 않게)
		ArmTouch = 0.05, -- 팔이 몸통에 살짝 파묻히는 정도 (떨어져 보이지 않게)
		ShoulderDrop = 0.22, -- 팔 윗부분을 내리는 정도 (윗팔 길이에 대한 비율, 어깨가 몸통보다 아래에 붙게)
		InnerShrink = 0.97, -- 겹쳐 들어가는 조각(아랫몸 윗부분, 관절 공)을 이만큼 가늘게 (겹친 면이 지글거리지 않게)
		HandRatio = Vector3.new(0.75, 3.2, 0.85), -- 손 타원 크기 (손 크기에 대한 비율)
		ShoeRatio = Vector3.new(1.0, 2.0, 1.4), -- 신발 타원 크기 (발 크기에 대한 비율)
		ShoeForward = 0.15, -- 신발이 앞으로 나온 정도
		ShoeLift = 0.5, -- 신발을 위로 올리는 정도 (발 높이에 대한 비율, 바닥에 묻히지 않게)
	},
	Blush = { size = Vector3.new(0.14, 0.07, 0.03), gapX = 0.3, y = -0.08, color = Color3.fromRGB(255, 130, 150), transparency = 0.35 },
	Freckles = { size = 0.025, color = Color3.fromRGB(150, 90, 60), y = -0.07, gapX = 0.28, spread = 0.05 },
	Glasses = {
		lens = Vector3.new(0.22, 0.24, 0.02), gapX = 0.12, y = 0.1, front = 0.08, -- 기본 얼굴 눈 위치에 맞춤
		lensColor = Color3.fromRGB(200, 230, 255), lensTransparency = 0.6,
		bridge = Vector3.new(0.1, 0.025, 0.02), frameColor = Color3.fromRGB(30, 30, 35), rim = 0.03,
	},
	-- 머리카락 : 모든 머리 모양은 정수리를 덮는 "모자" 부분을 먼저 깔고 모양마다 덧붙인다
	HairCap = { size = Vector3.new(1.1, 0.78, 1.1), offset = Vector3.new(0, 0.36, 0.06) }, -- 이마가 보이게 조금 위로
	Hair = {
		spiky = { count = 6, spike = Vector3.new(0.16, 0.32, 0.16), radius = 0.3, y = 0.6, tiltDegrees = 25 },
		sidepart = { fringe = Vector3.new(0.55, 0.2, 0.3), offset = Vector3.new(-0.15, 0.4, -0.36), tiltDegrees = 12 },
		ponytail = { knot = 0.32, knotOffset = Vector3.new(0, 0.3, 0.58), tail = Vector3.new(0.22, 0.6, 0.22), tailOffset = Vector3.new(0, -0.05, 0.68) },
		cap = { brim = Vector3.new(0.95, 0.08, 0.8), brimOffset = Vector3.new(0, 0.3, -0.72), top = Vector3.new(1.14, 0.62, 1.14), topOffset = Vector3.new(0, 0.38, 0.03), button = 0.1 },
		buns = { bun = 0.38, gapX = 0.4, y = 0.5, z = 0.1 },
		curly = { count = 14, curl = 0.3, radius = 0.5, y = 0.42, rise = 0.5, backZ = 0.05 },
		headband = { band = Vector3.new(1.12, 0.12, 1.12), y = 0.3, color = Color3.fromRGB(255, 255, 255) },
		long = { back = Vector3.new(1.0, 1.25, 0.32), backOffset = Vector3.new(0, -0.2, 0.42), side = Vector3.new(0.18, 0.9, 0.5), sideGapX = 0.5, sideY = -0.1 },
	},
	HairClip = { size = 0.16, offset = Vector3.new(0.42, 0.32, -0.25), color = Color3.fromRGB(255, 220, 60) },
	-- 옷
	CollarSize = Vector3.new(0.55, 0.12, 0.55), -- 윗옷 목둘레 (둥근 몸통 크기에 대한 비율)
	NumberCardSize = Vector3.new(0.6, 0.7, 0.02), -- 등번호 판 크기 (둥근 몸통 크기에 대한 비율)
	NumberCardGap = 0.02, -- 등번호 판이 등에서 떨어진 거리
	CatalogJerseyWidth = 0.75, -- 카탈로그 몸일 때 등번호 판 너비 (몸통 너비에 대한 비율)
	CollarDarken = 0.15, -- 목둘레는 윗옷보다 조금 진하게
	NumberColor = Color3.fromRGB(255, 255, 255), -- 등번호 색
	NumberPixelsPerStud = 50, -- 등번호 글자 선명도
	NumberStrokeTransparency = 0.5, -- 등번호 테두리 진하기
}

-- 코트 무늬와 공 꼬리 (server/Scenery.lua, BallService가 쓴다)
Config.Scenery = {
	MarkThickness = 0.05, -- 바닥 무늬 두께
	CenterCircleRadius = 6, -- 가운데 원 반지름
	CenterLineWidth = 0.6, -- 가운데 원 선 두께
	LogoText = "SUPER DODGEBALL", -- 코트 가운데 글자
	LogoSize = Vector2.new(26, 5), -- 글자판 크기 (스터드)
	LogoColor = Color3.fromRGB(255, 255, 255),
	LogoTransparency = 0.25,
	-- 공 꼬리 (날아갈 때만)
	BallTrailLifetime = 0.25,
	BallTrailWidth = 0.8, -- 꼬리 굵기 (스터드)
	BallTrailColor = Color3.fromRGB(255, 255, 255),
	BallTrailTransparency = NumberSequence.new(0.3, 1),
}

-- 경기장 (server/ArenaService.lua) : 판마다 무작위로 바뀌는 장소. 튜토리얼은 체육관.
local V = Vector3.new
local RGB = Color3.fromRGB
local M = Enum.Material

-- 경기장 공통
Config.Arena = {
	TutorialArena = "gym", -- 튜토리얼 판 장소
	LayoutScale = 1.3, -- 경기장 넓이 배 : 방 크기와 가구 놓는 자리를 이만큼 넓힌다 (가구 크기는 그대로)
	FirstArena = "playground", -- 서버를 켰을 때 로비 장소
	WallThickness = 2, -- 벽·바닥·천장 두께
	FloorLift = 0.05, -- 방 바닥 높이 (코트 테두리보다 조금 낮게)
	TrimHeight = 1.5, TrimDepth = 0.4, -- 걸레받이 높이·두께
	LampSize = V(8, 0.4, 8), LampRange = 60, -- 천장 전등 크기, 빛이 닿는 거리
	DefaultColor = RGB(200, 200, 200),
	TextColor = RGB(255, 255, 255), TextPixelsPerStud = 20,
	AtmosphereHaze = 1.2, AtmosphereColor = RGB(200, 220, 255),
	BloomIntensity = 0.4, BloomSize = 24, BloomThreshold = 1.4,
	Saturation = 0.15, Contrast = 0.08, -- 색을 조금 더 진하고 또렷하게
	SunRaysIntensity = 0.06,
}

-- 가구 조립법 : 부품 목록. 크기 1 = 보통 사람(키 5) 기준. 앞(-Z)이 코트 쪽을 본다.
-- kind = block(상자) / ball(공·타원) / column(세운 원기둥, size = 지름·높이·지름)
-- at = 놓는 자리 바닥 가운데에서 부품 가운데까지, rot = 돌리기(도), tint = 경기장에서 정한 색으로 칠함
local WOOD, DARKWOOD, METAL, WHITE = RGB(205, 160, 110), RGB(120, 80, 50), RGB(150, 155, 165), RGB(250, 250, 250)
Config.Prefabs = {
	-- 운동장
	stand = { -- 계단식 관중석 (줄마다 의자 색)
		{ kind = "block", size = V(24, 1.4, 3), at = V(0, 0.7, 1.5), color = RGB(200, 200, 210), mat = M.Concrete },
		{ kind = "block", size = V(24, 2.8, 3), at = V(0, 1.4, 4.5), color = RGB(200, 200, 210), mat = M.Concrete },
		{ kind = "block", size = V(24, 4.2, 3), at = V(0, 2.1, 7.5), color = RGB(200, 200, 210), mat = M.Concrete },
		{ kind = "block", size = V(24, 5.6, 3), at = V(0, 2.8, 10.5), color = RGB(200, 200, 210), mat = M.Concrete },
		{ kind = "block", size = V(24, 0.4, 1.8), at = V(0, 1.6, 1.5), color = RGB(240, 95, 70) },
		{ kind = "block", size = V(24, 0.4, 1.8), at = V(0, 3.0, 4.5), color = RGB(40, 180, 170) },
		{ kind = "block", size = V(24, 0.4, 1.8), at = V(0, 4.4, 7.5), color = RGB(255, 240, 100) },
		{ kind = "block", size = V(24, 0.4, 1.8), at = V(0, 5.8, 10.5), color = RGB(170, 140, 220) },
	},
	tree = {
		{ kind = "column", size = V(1.4, 7, 1.4), at = V(0, 3.5, 0), color = RGB(110, 75, 50), mat = M.Wood },
		{ kind = "ball", size = V(8, 8, 8), at = V(0, 9, 0), color = RGB(80, 160, 80), mat = M.Grass },
		{ kind = "ball", size = V(6, 6, 6), at = V(2, 7, 1), color = RGB(110, 180, 90), mat = M.Grass },
		{ kind = "ball", size = V(5.6, 5.6, 5.6), at = V(-1.5, 7.5, -1.5), color = RGB(70, 140, 100), mat = M.Grass },
	},
	flag = {
		{ kind = "column", size = V(0.4, 12, 0.4), at = V(0, 6, 0), color = RGB(230, 230, 235), mat = M.Metal },
		{ kind = "block", size = V(0.2, 2.2, 3.5), at = V(0, 10.9, 1.75), tint = true, mat = M.Fabric },
	},
	-- 학교
	deskSet = { -- 책상 + 뒤에 의자 (의자 색은 tint)
		{ kind = "block", size = V(4, 0.3, 2.6), at = V(0, 2.6, 0), color = WOOD },
		{ kind = "block", size = V(3.6, 0.15, 2.2), at = V(0, 2.0, 0.1), color = METAL },
		{ kind = "block", size = V(0.25, 2.45, 0.25), at = V(1.8, 1.225, 1.1), color = METAL },
		{ kind = "block", size = V(0.25, 2.45, 0.25), at = V(-1.8, 1.225, 1.1), color = METAL },
		{ kind = "block", size = V(0.25, 2.45, 0.25), at = V(1.8, 1.225, -1.1), color = METAL },
		{ kind = "block", size = V(0.25, 2.45, 0.25), at = V(-1.8, 1.225, -1.1), color = METAL },
		{ kind = "block", size = V(1.8, 0.25, 1.8), at = V(0, 1.6, 2.4), tint = true },
		{ kind = "block", size = V(1.8, 1.6, 0.25), at = V(0, 2.6, 3.2), tint = true },
		{ kind = "block", size = V(0.2, 1.5, 0.2), at = V(0.75, 0.75, 1.65), color = METAL },
		{ kind = "block", size = V(0.2, 1.5, 0.2), at = V(-0.75, 0.75, 1.65), color = METAL },
		{ kind = "block", size = V(0.2, 1.5, 0.2), at = V(0.75, 0.75, 3.15), color = METAL },
		{ kind = "block", size = V(0.2, 1.5, 0.2), at = V(-0.75, 0.75, 3.15), color = METAL },
	},
	teacherDesk = {
		{ kind = "block", size = V(7, 0.35, 3.5), at = V(0, 2.8, 0), color = WOOD },
		{ kind = "block", size = V(6.8, 2.6, 0.3), at = V(0, 1.3, -1.6), color = DARKWOOD },
		{ kind = "block", size = V(0.3, 2.6, 3.2), at = V(3.3, 1.3, 0), color = DARKWOOD },
		{ kind = "block", size = V(0.3, 2.6, 3.2), at = V(-3.3, 1.3, 0), color = DARKWOOD },
		{ kind = "ball", size = V(0.7, 0.7, 0.7), at = V(2, 3.32, 0), color = RGB(220, 40, 40) }, -- 사과
		{ kind = "block", size = V(1.4, 0.4, 1), at = V(-2, 3.17, 0), color = RGB(60, 100, 200) }, -- 책
	},
	chalkboard = {
		{ kind = "block", size = V(30, 11, 0.4), at = V(0, 9.5, 0), color = DARKWOOD },
		{ kind = "block", size = V(29, 10, 0.5), at = V(0, 9.5, -0.05), color = RGB(40, 85, 60), text = { text = "오늘은 피구 시합!" } },
		{ kind = "block", size = V(30, 0.3, 0.9), at = V(0, 3.9, -0.4), color = DARKWOOD },
		{ kind = "block", size = V(0.8, 0.2, 0.2), at = V(5, 4.15, -0.5), color = WHITE },
		{ kind = "block", size = V(0.8, 0.2, 0.2), at = V(6.2, 4.15, -0.5), color = RGB(255, 170, 200) },
	},
	locker = { -- 사물함 한 칸 (색은 tint)
		{ kind = "block", size = V(3, 8, 2.5), at = V(0, 4, 0), tint = true, mat = M.Metal },
		{ kind = "block", size = V(2, 0.15, 0.05), at = V(0, 7, -1.27), color = RGB(60, 60, 70) },
		{ kind = "block", size = V(2, 0.15, 0.05), at = V(0, 6.6, -1.27), color = RGB(60, 60, 70) },
		{ kind = "block", size = V(0.15, 0.6, 0.15), at = V(0.9, 4, -1.3), color = METAL, mat = M.Metal },
	},
	window = {
		{ kind = "block", size = V(12, 9, 0.4), at = V(0, 10, 0), color = WHITE },
		{ kind = "block", size = V(11, 8, 0.5), at = V(0, 10, 0), color = RGB(170, 215, 255), transparency = 0.45, reflectance = 0.2, mat = M.Glass },
		{ kind = "block", size = V(0.3, 8, 0.6), at = V(0, 10, 0), color = WHITE },
		{ kind = "block", size = V(11, 0.3, 0.6), at = V(0, 10, 0), color = WHITE },
		{ kind = "block", size = V(12.5, 0.4, 1.2), at = V(0, 5.4, -0.5), color = WHITE },
	},
	clock = { -- 벽시계
		{ kind = "column", size = V(3.4, 0.25, 3.4), at = V(0, 14, 0.1), rot = V(90, 0, 0), color = RGB(30, 30, 35) },
		{ kind = "column", size = V(3, 0.3, 3), at = V(0, 14, 0), rot = V(90, 0, 0), color = WHITE },
		{ kind = "block", size = V(0.15, 1.1, 0.1), at = V(0, 14.5, -0.2), color = RGB(30, 30, 35) },
		{ kind = "block", size = V(0.8, 0.15, 0.1), at = V(0.35, 14, -0.2), color = RGB(30, 30, 35) },
	},
	hoop = { -- 농구 골대 (벽에 붙임)
		{ kind = "block", size = V(6, 4, 0.3), at = V(0, 13, 0), color = WHITE },
		{ kind = "block", size = V(2, 0.15, 0.05), at = V(0, 12.5, -0.18), color = RGB(220, 50, 40) },
		{ kind = "block", size = V(0.15, 1.4, 0.05), at = V(1, 11.8, -0.18), color = RGB(220, 50, 40) },
		{ kind = "block", size = V(0.15, 1.4, 0.05), at = V(-1, 11.8, -0.18), color = RGB(220, 50, 40) },
		{ kind = "block", size = V(0.3, 0.3, 1.2), at = V(0, 11, -0.75), color = METAL },
		{ kind = "block", size = V(1.05, 0.15, 0.15), at = V(1, 11, -1.4), rot = V(0, -90, 0), color = RGB(255, 120, 30) },
		{ kind = "block", size = V(1.05, 0.15, 0.15), at = V(0.5, 11, -0.534), rot = V(0, -150, 0), color = RGB(255, 120, 30) },
		{ kind = "block", size = V(1.05, 0.15, 0.15), at = V(-0.5, 11, -0.534), rot = V(0, -210, 0), color = RGB(255, 120, 30) },
		{ kind = "block", size = V(1.05, 0.15, 0.15), at = V(-1, 11, -1.4), rot = V(0, -270, 0), color = RGB(255, 120, 30) },
		{ kind = "block", size = V(1.05, 0.15, 0.15), at = V(-0.5, 11, -2.266), rot = V(0, -330, 0), color = RGB(255, 120, 30) },
		{ kind = "block", size = V(1.05, 0.15, 0.15), at = V(0.5, 11, -2.266), rot = V(0, -390, 0), color = RGB(255, 120, 30) },
		{ kind = "column", size = V(1.6, 1.4, 1.6), at = V(0, 10.2, -1.4), color = WHITE, transparency = 0.5, collide = false },
	},
	banner = { -- 벽에 거는 학교 깃발 (색은 tint)
		{ kind = "block", size = V(8, 5, 0.2), at = V(0, 16, 0), tint = true, mat = M.Fabric, text = { text = "SUPER 피구왕" } },
		{ kind = "block", size = V(8.4, 0.3, 0.3), at = V(0, 18.6, 0), color = DARKWOOD },
	},
	plant = { -- 화분
		{ kind = "column", size = V(1.6, 1.6, 1.6), at = V(0, 0.8, 0), color = RGB(190, 100, 60) },
		{ kind = "ball", size = V(2.4, 2.6, 2.4), at = V(0, 2.6, 0), color = RGB(80, 160, 80), mat = M.Grass },
		{ kind = "ball", size = V(1.6, 1.6, 1.6), at = V(0.7, 3.4, 0.3), color = RGB(110, 180, 90), mat = M.Grass },
	},
	-- 문구 (거인 교실)
	pencil = { -- 바닥에 누운 연필 (몸통 색은 tint)
		{ kind = "block", size = V(0.6, 0.6, 8), at = V(0, 0.3, 0), tint = true },
		{ kind = "ball", size = V(0.6, 0.6, 1.4), at = V(0, 0.3, -4.4), color = RGB(235, 200, 150) },
		{ kind = "ball", size = V(0.2, 0.2, 0.4), at = V(0, 0.3, -5.05), color = RGB(50, 50, 55) },
		{ kind = "block", size = V(0.64, 0.64, 0.5), at = V(0, 0.3, 4.25), color = METAL, mat = M.Metal },
		{ kind = "block", size = V(0.6, 0.6, 0.8), at = V(0, 0.3, 4.9), color = RGB(250, 150, 170) },
	},
	eraser = {
		{ kind = "block", size = V(3, 1.2, 1.8), at = V(0, 0.6, 0), color = WHITE },
		{ kind = "block", size = V(3.04, 1.24, 1), at = V(0, 0.6, 0.5), tint = true },
	},
	ruler = {
		{ kind = "block", size = V(14, 0.15, 1.6), at = V(0, 0.075, 0), color = RGB(255, 240, 160), transparency = 0.3,
			text = { text = "0  1  2  3  4  5  6  7  8  9  10", face = Enum.NormalId.Top, color = RGB(60, 60, 60) } },
	},
	bookStack = {
		{ kind = "block", size = V(3, 0.6, 2.2), at = V(0, 0.3, 0), color = RGB(220, 80, 70) },
		{ kind = "block", size = V(2.8, 0.6, 2), at = V(0.1, 0.9, 0.05), rot = V(0, 8, 0), color = RGB(60, 120, 200) },
		{ kind = "block", size = V(2.9, 0.6, 2.1), at = V(-0.1, 1.5, 0), rot = V(0, -6, 0), color = RGB(250, 200, 60) },
	},
	-- 집 (안방·식당·침실)
	wardrobe = { -- 장롱
		{ kind = "block", size = V(9, 11, 3.5), at = V(0, 5.5, 0), color = RGB(160, 110, 70), mat = M.Wood },
		{ kind = "block", size = V(9.4, 0.5, 3.8), at = V(0, 11.25, 0), color = DARKWOOD, mat = M.Wood },
		{ kind = "block", size = V(0.08, 10.5, 0.05), at = V(0, 5.5, -1.77), color = DARKWOOD },
		{ kind = "block", size = V(0.08, 10.5, 0.05), at = V(2.25, 5.5, -1.77), color = DARKWOOD },
		{ kind = "block", size = V(0.08, 10.5, 0.05), at = V(-2.25, 5.5, -1.77), color = DARKWOOD },
		{ kind = "block", size = V(0.15, 0.8, 0.15), at = V(0.35, 5.5, -1.8), color = RGB(230, 190, 80), mat = M.Metal },
		{ kind = "block", size = V(0.15, 0.8, 0.15), at = V(-0.35, 5.5, -1.8), color = RGB(230, 190, 80), mat = M.Metal },
	},
	vanity = { -- 화장대 + 거울 + 의자
		{ kind = "block", size = V(5, 3, 2.4), at = V(0, 1.5, 0), color = RGB(245, 240, 235) },
		{ kind = "block", size = V(3.8, 4.6, 0.25), at = V(0, 5.6, 0.9), color = RGB(160, 110, 70) },
		{ kind = "block", size = V(3.4, 4.2, 0.3), at = V(0, 5.6, 0.85), color = RGB(200, 215, 225), reflectance = 0.6 },
		{ kind = "column", size = V(1.6, 1.8, 1.6), at = V(0, 0.9, -2.2), color = RGB(250, 170, 190) },
		{ kind = "column", size = V(0.4, 0.8, 0.4), at = V(1.5, 3.4, 0.3), color = RGB(240, 120, 160) },
		{ kind = "ball", size = V(0.5, 0.5, 0.5), at = V(1, 3.25, 0.4), color = RGB(150, 200, 240) },
	},
	futonStack = { -- 개어 둔 이불
		{ kind = "block", size = V(6, 0.7, 4), at = V(0, 0.35, 0), color = RGB(250, 170, 190), mat = M.Fabric },
		{ kind = "block", size = V(6, 0.7, 4), at = V(0, 1.05, 0), color = RGB(150, 220, 200), mat = M.Fabric },
		{ kind = "block", size = V(6, 0.7, 4), at = V(0, 1.75, 0), color = RGB(255, 235, 140), mat = M.Fabric },
		{ kind = "ball", size = V(2.6, 0.8, 1.4), at = V(0, 2.5, 0), color = WHITE, mat = M.Fabric },
	},
	cushion = { -- 방석 (색은 tint)
		{ kind = "block", size = V(2.4, 0.35, 2.4), at = V(0, 0.175, 0), tint = true, mat = M.Fabric },
	},
	lowTable = { -- 좌식 상
		{ kind = "block", size = V(6, 0.4, 3.5), at = V(0, 1.6, 0), color = RGB(170, 115, 70), mat = M.Wood },
		{ kind = "block", size = V(0.4, 1.4, 0.4), at = V(2.6, 0.7, 1.4), color = DARKWOOD },
		{ kind = "block", size = V(0.4, 1.4, 0.4), at = V(-2.6, 0.7, 1.4), color = DARKWOOD },
		{ kind = "block", size = V(0.4, 1.4, 0.4), at = V(2.6, 0.7, -1.4), color = DARKWOOD },
		{ kind = "block", size = V(0.4, 1.4, 0.4), at = V(-2.6, 0.7, -1.4), color = DARKWOOD },
	},
	diningTable = {
		{ kind = "block", size = V(9, 0.4, 5), at = V(0, 2.8, 0), color = WOOD, mat = M.Wood },
		{ kind = "block", size = V(8, 0.05, 1.6), at = V(0, 3.03, 0), tint = true, mat = M.Fabric },
		{ kind = "block", size = V(0.45, 2.6, 0.45), at = V(4, 1.3, 2.1), color = DARKWOOD },
		{ kind = "block", size = V(0.45, 2.6, 0.45), at = V(-4, 1.3, 2.1), color = DARKWOOD },
		{ kind = "block", size = V(0.45, 2.6, 0.45), at = V(4, 1.3, -2.1), color = DARKWOOD },
		{ kind = "block", size = V(0.45, 2.6, 0.45), at = V(-4, 1.3, -2.1), color = DARKWOOD },
	},
	diningChair = { -- 등받이가 뒤(+Z)에 있다 (방석 색은 tint)
		{ kind = "block", size = V(1.9, 0.3, 1.9), at = V(0, 1.7, 0), color = WOOD },
		{ kind = "block", size = V(1.9, 2.4, 0.3), at = V(0, 3.05, 0.85), color = WOOD },
		{ kind = "block", size = V(1.7, 0.15, 1.7), at = V(0, 1.92, 0), tint = true, mat = M.Fabric },
		{ kind = "block", size = V(0.22, 1.6, 0.22), at = V(0.8, 0.8, 0.8), color = DARKWOOD },
		{ kind = "block", size = V(0.22, 1.6, 0.22), at = V(-0.8, 0.8, 0.8), color = DARKWOOD },
		{ kind = "block", size = V(0.22, 1.6, 0.22), at = V(0.8, 0.8, -0.8), color = DARKWOOD },
		{ kind = "block", size = V(0.22, 1.6, 0.22), at = V(-0.8, 0.8, -0.8), color = DARKWOOD },
	},
	riceBowl = { -- 밥그릇
		{ kind = "column", size = V(1.4, 0.8, 1.4), at = V(0, 0.4, 0), color = WHITE },
		{ kind = "column", size = V(1.45, 0.12, 1.45), at = V(0, 0.55, 0), color = RGB(60, 110, 200) },
		{ kind = "ball", size = V(1.3, 0.7, 1.3), at = V(0, 0.85, 0), color = WHITE },
	},
	spoon = {
		{ kind = "block", size = V(0.18, 0.08, 2), at = V(0, 0.04, 0), color = METAL, mat = M.Metal },
		{ kind = "ball", size = V(0.55, 0.12, 0.75), at = V(0, 0.06, -1.25), color = METAL, mat = M.Metal },
	},
	chopsticks = {
		{ kind = "block", size = V(0.1, 0.1, 2.4), at = V(0.12, 0.05, 0), color = METAL, mat = M.Metal },
		{ kind = "block", size = V(0.1, 0.1, 2.4), at = V(-0.12, 0.05, 0), color = METAL, mat = M.Metal },
	},
	plate = { -- 접시 + 음식 (음식 색은 tint)
		{ kind = "column", size = V(2, 0.15, 2), at = V(0, 0.075, 0), color = WHITE },
		{ kind = "ball", size = V(1, 0.5, 1), at = V(0, 0.3, 0), tint = true },
	},
	fridge = {
		{ kind = "block", size = V(4.4, 9, 3.6), at = V(0, 4.5, 0), color = RGB(240, 242, 245), mat = M.Metal },
		{ kind = "block", size = V(4.3, 0.08, 0.05), at = V(0, 6, -1.82), color = RGB(170, 170, 180) },
		{ kind = "block", size = V(0.2, 1.6, 0.2), at = V(1.8, 7.5, -1.9), color = RGB(170, 170, 180) },
		{ kind = "block", size = V(0.2, 1.6, 0.2), at = V(1.8, 3.5, -1.9), color = RGB(170, 170, 180) },
		{ kind = "ball", size = V(0.4, 0.4, 0.15), at = V(-1, 7, -1.82), color = RGB(230, 70, 60) },
		{ kind = "ball", size = V(0.4, 0.4, 0.15), at = V(-0.5, 4, -1.82), color = RGB(250, 210, 60) },
	},
	jar = { -- 장독
		{ kind = "ball", size = V(3.2, 3.6, 3.2), at = V(0, 1.8, 0), color = RGB(90, 55, 35) },
		{ kind = "column", size = V(2, 0.4, 2), at = V(0, 3.4, 0), color = RGB(70, 40, 25) },
		{ kind = "ball", size = V(2.2, 0.7, 2.2), at = V(0, 3.65, 0), color = RGB(110, 70, 45) },
	},
	bed = { -- 침대 (머리 쪽이 -Z, 이불 색은 tint)
		{ kind = "block", size = V(6, 1.2, 8), at = V(0, 0.6, 0), color = WOOD, mat = M.Wood },
		{ kind = "block", size = V(5.8, 1, 7.6), at = V(0, 1.7, 0), color = WHITE, mat = M.Fabric },
		{ kind = "block", size = V(5.9, 0.5, 5), at = V(0, 2.35, 1.3), tint = true, mat = M.Fabric },
		{ kind = "ball", size = V(3.6, 0.9, 1.8), at = V(0, 2.5, -2.7), color = WHITE, mat = M.Fabric },
		{ kind = "block", size = V(6, 3.4, 0.4), at = V(0, 1.7, -4), color = DARKWOOD, mat = M.Wood },
		{ kind = "block", size = V(6, 1.8, 0.3), at = V(0, 0.9, 4), color = DARKWOOD, mat = M.Wood },
	},
	teddy = { -- 곰 인형 (리본 색은 tint)
		{ kind = "ball", size = V(2.2, 2.4, 2), at = V(0, 1.2, 0), color = RGB(170, 115, 70), mat = M.Fabric },
		{ kind = "ball", size = V(1.7, 1.6, 1.6), at = V(0, 2.9, 0), color = RGB(170, 115, 70), mat = M.Fabric },
		{ kind = "ball", size = V(0.6, 0.6, 0.4), at = V(0.65, 3.6, 0), color = RGB(150, 100, 60), mat = M.Fabric },
		{ kind = "ball", size = V(0.6, 0.6, 0.4), at = V(-0.65, 3.6, 0), color = RGB(150, 100, 60), mat = M.Fabric },
		{ kind = "ball", size = V(0.7, 0.5, 0.4), at = V(0, 2.75, -0.75), color = RGB(225, 190, 150), mat = M.Fabric },
		{ kind = "ball", size = V(0.25, 0.18, 0.15), at = V(0, 2.9, -0.95), color = RGB(40, 30, 30) },
		{ kind = "ball", size = V(0.2, 0.2, 0.1), at = V(0.32, 3.15, -0.78), color = RGB(40, 30, 30) },
		{ kind = "ball", size = V(0.2, 0.2, 0.1), at = V(-0.32, 3.15, -0.78), color = RGB(40, 30, 30) },
		{ kind = "ball", size = V(0.8, 1.2, 0.8), at = V(1.2, 1.5, -0.1), color = RGB(170, 115, 70), mat = M.Fabric },
		{ kind = "ball", size = V(0.8, 1.2, 0.8), at = V(-1.2, 1.5, -0.1), color = RGB(170, 115, 70), mat = M.Fabric },
		{ kind = "ball", size = V(0.9, 0.8, 1.1), at = V(0.6, 0.4, -0.6), color = RGB(170, 115, 70), mat = M.Fabric },
		{ kind = "ball", size = V(0.9, 0.8, 1.1), at = V(-0.6, 0.4, -0.6), color = RGB(170, 115, 70), mat = M.Fabric },
		{ kind = "ball", size = V(0.8, 0.35, 0.3), at = V(0, 2.15, -0.85), tint = true },
	},
	toyBlock = { -- 장난감 블록 (색은 tint)
		{ kind = "block", size = V(2, 2, 2), at = V(0, 1, 0), tint = true, text = { text = "★" } },
	},
	floorLamp = { -- 스탠드 (불이 켜져 있다)
		{ kind = "column", size = V(1.6, 0.3, 1.6), at = V(0, 0.15, 0), color = RGB(60, 60, 70) },
		{ kind = "column", size = V(0.25, 6, 0.25), at = V(0, 3, 0), color = RGB(60, 60, 70), mat = M.Metal },
		{ kind = "column", size = V(2.4, 1.8, 2.4), at = V(0, 6.6, 0), color = RGB(255, 240, 210),
			light = { brightness = 1.5, range = 30, color = RGB(255, 220, 170) } },
	},
	-- 도서관
	bookshelf = { -- 책장 (책이 칸마다 색색이 꽂혀 있다)
		{ kind = "block", size = V(8, 12, 0.3), at = V(0, 6, 1.1), color = DARKWOOD, mat = M.Wood },
		{ kind = "block", size = V(0.4, 12, 2.5), at = V(3.8, 6, 0), color = DARKWOOD, mat = M.Wood },
		{ kind = "block", size = V(0.4, 12, 2.5), at = V(-3.8, 6, 0), color = DARKWOOD, mat = M.Wood },
		{ kind = "block", size = V(8.4, 0.5, 2.7), at = V(0, 12.1, 0), color = DARKWOOD, mat = M.Wood },
		{ kind = "block", size = V(7.2, 0.4, 2.3), at = V(0, 0.2, 0), color = DARKWOOD, mat = M.Wood },
		{ kind = "block", size = V(7.2, 0.3, 2.3), at = V(0, 3.0, 0), color = DARKWOOD, mat = M.Wood },
		{ kind = "block", size = V(7.2, 0.3, 2.3), at = V(0, 5.8, 0), color = DARKWOOD, mat = M.Wood },
		{ kind = "block", size = V(7.2, 0.3, 2.3), at = V(0, 8.6, 0), color = DARKWOOD, mat = M.Wood },
		{ kind = "block", size = V(2.3, 2.2, 1.8), at = V(-2.4, 1.5, 0.1), color = RGB(200, 70, 60) },
		{ kind = "block", size = V(2.3, 2.0, 1.8), at = V(0, 1.4, 0.1), color = RGB(60, 110, 190) },
		{ kind = "block", size = V(2.3, 2.3, 1.8), at = V(2.4, 1.55, 0.1), color = RGB(70, 150, 90) },
		{ kind = "block", size = V(2.3, 2.1, 1.8), at = V(-2.4, 4.2, 0.1), color = RGB(240, 190, 60) },
		{ kind = "block", size = V(2.3, 2.3, 1.8), at = V(0, 4.3, 0.1), color = RGB(150, 90, 170) },
		{ kind = "block", size = V(2.3, 1.9, 1.8), at = V(2.4, 4.1, 0.1), color = RGB(230, 120, 60) },
		{ kind = "block", size = V(2.3, 2.2, 1.8), at = V(-2.4, 7.05, 0.1), color = RGB(40, 150, 150) },
		{ kind = "block", size = V(2.3, 2.0, 1.8), at = V(0, 6.95, 0.1), color = RGB(130, 80, 50) },
		{ kind = "block", size = V(2.3, 2.3, 1.8), at = V(2.4, 7.1, 0.1), color = RGB(220, 90, 120) },
		{ kind = "block", size = V(2.3, 2.1, 1.8), at = V(-2.4, 9.8, 0.1), color = RGB(90, 140, 210) },
		{ kind = "block", size = V(2.3, 2.3, 1.8), at = V(0, 9.9, 0.1), color = RGB(250, 220, 100) },
		{ kind = "block", size = V(2.3, 1.9, 1.8), at = V(2.4, 9.7, 0.1), color = RGB(100, 170, 100) },
	},
	readingTable = { -- 열람 책상 + 초록 스탠드 + 펼친 책
		{ kind = "block", size = V(8, 0.35, 4), at = V(0, 2.7, 0), color = WOOD, mat = M.Wood },
		{ kind = "block", size = V(0.4, 2.5, 0.4), at = V(3.5, 1.25, 1.6), color = DARKWOOD },
		{ kind = "block", size = V(0.4, 2.5, 0.4), at = V(-3.5, 1.25, 1.6), color = DARKWOOD },
		{ kind = "block", size = V(0.4, 2.5, 0.4), at = V(3.5, 1.25, -1.6), color = DARKWOOD },
		{ kind = "block", size = V(0.4, 2.5, 0.4), at = V(-3.5, 1.25, -1.6), color = DARKWOOD },
		{ kind = "column", size = V(0.8, 0.2, 0.8), at = V(2.5, 2.97, 0), color = RGB(200, 160, 70), mat = M.Metal },
		{ kind = "column", size = V(0.15, 1.2, 0.15), at = V(2.5, 3.6, 0), color = RGB(200, 160, 70), mat = M.Metal },
		{ kind = "ball", size = V(1.4, 0.5, 0.8), at = V(2.5, 4.25, -0.1), color = RGB(40, 120, 70),
			light = { brightness = 1, range = 14, color = RGB(255, 225, 170) } },
		{ kind = "block", size = V(2, 0.12, 1.4), at = V(-1.5, 2.94, 0), color = WHITE },
	},
	quietSign = { -- "쉿! 조용히" 팻말
		{ kind = "column", size = V(0.3, 4.5, 0.3), at = V(0, 2.25, 0), color = METAL, mat = M.Metal },
		{ kind = "block", size = V(3.5, 2, 0.2), at = V(0, 5, 0), color = WHITE, text = { text = "쉿! 조용히", color = RGB(40, 40, 40) } },
	},
	globe = { -- 지구본
		{ kind = "column", size = V(1, 0.3, 1), at = V(0, 0.15, 0), color = DARKWOOD },
		{ kind = "column", size = V(0.2, 2.6, 0.2), at = V(0, 1.4, 0), color = RGB(200, 160, 70), mat = M.Metal },
		{ kind = "ball", size = V(2, 2, 2), at = V(0, 3.4, 0), color = RGB(70, 130, 210) },
		{ kind = "ball", size = V(0.9, 0.8, 0.6), at = V(0.4, 3.7, -0.75), color = RGB(90, 170, 90) },
		{ kind = "ball", size = V(0.7, 0.9, 0.6), at = V(-0.6, 3.1, -0.65), color = RGB(90, 170, 90) },
	},
	-- 박물관
	pillar = { -- 대리석 기둥
		{ kind = "block", size = V(5, 1, 5), at = V(0, 0.5, 0), color = RGB(235, 232, 225), mat = M.Marble },
		{ kind = "column", size = V(3.6, 30, 3.6), at = V(0, 16, 0), color = RGB(240, 238, 232), mat = M.Marble },
		{ kind = "block", size = V(5, 1.2, 5), at = V(0, 31.6, 0), color = RGB(235, 232, 225), mat = M.Marble },
	},
	statue = { -- 받침대 위 조각상
		{ kind = "block", size = V(3, 3.5, 3), at = V(0, 1.75, 0), color = RGB(225, 220, 210), mat = M.Marble },
		{ kind = "block", size = V(3.4, 0.3, 3.4), at = V(0, 3.65, 0), color = RGB(225, 220, 210), mat = M.Marble },
		{ kind = "column", size = V(1.2, 1.6, 1), at = V(0, 4.6, 0), color = RGB(242, 240, 235), mat = M.Marble },
		{ kind = "ball", size = V(1.6, 2.6, 1.2), at = V(0, 6.2, 0), color = RGB(242, 240, 235), mat = M.Marble },
		{ kind = "ball", size = V(1, 1.1, 1), at = V(0, 8.0, 0), color = RGB(242, 240, 235), mat = M.Marble },
		{ kind = "block", size = V(0.4, 1.6, 0.4), at = V(0.9, 6.5, -0.3), rot = V(30, 0, 0), color = RGB(242, 240, 235), mat = M.Marble },
	},
	vase = { -- 받침대 위 도자기 (색은 tint)
		{ kind = "block", size = V(3, 3.5, 3), at = V(0, 1.75, 0), color = RGB(225, 220, 210), mat = M.Marble },
		{ kind = "ball", size = V(1.8, 2.2, 1.8), at = V(0, 4.6, 0), tint = true },
		{ kind = "column", size = V(1.85, 0.3, 1.85), at = V(0, 4.6, 0), color = WHITE },
		{ kind = "column", size = V(0.8, 0.9, 0.8), at = V(0, 6.0, 0), tint = true },
		{ kind = "column", size = V(1.1, 0.2, 1.1), at = V(0, 6.5, 0), tint = true },
	},
	painting = { -- 벽에 건 그림 (바탕색은 tint)
		{ kind = "block", size = V(9, 7, 0.3), at = V(0, 12, 0), color = RGB(210, 170, 60) },
		{ kind = "block", size = V(8, 6, 0.35), at = V(0, 12, -0.03), tint = true },
		{ kind = "ball", size = V(1.4, 1.4, 0.1), at = V(2.2, 13.5, -0.25), color = RGB(255, 210, 70) },
		{ kind = "ball", size = V(6, 2.4, 0.1), at = V(-0.5, 10, -0.24), color = RGB(90, 160, 90) },
		{ kind = "block", size = V(1.6, 0.6, 0.1), at = V(0, 8, -0.1), color = WHITE },
	},
	rope = { -- 줄 쳐 둔 기둥 두 개
		{ kind = "column", size = V(0.35, 3, 0.35), at = V(4, 1.5, 0), color = RGB(210, 170, 60), mat = M.Metal },
		{ kind = "column", size = V(0.35, 3, 0.35), at = V(-4, 1.5, 0), color = RGB(210, 170, 60), mat = M.Metal },
		{ kind = "ball", size = V(0.6, 0.6, 0.6), at = V(4, 3.1, 0), color = RGB(210, 170, 60), mat = M.Metal },
		{ kind = "ball", size = V(0.6, 0.6, 0.6), at = V(-4, 3.1, 0), color = RGB(210, 170, 60), mat = M.Metal },
		{ kind = "block", size = V(8, 0.25, 0.25), at = V(0, 2.6, 0), color = RGB(170, 30, 40), mat = M.Fabric },
	},
	noTouchSign = { -- "만지지 마세요" 팻말
		{ kind = "column", size = V(0.3, 4.5, 0.3), at = V(0, 2.25, 0), color = METAL, mat = M.Metal },
		{ kind = "block", size = V(4, 2, 0.2), at = V(0, 5, 0), color = WHITE, text = { text = "만지지 마세요", color = RGB(170, 30, 40) } },
	},
	dinosaur = { -- 공룡 뼈 (받침대 위, 머리가 +X)
		{ kind = "block", size = V(20, 0.8, 6), at = V(0, 0.4, 0), color = RGB(70, 65, 60) },
		{ kind = "block", size = V(3, 1, 0.2), at = V(0, 0.9, -3.05), color = RGB(210, 170, 60), text = { text = "공룡 뼈", color = RGB(40, 30, 20) } },
		{ kind = "column", size = V(0.6, 5, 0.6), at = V(-2, 3.3, 1), color = RGB(235, 225, 200) },
		{ kind = "column", size = V(0.6, 5, 0.6), at = V(-2, 3.3, -1), color = RGB(235, 225, 200) },
		{ kind = "column", size = V(0.5, 4.6, 0.5), at = V(2.5, 3.1, 1), color = RGB(235, 225, 200) },
		{ kind = "column", size = V(0.5, 4.6, 0.5), at = V(2.5, 3.1, -1), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.4, 0.4, 0.4), at = V(-8, 4.5, 0), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.5, 0.5, 0.5), at = V(-6.5, 5, 0), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.6, 0.6, 0.6), at = V(-5, 5.5, 0), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.8, 0.8, 0.8), at = V(-3.5, 6, 0), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.9, 0.9, 0.9), at = V(-2, 6.3, 0), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.9, 0.9, 0.9), at = V(-0.5, 6.4, 0), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.9, 0.9, 0.9), at = V(1, 6.3, 0), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.8, 0.8, 0.8), at = V(2.5, 6.1, 0), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.6, 0.6, 0.6), at = V(3.8, 6.8, 0), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.6, 0.6, 0.6), at = V(5, 7.6, 0), color = RGB(235, 225, 200) },
		{ kind = "block", size = V(2.4, 1.4, 1.2), at = V(6.6, 8, 0), color = RGB(235, 225, 200) },
		{ kind = "block", size = V(2, 0.4, 1), at = V(6.6, 7.1, 0), rot = V(0, 0, -10), color = RGB(235, 225, 200) },
		{ kind = "ball", size = V(0.4, 0.4, 1.25), at = V(6.9, 8.2, 0), color = RGB(40, 35, 30) },
		{ kind = "block", size = V(1.6, 1, 2.2), at = V(-2, 6, 0), color = RGB(235, 225, 200) },
		{ kind = "block", size = V(1.2, 0.8, 2), at = V(2.5, 5.8, 0), color = RGB(235, 225, 200) },
		{ kind = "block", size = V(0.25, 2.6, 0.25), at = V(-1, 5.1, 0.9), rot = V(15, 0, 0), color = RGB(235, 225, 200) },
		{ kind = "block", size = V(0.25, 2.6, 0.25), at = V(-1, 5.1, -0.9), rot = V(-15, 0, 0), color = RGB(235, 225, 200) },
		{ kind = "block", size = V(0.25, 2.6, 0.25), at = V(0, 5.1, 0.9), rot = V(15, 0, 0), color = RGB(235, 225, 200) },
		{ kind = "block", size = V(0.25, 2.6, 0.25), at = V(0, 5.1, -0.9), rot = V(-15, 0, 0), color = RGB(235, 225, 200) },
		{ kind = "block", size = V(0.25, 2.6, 0.25), at = V(1, 5.1, 0.9), rot = V(15, 0, 0), color = RGB(235, 225, 200) },
		{ kind = "block", size = V(0.25, 2.6, 0.25), at = V(1, 5.1, -0.9), rot = V(-15, 0, 0), color = RGB(235, 225, 200) },
	},
}

-- 경기장 9곳. room = 방 (없으면 바깥), items = 놓을 가구 목록.
-- item : prefab(조립법 이름) 또는 parts(부품 목록), scale(크기 배), pos(바닥 자리), rotY(돌리기, 0이면 앞이 -Z),
--        repeatCount + step(줄지어 여러 개), ring(코트를 둘러싼 원 : count, radius, startDeg), colors(tint 색, 차례로)
-- 방 크기 : half = 가운데에서 벽까지, height = 천장 높이. 거인 교실만 내가 작아진 것처럼 가구가 거대하다.
-- y = 바닥에서 띄우는 높이 (식탁 위 그릇처럼)
local SHIRTS = { RGB(240, 95, 70), RGB(40, 180, 170), RGB(130, 220, 180), RGB(120, 190, 240), RGB(250, 130, 130), RGB(255, 240, 100), RGB(255, 180, 120), RGB(170, 140, 220) }
local OUTDOOR = { clockTime = 14.5, brightness = 2.5, ambient = RGB(90, 90, 100), outdoorAmbient = RGB(140, 140, 150), atmosphereDensity = 0.28, tint = RGB(255, 255, 255) }
local INDOOR = { clockTime = 14, brightness = 1, ambient = RGB(150, 150, 158), outdoorAmbient = RGB(120, 120, 130), atmosphereDensity = 0, tint = RGB(255, 255, 255) }
local WARM_INDOOR = { clockTime = 14, brightness = 1, ambient = RGB(160, 150, 140), outdoorAmbient = RGB(120, 120, 130), atmosphereDensity = 0, tint = RGB(255, 245, 230) }
Config.Arenas = {
	{
		id = "playground", name = "학교 운동장", light = OUTDOOR,
		items = {
			{ prefab = "stand", ring = { count = 4, radius = 58, startDeg = 45 } },
			{ prefab = "tree", ring = { count = 12, radius = 76 } },
			{ prefab = "flag", ring = { count = 8, radius = 50, startDeg = 22.5 }, colors = SHIRTS },
		},
	},
	{
		id = "gym", name = "체육관", light = INDOOR, courtColor = RGB(70, 140, 220),
		room = {
			half = 70, height = 44, floorColor = RGB(215, 170, 115), floorMat = M.WoodPlanks,
			wallColor = RGB(225, 230, 240), trimColor = RGB(60, 90, 160), ceilingColor = RGB(240, 240, 245),
			lightGrid = 3, lampColor = RGB(255, 250, 235), lampBrightness = 2,
		},
		items = {
			{ prefab = "hoop", pos = V(0, 0, 69.8) },
			{ prefab = "hoop", pos = V(0, 0, -69.8), rotY = 180 },
			{ prefab = "stand", pos = V(56, 0, 0), rotY = 90 },
			{ prefab = "stand", pos = V(-56, 0, 0), rotY = -90 },
			{ prefab = "banner", pos = V(69.8, 0, -30), rotY = 90, repeatCount = 2, step = V(0, 0, 60), colors = { RGB(240, 95, 70), RGB(40, 180, 170) } },
			{ prefab = "banner", pos = V(-69.8, 0, -30), rotY = -90, repeatCount = 2, step = V(0, 0, 60), colors = { RGB(255, 240, 100), RGB(170, 140, 220) } },
			{ prefab = "clock", pos = V(25, 0, -69.8), rotY = 180 },
		},
	},
	{
		id = "classroom", name = "넓은 교실", light = INDOOR, courtColor = RGB(110, 170, 120),
		room = {
			half = 70, height = 40, floorColor = RGB(200, 175, 140), floorMat = M.WoodPlanks,
			wallColor = RGB(250, 242, 222), trimColor = RGB(120, 90, 60), ceilingColor = RGB(250, 250, 250),
			lightGrid = 3, lampColor = RGB(255, 255, 245), lampBrightness = 2,
		},
		items = {
			{ prefab = "chalkboard", scale = 1.5, pos = V(0, 0, 69.6) },
			{ prefab = "teacherDesk", pos = V(0, 0, 60) },
			{ prefab = "clock", pos = V(32, 0, 69.8) },
			{ prefab = "deskSet", pos = V(62, 0, 40), rotY = 90, repeatCount = 7, step = V(0, 0, -12), colors = SHIRTS },
			{ prefab = "deskSet", pos = V(-62, 0, 40), rotY = -90, repeatCount = 7, step = V(0, 0, -12), colors = SHIRTS },
			{ prefab = "locker", pos = V(-31, 0, -68.6), rotY = 180, repeatCount = 21, step = V(3.1, 0, 0), colors = SHIRTS },
			{ prefab = "window", pos = V(69.8, 0, -40), rotY = 90, repeatCount = 5, step = V(0, 0, 20) },
			{ prefab = "plant", pos = V(60, 0, 60), scale = 1.5 },
			{ prefab = "plant", pos = V(-60, 0, 60), scale = 1.5 },
		},
	},
	{
		id = "giantClassroom", name = "거인 교실", light = INDOOR, courtColor = RGB(240, 240, 232),
		room = {
			half = 70, height = 64, floorColor = RGB(200, 175, 140), floorMat = M.WoodPlanks,
			wallColor = RGB(250, 242, 222), trimColor = RGB(120, 90, 60), ceilingColor = RGB(250, 250, 250),
			lightGrid = 2, lampColor = RGB(255, 255, 245), lampBrightness = 3,
		},
		items = {
			{ prefab = "chalkboard", scale = 4, pos = V(0, 0, 69.6) },
			{ prefab = "deskSet", scale = 5, pos = V(52, 0, -48), rotY = 45, colors = { RGB(120, 190, 240) } },
			{ prefab = "deskSet", scale = 5, pos = V(-52, 0, -48), rotY = -45, colors = { RGB(250, 130, 130) } },
			{ prefab = "pencil", scale = 4, pos = V(-10, 0, 56), rotY = 90, colors = { RGB(255, 220, 60) } },
			{ prefab = "pencil", scale = 4, pos = V(56, 0, 14), rotY = 10, colors = { RGB(240, 95, 70) } },
			{ prefab = "eraser", scale = 5, pos = V(-58, 0, 10), rotY = 70, colors = { RGB(60, 110, 200) } },
			{ prefab = "ruler", scale = 4, pos = V(0, 0, -60) },
			{ prefab = "bookStack", scale = 5, pos = V(55, 0, 52) },
		},
	},
	{
		id = "anbang", name = "안방", light = WARM_INDOOR, courtColor = RGB(120, 170, 220),
		room = {
			half = 70, height = 30, floorColor = RGB(232, 190, 120), floorMat = M.SmoothPlastic, -- 노란 장판
			wallColor = RGB(245, 235, 215), trimColor = RGB(150, 110, 70), ceilingColor = RGB(250, 245, 235),
			lightGrid = 3, lampColor = RGB(255, 245, 225), lampBrightness = 2,
		},
		items = {
			{ prefab = "wardrobe", pos = V(-45, 0, 68), repeatCount = 10, step = V(10, 0, 0) },
			{ prefab = "futonStack", pos = V(65.5, 0, -40), rotY = 90, repeatCount = 9, step = V(0, 0, 10) },
			{ prefab = "vanity", pos = V(-66, 0, -30), rotY = -90, repeatCount = 3, step = V(0, 0, 30) },
			{ prefab = "lowTable", pos = V(-40, 0, -59), repeatCount = 3, step = V(40, 0, 0) },
			{ prefab = "cushion", pos = V(-42, 0, -53.5), repeatCount = 3, step = V(40, 0, 0), colors = { RGB(240, 95, 70), RGB(130, 220, 180), RGB(255, 240, 100) } },
			{ prefab = "cushion", pos = V(-38, 0, -64.5), repeatCount = 3, step = V(40, 0, 0), colors = { RGB(170, 140, 220), RGB(250, 130, 130), RGB(120, 190, 240) } },
			{ prefab = "floorLamp", pos = V(-62, 0, 62) },
			{ prefab = "plant", pos = V(62, 0, 62) },
			{ prefab = "clock", pos = V(0, 0, 69.8), rotY = 0 },
		},
	},
	{
		id = "dining", name = "식당", light = WARM_INDOOR, courtColor = RGB(240, 150, 120),
		room = {
			half = 70, height = 30, floorColor = RGB(235, 230, 220), floorMat = M.Marble,
			wallColor = RGB(255, 245, 230), trimColor = RGB(180, 120, 80), ceilingColor = RGB(255, 250, 245),
			lightGrid = 3, lampColor = RGB(255, 240, 215), lampBrightness = 2,
		},
		items = {
			-- 코트를 빙 둘러싼 식탁 10개, 식탁마다 앞뒤로 의자, 위에 밥그릇
			{ prefab = "diningTable", ring = { count = 10, radius = 58 }, colors = SHIRTS },
			{ prefab = "diningChair", ring = { count = 10, radius = 52.5 }, rotY = 180, colors = SHIRTS },
			{ prefab = "diningChair", ring = { count = 10, radius = 63.5 }, colors = SHIRTS },
			{ prefab = "riceBowl", ring = { count = 10, radius = 57 }, y = 3.03 },
			{ prefab = "plate", ring = { count = 10, radius = 59, startDeg = 4 }, y = 3.03, colors = { RGB(250, 200, 60), RGB(230, 70, 60) } },
			-- 구석 식탁 4개
			{ prefab = "diningTable", pos = V(61, 0, 61), rotY = 45, colors = SHIRTS },
			{ prefab = "diningTable", pos = V(-61, 0, 61), rotY = -45, colors = SHIRTS },
			{ prefab = "diningTable", pos = V(61, 0, -61), rotY = 135, colors = SHIRTS },
			{ prefab = "diningTable", pos = V(-61, 0, -61), rotY = -135, colors = SHIRTS },
			{ prefab = "fridge", pos = V(-30, 0, 67.8), repeatCount = 2, step = V(-6, 0, 0) },
			{ prefab = "jar", pos = V(28, 0, 67), repeatCount = 3, step = V(5, 0, 0) },
		},
	},
	{
		id = "bedroom", name = "침실", light = WARM_INDOOR, courtColor = RGB(170, 140, 220),
		room = {
			half = 70, height = 30, floorColor = RGB(190, 150, 110), floorMat = M.WoodPlanks,
			wallColor = RGB(220, 235, 250), trimColor = RGB(250, 250, 250), ceilingColor = RGB(250, 250, 255),
			lightGrid = 3, lampColor = RGB(255, 250, 240), lampBrightness = 2,
		},
		items = {
			{ parts = { { kind = "column", size = V(100, 0.04, 100), at = V(0, 0.06, 0), color = RGB(250, 180, 200), mat = M.Fabric, collide = false } }, pos = V(0, 0, 0) }, -- 동그란 러그
			-- 네 벽을 따라 침대가 줄지어 있다 (머리 쪽이 벽)
			{ prefab = "bed", pos = V(-56, 0, 65.6), rotY = 180, repeatCount = 15, step = V(8, 0, 0), colors = SHIRTS },
			{ prefab = "bed", pos = V(-56, 0, -65.6), repeatCount = 15, step = V(8, 0, 0), colors = SHIRTS },
			{ prefab = "bed", pos = V(65.6, 0, -44), rotY = -90, repeatCount = 12, step = V(0, 0, 8), colors = SHIRTS },
			{ prefab = "bed", pos = V(-65.6, 0, -44), rotY = 90, repeatCount = 12, step = V(0, 0, 8), colors = SHIRTS },
			{ prefab = "teddy", pos = V(-40, 0, 58), rotY = 0, repeatCount = 3, step = V(40, 0, 0), colors = { RGB(240, 95, 70), RGB(40, 180, 170), RGB(255, 240, 100) } },
			{ prefab = "toyBlock", pos = V(52, 0, -52), repeatCount = 3, step = V(2.5, 0, 1), colors = { RGB(240, 95, 70), RGB(255, 240, 100), RGB(40, 180, 170) } },
		},
	},
	{
		id = "library", name = "도서관", quiet = true, light = WARM_INDOOR, courtColor = RGB(90, 140, 110),
		room = {
			half = 70, height = 40, floorColor = RGB(130, 45, 50), floorMat = M.Fabric, -- 짙은 빨간 카펫
			wallColor = RGB(235, 225, 205), trimColor = RGB(120, 80, 50), ceilingColor = RGB(245, 240, 230),
			lightGrid = 3, lampColor = RGB(255, 240, 215), lampBrightness = 2,
		},
		items = {
			{ prefab = "bookshelf", scale = 1.5, pos = V(-54, 0, 68.1), repeatCount = 10, step = V(12, 0, 0) },
			{ prefab = "bookshelf", scale = 1.5, pos = V(-54, 0, -68.1), rotY = 180, repeatCount = 10, step = V(12, 0, 0) },
			{ prefab = "bookshelf", scale = 1.5, pos = V(68.1, 0, -42), rotY = 90, repeatCount = 8, step = V(0, 0, 12) },
			{ prefab = "bookshelf", scale = 1.5, pos = V(-68.1, 0, -42), rotY = -90, repeatCount = 8, step = V(0, 0, 12) },
			{ prefab = "readingTable", pos = V(-30, 0, 57), repeatCount = 2, step = V(60, 0, 0) },
			{ prefab = "readingTable", pos = V(-30, 0, -57), rotY = 180, repeatCount = 2, step = V(60, 0, 0) },
			{ prefab = "quietSign", pos = V(-12, 0, 54) },
			{ prefab = "quietSign", pos = V(12, 0, -54), rotY = 180 },
			{ prefab = "quietSign", pos = V(56, 0, 0), rotY = 90 },
			{ prefab = "globe", scale = 1.5, pos = V(-56, 0, 0), rotY = -90 },
		},
	},
	{
		id = "museum", name = "박물관", quiet = true, light = INDOOR, courtColor = RGB(190, 55, 60), -- 빨간 카펫 코트
		room = {
			half = 70, height = 48, floorColor = RGB(235, 232, 225), floorMat = M.Marble,
			wallColor = RGB(240, 235, 225), trimColor = RGB(190, 160, 90), ceilingColor = RGB(250, 248, 240),
			lightGrid = 3, lampColor = RGB(255, 252, 245), lampBrightness = 2,
		},
		items = {
			{ prefab = "pillar", scale = 1.4, ring = { count = 8, radius = 56, startDeg = 22.5 } },
			{ prefab = "dinosaur", scale = 1.6, pos = V(0, 0, 58) },
			{ prefab = "rope", pos = V(-8, 0, 49), repeatCount = 3, step = V(8, 0, 0) },
			{ prefab = "noTouchSign", pos = V(-17, 0, 48) },
			{ prefab = "noTouchSign", pos = V(17, 0, 48) },
			{ prefab = "painting", scale = 1.3, pos = V(69.8, 0, -30), rotY = 90, repeatCount = 3, step = V(0, 0, 30),
				colors = { RGB(150, 200, 240), RGB(255, 200, 160), RGB(180, 230, 200) } },
			{ prefab = "painting", scale = 1.3, pos = V(-69.8, 0, -30), rotY = -90, repeatCount = 3, step = V(0, 0, 30),
				colors = { RGB(250, 230, 150), RGB(200, 180, 240), RGB(250, 170, 170) } },
			{ prefab = "painting", scale = 1.3, pos = V(-30, 0, -69.8), rotY = 180, repeatCount = 3, step = V(30, 0, 0),
				colors = { RGB(170, 220, 230), RGB(240, 200, 120), RGB(210, 200, 250) } },
			{ prefab = "statue", scale = 1.5, pos = V(52, 0, -52), rotY = 135 },
			{ prefab = "statue", scale = 1.5, pos = V(-52, 0, -52), rotY = -135 },
			{ prefab = "vase", scale = 1.5, pos = V(52, 0, 52), colors = { RGB(60, 110, 200) } },
			{ prefab = "vase", scale = 1.5, pos = V(-52, 0, 52), colors = { RGB(70, 150, 120) } },
		},
	},
}

-- NPC·분신 애니메이션 (로블록스 기본 R15 애니메이션)
Config.Animation = {
	Idle = "rbxassetid://507766388",
	Walk = "rbxassetid://507777826",
	Sit = "rbxassetid://2506281703",
	WalkThreshold = 0.5, -- 이보다 빠르면 걷는 동작
	FadeSeconds = 0.2, -- 동작이 바뀔 때 부드럽게 섞는 시간
}

-- 소리 (server/SoundFx.lua) : 효과음은 로블록스 기본 소리, 배경 음악은 목록의 곡을 차례로 시도
Config.Sounds = {
	Effects = {
		Throw = { id = "rbxasset://sounds/swoosh.wav", volume = 0.7 }, -- 던질 때 휙
		Hit = { id = "rbxasset://sounds/uuhhh.mp3", volume = 0.9 }, -- 맞아서 아웃 (oof!)
		Catch = { id = "rbxasset://sounds/electronicpingshort.wav", volume = 0.8 }, -- 캐치 띵
		Ability = { id = "rbxasset://sounds/electronicpingshort.wav", volume = 0.7, pitch = 1.6 }, -- 능력 쓰기
		Box = { id = "rbxasset://sounds/clickfast.wav", volume = 0.8 }, -- 능력 상자 줍기
		Block = { id = "rbxasset://sounds/electronicpingshort.wav", volume = 0.9, pitch = 0.6 }, -- 방패로 막기
		Beep = { id = "rbxasset://sounds/button.wav", volume = 0.7 }, -- 카운트다운 삑
		Start = { id = "rbxasset://sounds/electronicpingshort.wav", volume = 0.9, pitch = 0.8 }, -- 시작!
		Win = { id = "rbxasset://sounds/victory.wav", volume = 0.9 }, -- 승리
	},
	HearDistance = 150, -- 효과음이 들리는 거리
	EffectLifetime = 5, -- 효과음을 치우기까지 시간 (초)
	-- 배경 음악 (앞의 곡이 안 되면 다음 곡) : Stadium Rave, Tear It Up, 공식 튜토리얼 곡, Happy Song
	MusicIds = { "rbxassetid://1846368080", "rbxassetid://1842763322", "rbxassetid://1841461968", "rbxassetid://1843404009" },
	MusicVolume = 0.45,
	MusicSpeed = 1.05, -- 조금 빠르게 (더 신나게)
}

-- 화면 표시
Config.Hud = {
	MessageSeconds = 2.5, -- 알림 글자가 떠 있는 시간
	AbilitySlotWidth = 110, -- 능력 칸 하나 너비 (픽셀)
	AbilitySlotHeight = 40, -- 능력 칸 높이 (픽셀)
	AbilitySlotGap = 8, -- 능력 칸 사이 간격 (픽셀)
}

return Config
