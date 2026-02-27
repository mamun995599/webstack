#!/bin/bash
# build_php.sh - Build PHP 8.3 with all extensions including Redis & Memcached

set -e

export WEBSTACK_ROOT="$HOME/webstack"
export DEPS_DIR="$WEBSTACK_ROOT/deps"
export SRC_DIR="$WEBSTACK_ROOT/src"
export PHP_DIR="$WEBSTACK_ROOT/php"

export PATH="$DEPS_DIR/bin:$PATH"
export PKG_CONFIG_PATH="$DEPS_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="$DEPS_DIR/lib:$LD_LIBRARY_PATH"

export CFLAGS="-I$DEPS_DIR/include"
export CPPFLAGS="-I$DEPS_DIR/include"
export LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib -Wl,-rpath,$PHP_DIR/lib"

export OPENSSL_CFLAGS="-I$DEPS_DIR/include"
export OPENSSL_LIBS="-L$DEPS_DIR/lib -lssl -lcrypto"
export ICU_CFLAGS="-I$DEPS_DIR/include"
export ICU_LIBS="-L$DEPS_DIR/lib -licuuc -licui18n -licuio"

cd "$SRC_DIR"

echo "========================================"
echo "Building PHP 8.3 with Redis & Memcached"
echo "========================================"
echo ""

# ============================================
# STEP 1: Check Dependencies
# ============================================
echo "Checking dependencies..."
MISSING=""
[ ! -f "$DEPS_DIR/lib/libz.so" ] && [ ! -f "$DEPS_DIR/lib/libz.a" ] && MISSING="$MISSING zlib"
[ ! -f "$DEPS_DIR/lib/libssl.so" ] && [ ! -f "$DEPS_DIR/lib/libssl.a" ] && MISSING="$MISSING openssl"
[ ! -f "$DEPS_DIR/lib/libxml2.so" ] && MISSING="$MISSING libxml2"
[ ! -f "$DEPS_DIR/lib/libonig.so" ] && MISSING="$MISSING oniguruma"
[ ! -f "$DEPS_DIR/lib/libcurl.so" ] && MISSING="$MISSING curl"

if [ -n "$MISSING" ]; then
    echo "ERROR: Missing core dependencies:$MISSING"
    echo "Run build_php_deps.sh first!"
    exit 1
fi

# Check Redis/Memcached dependencies
REDIS_DEPS_OK=1
MEMCACHED_DEPS_OK=1

[ ! -f "$DEPS_DIR/lib/libhiredis.so" ] && REDIS_DEPS_OK=0
[ ! -f "$DEPS_DIR/lib/libmemcached.so" ] && MEMCACHED_DEPS_OK=0
[ ! -f "$DEPS_DIR/lib/libevent.so" ] && MEMCACHED_DEPS_OK=0

echo "✓ Core dependencies found"
[ $REDIS_DEPS_OK -eq 1 ] && echo "✓ Redis dependencies found (hiredis)" || echo "⚠ Redis dependencies missing (hiredis)"
[ $MEMCACHED_DEPS_OK -eq 1 ] && echo "✓ Memcached dependencies found (libmemcached, libevent)" || echo "⚠ Memcached dependencies missing"
echo ""

# ============================================
# STEP 2: Download PHP
# ============================================
PHP_VERSION="8.3.2"

if [ ! -d "php-$PHP_VERSION" ]; then
    echo "[1/6] Downloading PHP $PHP_VERSION..."
    
    if [ ! -f "php-${PHP_VERSION}.tar.gz" ]; then
        wget -q --show-progress "https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz" || \
        wget -q --show-progress "https://museum.php.net/php8/php-${PHP_VERSION}.tar.gz"
    fi
    tar xzf "php-$PHP_VERSION.tar.gz"
else
    echo "[1/6] PHP source already downloaded..."
fi

cd "php-$PHP_VERSION"

