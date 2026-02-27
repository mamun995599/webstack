#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$LD_LIBRARY_PATH"

echo "Starting Redis..."

if [ -f "$WEBSTACK_ROOT/tmp/redis.pid" ] && kill -0 $(cat "$WEBSTACK_ROOT/tmp/redis.pid") 2>/dev/null; then
    echo "  Already running"
    exit 0
fi

mkdir -p "$WEBSTACK_ROOT/data/redis"
mkdir -p "$WEBSTACK_ROOT/logs"
mkdir -p "$WEBSTACK_ROOT/tmp"

"$WEBSTACK_ROOT/deps/bin/redis-server" "$WEBSTACK_ROOT/redis/redis.conf"
sleep 1

if [ -f "$WEBSTACK_ROOT/tmp/redis.pid" ]; then
    echo "  Started (PID: $(cat $WEBSTACK_ROOT/tmp/redis.pid))"
else
    echo "  Failed - check $WEBSTACK_ROOT/logs/redis.log"
fi
