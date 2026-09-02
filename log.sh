#!/usr/bin/env bash

LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logs"
LOG_FILE="$LOG_DIR/operations.log"

mkdir -p "$LOG_DIR"

log_message() {
    local message="$1"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    printf '%s - %s\n' "$timestamp" "$message" >> "$LOG_FILE"
}
