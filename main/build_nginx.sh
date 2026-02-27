
#!/bin/bash
# build_nginx.sh - Build Nginx with HTTP/2, HTTP/3, RTMP, RTMPS

set -e

export WEBSTACK_ROOT="$HOME/webstack"
export DEPS_DIR="$WEBSTACK_ROOT/deps"
export SRC_DIR="$WEBSTACK_ROOT/src"
export NGINX_DIR="$WEBSTACK_ROOT/nginx"

export PATH="$DEPS_DIR/bin:$PATH"
export PKG_CONFIG_PATH="$DEPS_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="$DEPS_DIR/lib:$LD_LIBRARY_PATH"
export C_INCLUDE_PATH="$DEPS_DIR/include"
export LIBRARY_PATH="$DEPS_DIR/lib"

mkdir -p "$SRC_DIR"
cd "$SRC_DIR"

echo "========================================"
echo "Building Nginx with HTTP/2, HTTP/3, RTMP, RTMPS"
echo "========================================"
echo ""

# Check dependencies
echo "Checking dependencies..."
MISSING=""
[ ! -f "$DEPS_DIR/lib/libpcre2-8.so" ] && MISSING="$MISSING pcre2"
[ ! -f "$DEPS_DIR/lib/libz.so" ] && [ ! -f "$DEPS_DIR/lib/libz.a" ] && MISSING="$MISSING zlib"
[ ! -f "$DEPS_DIR/lib/libssl.so" ] && [ ! -f "$DEPS_DIR/lib/libssl.a" ] && MISSING="$MISSING openssl"

if [ -n "$MISSING" ]; then
    echo "ERROR: Missing dependencies:$MISSING"
    echo "Run build_nginx_deps.sh first!"
    exit 1
fi
echo "✓ All dependencies found"

# Download Nginx
NGINX_VERSION="1.25.4"

if [ ! -d "nginx-$NGINX_VERSION" ]; then
    echo ""
    echo "[1/5] Downloading Nginx $NGINX_VERSION..."
    
    if [ ! -f "nginx-${NGINX_VERSION}.tar.gz" ]; then
        wget -nc "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
    fi
    tar xzf "nginx-${NGINX_VERSION}.tar.gz"
fi

# Download modules
echo ""
echo "[2/5] Downloading third-party modules..."

modules=(
    "nginx-rtmp-module|https://github.com/arut/nginx-rtmp-module.git"
    "headers-more-nginx-module|https://github.com/openresty/headers-more-nginx-module.git"
    "ngx-fancyindex|https://github.com/aperezdc/ngx-fancyindex.git"
    "nginx-upload-module|https://github.com/fdintino/nginx-upload-module.git"
    "ngx_http_substitutions_filter_module|https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git"
    "ngx_cache_purge|https://github.com/nginx-modules/ngx_cache_purge.git"
    "nginx-module-vts|https://github.com/vozlt/nginx-module-vts.git"
    "nginx-push-stream-module|https://github.com/wandenberg/nginx-push-stream-module.git"
    "nginx-dav-ext-module|https://github.com/arut/nginx-dav-ext-module.git"
    "ngx_http_geoip2_module|https://github.com/leev/ngx_http_geoip2_module.git"
    "njs|https://github.com/nginx/njs.git"
)

for mod in "${modules[@]}"; do
    name="${mod%%|*}"
    url="${mod##*|}"
    if [ ! -d "$name" ]; then
        echo "  - Downloading $name..."
        git clone --depth 1 "$url"
    fi
done

# Brotli module (needs submodule)
if [ ! -d "ngx_brotli" ]; then
    echo "  - Downloading ngx_brotli..."
    git clone --depth 1 https://github.com/google/ngx_brotli.git
    cd ngx_brotli && git submodule update --init && cd "$SRC_DIR"
fi

echo "  ✓ All modules downloaded"

# Configure
echo ""
echo "[3/5] Configuring Nginx..."

cd "nginx-$NGINX_VERSION"

[ -f "Makefile" ] && make clean 2>/dev/null || true

