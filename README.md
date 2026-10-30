# kit — AI 과제용 개인 작업 템플릿

처음 보는 과제를 Codex와 함께 풀 때 쓰는 **작업 체계**입니다. 정답은 없고, 계획·위임·검증·인수인계를 남기는 틀만 있습니다.
과제 시작 직후 `git clone` → `bootstrap.sh` 한 번이면 작업 루트에 틀이 깔리고 첫 커밋까지 됩니다.

```
kit/
├── AGENTS.md                 Codex가 자동으로 읽는 작업 규칙
├── .agents/skills/           Codex 스킬: $plan-draft  $fresh-review  $verify  $handoff
├── docs/                     계획·결정·추적·검증·인수인계 템플릿 + 인터뷰 질문지
├── prompts/PLAYBOOK.md       Codex 명령 순서 전체 (복사해서 쓰는 프롬프트 모음) ★
├── prompts/                  kickoff.md(첫 메시지), task.md(작업 위임 틀)
├── scripts/env-check.sh      사전 체험 1분: 도구·저장소 접근 확인 → 스택 결정
├── scripts/bootstrap.sh      과제 루트에 틀 복사 + 첫 커밋
├── scripts/check.sh          테스트(pytest/npm/mvn/gradle 자동 감지) + /health 점검
├── scaffold/python-fastapi/  최소 웹앱 (FastAPI)
├── scaffold/node-http/       최소 웹앱 (Node 내장 http, 의존성 0)
└── CHECKLIST.md              당일 시간표·서술형 답변 틀·금지 목록 (사람용)
```

---

## 1. 빠른 시작

```bash
# 사전 체험 (15분, 1회)
git clone https://github.com/<아이디>/kit.git ~/kit    # 루트 바깥(~)에 받는다
bash ~/kit/scripts/env-check.sh                       # 도구·저장소 접근 → 스택 결정

# 본 과제
cd ~/workspace                        # README.md가 있는 과제 루트
bash ~/kit/scripts/bootstrap.sh       # 템플릿만 (스택 미정일 때)
bash ~/kit/scripts/bootstrap.sh python   # 스택 정해지면 다시 실행 → 스캐폴드만 추가됨
bash ~/kit/scripts/bootstrap.sh node
cat docs/prompts/PLAYBOOK.md          # 이후 순서는 이 파일대로
```

- 이미 있는 파일(과제 README 등)은 **절대 덮어쓰지 않습니다.** 없는 파일만 채웁니다.
- 두 번 실행해도 안전합니다. 첫 실행은 템플릿, 두 번째는 스캐폴드.
- kit을 과제 루트 **안에** clone했으면 복사 후 kit 폴더를 지웁니다(제출물에 안 섞이게). CHECKLIST를 계속 보려면 `~/kit`에 받으세요.

### 스택 선택 규칙
| env-check 결과 | 선택 |
|---|---|
| 기본 | `python` 또는 `node` 스캐폴드. 2분 안에 T1 끝 |
| java ≥17 **그리고** mvn/gradle **그리고** Maven Central OK **그리고** Java가 확실히 더 능숙 | Spring Boot 가능. 단 프론트는 `static/`에서 서빙, 별도 프론트 서버·빌드 도구 없음 |
| 셋 중 하나라도 없음 | Spring 불가. 고민하지 말고 python/node |

React·Vite 등 빌드 체인은 어느 경우에도 권하지 않습니다. 서버 2개 + 프록시 + 빌드 = 30~40분과 장애 지점만 늘고, 점수는 안 늡니다. 화면은 백엔드가 서빙하는 HTML/JS 한 장으로.

---

## 2. 작업 흐름 (180분 기준)

