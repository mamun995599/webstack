#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"

case "${1:-all}" in
    nginx)
        tail -f "$WEBSTACK_ROOT/nginx/logs/error.log" "$WEBSTACK_ROOT/nginx/logs/access.log"
        ;;
    php)
        tail -f "$WEBSTACK_ROOT/php/var/log/php-fpm.log" "$WEBSTACK_ROOT/php/var/log/php-error.log"
        ;;
    node)
        tail -f "$WEBSTACK_ROOT/logs/node.log"
        ;;
    mysql)
        tail -f "$WEBSTACK_ROOT/logs/mysql-error.log"
        ;;
    cloudflare|cf)
        tail -f "$WEBSTACK_ROOT/logs/cloudflare/tunnel.log"
        ;;
    all|*)
        tail -f "$WEBSTACK_ROOT/nginx/logs/error.log" \
               "$WEBSTACK_ROOT/php/var/log/php-fpm.log" \
               "$WEBSTACK_ROOT/logs/node.log" \
               "$WEBSTACK_ROOT/logs/cloudflare/tunnel.log" 2>/dev/null
        ;;
esac
