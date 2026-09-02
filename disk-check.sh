#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/log.sh"
log_message "Disk usage check executed"

# disk-check.sh
# Usage: ./disk-check.sh <threshold> [path]
# Default path: /
# Threshold must be an integer from 1 to 100.
# Exit 0 if usage is below threshold
# Exit 1 if usage is at or above threshold
# Exit 2 for invalid input

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <threshold> [path]" >&2
    log_message "Disk check invalid arguments: $*"
    exit 2
fi

threshold="$1"
path="${2:-/}"

if ! [[ "$threshold" =~ ^([1-9]|[1-9][0-9]|100)$ ]]; then
    echo "Invalid threshold: $threshold. Enter an integer from 1 to 100." >&2
    log_message "Disk check invalid threshold: $threshold"
    exit 2
fi

if [ ! -d "$path" ]; then
    echo "Invalid path: $path" >&2
    log_message "Disk check invalid path: $path"
    exit 2
fi

usage=$(df -P "$path" 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')

if ! [[ "$usage" =~ ^[0-9]+$ ]]; then
    echo "Unable to determine disk usage for $path" >&2
    log_message "Disk check could not determine usage for $path"
    exit 2
fi

echo "Disk usage for $path: ${usage}%"
log_message "Disk usage for $path: ${usage}%"

if [ "$usage" -lt "$threshold" ]; then
    exit 0
else
    exit 1
fi
