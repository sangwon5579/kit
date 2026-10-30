# kit — Codex 작업 템플릿

Codex와 함께 처음 보는 과제를 풀 때 쓰는 **작업 체계**입니다. 정답은 없고, 계획 → 위임 → 검증 → 기록 → 인수인계를 남기는 틀만 있습니다.
새 작업 폴더에서 `git clone` → `bootstrap.sh` 한 번이면 틀이 깔리고 첫 커밋까지 됩니다.

```
kit/
├── AGENTS.md                 Codex가 자동으로 읽는 작업 규칙 (범위·승인·검증·보고·토큰 효율)
├── .agents/skills/           Codex 스킬: $plan-draft  $fresh-review  $verify  $handoff
├── docs/                     계획·결정·추적·검증·인수인계 템플릿 + 인터뷰 질문지
├── prompts/PLAYBOOK.md       Codex 명령 순서 전체 — 복사해서 쓰는 프롬프트 모음 ★
├── prompts/                  kickoff.md(첫 메시지), task.md(작업 위임 틀)
├── scripts/env-check.sh      새 환경 점검: 도구·저장소 접근 → 스택 결정
├── scripts/bootstrap.sh      작업 루트에 틀 복사 + 첫 커밋
├── scripts/check.sh          테스트(pytest/npm/mvn/gradle 자동 감지) + /health 점검
├── scripts/peek.sh           큰 파일을 통째로 읽지 않고 구조만 보기 (토큰 절약)
├── scaffold/python-fastapi/  최소 웹앱 (FastAPI)
├── scaffold/node-http/       최소 웹앱 (Node 내장 http, 의존성 0)
└── CHECKLIST.md              특정 시험용 당일 메모 (사람용, 작업 폴더에 복사되지 않음)
```

---

## 1. 시작

```bash
git clone https://github.com/<아이디>/kit.git ~/kit    # 작업 루트 바깥에 받는다
bash ~/kit/scripts/env-check.sh                       # 도구·저장소 접근 확인 → 스택 결정

cd <작업 루트>                                         # 과제 README.md가 있는 곳
bash ~/kit/scripts/bootstrap.sh                       # 템플릿만
bash ~/kit/scripts/bootstrap.sh python                # 스택 정해지면 다시 실행 → 스캐폴드만 추가
bash ~/kit/scripts/bootstrap.sh node
cat docs/prompts/PLAYBOOK.md                          # 이후 순서는 이 파일대로
```

- 이미 있는 파일은 **절대 덮어쓰지 않습니다.** 없는 파일만 채웁니다. 두 번 실행해도 안전합니다.
- kit을 작업 루트 **안에** clone했으면 복사 후 kit 폴더를 지웁니다(결과물에 안 섞이게). 그래서 `~/kit`에 받습니다.
- 작업 루트에 이미 `AGENTS.md`가 있으면 건너뜁니다. 그 파일을 열어 `~/kit/AGENTS.md` 내용을 아래에 붙이세요(기존 규칙 우선).

### 스택 선택
| env-check 결과 | 선택 |
|---|---|
| 기본 | `python` 또는 `node` 스캐폴드. 2분 안에 첫 테스트 통과 |
| java ≥17 **그리고** mvn/gradle **그리고** Maven Central OK **그리고** Java가 확실히 더 능숙 | Spring Boot. 프론트는 `static/`에서 서빙, 별도 프론트 서버·빌드 도구 없음 |
| 셋 중 하나라도 없음 | Spring 불가 → python/node |

React·Vite 같은 빌드 체인은 권하지 않습니다. 서버 2개 + 프록시 + 빌드는 장애 지점만 늘립니다. 화면은 백엔드가 서빙하는 HTML/JS 한 장으로.

---

## 2. 작업 순서

