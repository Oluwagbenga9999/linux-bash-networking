#!/usr/bin/env bash

# Assignment 1 grading script
# Checks required files, bash syntax, executable permissions, output requirements,
# logging behaviour, and basic git history.

set +e

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_dir" || exit 1

score=0
max_score=100

pass() {
    echo "PASS: $1"
    score=$((score + 1))
}

warn() {
    echo "WARN: $1" >&2
}

# Required files
for file in system-info.sh disk-check.sh network-check.sh log.sh README.md logs; do
    if [ -e "$file" ]; then
        pass "Found $file"
    else
        warn "Missing $file"
    fi
done

# Shell syntax checks
for script in *.sh; do
    if [ -f "$script" ]; then
        bash -n "$script" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            pass "Bash syntax OK: $script"
        else
            warn "Syntax error in $script"
        fi
    fi
done

# Executable bits
for script in *.sh; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        pass "Executable: $script"
    else
        warn "Not executable: $script"
    fi
done

# System info output check
if [ -x ./system-info.sh ]; then
    output=$(./system-info.sh 2>/dev/null)
    if echo "$output" | grep -q "Hostname:" && \
       echo "$output" | grep -q "Current User:" && \
       echo "$output" | grep -q "Date/Time:" && \
       echo "$output" | grep -q "Operating System:" && \
       echo "$output" | grep -q "Kernel Version:" && \
       echo "$output" | grep -q "Current Working Directory:"; then
        pass "System info output includes required values"
    else
        warn "System info output missing required values"
    fi
fi

# Disk argument validation
if ./disk-check.sh 80 >/dev/null 2>&1; then
    pass "Disk check valid threshold exits 0 when below threshold"
else
    warn "Disk check threshold validation issue"
fi

if ./disk-check.sh 0 >/dev/null 2>&1; then
    warn "Disk check invalid threshold should fail"
else
    pass "Disk check invalid threshold returns non-zero"
fi

# Network validation
if ./network-check.sh localhost 80 >/dev/null 2>&1; then
    pass "Network check valid arguments succeed"
else
    warn "Network check valid arguments failed"
fi

if ./network-check.sh "bad host" >/dev/null 2>&1; then
    warn "Network check invalid host should fail"
else
    pass "Network check invalid host fails cleanly"
fi

if ./network-check.sh localhost 70000 >/dev/null 2>&1; then
    warn "Network check invalid port should fail"
else
    pass "Network check invalid port fails cleanly"
fi

# Logging
if [ -f logs/operations.log ] && [ -s logs/operations.log ]; then
    if tail -n 1 logs/operations.log | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} - '; then
        pass "Log entries include timestamp and description"
    else
        warn "Log entries do not follow timestamp + description format"
    fi
else
    warn "No log file or log entries found"
fi

# Basic git history check
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    commits=$(git rev-list --count HEAD 2>/dev/null || echo 0)
    if [ "$commits" -gt 0 ]; then
        pass "Git repository has commit history"
    else
        warn "No Git history found"
    fi
else
    warn "Not a git repository"
fi

# README check
if [ -f README.md ] && grep -qi "bash\|network\|logs" README.md; then
    pass "README contains project description"
else
    warn "README missing expected details"
fi

# Score summary
printf '\nFinal Score: %s/%s\n' "$score" "$max_score"

# Exit 0 for pass even if some warnings; this is a grader helper
exit 0
