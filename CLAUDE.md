# CLAUDE.md — Super Dodgeball (개인 피구) 로블록스 게임

## 프로젝트
- 로블록스 게임. Rojo로 `src/`를 Studio에 동기화한다.
- 설계서는 `SUPER_DODGEBALL_DESIGN.md`. 규칙·숫자·구조는 전부 거기 따른다. 설계서와 코드가 다르면 설계서가 맞다.
- 개발 순서는 설계서 7장. 한 단계씩 끝내고 다음으로 간다. 미리 다음 단계 코드를 만들지 않는다.

## 코드 규칙
- Luau. 서버 권위 : 판정·상태 변경·능력 실행은 전부 서버. 클라이언트는 입력과 표시만.
- 모든 숫자(속도, 시간, 반지름, 게이지)는 `src/shared/Config.lua`에만 둔다. 코드 안에 매직넘버 금지.
- RemoteEvent 이름은 `src/shared/Remotes.lua`에서만 정의.
- 능력 1개 = `src/shared/Abilities/` 모듈 1개. 공통 인터페이스(`id, name, canUse, activate`)를 지킨다.
- 상대를 직접 아웃시키는 능력은 만들지 않는다. 아웃은 공으로만.
- 주석은 한국어. 아이가 읽는다. 함수마다 한 줄로 무엇을 하는지 쓴다.

## 작업 방식
- 파일을 새로 만들거나 구조를 바꾸기 전에 어느 파일을 왜 바꾸는지 한 줄로 먼저 말한다.
- 테스트는 Studio에서 사람이 한다. 작업 끝에 "Studio에서 확인할 것" 목록을 3줄 이내로 적는다.
- 설계서에 없는 기능을 제안할 때는 코드로 만들지 말고 질문만 한다.

## 실행
- `start.bat` 더블클릭 → git pull, rokit install, rojo serve(포트 34874), Studio 열기까지 한 번에.
- Studio Rojo 플러그인에서 포트를 34874로 바꾸고 Connect. (34872 Stealth Animals, 34873 도플갱어 호텔)
- 배치파일은 roblox-doppelganger-hotel 레포와 같은 방식. `make_shortcut.bat`은 바탕화면 바로가기를 한 번 만든다.