1. **읽기** — 과제 README와 제공 파일. 수정하지 않는다.
2. **인터뷰** — 요청자·담당자가 있으면 `docs/INTERVIEW.md` 질문을 순서대로. 답변은 그대로 붙여 넣고 합의문으로 확인받는다. 없으면 README 기준으로 스스로 답하고 `가정:`으로 표시.
3. **계획** — `codex` → `prompts/kickoff.md` 첫 메시지 → `$plan-draft` → 초안을 **내 판단으로** 수정 → `docs/TRACEABILITY.md`에 요구사항 R1… 번호 매기기 → 스택 결정, `docs/DECISIONS.md` D1.
4. **스캐폴드** — `bootstrap.sh python|node` 또는 Spring T1 프롬프트 → `bash scripts/check.sh` 통과 → 커밋.
5. **작업 루프** — 작업마다 `prompts/task.md` 틀(목표·완료 조건·제약·검증) → Codex → `check.sh` → 직접 확인 → 커밋. 구조적 선택은 내가 고르고 DECISIONS에 적는다. Codex가 도는 동안 문서를 갱신한다.
6. **리뷰** — 새 터미널에 두 번째 `codex` → `$fresh-review` → 상위 지적만 메인 세션에서 수정 + 재발 방지 테스트 → 요청자 수용 확인.
7. **마무리** — `$verify` → `$handoff` → DECISIONS 정리 → 안 쓴 템플릿 절·예제 코드 삭제 → 최종 커밋.
8. **설명 준비** — DECISIONS 기준으로 결정마다 "지점 → 이유·대안 → 깨지는 곳 → 다음 검증" 순으로 말할 수 있게.

---

## 3. 파일별 사용법

### `AGENTS.md`
Codex가 세션 시작 시 자동으로 읽습니다. 과제와 안 맞는 규칙은 바로 고치세요(예: CLI 과제면 `/health`·`0.0.0.0` 항목 삭제).
핵심: 범위 밖 구현 금지 · 구조적 결정은 선택지 2개 후 내 승인 · 변경 후 `check.sh` · 실행 결과로만 보고 · 커밋은 "커밋"이라고 할 때만 · 큰 파일은 `peek.sh`로 먼저 보고 필요한 범위만 읽기.

### `.agents/skills/` — Codex에서 `$이름`으로 호출
| 스킬 | 언제 | 하는 일 |
|---|---|---|
| `$plan-draft` | 인터뷰 직후, 코드 전 | README + INTERVIEW로 PLAN.md 초안. 코드는 안 씀 |
| `$fresh-review` | 구현 후반, **새 세션**에서 | 처음 보는 리뷰어 관점으로 미충족·깨지는 지점·리스크·과잉·문서 불일치 보고. 수정은 안 함 |
| `$verify` | 작업 완료 시, 마무리 전 | 테스트 실행 + 수동 시나리오 실제 재현 → 표로 기록 |
| `$handoff` | 마무리 단계 | HANDOFF.md 작성 + README 실행 방법을 실제로 따라 검증 |

목록에 안 뜨면 해당 `SKILL.md` 본문을 복사해 붙여넣으면 똑같이 동작합니다.

### `docs/`
| 파일 | 채우는 사람 | 내용 |
|---|---|---|
| `INTERVIEW.md` | 나 | 질문 순서대로 → 답변 **그대로** → 합의문 7줄 → 확인 답변 |
| `PLAN.md` | Codex 초안 → 내가 수정 | 문제 정의·성공 기준(실행 가능하게)·In/Out·구조와 버린 대안·작업 분해(5개 이하)·리스크·**변경 이력** |
| `DECISIONS.md` | **나** | 결정 3~6개: 결정/대안/이유/깨지는 지점/다음 검증/증거. 이유는 꼭 내 말로 |
| `TRACEABILITY.md` | Codex 제안 → 내가 확인 | 요구사항 ↔ 구현 파일 ↔ 테스트. "완료"는 검증 열이 채워졌을 때만 |
| `VERIFICATION.md` | `$verify` | 실제 실행한 것만. 실패·미실행은 그대로 |
| `HANDOFF.md` | `$handoff` → 내가 다듬기 | 실행법·완료·미완·이슈·다음 할 일·AI 활용 요약. "완벽/모든/항상" 금지 |

