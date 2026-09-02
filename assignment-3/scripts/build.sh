#!/usr/bin/env bash
set -u

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir" || exit 1

docker build -t devops-tool . >/tmp/devops-build.log 2>&1 || {
    echo "Docker build failed" >&2
    cat /tmp/devops-build.log >&2
    exit 1
}

echo "Docker image built successfully"

docker run --rm devops-tool help >/tmp/devops-help.log 2>&1 || {
    echo "Help smoke test failed" >&2
    cat /tmp/devops-help.log >&2
    exit 1
}

docker run --rm devops-tool system-info >/tmp/devops-system.log 2>&1 || {
    echo "System-info smoke test failed" >&2
    cat /tmp/devops-system.log >&2
    exit 1
}

if docker run --rm devops-tool invalid-command >/tmp/devops-invalid.log 2>&1; then
    echo "Invalid command was accepted unexpectedly" >&2
    exit 1
fi

echo "Smoke tests passed"
