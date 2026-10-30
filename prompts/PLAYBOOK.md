# PLAYBOOK — Codex 명령 순서 (복사해서 쓰기)

`cat docs/prompts/PLAYBOOK.md` 로 보면서 진행한다. `{ }` 안만 채운다.
스킬(`$이름`)이 목록에 안 뜨면 `.agents/skills/{이름}/SKILL.md` 본문을 복사해 붙인다.

---

## 0. 터미널 (Codex 전)

```bash
git clone https://github.com/{아이디}/kit.git ~/kit
cd ~/workspace                                 # README.md가 있는 과제 루트
bash ~/kit/scripts/bootstrap.sh                # 템플릿만. 첫 커밋 자동
```

## 1. 담당자 인터뷰 (DM 두 번째 상대 "업무 담당자", Codex 아님)

`docs/INTERVIEW.md` 질문을 위에서부터 보낸다. 답변은 **그대로** 붙여 넣는다. 마지막에 합의문 7줄을 보내고 확인 답변도 붙여 넣는다.
README에 다 적혀 있어도 한다 — 우선순위·숫자·안 해도 되는 것을 캐내고, 대화 로그 자체가 평가 대상이다.

## 2. Codex 시작 (`codex` 입력 → 신뢰 확인 → 작업 폴더 확인)

```
AGENTS.md를 읽고 이 저장소의 작업 규칙을 확인해라.
그 다음 환경을 요약해라: python3/node/java 버전, 패키지 설치 가능 여부, 현재 파일 구조.
아직 코드는 쓰지 마라. 규칙 중 지키기 어려운 것이 있으면 지금 말해라.
```

## 3. 계획

```
$plan-draft
```
```
README.md의 필수 조건·제출물과 docs/INTERVIEW.md의 담당자 요구를 R1부터 번호 붙여
docs/TRACEABILITY.md 표에 채워라. 출처 열에 README 또는 담당자를 적어라. 코드는 아직 쓰지 마라.
```
→ `docs/PLAN.md`, `docs/TRACEABILITY.md`를 **직접 열어 고친다**: 성공 기준 숫자, Out 범위, 작업 5개 이하, 스택.
→ `docs/DECISIONS.md` D1 = 스택 선택. 이유는 내 말로.

## 4. 스캐폴드 (다른 터미널)

```bash
bash ~/kit/scripts/bootstrap.sh python     # 또는 node
```
Codex에:
```
스캐폴드를 추가했다 (app/ 또는 server.js, tests/, scripts/check.sh). T1: bash scripts/check.sh가 통과하는지 확인하고,
PLAN 5절 구조에 맞게 바꿔야 할 파일이 있으면 알려라. 예제 /api/echo는 T2에서 교체한다.
```
**Spring을 택한 경우** (env-check에서 java·mvn·Maven Central 모두 OK일 때만):
```
T1: Spring Boot 3, Java {버전}, Maven 프로젝트를 만들어라. Initializr 접속은 불가하니 pom.xml을 직접 써라.
의존성은 spring-boot-starter-web, spring-boot-starter-test만. application.properties에
server.address=0.0.0.0, server.port=${PORT:8080}. GET /health → {"status":"ok"},
src/main/resources/static/index.html(한 줄 제목), /health 테스트 1개.
mvn -q test 와 서버 기동 결과를 보여라. 프론트는 static 폴더에서 서빙한다. 별도 프론트 서버·빌드 도구는 쓰지 않는다.
```
통과 보고 → `커밋`

## 5. 작업 루프 (T2~T5, 작업당 15~25분)

```
작업 T{n}: {한 줄 목표}

관련 요구사항: R{..} (docs/TRACEABILITY.md)
현재 상태: {무엇이 있고 없는지 1~2줄}

완료 조건:
- {정상: 사용자가 ...하면 ...가 된다}
- {실패: ...이면 400과 한국어 에러 메시지}
- {경계: ...인 경우 ...}

제약:
- PLAN.md 4절 범위 밖 기능 추가 금지
- 새 의존성은 먼저 알릴 것
- {건드리지 않을 파일}

검증:
- bash scripts/check.sh
- {curl 명령 또는 브라우저 조작} → 응답 보여라
- {실패 케이스 curl} → 400 확인 보여라

끝나면 보고: 변경 파일 / 검증 결과 / 남은 리스크 각 1~3줄 + 커밋 메시지 초안
```

