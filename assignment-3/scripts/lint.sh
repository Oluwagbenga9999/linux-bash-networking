#!/usr/bin/env bash
set -u

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir" || exit 1

for file in app/*.sh scripts/*.sh tests/*.sh; do
    if [ -f "$file" ]; then
        bash -n "$file" || exit 1
    fi
done

echo "Lint checks passed"
