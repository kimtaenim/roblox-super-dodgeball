# Super Dodgeball — 로블록스 게임 설계서

아빠와 아들이 함께 만드는 능력 피구. 팀 없이 각자 살아남는 개인전.
대상 연령 : 초등 1-2학년. 조작 단순, 한 판 3-5분.

## 1. 핵심 규칙

### 1.1 플레이어 상태

| 상태 | 설명 | 할 수 있는 것 |
|---|---|---|
| Alive | 코트 안에서 뛰어다님 | 이동, 공 줍기, 던지기, 캐치, 능력 사용 |
| Sitting | 아웃된 자리에 앉아 고정 | 캐치만 가능 (이동·던지기 불가) |

### 1.2 아웃과 부활

① Alive 플레이어가 공에 맞으면 → Sitting. 그 자리에 앉는다.
② 공에는 `thrower`(던진 사람)가 기록된다. 바닥에 닿으면 thrower는 지워진다 (죽은 공).
③ 누구든(Alive·Sitting 모두) 날아오는 공을 캐치하면 → 캐치한 사람은 Alive, thrower는 Sitting.
④ 플레이어 A가 Sitting이 되면, A가 아웃시킨 사람들(`A.kills`)은 전원 Alive로 부활한다. 부활 후 `A.kills`는 비운다.
⑤ 부활은 그 자리에서 일어선다 (위치 유지).
⑥ 마지막 1명이 Alive로 남거나, 제한시간(기본 4분) 종료 시 Alive 인원이 많은 쪽… 개인전이므로 "마지막까지 살아남은 사람" 승리. 동시에 여러 명이면 kills 수 순위.

### 1.3 서버 데이터 모델

```lua
PlayerState = {
  status   = "Alive" | "Sitting",
  killedBy = Player?,     -- 나를 아웃시킨 사람
  kills    = {Player},    -- 내가 아웃시킨 사람 목록
  gauge    = number,      -- 0-100 능력 게이지
  ability  = string?,     -- 보유 능력 id
}
BallState = {
  thrower  = Player?,     -- nil이면 죽은 공
  live     = boolean,     -- 바닥 닿기 전 true
  flags    = {},          -- 능력 효과 (강속구, 유도 등)
}
```

### 1.4 판정 순서 (한 틱)

① 공이 Alive 캐릭터에 닿음 → 그 캐릭터가 닿기 전 0.5초 안에 캐치 버튼을 눌렀으면 캐치, 아니면 피격 (자동 캐치 없음).
② 피격 : 피해자 Sitting, thrower.kills에 피해자 추가, 피해자.killedBy = thrower.
③ 캐치 : 캐처 Alive, thrower → Sitting 처리(②와 같은 절차, killedBy = 캐처).
④ 누군가 Sitting이 될 때마다 그 사람의 kills 전원 부활 → 부활자들의 killedBy = nil.
⑤ 연쇄 : 부활은 한 단계만. 부활한 사람의 kills는 건드리지 않는다 (무한 연쇄 방지).

### 1.5 공

- 기본 공 수 : 플레이어 수 ÷ 2 (최소 2개).
- 공은 던진 뒤 바닥에 한 번 닿으면 죽은 공 → 아무나 주울 수 있다.
- 죽은 공이 코트 밖으로 나가면 3초 뒤 코트 중앙으로 리스폰.
- 머리 맞음은 아웃 아님 (초등 피구 관행). 머리 부위 히트박스 제외.

## 2. 능력 시스템

### 2.1 게이지

- 생존 중 1초당 +4, 아웃시킬 때 +25, 캐치 성공 시 +30.
- 100이 되면 능력 1회 사용 가능 (버튼 깜빡임). 사용 후 0.
- 게임 시작 시 능력 1개를 랜덤 배정 (또는 로비에서 선택 — 1차는 랜덤).
- Sitting 중에는 게이지가 차지 않는다.

### 2.2 능력 9종

