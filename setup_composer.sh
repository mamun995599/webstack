
#!/bin/bash
# setup_composer.sh - Install Composer with SSL fix

set -e

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
PHP_DIR="$WEBSTACK_ROOT/php"
DEPS_DIR="$WEBSTACK_ROOT/deps"

echo "========================================"
echo "Installing Composer"
echo "========================================"
echo ""

# Check PHP
if [ ! -x "$PHP_DIR/bin/php" ]; then
    echo "ERROR: PHP not found at $PHP_DIR/bin/php"
    exit 1
fi

echo "PHP: $($PHP_DIR/bin/php -v | head -1)"
echo ""

# Setup SSL certificates
echo "[1/3] Setting up SSL certificates..."
mkdir -p "$DEPS_DIR/ssl/certs"

if [ ! -f "$DEPS_DIR/ssl/certs/cacert.pem" ]; then
    wget -q --no-check-certificate https://curl.se/ca/cacert.pem -O "$DEPS_DIR/ssl/certs/cacert.pem" 2>/dev/null || \
    curl -sk https://curl.se/ca/cacert.pem -o "$DEPS_DIR/ssl/certs/cacert.pem" 2>/dev/null || \
    cp /etc/ssl/certs/ca-certificates.crt "$DEPS_DIR/ssl/certs/cacert.pem" 2>/dev/null || \
    cp /etc/pki/tls/certs/ca-bundle.crt "$DEPS_DIR/ssl/certs/cacert.pem" 2>/dev/null
fi

mkdir -p "$PHP_DIR/etc/conf.d"
cat > "$PHP_DIR/etc/conf.d/ssl.ini" << EOF
openssl.cafile = $DEPS_DIR/ssl/certs/cacert.pem
curl.cainfo = $DEPS_DIR/ssl/certs/cacert.pem
EOF

echo "  Done"

# Download Composer
echo "[2/3] Downloading Composer..."

wget -q https://getcomposer.org/download/latest-stable/composer.phar -O "$PHP_DIR/bin/composer" 2>/dev/null || \
curl -sS https://getcomposer.org/download/latest-stable/composer.phar -o "$PHP_DIR/bin/composer" 2>/dev/null

if [ ! -f "$PHP_DIR/bin/composer" ] || [ ! -s "$PHP_DIR/bin/composer" ]; then
    echo "ERROR: Failed to download Composer"
    exit 1
fi

chmod +x "$PHP_DIR/bin/composer"
echo "  Done"

# Create wrapper
echo "[3/3] Creating wrapper script..."

cat > "$WEBSTACK_ROOT/composer" << 'EOF'
#!/bin/bash
WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
export PATH="$WEBSTACK_ROOT/php/bin:$PATH"
export SSL_CERT_FILE="$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem"
"$WEBSTACK_ROOT/php/bin/php" \
    -d openssl.cafile="$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem" \
    -d curl.cainfo="$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem" \
    "$WEBSTACK_ROOT/php/bin/composer" "$@"
EOF

chmod +x "$WEBSTACK_ROOT/composer"
echo "  Done"

echo ""
echo "========================================"
echo "Composer Installed!"
echo "========================================"
echo ""
echo "Version: $($WEBSTACK_ROOT/composer --version 2>/dev/null || echo 'Run ./composer --version')"
echo ""
echo "Usage:"
echo "  ./composer --version"
echo "  ./composer install"
echo "  ./composer require vendor/package"