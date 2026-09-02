#!/usr/bin/env bash
set -u

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_dir" || exit 1

score=0

check_file() {
  if [ -e "$1" ]; then
    echo "PASS: found $1"
    score=$((score + 5))
  else
    echo "FAIL: missing $1"
  fi
}

check_file README.md
check_file app/diagnostic.sh
check_file app/health-check.sh
check_file Dockerfile
check_file compose.yaml
check_file .dockerignore
check_file test.sh

for script in app/*.sh test.sh; do
  if [ -f "$script" ]; then
    bash -n "$script" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "PASS: syntax OK $script"
      score=$((score + 5))
    else
      echo "FAIL: syntax error in $script"
    fi
  fi
done

for script in app/*.sh test.sh; do
  if [ -f "$script" ] && [ -x "$script" ]; then
    echo "PASS: executable $script"
    score=$((score + 5))
  elif [ -f "$script" ]; then
    echo "FAIL: not executable $script"
  fi
done

if [ -x ./app/health-check.sh ] && ./app/health-check.sh >/dev/null 2>&1; then
  echo "PASS: health check runs successfully"
  score=$((score + 10))
else
  echo "FAIL: health check failed"
fi

if [ -f Dockerfile ] && grep -q "FROM" Dockerfile; then
  echo "PASS: Dockerfile present"
  score=$((score + 10))
else
  echo "FAIL: Dockerfile missing base image"
fi

if [ -f compose.yaml ] && grep -q "services:" compose.yaml; then
  echo "PASS: compose file present"
  score=$((score + 10))
else
  echo "FAIL: compose file missing"
fi

if [ -f Dockerfile ] && grep -q "ENTRYPOINT\|CMD" Dockerfile; then
  echo "PASS: Docker entrypoint configured"
  score=$((score + 10))
else
  echo "FAIL: Docker entrypoint/configuration missing"
fi

echo "Total score: $score/100"
exit 0
