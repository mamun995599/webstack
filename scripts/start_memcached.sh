#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$LD_LIBRARY_PATH"

echo "Starting Memcached..."

if [ -f "$WEBSTACK_ROOT/tmp/memcached.pid" ] && kill -0 $(cat "$WEBSTACK_ROOT/tmp/memcached.pid") 2>/dev/null; then
    echo "  Already running"
    exit 0
fi

mkdir -p "$WEBSTACK_ROOT/logs"
mkdir -p "$WEBSTACK_ROOT/tmp"

"$WEBSTACK_ROOT/deps/bin/memcached" \
    -d \
    -m 64 \
    -p 11211 \
    -u $(whoami) \
    -l 127.0.0.1 \
    -P "$WEBSTACK_ROOT/tmp/memcached.pid" \
    -v >> "$WEBSTACK_ROOT/logs/memcached.log" 2>&1

sleep 1

if [ -f "$WEBSTACK_ROOT/tmp/memcached.pid" ]; then
    echo "  Started (PID: $(cat $WEBSTACK_ROOT/tmp/memcached.pid))"
else
    echo "  Failed - check $WEBSTACK_ROOT/logs/memcached.log"
fi
