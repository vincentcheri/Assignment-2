#!/usr/bin/env bash

set -euo pipefail

image=${IMAGE_NAME:-diagnostic-tool:test}
output_file=$(mktemp)
trap 'rm -f "$output_file"' EXIT

docker build -t "$image" .

assert_output_contains() {
    local label=$1
    local expected=$2
    shift 2
    docker run --rm "$image" "$@" >"$output_file" 2>&1
    if ! grep -Fq -- "$expected" "$output_file"; then
        printf 'FAIL: %s output did not contain: %s\n' "$label" "$expected" >&2
        cat "$output_file" >&2
        exit 1
    fi
    printf 'PASS: %s\n' "$label"
}

assert_exit_code() {
    local label=$1
    local expected=$2
    shift 2
    local actual
    if docker run --rm "$image" "$@" >"$output_file" 2>&1; then
        actual=0
    else
        actual=$?
    fi
    if [[ $actual -ne $expected ]]; then
        printf 'FAIL: %s exited with %s; expected %s\n' "$label" "$actual" "$expected" >&2
        cat "$output_file" >&2
        exit 1
    fi
    printf 'PASS: %s (exit %s)\n' "$label" "$actual"
}

assert_output_contains "help" "Usage:" help
assert_output_contains "system" "System information" system
assert_output_contains "system uptime" "up" system
assert_output_contains "disk" "Disk usage" disk
assert_exit_code "network localhost" 0 network localhost
assert_exit_code "invalid command" 2 not-a-command
assert_exit_code "missing network host" 2 network
if docker run --rm --entrypoint /app/health-check.sh "$image" >"$output_file" 2>&1; then
    printf 'PASS: health check\n'
else
    printf 'FAIL: health check\n' >&2
    cat "$output_file" >&2
    exit 1
fi

printf 'All Docker image tests passed.\n'
