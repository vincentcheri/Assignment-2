#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  diagnostic system
  diagnostic network <host>
  diagnostic disk
  diagnostic help

Commands:
  system          Display Linux system information.
  network <host>  Check whether a host is reachable.
  disk            Display filesystem disk usage.
  help            Display this help message.
EOF
}

invalid_input() {
    printf 'Error: %s\n\n' "$1" >&2
    usage >&2
    exit 2
}

if (( $# == 0 )); then
    invalid_input "a command is required."
fi

command_name=$1
shift

case "$command_name" in
    system)
        (( $# == 0 )) || invalid_input "'system' does not take arguments."
        printf 'System information\n'
        printf 'Operating system: '
        if [[ -r /etc/os-release ]]; then
            . /etc/os-release
            printf '%s\n' "${PRETTY_NAME:-Linux}"
        else
            printf 'Linux\n'
        fi
        printf 'Kernel: %s\n' "$(uname -sr)"
        printf 'Architecture: %s\n' "$(uname -m)"
        printf 'Uptime: '
        uptime
        printf 'Memory: '
        awk '/^MemTotal:/ { printf "%.0f MiB total\n", $2 / 1024; found=1 } END { if (!found) exit 1 }' /proc/meminfo
        ;;
    network)
        (( $# == 1 )) || invalid_input "'network' requires exactly one host."
        host=$1
        [[ $host =~ ^[[:alnum:]][[:alnum:].:-]*$ && $host != *..* ]] ||
            invalid_input "host must be a hostname or IP address."
        if ping -c 1 -W 3 "$host"; then
            exit 0
        else
            printf 'Error: could not reach host %s.\n' "$host" >&2
            exit 1
        fi
        ;;
    disk)
        (( $# == 0 )) || invalid_input "'disk' does not take arguments."
        printf 'Disk usage\n'
        df -h
        ;;
    help)
        (( $# == 0 )) || invalid_input "'help' does not take arguments."
        usage
        ;;
    *)
        invalid_input "unknown command: $command_name."
        ;;
esac
