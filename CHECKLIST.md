# 당일 체크리스트 (사람용 — 제출물에 넣지 않음)

터미널에서 `cat ~/kit/CHECKLIST.md`로 본다.

## 180분 시간표

| 시각 | 단계 | 산출물 | 신호 |
|---|---|---|---|
| 0:00–0:05 | clone → bootstrap → 첫 커밋 | AGENTS.md, docs/, scripts/ | `git log` 1줄 |
| 0:05–0:20 | README 정독 → 담당자 인터뷰 → 합의문 확인 | INTERVIEW.md | 담당자 "맞습니다" |
| 0:20–0:35 | `$plan-draft` → 내 판단으로 수정 → 스택 결정 → bootstrap python/node | PLAN.md, D1 | T1 완료, check.sh ALL OK |
| 0:35–2:00 | T2~T5 위임 → check.sh → 커밋 (작업당 15~25분) | 커밋 4~6개, TRACEABILITY | 브라우저에서 직접 눌러봄 |
| 2:00–2:30 | 새 세션 `$fresh-review` → 상위 3개 수정 + 테스트 | 커밋, VERIFICATION | 담당자 수용 확인 |
| 2:30–2:50 | `$verify` → `$handoff` → DECISIONS 3~5개 마무리 | HANDOFF, DECISIONS | 문서 ↔ 코드 일치 |
| 2:50–2:55 | 안 쓴 파일 삭제, 저장 상태 "저장됨", 최종 커밋 | — | `git status` clean |
| 2:55–3:00 | 핵심 결정 5개 머릿속 정리 → "제출하고 문제풀기" | — | — |

Codex 응답을 기다리는 동안: DECISIONS 한 줄, TRACEABILITY 갱신, 다음 task 프롬프트 작성, 브라우저 확인. 멍하니 기다리지 않는다.

## 위임 프롬프트에 꼭 넣을 4가지
목표 · 완료 조건(실패 케이스 포함) · 제약(범위 밖 금지, 새 의존성 알리기) · 검증 방법(실행 결과 보여라)

## 서술형 답변 틀 (6문항 × 5분, AI·복붙 불가)
1. **지점**: "그 부분은 `파일/함수`에서 ~하게 구현했습니다."
2. **이유/대안**: "~ 대신 ~를 택한 이유는 ~. 대안은 ~였지만 시간/제약 때문에 제외."
3. **리스크**: "~한 입력/상황에서 깨질 수 있고, 영향은 ~."
4. **다음 검증·개선**: "다음엔 ~를 테스트하고 ~로 바꾸겠습니다."
- 질문의 전제가 내 구현과 다르면 **먼저** 그 차이를 밝힌다.
- 5~7문장. 첫 문장부터 구체적 파일·함수 이름.

## 제출 직전 5분 점검
- [ ] README에 필수 제출물 파일명이 있다면 그 이름 그대로 있는가
- [ ] 실행 방법대로 새 터미널에서 실제로 뜨는가 (0.0.0.0, PORT)
- [ ] `bash scripts/check.sh` ALL OK
- [ ] 문서에 "완벽/모든/항상" 없음, 미완은 미완으로 적음
- [ ] 빈 템플릿 절·안 쓴 스캐폴드 파일 삭제
- [ ] 에디터 탭 "저장됨", `git status` clean
- [ ] 서버 터미널은 그대로 둔다

## 하지 말 것 (탈락·감점 사유)
- Claude Code, Astra, 개인 API 키·유료 구독, 별도 AI 모델 연결
- git push, 개인 PC 파일 업로드, 외부 브라우저 직접 접속
- Computer Use(자동 조작), 전체화면 이탈, 캡처 단축키
- 제출 직전 결과물 통째 교체 (작업 이력과 어긋남)
- 후속 서술형에서 AI·복사·붙여넣기

## 사전 체험 15분에 확인할 것 (1회뿐)
1. `git clone https://github.com/<아이디>/kit.git ~/kit` 되는가 → 바로 `bash ~/kit/scripts/env-check.sh`
   - Spring은 java≥17 + mvn/gradle + Maven Central OK **셋 다** 있을 때만. 아니면 python/node로 확정
   - React/Vite 빌드 체인은 안 함. 프론트는 백엔드 static 한 장
2. `codex` → `/status` `/model` → `$` 입력 시 스킬 목록에 plan-draft 뜨는가
3. 짧은 요청 1개 → 승인 방식 확인 (허용 범위 명령은 자동 실행)
4. 스캐폴드 서버 띄우고 Browser 탭 PORT 입력 → 화면 뜨는가
5. 업무 담당자 DM 1회 (Enter 전송, Shift+Enter 줄바꿈)
6. 붙여넣기 단축키 `Ctrl+Shift+V` (Mac `⌘V`), 파일 저장 상태 표시
7. 웹캠·화면공유·Proctor 연결·충전 상태