| id | 이름 | 효과 | 지속 | 구현 메모 |
|---|---|---|---|---|
| teleport | 텔레포트 | 바라보는 방향 20스터드 순간이동 (코트 밖이면 경계로 클램프) | 즉시 | CFrame 이동 |
| doubleball | 공 두 개 | 다음 던지기가 공 2개 (옆으로 15도 벌어짐) | 1회 | 공 복제, 복제공은 바닥 닿으면 소멸 |
| clone | 분신술 | 내 모습 분신 3개가 5초간 무작위 이동, 맞으면 터짐 | 5초 | 더미 모델 + Humanoid 없음 |
| shield | 방패 | 3초간 맞아도 아웃 안 됨, 공은 튕겨나감 | 3초 | 피격 판정 무시 플래그 |
| magnet | 자석 | 반경 25스터드 안 죽은 공이 손으로 끌려옴 | 즉시 | BodyPosition 또는 Tween |
| fastball | 강속구 | 다음 던지기 속도 2배, 중력 영향 없음 | 1회 | 공 flags.fast |
| homing | 유도탄 | 다음 공이 가장 가까운 Alive 적을 2초간 추적 | 1회 | 매 프레임 방향 보정, 최대 회전각 제한 |
| invisible | 투명 | 4초 투명 (손의 공은 보임) | 4초 | Transparency 0.9 |
| slow | 시간 느림 | 반경 30스터드 안 Alive 적 WalkSpeed 절반 | 3초 | 본인 제외 |

설계 원칙 : 상대를 직접 아웃시키는 능력은 없다. 모든 아웃은 반드시 공으로만.

## 3. 조작

| 입력 | PC | 모바일 |
|---|---|---|
| 이동 | WASD | 조이스틱 |
| 줍기 | 공 근처 자동 | 자동 |
| 던지기 | 마우스 왼클릭 (꾹 누르면 파워) | 던지기 버튼 |
| 캐치 | 마우스 오른클릭 / F | 캐치 버튼 |
| 능력 | Q | 능력 버튼 |

던지기 : 카메라 방향, 파워 0.3-1.0초 홀드. 최대 속도 80스터드/초.

## 4. 코트

- 원형 코트 반지름 40스터드, 벽 없음. 바깥은 낭떠러지가 아니라 평지(떨어지지 않음).
- 코트 밖으로 나가면 3초 경고 후 코트 안으로 강제 이동.
- 90초마다 코트 반지름 -8 (배틀로얄식 축소). Sitting 플레이어가 코트 밖에 남으면 코트 가장자리로 옮겨 앉힘.

## 5. 게임 흐름

① 로비 대기 (최소 2명, 대기 20초)
② 카운트다운 3초, 전원 Alive, 공 배치, 능력 배정
③ 플레이 (최대 4분)
④ 승자 표시 5초 → 로비

## 6. 프로젝트 구조 (Rojo)

```
default.project.json
src/
  server/
    GameManager.server.lua     -- 로비·라운드·타이머
    PlayerStateService.lua     -- Alive/Sitting, kills, 부활 연쇄
    BallService.lua            -- 공 생성·던지기·판정·리스폰
    AbilityService.lua         -- 게이지, 능력 실행 (shared/Abilities 호출)
    CourtService.lua           -- 코트 축소, 경계
  client/
    InputController.client.lua -- 조작 입력 → RemoteEvent
    HUD.client.lua             -- 게이지, 상태, 남은 인원, 타이머
    ThrowCamera.client.lua     -- 던지기 조준
  shared/
    Config.lua                 -- 모든 숫자 (속도, 시간, 반지름)
    Remotes.lua                -- RemoteEvent 이름 모음
    Abilities/
      init.lua                 -- id → 모듈 테이블
      Teleport.lua
      DoubleBall.lua
      Clone.lua
      Shield.lua
      Magnet.lua
      Fastball.lua
      Homing.lua
      Invisible.lua
      Slow.lua
```

능력 모듈 공통 인터페이스 :

```lua
return {
  id = "teleport",
  name = "텔레포트",
  canUse = function(player, state) return state.status == "Alive" end,
  activate = function(player, state, services) ... end,
}
```

새 능력 추가 = 파일 하나 + init.lua에 한 줄.

## 7. 개발 순서

① 코트 + 이동 + 공 줍기/던지기 (능력 없이)
② Alive/Sitting + 피격 + 캐치
③ 부활 연쇄 (kills) — 여기까지가 "개인 피구" 완성
④ 게이지 + 능력 3개 (텔레포트·방패·공 두 개)
⑤ 나머지 능력 6개
⑥ 코트 축소, HUD 마무리, 모바일 버튼

## 8. 미결 사항

- 게임 이름 : Super Dodgeball (레포명 기준, 한글 표기 미정)
- 능력 선택 방식 (랜덤 vs 로비 선택)
- 로벅스 결제 연동 여부 (Flick Flock과 동일 방침이면 나중에)
