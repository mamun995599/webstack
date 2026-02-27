#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
SSL_DIR="$WEBSTACK_ROOT/nginx/conf/ssl"

echo "Generating new SSL certificate..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/key.pem" \
    -out "$SSL_DIR/cert.pem" \
    -subj "/C=US/ST=State/L=City/O=WebStack/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" 2>/dev/null

chmod 600 "$SSL_DIR/key.pem"

# Reload nginx
[ -f "$WEBSTACK_ROOT/tmp/nginx.pid" ] && "$WEBSTACK_ROOT/nginx/sbin/nginx" -p "$WEBSTACK_ROOT/nginx" -s reload

echo "SSL certificate renewed"
openssl x509 -in "$SSL_DIR/cert.pem" -noout -dates
