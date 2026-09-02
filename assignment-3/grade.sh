#!/usr/bin/env bash
set -u

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_dir" || exit 1

score=0

check_exists() {
    if [ -e "$1" ]; then
        echo "PASS: found $1"
        score=$((score + 5))
    else
        echo "FAIL: missing $1"
    fi
}

check_exists README.md
check_exists app/app.sh
check_exists scripts/lint.sh
check_exists scripts/build.sh
check_exists tests/test.sh
check_exists Dockerfile
check_exists compose.yaml
check_exists .dockerignore
check_exists .github/workflows/ci.yml

for script in app/*.sh scripts/*.sh tests/*.sh; do
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

for script in app/*.sh scripts/*.sh tests/*.sh; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "PASS: executable $script"
        score=$((score + 5))
    elif [ -f "$script" ]; then
        echo "FAIL: not executable $script"
    fi
done

if [ -x ./app/app.sh ] && ./app/app.sh help >/dev/null 2>&1; then
    echo "PASS: app help works"
    score=$((score + 10))
else
    echo "FAIL: app help failed"
fi

if ./app/app.sh check-host localhost >/dev/null 2>&1; then
    echo "PASS: host check works"
    score=$((score + 10))
else
    echo "FAIL: host check failed"
fi

if ./app/app.sh check-port localhost 80 >/dev/null 2>&1; then
    echo "PASS: port check works"
    score=$((score + 10))
else
    echo "FAIL: port check did not work"
fi

if [ -f Dockerfile ] && grep -q "FROM" Dockerfile && grep -q "ENTRYPOINT\|CMD" Dockerfile; then
    echo "PASS: Dockerfile configured"
    score=$((score + 15))
else
    echo "FAIL: Dockerfile configuration missing"
fi

if [ -f .github/workflows/ci.yml ] && grep -q "needs:" .github/workflows/ci.yml && grep -q "push:\|pull_request:" .github/workflows/ci.yml; then
    echo "PASS: workflow triggers and job dependencies configured"
    score=$((score + 20))
else
    echo "FAIL: workflow missing required triggers or dependencies"
fi

if ./scripts/lint.sh >/dev/null 2>&1 && ./tests/test.sh >/dev/null 2>&1; then
    echo "PASS: validation and tests succeed"
    score=$((score + 15))
else
    echo "FAIL: validation and tests failed"
fi

echo "Total score: $score/100"
exit 0
