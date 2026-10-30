#!/usr/bin/env bash
# 작업 루트(과제 README.md가 있는 곳)에서 실행한다. 키트의 작업 규칙·문서 템플릿·스킬·점검 스크립트를 복사하고 첫 커밋을 만든다.
#
# 사용 (과제 루트, 예: ~/workspace 에서):
#   bash ~/kit/scripts/bootstrap.sh            # 템플릿만
#   bash ~/kit/scripts/bootstrap.sh python     # + FastAPI 스캐폴드
#   bash ~/kit/scripts/bootstrap.sh node       # + Node(내장 http) 스캐폴드
#
# 이미 있는 파일(README.md 등)은 덮어쓰지 않는다.
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(pwd)"
SCAFFOLD="${1:-}"

if [ ! -f "$KIT/AGENTS.md" ]; then
  echo "키트 폴더를 찾지 못했습니다: $KIT"; exit 1
fi
if [ "$KIT" = "$ROOT" ]; then
  echo "키트 폴더 안에서 실행하지 마세요. 과제 루트에서 실행하세요:"
  echo "  cd ~/workspace && bash $KIT/scripts/bootstrap.sh"
  exit 1
fi

# 이미 있는 파일은 건너뛰고, 없는 파일만 복사한다 (src 디렉토리 → dst 디렉토리)
copy_missing() {
  local src="$1" dst="$2" f rel
  while IFS= read -r -d '' f; do
    rel="${f#"$src"/}"
    if [ -e "$dst/$rel" ]; then
      echo "  건너뜀(이미 있음): $rel"
    else
      mkdir -p "$(dirname "$dst/$rel")"
      cp "$f" "$dst/$rel"
    fi
  done < <(find "$src" -type f -print0)
}

mkdir -p docs/prompts scripts .agents/skills
[ -e AGENTS.md ] && echo "  건너뜀(이미 있음): AGENTS.md" || cp "$KIT/AGENTS.md" ./AGENTS.md
copy_missing "$KIT/.agents/skills" ./.agents/skills
copy_missing "$KIT/docs" ./docs
copy_missing "$KIT/prompts" ./docs/prompts
[ -e scripts/check.sh ] || cp "$KIT/scripts/check.sh" ./scripts/check.sh
[ -e scripts/peek.sh ]  || cp "$KIT/scripts/peek.sh"  ./scripts/peek.sh
chmod +x scripts/check.sh scripts/peek.sh

case "$SCAFFOLD" in
  python) copy_missing "$KIT/scaffold/python-fastapi" . ; echo "FastAPI 스캐폴드 복사" ;;
  node)   copy_missing "$KIT/scaffold/node-http" . ;  echo "Node(내장 http) 스캐폴드 복사" ;;
  "")     ;;
  *)      echo "알 수 없는 스캐폴드: $SCAFFOLD (python | node)"; exit 1 ;;
esac

# 키트가 작업 루트 안에 클론돼 있으면 제출물에 섞이지 않도록 제거
case "$KIT" in
  "$ROOT"/*) rm -rf "$KIT"; echo "키트 폴더 제거: $KIT (복사 완료)" ;;
esac

if [ ! -d .git ]; then git init -q; echo "git init"; fi
git config user.name  >/dev/null 2>&1 || git config user.name  "participant"
git config user.email >/dev/null 2>&1 || git config user.email "participant@example.com"
git add -A
case "$SCAFFOLD" in
  python) MSG="chore: FastAPI 스캐폴드 추가 (개인 공개 키트 kit에서 복사: /health, 0.0.0.0+PORT, 테스트 4개)" ;;
  node)   MSG="chore: Node http 스캐폴드 추가 (개인 공개 키트 kit에서 복사: /health, 0.0.0.0+PORT, 테스트 4개)" ;;
  *)      MSG="chore: 작업 템플릿 추가 (개인 공개 키트 kit에서 복사: AGENTS.md, docs/, scripts/check.sh·peek.sh, .agents/skills)" ;;
esac
git commit -q -m "$MSG" && echo "커밋 완료: $MSG" || echo "커밋할 변경 없음"

echo
echo "완료. 다음 순서:"
echo "  1) docs/INTERVIEW.md 열고 요청자 인터뷰(있으면) → 합의문 확인"
echo "  2) 터미널에서 codex 실행 → docs/prompts/kickoff.md 첫 메시지 → \$plan-draft"
echo "  3) 작업마다 docs/prompts/task.md 틀 → bash scripts/check.sh → 커밋"