./configure \
    --prefix="$NGINX_DIR" \
    --sbin-path="$NGINX_DIR/sbin/nginx" \
    --modules-path="$NGINX_DIR/modules" \
    --conf-path="$NGINX_DIR/conf/nginx.conf" \
    --error-log-path="$NGINX_DIR/logs/error.log" \
    --http-log-path="$NGINX_DIR/logs/access.log" \
    --pid-path="$WEBSTACK_ROOT/tmp/nginx.pid" \
    --lock-path="$WEBSTACK_ROOT/tmp/nginx.lock" \
    --http-client-body-temp-path="$WEBSTACK_ROOT/tmp/client_body" \
    --http-proxy-temp-path="$WEBSTACK_ROOT/tmp/proxy" \
    --http-fastcgi-temp-path="$WEBSTACK_ROOT/tmp/fastcgi" \
    --http-uwsgi-temp-path="$WEBSTACK_ROOT/tmp/uwsgi" \
    --http-scgi-temp-path="$WEBSTACK_ROOT/tmp/scgi" \
    \
    --with-cc-opt="-I$DEPS_DIR/include -O2 -fPIC" \
    --with-ld-opt="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
    \
    --with-pcre="$SRC_DIR/pcre2-10.42" \
    --with-pcre-jit \
    --with-zlib="$SRC_DIR/zlib-1.3.1" \
    --with-openssl="$SRC_DIR/openssl-quic" \
    --with-openssl-opt="enable-tls1_3" \
    \
    --with-threads \
    --with-file-aio \
    --with-compat \
    \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_slice_module \
    --with-http_degradation_module \
    \
    --with-mail \
    --with-mail_ssl_module \
    \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_ssl_preread_module \
    \
    --add-module="$SRC_DIR/nginx-rtmp-module" \
    --add-module="$SRC_DIR/headers-more-nginx-module" \
    --add-module="$SRC_DIR/ngx-fancyindex" \
    --add-module="$SRC_DIR/nginx-upload-module" \
    --add-module="$SRC_DIR/ngx_http_substitutions_filter_module" \
    --add-module="$SRC_DIR/ngx_cache_purge" \
    --add-module="$SRC_DIR/nginx-module-vts" \
    --add-module="$SRC_DIR/nginx-push-stream-module" \
    --add-module="$SRC_DIR/nginx-dav-ext-module" \
    --add-module="$SRC_DIR/ngx_brotli" \
    --add-module="$SRC_DIR/njs/nginx" \
    --add-module="$SRC_DIR/ngx_http_geoip2_module"

# Build
echo ""
echo "[4/5] Building Nginx (10-15 minutes)..."
make -j$(nproc)

# Install
echo ""
echo "[5/5] Installing Nginx..."
make install

# Create directories
mkdir -p "$WEBSTACK_ROOT/tmp"/{client_body,proxy,fastcgi,uwsgi,scgi}
mkdir -p "$NGINX_DIR/conf"/{conf.d,sites-available,sites-enabled,ssl}
mkdir -p "$WEBSTACK_ROOT/www"/{hls,videos,recordings}

# Copy config files
cd "$SRC_DIR/nginx-$NGINX_VERSION"
for f in mime.types fastcgi_params koi-utf koi-win win-utf scgi_params uwsgi_params; do
    [ -f "conf/$f" ] && [ ! -f "$NGINX_DIR/conf/$f" ] && cp "conf/$f" "$NGINX_DIR/conf/"
done

echo ""
echo "========================================"
echo "Nginx built successfully!"
echo "========================================"
echo ""
echo "Binary: $NGINX_DIR/sbin/nginx"
echo "Config: $NGINX_DIR/conf/nginx.conf"
echo ""

"$NGINX_DIR/sbin/nginx" -V 2>&1 | head -20

echo ""
echo "Features: HTTP/2, HTTP/3, RTMP, RTMPS (via stream), SSL/TLS 1.3"
echo ""
echo "Next: ./build_php_deps.sh"