### `prompts/`
- `PLAYBOOK.md` ★: 전체 순서와 **그대로 복사할 프롬프트**. `docs/prompts/`로 복사되므로 `cat docs/prompts/PLAYBOOK.md`로 보면서 진행
- `kickoff.md`, `task.md`: PLAYBOOK의 시작·작업 루프 부분만 따로 뗀 것

### `scripts/`
```bash
bash ~/kit/scripts/env-check.sh        # 도구 버전, GitHub/PyPI/npm/Maven Central 접근, 캐시, CPU/RAM
bash scripts/check.sh                  # 테스트 (pytest / npm test / mvn test / gradle test 자동 감지)
PORT=8000 bash scripts/check.sh        # + 떠 있는 서버의 /health
bash scripts/peek.sh data.csv [N]      # 크기·줄 수·열·앞 N줄·뒤 줄. json은 구조 요약
```

### `scaffold/`
둘 다 `/health`, `0.0.0.0` + `PORT`, 정적 `index.html`, 예제 API(`POST /api/echo`, 빈 입력 400), 테스트 4개.
```bash
pip install -r requirements.txt && bash run.sh      # python-fastapi, 기본 8000
bash run.sh                                          # node-http, 설치 없음, 기본 3000
```
서버는 **별도 터미널**에 띄우고 닫지 않습니다. 예제 `/api/echo`와 그 테스트는 실제 기능을 넣으면서 **지우거나 바꿉니다.**

---

## 4. 원칙

1. **쓰지 않는 것은 지운다.** 빈 템플릿 절, 안 쓴 스캐폴드 파일은 마무리 때 삭제. 빈 양식은 노이즈.
2. **문서 ≤ 코드.** 문서에 쓴 것은 코드와 커밋에 있어야 한다.
3. **판단은 내 말로.** AI가 초안을 써도 DECISIONS의 "선택 이유"는 직접 쓴다.
4. **투명하게.** PLAN 변경 이력 첫 줄에 "작업 템플릿은 개인 공개 키트(kit)에서 가져옴". 아무것도 숨기지 않는다.
5. **큰 파일은 통째로 읽지 않는다.** `peek.sh` → 필요한 범위만.

---

## 5. 처음 올리기

```bash
cd kit
git init && git add -A && git commit -m "kit" && git branch -M main
git remote add origin https://github.com/<아이디>/kit.git     # GitHub에 public 저장소 kit 생성 후
git push -u origin main
```
웹에서 `.agents/skills/` 폴더가 보이는지 확인. 숨김 폴더가 빠지면 스킬이 안 뜹니다.

## 6. 새 환경에서 점검

```bash
mkdir ~/try && cd ~/try && echo "# 과제" > README.md
bash ~/kit/scripts/bootstrap.sh node
bash run.sh                                # 터미널 1
PORT=3000 bash scripts/check.sh            # 터미널 2 → ALL OK
codex                                      # $ 입력 → plan-draft 보이는지
```

---

## 막혔을 때

| 상황 | 대응 |
|---|---|
| `$plan-draft` 안 뜸 | `.agents/skills/plan-draft/SKILL.md` 본문 복사해 붙여넣기 |
| `git clone` 불가 | AGENTS.md와 PLAN 틀을 Codex에게 설명해서 환경 안에서 만들게 한다 (PLAYBOOK 맨 아래 "재생성 프롬프트") |
| 서버 미리보기 연결 안 됨 | `0.0.0.0`에 떠 있는지, PORT 숫자가 같은지, 서버 터미널을 닫지 않았는지 |
| `check.sh` "실행할 테스트가 없습니다" | `tests/test_*.py`, `package.json`의 `"test"`, `pom.xml` 중 하나가 있어야 함 |
| 커밋 시 `user.name` 오류 | `git config user.name 이름 && git config user.email a@b.c` |
| 작업이 범위를 벗어남 | PLAN 4절 Out에 적고 9절 변경 이력에 시각·이유. 되돌린 기록도 의도 갱신의 증거 |