| 구간 | 할 일 | 쓰는 것 |
|---|---|---|
| 0–5분 | clone → bootstrap → 첫 커밋 → `cat docs/prompts/PLAYBOOK.md` | `scripts/bootstrap.sh`, `PLAYBOOK.md` |
| 5–20분 | README 정독 → 담당자 인터뷰 → 합의문 확인받기 | `docs/INTERVIEW.md` |
| 20–35분 | `codex` 실행 → 첫 메시지 → `$plan-draft` → 초안을 **내 판단으로** 수정 → 스택 결정 → `bootstrap.sh python\|node` | `prompts/kickoff.md`, `docs/PLAN.md`, `docs/DECISIONS.md` D1 |
| 35–120분 | 작업마다: 위임 프롬프트 → Codex 작업 → `check.sh` → 브라우저 확인 → "커밋" | `prompts/task.md`, `scripts/check.sh`, `docs/TRACEABILITY.md` |
| 120–150분 | 새 터미널에 두 번째 `codex` → `$fresh-review` → 상위 3개 메인 세션에서 수정 → 담당자 수용 확인 | `prompts/task.md` 하단 "리뷰 반영" 틀 |
| 150–175분 | `$verify` → `$handoff` → DECISIONS 마무리 → 안 쓴 파일 삭제 → 최종 커밋 → 제출 | `docs/VERIFICATION.md`, `docs/HANDOFF.md` |

Codex 응답을 기다리는 동안 할 일: DECISIONS 한 줄, TRACEABILITY 갱신, 다음 작업 프롬프트 작성, 브라우저에서 직접 눌러보기.

---

## 3. 파일별 사용법

### `AGENTS.md`
Codex가 세션 시작 시 자동으로 읽습니다. 따로 할 일 없음. 다만 규칙이 과제와 안 맞으면 바로 고치세요(예: 서버가 아닌 CLI 과제면 `/health`·`0.0.0.0` 항목 삭제).
핵심 규칙: 범위 밖 구현 금지 · 구조적 결정은 선택지 2개 제시 후 내 승인 · 변경 후 `check.sh` 실행 · 실행 결과로만 보고 · 커밋은 "커밋"이라고 할 때만.

### `.agents/skills/` — Codex에서 `$이름`으로 호출
| 스킬 | 언제 | 하는 일 |
|---|---|---|
| `$plan-draft` | 인터뷰 직후, 코드 전 | README + INTERVIEW로 PLAN.md 초안. 코드는 안 씀 |
| `$fresh-review` | 구현 후반, **새 세션**에서 | 처음 보는 리뷰어 관점으로 미충족·깨지는 지점·리스크·과잉·문서 불일치 보고. 수정은 안 함 |
| `$verify` | 작업 완료 시, 제출 전 | 테스트 실행 + 수동 시나리오 실제 재현 → 표로 기록 |
| `$handoff` | 제출 30분 전 | HANDOFF.md 작성 + README 실행 방법을 실제로 따라 검증 |

스킬 목록에 안 뜨면 해당 `SKILL.md` 본문을 열어 복사해 붙여넣으면 똑같이 동작합니다.

### `docs/`
| 파일 | 채우는 사람 | 내용 |
|---|---|---|
| `INTERVIEW.md` | 나 | 질문을 순서대로 DM → 답변 **그대로** 붙여넣기 → 합의문 7줄 → 확인 답변 붙여넣기 |
| `PLAN.md` | Codex 초안 → 내가 수정 | 문제 정의·성공 기준(실행 가능하게)·In/Out·구조와 버린 대안·작업 분해(5개 이하)·리스크·**변경 이력** |
| `DECISIONS.md` | **나** | 결정 3~6개: 결정/대안/이유/깨지는 지점/다음 검증/증거. 서술형 답변의 재료 — 이유는 꼭 내 말로 |
| `TRACEABILITY.md` | Codex 제안 → 내가 확인 | 요구사항 ↔ 구현 파일 ↔ 테스트. "완료"는 검증 열이 채워졌을 때만 |
| `VERIFICATION.md` | `$verify` | 실제 실행한 것만. 실패·미실행은 그대로 적음 |
| `HANDOFF.md` | `$handoff` → 내가 다듬기 | 실행법·완료·미완·이슈·다음 할 일·AI 활용 요약. "완벽/모든/항상" 금지 |

### `prompts/`
- `PLAYBOOK.md` ★: 0~8단계 전체 순서와 **그대로 복사할 프롬프트** 전부 (시작·계획·스캐폴드·작업 루프·리뷰·마무리·서술형). `docs/prompts/`로 복사되므로 `cat docs/prompts/PLAYBOOK.md`로 보면서 진행
- `kickoff.md`, `task.md`: PLAYBOOK의 2단계·5단계만 따로 뗀 것

