
#!/bin/bash
# install_node.sh - Install Node.js portable binary

set -e

export WEBSTACK_ROOT="$HOME/webstack"
export NODE_DIR="$WEBSTACK_ROOT/node"
export SRC_DIR="$WEBSTACK_ROOT/src"

NODE_VERSION="20.10.0"

echo "========================================"
echo "Installing Node.js $NODE_VERSION"
echo "========================================"
echo ""

mkdir -p "$SRC_DIR" "$NODE_DIR"
cd "$SRC_DIR"

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) NODE_ARCH="x64" ;;
    aarch64) NODE_ARCH="arm64" ;;
    armv7l) NODE_ARCH="armv7l" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

echo "Architecture: $ARCH ($NODE_ARCH)"
echo ""

# Download
TARBALL="node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"
URL="https://nodejs.org/dist/v${NODE_VERSION}/${TARBALL}"

if [ ! -f "$TARBALL" ]; then
    echo "Downloading Node.js..."
    wget "$URL"
fi

# Extract
echo "Extracting..."
tar xf "$TARBALL"

# Copy to node directory
echo "Installing..."
cp -r "node-v${NODE_VERSION}-linux-${NODE_ARCH}"/* "$NODE_DIR/"

# Test
export PATH="$NODE_DIR/bin:$PATH"
echo ""
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"

# Install global packages
echo ""
echo "Installing global packages..."
npm install -g pm2 nodemon 2>/dev/null || true

# Setup WebSocket
echo ""
echo "Setting up WebSocket server..."
mkdir -p "$WEBSTACK_ROOT/ws"
cd "$WEBSTACK_ROOT/ws"

if [ ! -f "package.json" ]; then
    cat > package.json << 'EOF'
{
    "name": "webstack-websocket",
    "version": "1.0.0",
    "main": "server.js",
    "dependencies": {
        "ws": "^8.14.2"
    }
}
EOF
    npm install
fi

echo ""
echo "========================================"
echo "Node.js Installed!"
echo "========================================"
echo ""
echo "Binary: $NODE_DIR/bin/node"
echo "npm:    $NODE_DIR/bin/npm"
echo ""
echo "Next: ./setup_mysql.sh (optional)"
echo "      ./setup.sh (to generate configs)"