#!/bin/bash
# install_cloudflared.sh - Download and install cloudflared binary

set -e

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
DEPS_DIR="$WEBSTACK_ROOT/deps"

echo "========================================"
echo "Installing Cloudflared"
echo "========================================"
echo ""

mkdir -p "$DEPS_DIR/bin"
cd "$DEPS_DIR"

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  CF_ARCH="amd64" ;;
    aarch64) CF_ARCH="arm64" ;;
    armv7l)  CF_ARCH="arm" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Architecture: $ARCH ($CF_ARCH)"
echo ""

# Download cloudflared
echo "[1/2] Downloading cloudflared..."

CF_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CF_ARCH}"

if [ -f "$DEPS_DIR/bin/cloudflared" ]; then
    echo "  Cloudflared already exists, checking for updates..."
    CURRENT_VERSION=$("$DEPS_DIR/bin/cloudflared" --version 2>/dev/null | head -1 || echo "unknown")
    echo "  Current: $CURRENT_VERSION"
fi

wget -q --show-progress "$CF_URL" -O "$DEPS_DIR/bin/cloudflared.tmp" || \
curl -sL "$CF_URL" -o "$DEPS_DIR/bin/cloudflared.tmp"

if [ ! -s "$DEPS_DIR/bin/cloudflared.tmp" ]; then
    echo "ERROR: Failed to download cloudflared"
    rm -f "$DEPS_DIR/bin/cloudflared.tmp"
    exit 1
fi

mv "$DEPS_DIR/bin/cloudflared.tmp" "$DEPS_DIR/bin/cloudflared"
chmod +x "$DEPS_DIR/bin/cloudflared"

echo "[2/2] Creating symlinks..."
ln -sf "$DEPS_DIR/bin/cloudflared" "$WEBSTACK_ROOT/cloudflared"

# Create directories for cloudflare
mkdir -p "$WEBSTACK_ROOT/logs/cloudflare"
mkdir -p "$WEBSTACK_ROOT/tmp"

echo ""
echo "========================================"
echo "Cloudflared Installed!"
echo "========================================"
echo ""
echo "Version:"
"$DEPS_DIR/bin/cloudflared" --version
echo ""
echo "Location: $DEPS_DIR/bin/cloudflared"
echo ""
echo "Next: Run ./scripts/cloudflare_tunnel.sh start"
echo ""