### `scripts/env-check.sh`
사전 체험 첫 1분. python/node/java/mvn/gradle/codex 버전, GitHub·PyPI·npm·Maven Central 접근(HTTP 코드), 캐시, CPU/RAM을 출력하고 스택 판단 기준을 알려줍니다.

### `scripts/check.sh`
```bash
bash scripts/check.sh              # 테스트만 (pytest / npm test / mvn test / gradle test 자동 감지)
PORT=8000 bash scripts/check.sh    # + 떠 있는 서버의 /health
```
`ALL OK` / `FAILED`로 끝나고 종료 코드 0/1. Codex도 같은 명령을 씁니다.

### `scaffold/`
둘 다 `/health`, `0.0.0.0` + `PORT`, 정적 `index.html`, 예제 API(`POST /api/echo`, 빈 입력 400), 테스트 4개.
```bash
# python-fastapi
pip install -r requirements.txt && bash run.sh      # 기본 8000
# node-http (설치 없음)
bash run.sh                                          # 기본 3000
```
서버는 **별도 터미널**에 띄우고 닫지 않습니다. Browser 탭 PORT 칸에 같은 숫자 입력.
예제 `/api/echo`와 그 테스트는 실제 기능을 넣으면서 **지우거나 바꿉니다.**

### `CHECKLIST.md`
제출물에 들어가지 않는 사람용 메모. `cat ~/kit/CHECKLIST.md`로 봅니다. 시간표, 서술형 답변 4단계 틀, 제출 직전 점검, 금지 목록, 사전 체험 확인 항목.

---

## 4. 원칙

1. **쓰지 않는 것은 지운다.** 빈 템플릿 절, 안 쓴 스캐폴드 파일은 제출 전 삭제. 빈 양식은 노이즈.
2. **문서 ≤ 코드.** 문서에 쓴 것은 코드와 커밋에 있어야 한다. 심사는 둘을 대조한다.
3. **판단은 내 말로.** AI가 초안을 써도 DECISIONS의 "선택 이유"는 직접 쓴다. 그 문장이 서술형 답변이 된다.
4. **투명하게.** PLAN 변경 이력 첫 줄에 "작업 템플릿은 개인 공개 키트(kit)에서 가져옴" 한 줄.

---

## 5. 처음 올리기 (내 PC에서 1회)

```bash
cd kit
git init && git add -A && git commit -m "kit" && git branch -M main
# GitHub 웹: New repository → 이름 kit → Public → README 없이 생성
git remote add origin https://github.com/<아이디>/kit.git
git push -u origin main
```
올린 뒤 웹에서 `.agents/skills/` 폴더가 보이는지 확인. (숨김 폴더가 빠지면 스킬이 안 뜹니다.)

## 6. 리허설

```bash
mkdir ~/rehearsal && cd ~/rehearsal && echo "# 가상 과제" > README.md
bash ~/kit/scripts/bootstrap.sh python     # 또는 node
pip install -r requirements.txt            # python만
bash run.sh                                # 터미널 1
PORT=8000 bash scripts/check.sh            # 터미널 2 → ALL OK
codex                                      # $ 입력 → plan-draft 보이는지
```

---

## 막혔을 때

| 상황 | 대응 |
|---|---|
| `$plan-draft` 안 뜸 | `.agents/skills/plan-draft/SKILL.md` 본문 복사해 붙여넣기 |
| `git clone` 실패 | 사전 체험에서 먼저 확인. 안 되면 AGENTS.md와 PLAN 틀을 기억으로 직접 작성(5분) |
| Browser "응답하는 서버가 없어요" | 서버가 `0.0.0.0`에 떠 있는지, PORT 숫자가 같은지, 서버 터미널을 닫지 않았는지 |
| `check.sh` "실행할 테스트가 없습니다" | `tests/test_*.py` 또는 `package.json`의 `"test"` 스크립트 형태인지 |
| 커밋 시 `user.name` 오류 | `git config user.name 참가자 && git config user.email a@b.c` |
| 작업이 범위를 벗어남 | PLAN 4절 Out에 적고 9절 변경 이력에 시각·이유. 되돌린 기록도 의도 갱신의 증거 |
