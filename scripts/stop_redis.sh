#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$LD_LIBRARY_PATH"

echo "Stopping Redis..."

if [ -f "$WEBSTACK_ROOT/tmp/redis.pid" ]; then
    "$WEBSTACK_ROOT/deps/bin/redis-cli" -p 6379 shutdown 2>/dev/null || \
    kill $(cat "$WEBSTACK_ROOT/tmp/redis.pid") 2>/dev/null
    rm -f "$WEBSTACK_ROOT/tmp/redis.pid"
    echo "  Stopped"
else
    echo "  Not running"
fi
