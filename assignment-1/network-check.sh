#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/log.sh"
log_message "Network check script executed"

# network-check.sh
# Usage: ./network-check.sh <hostname-or-ip> [port]
# Validate host argument.
# Resolve host and display resolved address.
# Perform basic connectivity check.
# Display network interface information.
# If a port is supplied, check TCP connectivity.
# Valid ports are 1-65535.
# Invalid input must return non-zero and should not crash the script.

set +e

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <hostname-or-ip> [port]" >&2
    log_message "Network check invalid arguments: $*"
    exit 2
fi

host="$1"
port="${2:-}"

# Validate host: allow hostname or IPv4/IPv6-like input
if [[ "$host" =~ ^[0-9A-Za-z.-]+$ ]] || [[ "$host" =~ ^[0-9a-fA-F:]+$ ]]; then
    :
else
    echo "Invalid host: $host" >&2
    log_message "Network check invalid host: $host"
    exit 2
fi

if [ -n "$port" ]; then
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "Invalid port: $port. Port must be an integer from 1 to 65535." >&2
        log_message "Network check invalid port: $port"
        exit 2
    fi
fi

# Resolve the host
resolved=$(getent ahosts "$host" 2>/dev/null | awk 'NR==1 {print $1}')
if [ -z "$resolved" ]; then
    resolved=$(getent hosts "$host" 2>/dev/null | awk 'NR==1 {print $1}')
fi

if [ -n "$resolved" ]; then
    echo "Resolved Address: $resolved"
else
    echo "Resolved Address: Unable to resolve host $host"
fi

# Basic connectivity check using ping when available
if command -v ping >/dev/null 2>&1; then
    ping -c 1 -W 2 "$host" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Connectivity: Reachable"
    else
        echo "Connectivity: Unreachable"
    fi
else
    echo "Connectivity: ping not available on this system"
fi

# Network interfaces
if command -v ip >/dev/null 2>&1; then
    echo "Network Interfaces:"
    ip addr show 2>/dev/null | sed -n '1,12p'
elif command -v ifconfig >/dev/null 2>&1; then
    echo "Network Interfaces:"
    ifconfig 2>/dev/null | sed -n '1,12p'
else
    echo "Network Interfaces: unavailable"
fi

# TCP port check if port is supplied
if [ -n "$port" ]; then
    echo "Checking TCP connectivity on port $port..."
    if command -v nc >/dev/null 2>&1; then
        nc -z -w 3 "$host" "$port" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "TCP Port $port: Open"
            log_message "Network check TCP port $port on $host succeeded"
            exit 0
        else
            echo "TCP Port $port: Closed or unreachable"
            log_message "Network check TCP port $port on $host failed"
            exit 1
        fi
    else
        echo "TCP Port $port: nc not available; cannot check"
        log_message "Network check port $port cannot be validated because nc is unavailable"
        exit 1
    fi
fi

log_message "Network check completed for $host"
exit 0
