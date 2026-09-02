#!/usr/bin/env bash
set -u

usage() {
    echo "Usage:"
    echo "  diagnostic system"
    echo "  diagnostic network <host>"
    echo "  diagnostic disk"
    echo "  diagnostic help"
    echo ""
    echo "Commands:"
    echo "  system  Display useful Linux system information."
    echo "  network Check the supplied host."
    echo "  disk    Display disk information."
    echo "  help    Display commands and usage."
}

system_info() {
    echo "Hostname: $(hostname)"
    echo "Current User: $(whoami)"
    echo "Date/Time: $(date)"
    echo "Operating System: $(uname -o 2>/dev/null || cat /etc/os-release | sed -n '1p' | cut -d= -f2-)"
    echo "Kernel Version: $(uname -r)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo "Current Working Directory: $(pwd)"
}

network_check() {
    local host="${1:-}"

    if [ -z "$host" ]; then
        echo "Missing host argument." >&2
        exit 2
    fi

    if getent hosts "$host" >/dev/null 2>&1; then
        echo "Resolved Address: $(getent hosts "$host" | head -n 1 | awk '{print $1}')"
    elif getent ahostsv4 "$host" >/dev/null 2>&1; then
        echo "Resolved Address: $(getent ahostsv4 "$host" | head -n 1 | awk '{print $1}')"
    else
        echo "Resolved Address: unable to resolve $host"
    fi

    if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
        echo "Connectivity: reachable"
    else
        echo "Connectivity: unreachable"
    fi
}

disk_info() {
    df -h
}

case "${1:-help}" in
    system)
        system_info
        ;;
    network)
        shift
        network_check "${1:-}"
        ;;
    disk)
        disk_info
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
