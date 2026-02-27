#!/bin/bash
# install_redis_memcached.sh - Install Redis, Memcached servers and PHP extensions

set -e

export WEBSTACK_ROOT="$HOME/webstack"
export DEPS_DIR="$WEBSTACK_ROOT/deps"
export SRC_DIR="$WEBSTACK_ROOT/src"
export PHP_DIR="$WEBSTACK_ROOT/php"
export PATH="$DEPS_DIR/bin:$PHP_DIR/bin:$PATH"
export PKG_CONFIG_PATH="$DEPS_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="$DEPS_DIR/lib:$PHP_DIR/lib:$LD_LIBRARY_PATH"

mkdir -p "$SRC_DIR" "$DEPS_DIR/bin"
cd "$SRC_DIR"

echo "========================================"
echo "Installing Redis & Memcached Support"
echo "========================================"
echo ""

# ============================================
# 1. REDIS SERVER
# ============================================
if [ ! -f "$DEPS_DIR/bin/redis-server" ]; then
    echo ""
    echo "[1/6] Building Redis Server..."
    
    REDIS_VERSION="7.2.4"
    
    if [ ! -f "redis-$REDIS_VERSION.tar.gz" ]; then
        wget -q --show-progress "https://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz"
    fi
    
    rm -rf "redis-$REDIS_VERSION"
    tar xzf "redis-$REDIS_VERSION.tar.gz"
    cd "redis-$REDIS_VERSION"
    
    # Build Redis
    make -j$(nproc) PREFIX="$DEPS_DIR"
    make install PREFIX="$DEPS_DIR"
    
    cd "$SRC_DIR"
    echo "  ✓ Redis Server built"
else
    echo "[1/6] Redis Server already installed, skipping..."
fi

# ============================================
# 2. MEMCACHED SERVER
# ============================================
if [ ! -f "$DEPS_DIR/bin/memcached" ]; then
    echo ""
    echo "[2/6] Building Memcached Server..."
    
    # First, build libevent (dependency)
    if [ ! -f "$DEPS_DIR/lib/libevent.so" ]; then
        echo "  Building libevent dependency..."
        
        LIBEVENT_VERSION="2.1.12"
        if [ ! -f "libevent-$LIBEVENT_VERSION-stable.tar.gz" ]; then
            wget -q --show-progress "https://github.com/libevent/libevent/releases/download/release-$LIBEVENT_VERSION-stable/libevent-$LIBEVENT_VERSION-stable.tar.gz"
        fi
        
        rm -rf "libevent-$LIBEVENT_VERSION-stable"
        tar xzf "libevent-$LIBEVENT_VERSION-stable.tar.gz"
        cd "libevent-$LIBEVENT_VERSION-stable"
        
        ./configure --prefix="$DEPS_DIR"
        make -j$(nproc)
        make install
        cd "$SRC_DIR"
    fi
    
    # Build memcached
    MEMCACHED_VERSION="1.6.23"
    if [ ! -f "memcached-$MEMCACHED_VERSION.tar.gz" ]; then
        wget -q --show-progress "https://memcached.org/files/memcached-$MEMCACHED_VERSION.tar.gz"
    fi
    
    rm -rf "memcached-$MEMCACHED_VERSION"
    tar xzf "memcached-$MEMCACHED_VERSION.tar.gz"
    cd "memcached-$MEMCACHED_VERSION"
    
    CFLAGS="-I$DEPS_DIR/include" \
    LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
    ./configure --prefix="$DEPS_DIR" \
        --with-libevent="$DEPS_DIR"
    
    make -j$(nproc)
    make install
    cd "$SRC_DIR"
    echo "  ✓ Memcached Server built"
else
    echo "[2/6] Memcached Server already installed, skipping..."
fi

# ============================================
# 3. LIBMEMCACHED (required for PHP extension)
# ============================================
if [ ! -f "$DEPS_DIR/lib/libmemcached.so" ]; then
    echo ""
    echo "[3/6] Building libmemcached..."
    
    # libmemcached requires libevent (already built above)
    
    LIBMEMCACHED_VERSION="1.0.18"
    if [ ! -f "libmemcached-$LIBMEMCACHED_VERSION.tar.gz" ]; then
        wget -q --show-progress "https://launchpad.net/libmemcached/1.0/$LIBMEMCACHED_VERSION/+download/libmemcached-$LIBMEMCACHED_VERSION.tar.gz"
    fi
    
    rm -rf "libmemcached-$LIBMEMCACHED_VERSION"
    tar xzf "libmemcached-$LIBMEMCACHED_VERSION.tar.gz"
    cd "libmemcached-$LIBMEMCACHED_VERSION"
    
    # Fix for newer compilers
    sed -i 's/opt_servers == false/opt_servers == 0/' clients/memflush.cc 2>/dev/null || true
    
    CFLAGS="-I$DEPS_DIR/include" \
    CXXFLAGS="-I$DEPS_DIR/include" \
    LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
    ./configure --prefix="$DEPS_DIR" \
        --with-memcached="$DEPS_DIR/bin/memcached" \
        --disable-memcached-sasl
    
    make -j$(nproc)
    make install
    cd "$SRC_DIR"
    echo "  ✓ libmemcached built"
