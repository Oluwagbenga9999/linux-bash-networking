#!/usr/bin/env bash
set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f /etc/os-release ] && { [ -d /app ] || [ -d "$script_dir" ]; }; then
    echo "Health check passed: environment is ready"
    exit 0
else
    echo "Health check failed: required environment is missing" >&2
    exit 1
fi
