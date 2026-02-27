
#!/bin/bash
# generate_rtmp_cert.sh - Generate better self-signed certificate for RTMP

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
SSL_DIR="$WEBSTACK_ROOT/nginx/conf/ssl"
DAYS=3650  # 10 years

# Backup old certs
[ -f "$SSL_DIR/cert.pem" ] && mv "$SSL_DIR/cert.pem" "$SSL_DIR/cert.pem.bak"
[ -f "$SSL_DIR/key.pem" ] && mv "$SSL_DIR/key.pem" "$SSL_DIR/key.pem.bak"

# Get local IP
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Create OpenSSL config
cat > /tmp/openssl_rtmp.cnf << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req

[dn]
C = US
ST = State
L = City
O = WebStack RTMP Server
OU = Streaming
CN = localhost

[v3_req]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = localhost
DNS.2 = *.localhost
DNS.3 = $(hostname)
IP.1 = 127.0.0.1
IP.2 = $LOCAL_IP
EOF

# Generate certificate
openssl req -x509 -nodes -days $DAYS -newkey rsa:2048 \
    -keyout "$SSL_DIR/key.pem" \
    -out "$SSL_DIR/cert.pem" \
    -config /tmp/openssl_rtmp.cnf

# Set permissions
chmod 600 "$SSL_DIR/key.pem"
chmod 644 "$SSL_DIR/cert.pem"

# Cleanup
rm -f /tmp/openssl_rtmp.cnf

echo ""
echo "Certificate generated!"
echo ""
echo "Certificate info:"
openssl x509 -in "$SSL_DIR/cert.pem" -noout -subject -dates
echo ""
echo "To trust this certificate, run:"
echo "  sudo cp $SSL_DIR/cert.pem /usr/local/share/ca-certificates/webstack-rtmp.crt"
echo "  sudo update-ca-certificates"
echo ""
echo "Then restart WebStack:"
echo "  ./webstack restart"