else
    echo "[3/6] libmemcached already installed, skipping..."
fi

# ============================================
# 4. HIREDIS (required for PHP redis extension)
# ============================================
if [ ! -f "$DEPS_DIR/lib/libhiredis.so" ]; then
    echo ""
    echo "[4/6] Building hiredis..."
    
    if [ ! -d "hiredis" ]; then
        git clone --depth 1 https://github.com/redis/hiredis.git
    fi
    
    cd hiredis
    make clean 2>/dev/null || true
    make PREFIX="$DEPS_DIR"
    make install PREFIX="$DEPS_DIR"
    cd "$SRC_DIR"
    echo "  ✓ hiredis built"
else
    echo "[4/6] hiredis already installed, skipping..."
fi

# ============================================
# 5. PHP REDIS EXTENSION (via PECL)
# ============================================
echo ""
echo "[5/6] Installing PHP Redis extension..."

# Check if already installed
if "$PHP_DIR/bin/php" -m 2>/dev/null | grep -q "^redis$"; then
    echo "  PHP Redis extension already installed, skipping..."
else
    # Set up environment
    export PATH="$PHP_DIR/bin:$DEPS_DIR/bin:$PATH"
    export PKG_CONFIG_PATH="$DEPS_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
    
    cd "$SRC_DIR"
    
    # Download phpredis
    REDIS_EXT_VERSION="6.0.2"
    if [ ! -f "redis-$REDIS_EXT_VERSION.tgz" ]; then
        wget -q --show-progress "https://pecl.php.net/get/redis-$REDIS_EXT_VERSION.tgz"
    fi
    
    rm -rf "redis-$REDIS_EXT_VERSION"
    tar xzf "redis-$REDIS_EXT_VERSION.tgz"
    cd "redis-$REDIS_EXT_VERSION"
    
    # Build extension
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
fi

# ============================================
# 6. PHP MEMCACHED EXTENSION (via PECL)
# ============================================
echo ""
echo "[6/6] Installing PHP Memcached extension..."

# Check if already installed
if "$PHP_DIR/bin/php" -m 2>/dev/null | grep -q "^memcached$"; then
    echo "  PHP Memcached extension already installed, skipping..."
else
    cd "$SRC_DIR"
    
    # Download php-memcached
    MEMCACHED_EXT_VERSION="3.2.0"
    if [ ! -f "memcached-$MEMCACHED_EXT_VERSION.tgz" ]; then
        wget -q --show-progress "https://pecl.php.net/get/memcached-$MEMCACHED_EXT_VERSION.tgz"
    fi
    
    rm -rf "memcached-$MEMCACHED_EXT_VERSION"
    tar xzf "memcached-$MEMCACHED_EXT_VERSION.tgz"
    cd "memcached-$MEMCACHED_EXT_VERSION"
    
    # Build extension
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
fi

# ============================================
# CREATE MANAGEMENT SCRIPTS
# ============================================
echo ""
echo "Creating management scripts..."

# Redis config
mkdir -p "$WEBSTACK_ROOT/redis"
cat > "$WEBSTACK_ROOT/redis/redis.conf" << EOF
# Redis Configuration
bind 127.0.0.1
port 6379
daemonize yes
pidfile $WEBSTACK_ROOT/tmp/redis.pid
logfile $WEBSTACK_ROOT/logs/redis.log
dir $WEBSTACK_ROOT/data/redis
dbfilename dump.rdb

# Memory
maxmemory 128mb
maxmemory-policy allkeys-lru

# Persistence
save 900 1
save 300 10
save 60 10000

# Security (uncomment and set password)
# requirepass your_password_here
EOF

mkdir -p "$WEBSTACK_ROOT/data/redis"

# Start Redis script
cat > "$WEBSTACK_ROOT/scripts/start_redis.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$LD_LIBRARY_PATH"

echo "Starting Redis..."

if [ -f "$WEBSTACK_ROOT/tmp/redis.pid" ] && kill -0 $(cat "$WEBSTACK_ROOT/tmp/redis.pid") 2>/dev/null; then
    echo "  Already running"
    exit 0
fi

mkdir -p "$WEBSTACK_ROOT/data/redis"
mkdir -p "$WEBSTACK_ROOT/logs"
mkdir -p "$WEBSTACK_ROOT/tmp"

"$WEBSTACK_ROOT/deps/bin/redis-server" "$WEBSTACK_ROOT/redis/redis.conf"
sleep 1

