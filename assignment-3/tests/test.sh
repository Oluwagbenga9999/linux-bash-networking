#!/usr/bin/env bash
set -u

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir" || exit 1

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

check_expect() {
    local command="$1"
    local expected_pattern="$2"
    local output
    output=$(eval "$command" 2>&1)
    echo "$output" | grep -q "$expected_pattern" || fail "$command did not produce expected output"
}

check_expect "./app/app.sh help" "Usage:"
check_expect "./app/app.sh system-info" "Hostname:"
if ./app/app.sh invalid-command >/tmp/invalid.log 2>&1; then
    fail "invalid command should fail"
else
    grep -q "Invalid command" /tmp/invalid.log || fail "invalid command should print message"
fi

if ./app/app.sh check-host >/tmp/missing-host.log 2>&1; then
    fail "missing host should fail"
else
    grep -q "Missing host argument" /tmp/missing-host.log || fail "missing host error message missing"
fi

check_expect "./app/app.sh check-host localhost" "Resolved Address:"

if ./app/app.sh check-port localhost >/tmp/missing-port.log 2>&1; then
    fail "missing port should fail"
else
    grep -q "Missing host or port argument" /tmp/missing-port.log || fail "missing port error message missing"
fi

if ./app/app.sh check-port localhost abc >/tmp/non-numeric.log 2>&1; then
    fail "non-numeric port should fail"
else
    grep -q "Invalid port" /tmp/non-numeric.log || fail "non-numeric port error message missing"
fi

if ./app/app.sh check-port localhost 70000 >/tmp/out-of-range.log 2>&1; then
    fail "out-of-range port should fail"
else
    grep -q "Invalid port" /tmp/out-of-range.log || fail "out-of-range port error message missing"
fi

./scripts/lint.sh >/tmp/lint.log || fail "lint failed"

echo "All tests passed"
