#!/usr/bin/env bash
# 한 번에 점검: 테스트 실행 + (PORT가 설정돼 있으면) /health 확인.
# 사용: bash scripts/check.sh            # 테스트만
#       PORT=8000 bash scripts/check.sh  # 테스트 + 떠 있는 서버의 /health
# 종료 코드 0 = 전부 통과, 1 = 하나라도 실패.
set -uo pipefail
status=0
ran=0

if [ -f package.json ] && grep -q '"test"' package.json; then
  echo "== npm test"
  npm test --silent || status=1
  ran=1
fi

PY="$(command -v python3 || command -v python || true)"
if [ -n "$PY" ] && { ls tests/test_*.py >/dev/null 2>&1 || ls test_*.py >/dev/null 2>&1; }; then
  echo "== pytest"
  "$PY" -m pytest -q || status=1
  ran=1
fi

if [ -n "${PORT:-}" ]; then
  echo "== health check :$PORT"
  if curl -fsS --max-time 5 "http://127.0.0.1:$PORT/health" >/dev/null; then
    echo "health OK"
  else
    echo "health FAIL (서버가 떠 있는지, 0.0.0.0:$PORT에 바인딩했는지 확인)"
    status=1
  fi
  ran=1
fi

if [ "$ran" -eq 0 ]; then
  echo "실행할 테스트가 없습니다. tests/test_*.py 또는 package.json의 test 스크립트를 추가하세요."
  status=1
fi

if [ "$status" -eq 0 ]; then echo "ALL OK"; else echo "FAILED"; fi
exit $status
