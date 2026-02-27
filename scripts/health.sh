#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"

echo "WebStack Health Check"
echo "====================="

check() {
    local name="$1"
    local cmd="$2"
    echo -n "$name: "
    if eval "$cmd" >/dev/null 2>&1; then
        echo "OK"
        return 0
    else
        echo "FAIL"
        return 1
    fi
}

check "Nginx" "curl -s http://localhost >/dev/null"
check "PHP-FPM" "curl -s http://localhost/index.php >/dev/null"
check "Node.js" "curl -s http://localhost/api/status >/dev/null"
check "WebSocket" "[ -f '$WEBSTACK_ROOT/tmp/ws.pid' ] && kill -0 \$(cat '$WEBSTACK_ROOT/tmp/ws.pid')"

if [ -d "$WEBSTACK_ROOT/mysql" ]; then
    check "MySQL" "[ -S '$WEBSTACK_ROOT/tmp/mysql.sock' ]"
fi

if [ -f "$WEBSTACK_ROOT/tmp/cloudflare_tunnel.pid" ]; then
    check "Cloudflare" "kill -0 \$(cat '$WEBSTACK_ROOT/tmp/cloudflare_tunnel.pid')"
fi

echo ""
echo "Disk usage: $(du -sh "$WEBSTACK_ROOT" | cut -f1)"
