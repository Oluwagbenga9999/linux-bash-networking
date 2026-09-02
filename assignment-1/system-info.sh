#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/log.sh"
log_message "System information script executed"

# System Information Script
# Collects runtime values for the requested system details.

echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Date/Time: $(date)"
echo "Operating System: $(uname -o 2>/dev/null || cat /etc/os-release | sed -n '1p' | cut -d= -f2-)"
echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo "CPU Information:"
lscpu | sed -n '1,5p'
echo "Memory Information:"
free -h
echo "Current Working Directory: $(pwd)"
