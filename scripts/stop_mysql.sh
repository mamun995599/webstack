#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/mysql/lib:$LD_LIBRARY_PATH"

echo "Stopping MySQL..."
[ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ] && "$WEBSTACK_ROOT/mysql/bin/mysqladmin" --socket="$WEBSTACK_ROOT/tmp/mysql.sock" -u root shutdown 2>/dev/null
[ -f "$WEBSTACK_ROOT/tmp/mysql.pid" ] && kill $(cat "$WEBSTACK_ROOT/tmp/mysql.pid") 2>/dev/null
rm -f "$WEBSTACK_ROOT/tmp/mysql.pid" "$WEBSTACK_ROOT/tmp/mysql.sock"
echo "Stopped"