# ============================================
# STEP 3: Configure PHP
# ============================================
echo ""
echo "[2/6] Detecting available features..."
echo ""

CONFIGURE_OPTS="
    --prefix=$PHP_DIR
    --with-config-file-path=$PHP_DIR/etc
    --with-config-file-scan-dir=$PHP_DIR/etc/conf.d
    --enable-fpm
    --disable-cgi
    --enable-bcmath
    --enable-calendar
    --enable-exif
    --enable-ftp
    --enable-mbstring
    --enable-pcntl
    --enable-shmop
    --enable-soap
    --enable-sockets
    --enable-opcache
    --enable-fileinfo
    --enable-posix
    --enable-ctype
    --enable-tokenizer
    --enable-filter
    --enable-phar
    --enable-mysqlnd
    --with-mysqli=mysqlnd
    --with-pdo-mysql=mysqlnd
"

# Add optional features
[ -f "$DEPS_DIR/lib/libssl.so" ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-openssl=$DEPS_DIR" && echo "✓ OpenSSL"
[ -f "$DEPS_DIR/lib/libz.so" ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-zlib=$DEPS_DIR" && echo "✓ zlib"
[ -f "$DEPS_DIR/lib/libcurl.so" ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-curl=$DEPS_DIR" && echo "✓ curl"
[ -f "$DEPS_DIR/lib/libxml2.so" ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-libxml=$DEPS_DIR --enable-xml --enable-simplexml --enable-dom --enable-xmlreader --enable-xmlwriter" && echo "✓ libxml2"
[ -f "$DEPS_DIR/lib/libzip.so" ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-zip=$DEPS_DIR" && echo "✓ libzip"
[ -f "$DEPS_DIR/lib/libsodium.so" ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-sodium=$DEPS_DIR" && echo "✓ libsodium"
[ -f "$DEPS_DIR/lib/libicuuc.so" ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --enable-intl" && echo "✓ ICU"
[ -f "$DEPS_DIR/lib/libargon2.so" ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-password-argon2=$DEPS_DIR" && echo "✓ argon2"
[ -f "$DEPS_DIR/lib/libiconv.so" ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-iconv=$DEPS_DIR" || CONFIGURE_OPTS="$CONFIGURE_OPTS --with-iconv"

# GD
if [ -f "$DEPS_DIR/lib/libfreetype.so" ] && [ -f "$DEPS_DIR/lib/libjpeg.so" ]; then
    GD_OPTS="--enable-gd --with-freetype=$DEPS_DIR --with-jpeg=$DEPS_DIR"
    [ -f "$DEPS_DIR/lib/libwebp.so" ] && GD_OPTS="$GD_OPTS --with-webp=$DEPS_DIR"
    CONFIGURE_OPTS="$CONFIGURE_OPTS $GD_OPTS"
    echo "✓ GD (freetype, jpeg, webp)"
fi

# System libraries
[ -f /usr/lib/x86_64-linux-gnu/libsqlite3.so ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-sqlite3 --with-pdo-sqlite" && echo "✓ SQLite"
[ -f /usr/lib/x86_64-linux-gnu/libreadline.so ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-readline" && echo "✓ readline"
[ -f /usr/lib/x86_64-linux-gnu/libbz2.so ] && CONFIGURE_OPTS="$CONFIGURE_OPTS --with-bz2" && echo "✓ bz2"

echo "✓ MySQL (mysqlnd)"
echo ""

# Clean previous build
[ -f "Makefile" ] && make clean 2>/dev/null || true

echo "[3/6] Configuring PHP..."
./configure $CONFIGURE_OPTS

# ============================================
# STEP 4: Build PHP
# ============================================
echo ""
echo "[4/6] Building PHP (15-25 minutes)..."
make -j$(nproc)

# ============================================
# STEP 5: Install PHP
# ============================================
echo ""
echo "[5/6] Installing PHP..."
make install

# Create directories
mkdir -p "$PHP_DIR/etc/conf.d"
mkdir -p "$PHP_DIR/etc/php-fpm.d"
mkdir -p "$PHP_DIR/var/run"
mkdir -p "$PHP_DIR/var/log"

# php.ini
cp php.ini-production "$PHP_DIR/etc/php.ini"

# php-fpm.conf
cat > "$PHP_DIR/etc/php-fpm.conf" << FPMCONF
[global]
pid = $PHP_DIR/var/run/php-fpm.pid
error_log = $PHP_DIR/var/log/php-fpm.log
daemonize = yes

include = $PHP_DIR/etc/php-fpm.d/*.conf
FPMCONF

# www.conf
cat > "$PHP_DIR/etc/php-fpm.d/www.conf" << WWWCONF
[www]
listen = $WEBSTACK_ROOT/tmp/php-fpm.sock
listen.mode = 0666

user = $(whoami)
group = $(id -gn)

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500

catch_workers_output = yes
decorate_workers_output = no

php_admin_value[error_log] = $PHP_DIR/var/log/php-error.log
php_admin_flag[log_errors] = on
WWWCONF

# Custom settings
cat > "$PHP_DIR/etc/conf.d/custom.ini" << CUSTOMINI
; Custom PHP Settings
date.timezone = UTC
memory_limit = 256M
max_execution_time = 300
post_max_size = 100M
upload_max_filesize = 100M
max_file_uploads = 20

; OPcache
opcache.enable = 1
opcache.enable_cli = 1
opcache.memory_consumption = 128
opcache.max_accelerated_files = 10000
opcache.jit = 1255
opcache.jit_buffer_size = 64M

; Error handling
display_errors = Off
log_errors = On
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; Security
expose_php = Off
CUSTOMINI

# SSL config
cat > "$PHP_DIR/etc/conf.d/ssl.ini" << SSLINI
openssl.cafile = $DEPS_DIR/ssl/certs/cacert.pem
curl.cainfo = $DEPS_DIR/ssl/certs/cacert.pem
SSLINI

echo "  ✓ PHP core installed"

# ============================================
# STEP 6: Install Redis & Memcached Extensions
# ============================================
echo ""
echo "[6/6] Installing Redis & Memcached PHP extensions..."
echo ""

# Update PATH to use newly installed PHP
export PATH="$PHP_DIR/bin:$PATH"

cd "$SRC_DIR"

# ------------ Redis Extension ------------
echo "Installing PHP Redis extension..."

if "$PHP_DIR/bin/php" -m 2>/dev/null | grep -q "^redis$"; then
    echo "  Redis extension already installed, skipping..."
else
    if [ $REDIS_DEPS_OK -eq 1 ]; then
        REDIS_EXT_VERSION="6.0.2"
        
        rm -rf "redis-$REDIS_EXT_VERSION"
        
        if [ ! -f "redis-$REDIS_EXT_VERSION.tgz" ]; then
            echo "  Downloading redis extension..."
            wget -q --show-progress "https://pecl.php.net/get/redis-$REDIS_EXT_VERSION.tgz"
        fi
        
        tar xzf "redis-$REDIS_EXT_VERSION.tgz"
        cd "redis-$REDIS_EXT_VERSION"
        
        "$PHP_DIR/bin/phpize"
        
        CFLAGS="-I$DEPS_DIR/include" \
        LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
        ./configure --with-php-config="$PHP_DIR/bin/php-config" \
            --enable-redis \
            --enable-redis-igbinary=no \
            --enable-redis-lzf=no \
            --enable-redis-zstd=no
        
        make -j$(nproc)
        make install
        
        # Enable extension
        echo "extension=redis.so" > "$PHP_DIR/etc/conf.d/redis.ini"
        
        cd "$SRC_DIR"
        echo "  ✓ PHP Redis extension installed"
    else
        echo "  ⚠ Skipping Redis (hiredis not found)"
        echo "    Run build_php_deps.sh to install hiredis first"
    fi
fi

# ------------ Memcached Extension ------------
echo ""
echo "Installing PHP Memcached extension..."

if "$PHP_DIR/bin/php" -m 2>/dev/null | grep -q "^memcached$"; then
    echo "  Memcached extension already installed, skipping..."
else
    if [ $MEMCACHED_DEPS_OK -eq 1 ]; then
        MEMCACHED_EXT_VERSION="3.2.0"
        
        cd "$SRC_DIR"
        rm -rf "memcached-$MEMCACHED_EXT_VERSION"
        
        if [ ! -f "memcached-$MEMCACHED_EXT_VERSION.tgz" ]; then
            echo "  Downloading memcached extension..."
            wget -q --show-progress "https://pecl.php.net/get/memcached-$MEMCACHED_EXT_VERSION.tgz"
        fi
        
        tar xzf "memcached-$MEMCACHED_EXT_VERSION.tgz"
        cd "memcached-$MEMCACHED_EXT_VERSION"
        
        "$PHP_DIR/bin/phpize"
        
        CFLAGS="-I$DEPS_DIR/include" \
        LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
        ./configure --with-php-config="$PHP_DIR/bin/php-config" \
            --with-libmemcached-dir="$DEPS_DIR" \
            --disable-memcached-sasl \
            --disable-memcached-session \
            --disable-memcached-igbinary \
            --disable-memcached-msgpack
        
        make -j$(nproc)
        make install
        
        # Enable extension
        echo "extension=memcached.so" > "$PHP_DIR/etc/conf.d/memcached.ini"
        
        cd "$SRC_DIR"
        echo "  ✓ PHP Memcached extension installed"
    else
        echo "  ⚠ Skipping Memcached (libmemcached or libevent not found)"
        echo "    Run build_php_deps.sh to install dependencies first"
    fi
fi

# ============================================
# VERIFY INSTALLATION
# ============================================
echo ""
echo "========================================"
echo "Verifying PHP Installation"
echo "========================================"
echo ""

"$PHP_DIR/bin/php" -v
echo ""

echo "Core Extensions:"
"$PHP_DIR/bin/php" -m | head -30
echo "..."
echo ""

echo "Cache Extensions:"
"$PHP_DIR/bin/php" -m | grep -E "^(redis|memcached)$" | while read ext; do
    echo "  ✓ $ext"
done

# Count extensions
TOTAL_EXT=$("$PHP_DIR/bin/php" -m | wc -l)
REDIS_OK=$("$PHP_DIR/bin/php" -m 2>/dev/null | grep -c "^redis$" || echo 0)
MEMCACHED_OK=$("$PHP_DIR/bin/php" -m 2>/dev/null | grep -c "^memcached$" || echo 0)

echo ""
echo "========================================"
echo "PHP Build Complete!"
echo "========================================"
echo ""
echo "PHP Binary:   $PHP_DIR/bin/php"
echo "PHP-FPM:      $PHP_DIR/sbin/php-fpm"
echo "php.ini:      $PHP_DIR/etc/php.ini"
echo "Extensions:   $TOTAL_EXT loaded"
echo ""
echo "Cache Support:"
[ $REDIS_OK -eq 1 ] && echo "  ✓ Redis extension installed" || echo "  ✗ Redis extension NOT installed"
[ $MEMCACHED_OK -eq 1 ] && echo "  ✓ Memcached extension installed" || echo "  ✗ Memcached extension NOT installed"
echo ""

if [ $REDIS_OK -eq 0 ] || [ $MEMCACHED_OK -eq 0 ]; then
    echo "To install missing cache extensions:"
    echo "  1. Run ./build_php_deps.sh (includes hiredis, libmemcached)"
    echo "  2. Run this script again"
    echo ""
fi

echo "Next steps:"
echo "  1. ./install_node.sh"
echo "  2. ./setup.sh"
echo "  3. ./webstack start"
echo ""