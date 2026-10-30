#!/usr/bin/env bash
# 서버 실행. 0.0.0.0에 바인딩해야 IDE의 Browser 미리보기에서 연결된다.
# 사용: bash run.sh            (PORT 기본 8000)
#       PORT=3000 bash run.sh
set -euo pipefail
PORT="${PORT:-8000}"
echo "http://0.0.0.0:$PORT  (Browser 탭의 PORT에 $PORT 입력)"
exec python3 -m uvicorn app.main:app --host 0.0.0.0 --port "$PORT"
