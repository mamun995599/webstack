#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/mysql/lib:$LD_LIBRARY_PATH"

[ ! -d "$WEBSTACK_ROOT/mysql" ] && { echo "MySQL not installed"; exit 1; }
[ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ] && { echo "Already running"; exit 0; }

echo "Starting MySQL..."
"$WEBSTACK_ROOT/mysql/bin/mysqld_safe" --defaults-file="$WEBSTACK_ROOT/mysql/my.cnf" &
sleep 3
[ -S "$WEBSTACK_ROOT/tmp/mysql.sock" ] && echo "Started" || echo "Failed"
