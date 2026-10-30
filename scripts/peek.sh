#!/usr/bin/env bash
# 큰 파일을 통째로 읽지 않고 구조만 본다 (토큰 절약).
# 사용: bash scripts/peek.sh <파일> [앞 N줄=5]
set -uo pipefail
f="${1:-}"; n="${2:-5}"
[ -z "$f" ] && { echo "사용: bash scripts/peek.sh <파일> [앞 N줄]"; exit 2; }
[ -f "$f" ] || { echo "파일 없음: $f"; exit 1; }

size=$(wc -c < "$f"); lines=$(wc -l < "$f")
echo "== $f  ($(( size / 1024 ))KB, ${lines}줄)"

case "$f" in
  *.csv|*.tsv)
    delim=","; [[ "$f" == *.tsv ]] && delim=$'\t'
    cols=$(head -n 1 "$f" | awk -F"$delim" '{print NF}')
    echo "-- 열 ${cols}개: $(head -n 1 "$f" | cut -c1-200)"
    echo "-- 앞 ${n}줄"; sed -n "2,$((n+1))p" "$f" | cut -c1-200
    echo "-- 뒤 2줄";  tail -n 2 "$f" | cut -c1-200
    ;;
  *.json)
    echo "-- 앞 ${n}줄"; head -n "$n" "$f" | cut -c1-200
    if command -v python3 >/dev/null; then
      python3 -I - "$f" <<'PY' 2>/dev/null
import json,sys
p=sys.argv[1]
try:
    with open(p,encoding="utf-8") as fh: d=json.load(fh)
except Exception as e:
    print("-- json 파싱 실패:",e); sys.exit()
def shape(x,depth=0):
    if isinstance(x,dict): return "{"+", ".join(f"{k}:{shape(v,depth+1)}" for k,v in list(x.items())[:8])+("…" if len(x)>8 else "")+"}"
    if isinstance(x,list): return f"[{len(x)}×{shape(x[0],depth+1) if x else '?'}]"
    return type(x).__name__
print("-- 구조:",shape(d)[:300])
PY
    fi
    ;;
  *.log|*.txt|*.md|*)
    echo "-- 앞 ${n}줄"; head -n "$n" "$f" | cut -c1-200
    echo "-- 뒤 3줄";  tail -n 3 "$f" | cut -c1-200
    ;;
esac
