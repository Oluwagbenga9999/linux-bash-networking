#!/usr/bin/env bash
set -u

usage() {
    echo "Usage:"
    echo "  ./app.sh system-info"
    echo "  ./app.sh check-host <host>"
    echo "  ./app.sh check-port <host> <port>"
    echo "  ./app.sh help"
}

validate_host() {
    local host="$1"
    if [[ "$host" =~ ^[A-Za-z0-9.-]+$ ]] || [[ "$host" =~ ^[0-9a-fA-F:]+$ ]]; then
        return 0
    fi
    return 1
}

validate_port() {
    local port="$1"
    if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
        return 0
    fi
    return 1
}

system_info() {
    echo "Hostname: $(hostname)"
    echo "Current User: $(whoami)"
    echo "Date/Time: $(date)"
    echo "Operating System: $(uname -o 2>/dev/null || cat /etc/os-release 2>/dev/null | sed -n '1p' | cut -d= -f2-)"
    echo "Kernel Version: $(uname -r)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo "Current Working Directory: $(pwd)"
}

check_host() {
    local host="${1:-}"
    if [ -z "$host" ]; then
        echo "Missing host argument." >&2
        exit 2
    fi

    if ! validate_host "$host"; then
        echo "Invalid host: $host" >&2
        exit 2
    fi

    if command -v getent >/dev/null 2>&1; then
        resolved=$(getent hosts "$host" 2>/dev/null | awk 'NR==1 {print $1}')
    else
        resolved=$(nslookup "$host" 2>/dev/null | awk '/^Address: /{print $2; exit}' | head -n 1)
    fi

    if [ -n "$resolved" ]; then
        echo "Resolved Address: $resolved"
    else
        echo "Unable to resolve host: $host" >&2
        exit 1
    fi

    if command -v ping >/dev/null 2>&1; then
        if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
            echo "Connectivity: Reachable"
        else
            echo "Connectivity: Unreachable"
            exit 1
        fi
    else
        echo "Connectivity: Ping unavailable"
    fi
}

check_port() {
    local host="${1:-}"
    local port="${2:-}"

    if [ -z "$host" ] || [ -z "$port" ]; then
        echo "Missing host or port argument." >&2
        exit 2
    fi

    if ! validate_host "$host"; then
        echo "Invalid host: $host" >&2
        exit 2
    fi

    if ! validate_port "$port"; then
        echo "Invalid port: $port. Port must be between 1 and 65535." >&2
        exit 2
    fi

    if command -v nc >/dev/null 2>&1; then
        if nc -z -w 3 "$host" "$port" >/dev/null 2>&1; then
            echo "TCP Port $port on $host: Open"
            exit 0
        else
            echo "TCP Port $port on $host: Closed or unreachable" >&2
            exit 1
        fi
    elif timeout 5 bash -c "</dev/tcp/$host/$port" >/dev/null 2>&1; then
        echo "TCP Port $port on $host: Open"
        exit 0
    else
        echo "TCP Port $port on $host: Closed or unreachable" >&2
        exit 1
    fi
}

case "${1:-help}" in
    system-info)
        system_info
        ;;
    check-host)
        shift
        check_host "${1:-}"
        ;;
    check-port)
        shift
        check_port "${1:-}" "${2:-}"
        ;;
    help|-h|--help)
        usage
        ;;
    *)
        echo "Invalid command: ${1:-}" >&2
        usage >&2
        exit 2
        ;;
esac