채운 예시:
```
작업 T2: 장비 로그 CSV 업로드 → 파싱해서 /api/logs 로 JSON 반환

관련 요구사항: R1, R2 (docs/TRACEABILITY.md)
현재 상태: /health와 정적 페이지만 있음. /api/echo는 삭제하고 이 작업으로 대체.

완료 조건:
- POST /api/logs 에 CSV 파일을 보내면 {rows: n, columns: [...]} 반환
- 빈 파일, CSV 아닌 파일, 10MB 초과는 400과 한국어 에러 메시지
- 헤더 없는 CSV는 첫 행을 데이터로 취급

제약:
- PLAN.md 4절 범위 밖 기능(시각화, 저장) 추가 금지
- 새 의존성은 먼저 알릴 것. 표준 csv 모듈 우선
- app/static/index.html은 이번 작업에서 건드리지 않음

검증:
- bash scripts/check.sh
- curl -F "file=@sample.csv" http://127.0.0.1:8000/api/logs → 응답 보여라
- 빈 파일 curl → 400 확인 보여라

끝나면 보고: 변경 파일 / 검증 결과 / 남은 리스크 각 1~3줄 + 커밋 메시지 초안
```

보고가 오면: `bash scripts/check.sh` 직접 실행 → Browser 탭에서 직접 눌러보기 → `커밋`

구조적 선택지를 물어오면 **내가** 고르고 DECISIONS에 적는다. 초안을 시키려면:
```
docs/DECISIONS.md에 D{n} 추가안을 제안해라. 결정: {내가 고른 것}. 대안: {버린 것}.
깨지는 지점과 다음 검증 항목은 네가 채우고, 선택 이유는 비워 둬라. 내가 쓴다.
```

요구사항이 바뀌면:
```
담당자가 {변경 내용}라고 했다. docs/PLAN.md의 범위와 작업 분해를 갱신하고 9절 변경 이력에 시각과 이유를 적어라.
영향받는 TRACEABILITY 행도 알려라. 코드 수정은 내가 확인한 뒤 한다.
```

Codex가 돌아가는 동안: DECISIONS 한 줄, TRACEABILITY 상태 갱신, 다음 T 프롬프트 작성, 브라우저 확인.

## 6. 리뷰 (120분경, `+` 새 터미널 → `codex`)

```
$fresh-review
```
보고를 **메인 세션**에 붙여서:
```
아래 리뷰 중 {A1, B1, C1}을 고쳐라. 각 수정에 재발 방지 테스트 1개를 추가하고 전후 실행 결과를 보여라.
{D} 항목은 삭제해라. 범위 밖 기능은 추가하지 마라.

{리뷰 보고 붙여넣기}
```
담당자에게 수용 확인 1회: "이렇게 동작합니다. {핵심 시나리오 한 줄}. 맞나요?"

## 7. 마무리 (150분~)

```
$verify
```
```
$handoff
```
→ HANDOFF·DECISIONS를 내 손으로 다듬는다. "완벽/모든/항상" 지운다.
→ 안 쓴 것 삭제: 빈 템플릿 절, 예제 API와 그 테스트, 안 쓴 스캐폴드 파일.
```
docs/ 아래 비어 있는 절과 사용하지 않은 예제 코드(/api/echo 등)를 찾아 목록으로 보여라. 삭제는 내가 확인한 뒤 한다.
```
→ `커밋` → 에디터 "저장됨" 확인 → 서버 터미널은 그대로 → "제출하고 문제풀기"

## 8. 서술형 (6문항 × 5분, AI 금지)

지점(파일/함수) → 이유와 버린 대안 → 깨지는 지점 → 다음 검증. 5~7문장.
질문의 전제가 내 구현과 다르면 **먼저** 차이를 밝힌다. DECISIONS.md를 머릿속에 넣고 들어간다.