if [ -f "$WEBSTACK_ROOT/tmp/redis.pid" ]; then
    echo "  Started (PID: $(cat $WEBSTACK_ROOT/tmp/redis.pid))"
else
    echo "  Failed - check $WEBSTACK_ROOT/logs/redis.log"
fi
EOF

# Stop Redis script
cat > "$WEBSTACK_ROOT/scripts/stop_redis.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$LD_LIBRARY_PATH"

echo "Stopping Redis..."

if [ -f "$WEBSTACK_ROOT/tmp/redis.pid" ]; then
    "$WEBSTACK_ROOT/deps/bin/redis-cli" -p 6379 shutdown 2>/dev/null || \
    kill $(cat "$WEBSTACK_ROOT/tmp/redis.pid") 2>/dev/null
    rm -f "$WEBSTACK_ROOT/tmp/redis.pid"
    echo "  Stopped"
else
    echo "  Not running"
fi
EOF

# Memcached config
mkdir -p "$WEBSTACK_ROOT/memcached"

# Start Memcached script
cat > "$WEBSTACK_ROOT/scripts/start_memcached.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$LD_LIBRARY_PATH"

echo "Starting Memcached..."

if [ -f "$WEBSTACK_ROOT/tmp/memcached.pid" ] && kill -0 $(cat "$WEBSTACK_ROOT/tmp/memcached.pid") 2>/dev/null; then
    echo "  Already running"
    exit 0
fi

mkdir -p "$WEBSTACK_ROOT/logs"
mkdir -p "$WEBSTACK_ROOT/tmp"

"$WEBSTACK_ROOT/deps/bin/memcached" \
    -d \
    -m 64 \
    -p 11211 \
    -u $(whoami) \
    -l 127.0.0.1 \
    -P "$WEBSTACK_ROOT/tmp/memcached.pid" \
    -v >> "$WEBSTACK_ROOT/logs/memcached.log" 2>&1

sleep 1

if [ -f "$WEBSTACK_ROOT/tmp/memcached.pid" ]; then
    echo "  Started (PID: $(cat $WEBSTACK_ROOT/tmp/memcached.pid))"
else
    echo "  Failed - check $WEBSTACK_ROOT/logs/memcached.log"
fi
EOF

# Stop Memcached script
cat > "$WEBSTACK_ROOT/scripts/stop_memcached.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTACK_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Stopping Memcached..."

if [ -f "$WEBSTACK_ROOT/tmp/memcached.pid" ]; then
    kill $(cat "$WEBSTACK_ROOT/tmp/memcached.pid") 2>/dev/null
    rm -f "$WEBSTACK_ROOT/tmp/memcached.pid"
    echo "  Stopped"
else
    echo "  Not running"
fi
EOF

# Make scripts executable
chmod +x "$WEBSTACK_ROOT/scripts/start_redis.sh"
chmod +x "$WEBSTACK_ROOT/scripts/stop_redis.sh"
chmod +x "$WEBSTACK_ROOT/scripts/start_memcached.sh"
chmod +x "$WEBSTACK_ROOT/scripts/stop_memcached.sh"

# ============================================
# VERIFY INSTALLATION
# ============================================
echo ""
echo "========================================"
echo "Verifying Installation"
echo "========================================"
echo ""

# Check binaries
echo "Servers:"
[ -f "$DEPS_DIR/bin/redis-server" ] && echo "  ✓ Redis Server: $($DEPS_DIR/bin/redis-server --version | head -1)" || echo "  ✗ Redis Server"
[ -f "$DEPS_DIR/bin/memcached" ] && echo "  ✓ Memcached: $($DEPS_DIR/bin/memcached -h 2>&1 | head -1)" || echo "  ✗ Memcached"

# Check PHP extensions
echo ""
echo "PHP Extensions:"
"$PHP_DIR/bin/php" -m 2>/dev/null | grep -q "^redis$" && echo "  ✓ PHP redis extension" || echo "  ✗ PHP redis extension"
"$PHP_DIR/bin/php" -m 2>/dev/null | grep -q "^memcached$" && echo "  ✓ PHP memcached extension" || echo "  ✗ PHP memcached extension"

echo ""
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo ""
echo "Start services:"
echo "  ./scripts/start_redis.sh"
echo "  ./scripts/start_memcached.sh"
echo ""
echo "Stop services:"
echo "  ./scripts/stop_redis.sh"
echo "  ./scripts/stop_memcached.sh"
echo ""
echo "Redis CLI:"
echo "  ./deps/bin/redis-cli"
echo ""
echo "Default ports:"
echo "  Redis:     127.0.0.1:6379"
echo "  Memcached: 127.0.0.1:11211"
echo ""
echo "Restart PHP-FPM to load extensions:"
echo "  kill -USR2 \$(cat php/var/run/php-fpm.pid)"
echo ""