#!/bin/bash
# Source this file: source ./scripts/env.sh

WEBSTACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export PATH="$WEBSTACK_ROOT/deps/bin:$WEBSTACK_ROOT/php/bin:$WEBSTACK_ROOT/node/bin:$WEBSTACK_ROOT/mysql/bin:$WEBSTACK_ROOT/nginx/sbin:$PATH"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$WEBSTACK_ROOT/php/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$WEBSTACK_ROOT/deps/lib/pkgconfig:$PKG_CONFIG_PATH"
export SSL_CERT_FILE="$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem"

echo "WebStack environment loaded"
echo "  PHP:   $(php -v 2>/dev/null | head -1 || echo 'not found')"
echo "  Node:  $(node -v 2>/dev/null || echo 'not found')"
echo "  Nginx: $($WEBSTACK_ROOT/nginx/sbin/nginx -v 2>&1 | head -1)"
