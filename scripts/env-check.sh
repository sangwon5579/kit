#!/usr/bin/env bash
# 사전 체험 첫 1분에 실행. 어떤 스택이 가능한지 한 번에 확인한다.
# 사용: bash ~/kit/scripts/env-check.sh
set -uo pipefail

ver() {  # 이름, 명령...
  local name="$1"; shift
  if command -v "$1" >/dev/null 2>&1; then
    printf "  %-9s %s\n" "$name" "$("$@" 2>&1 | grep -v -e JAVA_TOOL_OPTIONS -e '^$' -e '^-*$' | head -1)"
  else
    printf "  %-9s 없음\n" "$name"
  fi
}
reach() {  # 이름, URL  → HTTP 코드 (000 = 연결 실패/차단)
  local code; code="$(curl -s -m 8 -o /dev/null -w "%{http_code}" "$2" 2>/dev/null)"; code="${code:-000}"
  case "$code" in
    2*|3*|4*) printf "  %-14s %s OK\n" "$1" "$code" ;;   # 응답이 오면 접근 가능 (403/404도 연결은 됨)
    *)        printf "  %-14s %s ← 차단/실패\n" "$1" "$code" ;;
  esac
}

echo "== 도구"
ver python3 python3 --version
ver pip     pip --version
ver node    node --version
ver npm     npm --version
ver java    java -version
ver mvn     mvn -v
ver gradle  gradle --version
ver git     git --version
ver codex   codex --version

echo "== 저장소 접근 (8초 제한)"
reach "GitHub"        https://github.com/
reach "PyPI"          https://pypi.org/simple/
reach "npm"           https://registry.npmjs.org/
reach "Maven Central" https://repo.maven.apache.org/maven2/
reach "Gradle"        https://services.gradle.org/

echo "== 캐시"
[ -d ~/.m2/repository ] && echo "  ~/.m2: $(find ~/.m2/repository -name '*.jar' 2>/dev/null | wc -l) jar" || echo "  ~/.m2: 없음"
echo "  npm:  $(npm config get cache 2>/dev/null || echo ?)"

echo "== 자원"
nproc 2>/dev/null | sed 's/^/  CPU: /'
free -h 2>/dev/null | awk '/Mem:/{print "  RAM: " $2 " (가용 " $7 ")"}'

echo
echo "판단: Spring은 java≥17 + (mvn|gradle) + Maven Central OK 세 가지가 모두 있어야 선택지. 하나라도 빠지면 python|node."
