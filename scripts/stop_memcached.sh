#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Stopping Memcached..."

if [ -f "$WEBSTACK_ROOT/tmp/memcached.pid" ]; then
    kill $(cat "$WEBSTACK_ROOT/tmp/memcached.pid") 2>/dev/null
    rm -f "$WEBSTACK_ROOT/tmp/memcached.pid"
    echo "  Stopped"
else
    echo "  Not running"
fi
