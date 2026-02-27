#!/bin/bash
# INSTALL.sh - Quick setup for new machine

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$WEBSTACK_ROOT"

echo "========================================"
echo "WebStack Quick Install"
echo "========================================"
echo ""
echo "Location: $WEBSTACK_ROOT"
echo ""

# 1. Fix permissions
echo "[1/6] Fixing permissions..."
chmod +x webstack setup.sh create_scripts.sh install_cloudflared.sh 2>/dev/null
chmod +x scripts/*.sh 2>/dev/null
chmod +x nginx/sbin/nginx 2>/dev/null
chmod +x php/bin/php php/sbin/php-fpm 2>/dev/null
chmod +x node/bin/* 2>/dev/null
chmod +x deps/bin/* 2>/dev/null
chmod +x composer 2>/dev/null
echo "  Done"

# 2. Create directories
echo "[2/6] Creating directories..."
mkdir -p tmp logs logs/cloudflare data/mysql www/{hls,videos,recordings} php/var/{run,log} nginx/logs backups
echo "  Done"

# 3. Run setup
echo "[3/6] Generating configurations..."
if [ -f "setup.sh" ]; then
    bash setup.sh >/dev/null 2>&1
fi
echo "  Done"

# 4. Create scripts
echo "[4/6] Creating management scripts..."
if [ -f "create_scripts.sh" ]; then
    bash create_scripts.sh >/dev/null 2>&1
fi
echo "  Done"

# 5. Install WebSocket dependencies
echo "[5/6] Installing WebSocket dependencies..."
if [ -d "$WEBSTACK_ROOT/ws" ] && [ -f "$WEBSTACK_ROOT/ws/package.json" ]; then
    cd "$WEBSTACK_ROOT/ws"
    [ -x "$WEBSTACK_ROOT/node/bin/npm" ] && "$WEBSTACK_ROOT/node/bin/npm" install --silent 2>/dev/null
    cd "$WEBSTACK_ROOT"
fi
echo "  Done"

# 6. Port binding capability
echo "[6/6] Configuring port binding..."
if command -v setcap &>/dev/null; then
    if [ -x "$WEBSTACK_ROOT/nginx/sbin/nginx" ]; then
        sudo setcap 'cap_net_bind_service=+ep' "$WEBSTACK_ROOT/nginx/sbin/nginx" 2>/dev/null && \
        echo "  Nginx can bind to ports 80/443" || \
        echo "  Run with sudo for ports 80/443 or use ports > 1024"
    fi
else
    echo "  setcap not available - may need sudo for ports 80/443"
fi

# Display versions
echo ""
echo "========================================"
echo "Installed Components"
echo "========================================"
echo ""

[ -x "$WEBSTACK_ROOT/nginx/sbin/nginx" ] && echo "Nginx:      $($WEBSTACK_ROOT/nginx/sbin/nginx -v 2>&1 | cut -d'/' -f2)"
[ -x "$WEBSTACK_ROOT/php/bin/php" ] && echo "PHP:        $($WEBSTACK_ROOT/php/bin/php -v | head -1 | cut -d' ' -f2)"
[ -x "$WEBSTACK_ROOT/node/bin/node" ] && echo "Node.js:    $($WEBSTACK_ROOT/node/bin/node -v)"
[ -x "$WEBSTACK_ROOT/mysql/bin/mysql" ] && echo "MySQL:      $($WEBSTACK_ROOT/mysql/bin/mysql --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
[ -x "$WEBSTACK_ROOT/deps/bin/cloudflared" ] && echo "Cloudflared: $($WEBSTACK_ROOT/deps/bin/cloudflared --version 2>&1 | head -1 | awk '{print $3}')"
[ -x "$WEBSTACK_ROOT/deps/bin/ffmpeg" ] && echo "FFmpeg:     $($WEBSTACK_ROOT/deps/bin/ffmpeg -version 2>&1 | head -1 | awk '{print $3}')"

echo ""
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo ""
echo "Commands:"
echo "  ./webstack start       Start all services"
echo "  ./webstack stop        Stop all services"
echo "  ./webstack status      Show status"
echo "  ./webstack tunnel daemon  Start Cloudflare tunnel"
echo ""
echo "URLs (after starting):"
echo "  http://localhost"
echo "  https://localhost"
echo "  rtmp://localhost:1935/live/streamkey"
echo ""
echo "To start: ./webstack start"
echo ""