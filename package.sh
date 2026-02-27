#!/bin/bash
# package.sh - Create distributable package

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$WEBSTACK_ROOT"

echo "========================================"
echo "Package WebStack"
echo "========================================"
echo ""

# Stop all services
echo "Stopping services..."
./webstack stop 2>/dev/null || true
./scripts/cloudflare_tunnel.sh stop-daemon 2>/dev/null || true

# Ask about cleanup
echo ""
read -p "Run cleanup first? (recommended) [Y/n]: " cleanup
if [[ ! $cleanup =~ ^[Nn]$ ]]; then
    bash cleanup.sh
fi

# Clean runtime files
echo ""
echo "Cleaning runtime files..."
rm -f tmp/*.pid tmp/*.sock
find . -name "*.log" -type f -delete 2>/dev/null

# Ensure necessary directories exist
mkdir -p tmp logs logs/cloudflare www/{hls,videos} data/mysql backups

# Create package
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PACKAGE_NAME="webstack_portable_$TIMESTAMP.tar.gz"

echo ""
echo "Creating package..."
cd ..

# Exclude unnecessary files
tar -czvf "$PACKAGE_NAME" \
    --exclude='*.log' \
    --exclude='*.pid' \
    --exclude='*.sock' \
    --exclude='src' \
    --exclude='*.tar.gz' \
    --exclude='*.tar.xz' \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='data/mysql/*' \
    --exclude='www/hls/*' \
    --exclude='backups/*' \
    "$(basename "$WEBSTACK_ROOT")"

# Move package into webstack directory
mv "$PACKAGE_NAME" "$WEBSTACK_ROOT/"

echo ""
echo "========================================"
echo "Package Created!"
echo "========================================"
echo ""
echo "Package: $WEBSTACK_ROOT/$PACKAGE_NAME"
echo "Size:    $(du -h "$WEBSTACK_ROOT/$PACKAGE_NAME" | cut -f1)"
echo ""
echo "To deploy on new machine:"
echo "  1. Copy package to target machine"
echo "  2. tar -xzf $PACKAGE_NAME"
echo "  3. cd webstack"
echo "  4. ./INSTALL.sh"
echo "  5. ./webstack start"
echo ""
echo "Optional: ./webstack tunnel daemon  # Start Cloudflare tunnel"
echo ""