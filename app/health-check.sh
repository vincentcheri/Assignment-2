#!/usr/bin/env bash

set -o nounset

[[ -x /app/diagnostic.sh && -r /proc/uptime ]] || exit 1
exec /app/diagnostic.sh help >/dev/null
