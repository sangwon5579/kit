#!/usr/bin/env bash
# 서버 실행. 0.0.0.0에 바인딩해야 IDE의 Browser 미리보기에서 연결된다.
# 사용: bash run.sh            (PORT 기본 3000)
#       PORT=8000 bash run.sh
set -euo pipefail
exec env PORT="${PORT:-3000}" node server.js
