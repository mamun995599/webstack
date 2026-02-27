#!/bin/bash
# build_php_deps.sh - Build all PHP dependencies (FULLY FIXED)

set -e

export WEBSTACK_ROOT="$HOME/webstack"
export DEPS_DIR="$WEBSTACK_ROOT/deps"
export SRC_DIR="$WEBSTACK_ROOT/src"
export PATH="$DEPS_DIR/bin:$PATH"
export PKG_CONFIG_PATH="$DEPS_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="$DEPS_DIR/lib:$LD_LIBRARY_PATH"
export CFLAGS="-I$DEPS_DIR/include"
export CPPFLAGS="-I$DEPS_DIR/include"
export LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib"

mkdir -p "$SRC_DIR" "$DEPS_DIR"
cd "$SRC_DIR"

echo "========================================"
echo "Building PHP Dependencies"
echo "========================================"
echo ""
echo "WEBSTACK_ROOT: $WEBSTACK_ROOT"
echo "DEPS_DIR: $DEPS_DIR"
echo "SRC_DIR: $SRC_DIR"
echo ""

# Helper function
download_extract() {
    local url="$1"
    local file=$(basename "$url")
    local max_retries=3
    local retry=0
    
    cd "$SRC_DIR"
    
    while [ $retry -lt $max_retries ]; do
        if [ -f "$file" ]; then
            case "$file" in
                *.tar.gz|*.tgz)
                    if gzip -t "$file" 2>/dev/null; then
                        break
                    else
                        echo "  File corrupted, re-downloading..."
                        rm -f "$file"
                    fi
                    ;;
                *.tar.xz)
                    if xz -t "$file" 2>/dev/null; then
                        break
                    else
                        echo "  File corrupted, re-downloading..."
                        rm -f "$file"
                    fi
                    ;;
            esac
        fi
        
        if [ ! -f "$file" ]; then
            echo "  Downloading $file (attempt $((retry+1))/$max_retries)..."
            wget -q --show-progress --no-check-certificate --timeout=60 --tries=2 "$url" -O "$file" || {
                rm -f "$file"
                retry=$((retry + 1))
                sleep 2
                continue
            }
        fi
        
        retry=$((retry + 1))
    done
    
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        echo "  ERROR: Failed to download $file"
        return 1
    fi
    
    echo "  Extracting $file..."
    case "$file" in
        *.tar.gz|*.tgz) tar xzf "$file" ;;
        *.tar.xz) tar xf "$file" ;;
        *.tar.bz2) tar xjf "$file" ;;
    esac
    
    return 0
}

# ============ 1-14: Core Dependencies (same as before) ============

# ============ 1. zlib ============
if [ ! -f "$DEPS_DIR/lib/libz.so" ] && [ ! -f "$DEPS_DIR/lib/libz.a" ]; then
    echo ""
    echo "[1/17] Building zlib..."
    cd "$SRC_DIR"
    rm -rf zlib-1.3.1 zlib-1.3
    download_extract "https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz" || \
    download_extract "https://zlib.net/zlib-1.3.1.tar.gz"
    if [ -d "zlib-1.3.1" ]; then cd zlib-1.3.1; elif [ -d "zlib-1.3" ]; then cd zlib-1.3; fi
    ./configure --prefix="$DEPS_DIR"
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ zlib built"
else
    echo "[1/17] zlib already built, skipping..."
fi

# ============ 2. OpenSSL ============
if [ ! -f "$DEPS_DIR/lib/libssl.so" ] && [ ! -f "$DEPS_DIR/lib/libssl.a" ]; then
    echo ""
    echo "[2/17] Building OpenSSL..."
    cd "$SRC_DIR"
    rm -rf openssl-3.2.0
    download_extract "https://www.openssl.org/source/openssl-3.2.0.tar.gz"
    cd openssl-3.2.0
    ./Configure --prefix="$DEPS_DIR" --openssldir="$DEPS_DIR/ssl" linux-x86_64 shared
    make -j$(nproc) && make install_sw
    cd "$SRC_DIR"
    echo "  ✓ OpenSSL built"
else
    echo "[2/17] OpenSSL already built, skipping..."
fi

# ============ 3. libxml2 ============
if [ ! -f "$DEPS_DIR/lib/libxml2.so" ]; then
    echo ""
    echo "[3/17] Building libxml2..."
    cd "$SRC_DIR"
    rm -rf libxml2-2.12.3
    download_extract "https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.3.tar.xz"
    cd libxml2-2.12.3
    CFLAGS="-I$DEPS_DIR/include" LDFLAGS="-L$DEPS_DIR/lib" \
    ./configure --prefix="$DEPS_DIR" --without-python --with-zlib="$DEPS_DIR"
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ libxml2 built"
else
    echo "[3/17] libxml2 already built, skipping..."
fi

# ============ 4. libpng ============
if [ ! -f "$DEPS_DIR/lib/libpng.so" ] && [ ! -f "$DEPS_DIR/lib/libpng16.so" ]; then
    echo ""
    echo "[4/17] Building libpng..."
    cd "$SRC_DIR"
    rm -rf libpng-1.6.40
    download_extract "https://download.sourceforge.net/libpng/libpng-1.6.40.tar.gz"
    cd libpng-1.6.40
    CFLAGS="-I$DEPS_DIR/include" CPPFLAGS="-I$DEPS_DIR/include" \
    LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
    ZLIB_CFLAGS="-I$DEPS_DIR/include" ZLIB_LIBS="-L$DEPS_DIR/lib -lz" \
    ./configure --prefix="$DEPS_DIR" --with-zlib-prefix="$DEPS_DIR"
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ libpng built"
else
    echo "[4/17] libpng already built, skipping..."
fi

# ============ 5. libjpeg-turbo ============
if [ ! -f "$DEPS_DIR/lib/libjpeg.so" ]; then
    echo ""
    echo "[5/17] Building libjpeg-turbo..."
    cd "$SRC_DIR"
    rm -rf libjpeg-turbo-3.0.1
    download_extract "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.1/libjpeg-turbo-3.0.1.tar.gz"
    cd libjpeg-turbo-3.0.1
    rm -rf build && mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX="$DEPS_DIR" -DCMAKE_BUILD_TYPE=Release ..
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ libjpeg-turbo built"
else
    echo "[5/17] libjpeg already built, skipping..."
fi

# ============ 6. libwebp ============
if [ ! -f "$DEPS_DIR/lib/libwebp.so" ]; then
    echo ""
    echo "[6/17] Building libwebp..."
    cd "$SRC_DIR"
    rm -rf libwebp-1.3.2
    download_extract "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.3.2.tar.gz"
    cd libwebp-1.3.2
    CFLAGS="-I$DEPS_DIR/include" LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
    ./configure --prefix="$DEPS_DIR" --enable-libwebpmux --enable-libwebpdemux
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ libwebp built"
else
    echo "[6/17] libwebp already built, skipping..."
fi

# ============ 7. freetype ============
if [ ! -f "$DEPS_DIR/lib/libfreetype.so" ]; then
    echo ""
    echo "[7/17] Building freetype..."
    cd "$SRC_DIR"
    rm -rf freetype-2.13.2
    download_extract "https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.gz"
    cd freetype-2.13.2
    CFLAGS="-I$DEPS_DIR/include" LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
    ./configure --prefix="$DEPS_DIR" --with-zlib="$DEPS_DIR" --with-png="$DEPS_DIR"
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ freetype built"
else
    echo "[7/17] freetype already built, skipping..."
fi

# ============ 8. oniguruma ============
if [ ! -f "$DEPS_DIR/lib/libonig.so" ]; then
    echo ""
    echo "[8/17] Building oniguruma..."
    cd "$SRC_DIR"
    rm -rf onig-6.9.9
    download_extract "https://github.com/kkos/oniguruma/releases/download/v6.9.9/onig-6.9.9.tar.gz"
    cd onig-6.9.9
    ./configure --prefix="$DEPS_DIR"
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ oniguruma built"
else
    echo "[8/17] oniguruma already built, skipping..."
fi

# ============ 9. libsodium ============
if [ ! -f "$DEPS_DIR/lib/libsodium.so" ]; then
    echo ""
    echo "[9/17] Building libsodium..."
    cd "$SRC_DIR"
    rm -rf libsodium-1.0.19 libsodium-stable
    if [ ! -f "libsodium-1.0.19.tar.gz" ]; then
        wget -q --show-progress --no-check-certificate \
            "https://github.com/jedisct1/libsodium/releases/download/1.0.19-RELEASE/libsodium-1.0.19.tar.gz" \
            -O libsodium-1.0.19.tar.gz
    fi
    tar xzf libsodium-1.0.19.tar.gz
    SODIUM_DIR=$(find . -maxdepth 1 -type d -name "libsodium*" | head -1)
    cd "$SODIUM_DIR"
    ./configure --prefix="$DEPS_DIR"
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ libsodium built"
else
    echo "[9/17] libsodium already built, skipping..."
fi

# ============ 10. libzip ============
if [ ! -f "$DEPS_DIR/lib/libzip.so" ]; then
    echo ""
    echo "[10/17] Building libzip..."
    cd "$SRC_DIR"
    rm -rf libzip-1.10.1
    download_extract "https://libzip.org/download/libzip-1.10.1.tar.gz"
    cd libzip-1.10.1
    rm -rf build && mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX="$DEPS_DIR" -DCMAKE_PREFIX_PATH="$DEPS_DIR" \
          -DOPENSSL_ROOT_DIR="$DEPS_DIR" -DZLIB_LIBRARY="$DEPS_DIR/lib/libz.so" \
          -DZLIB_INCLUDE_DIR="$DEPS_DIR/include" ..
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ libzip built"
else
    echo "[10/17] libzip already built, skipping..."
fi

# ============ 11. curl ============
if [ ! -f "$DEPS_DIR/lib/libcurl.so" ]; then
    echo ""
    echo "[11/17] Building curl..."
    cd "$SRC_DIR"
    rm -rf curl-8.5.0
    download_extract "https://curl.se/download/curl-8.5.0.tar.gz"
    cd curl-8.5.0
    CFLAGS="-I$DEPS_DIR/include" LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
    ./configure --prefix="$DEPS_DIR" --with-openssl="$DEPS_DIR" --with-zlib="$DEPS_DIR" \
                --enable-shared --disable-static
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ curl built"
else
    echo "[11/17] curl already built, skipping..."
fi

# ============ 12. ICU ============
if [ ! -f "$DEPS_DIR/lib/libicuuc.so" ]; then
    echo ""
    echo "[12/17] Building ICU (this takes a while)..."
    cd "$SRC_DIR"
    rm -rf icu
    download_extract "https://github.com/unicode-org/icu/releases/download/release-74-1/icu4c-74_1-src.tgz"
    cd icu/source
    ./configure --prefix="$DEPS_DIR"
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ ICU built"
else
    echo "[12/17] ICU already built, skipping..."
fi

# ============ 13. libargon2 ============
if [ ! -f "$DEPS_DIR/lib/libargon2.so" ] && [ ! -f "$DEPS_DIR/lib/libargon2.a" ]; then
    echo ""
    echo "[13/17] Building libargon2..."
    cd "$SRC_DIR"
    rm -rf phc-winner-argon2-20190702
    if [ ! -f "argon2-20190702.tar.gz" ]; then
        wget --no-check-certificate \
            "https://github.com/P-H-C/phc-winner-argon2/archive/refs/tags/20190702.tar.gz" \
            -O argon2-20190702.tar.gz
    fi
    tar xzf argon2-20190702.tar.gz
    cd phc-winner-argon2-20190702
    make -j$(nproc) LIBRARY_REL=lib
    make install PREFIX="$DEPS_DIR" LIBRARY_REL=lib
    cd "$SRC_DIR"
    echo "  ✓ libargon2 built"
else
    echo "[13/17] libargon2 already built, skipping..."
fi

# ============ 14. libiconv ============
if [ ! -f "$DEPS_DIR/lib/libiconv.so" ]; then
    echo ""
    echo "[14/17] Building libiconv..."
    cd "$SRC_DIR"
    rm -rf libiconv-1.17
    download_extract "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz"
    cd libiconv-1.17
    ./configure --prefix="$DEPS_DIR" --enable-shared
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ libiconv built"
else
    echo "[14/17] libiconv already built, skipping..."
fi

# ============ 15. libevent (for memcached) ============
if [ ! -f "$DEPS_DIR/lib/libevent.so" ]; then
    echo ""
    echo "[15/17] Building libevent..."
    cd "$SRC_DIR"
    rm -rf libevent-2.1.12-stable
    download_extract "https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz"
    cd libevent-2.1.12-stable
    CFLAGS="-I$DEPS_DIR/include" LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
    ./configure --prefix="$DEPS_DIR" --with-openssl="$DEPS_DIR"
    make -j$(nproc) && make install
    cd "$SRC_DIR"
    echo "  ✓ libevent built"
else
    echo "[15/17] libevent already built, skipping..."
fi

# ============ 16. hiredis (for PHP redis extension) ============
if [ ! -f "$DEPS_DIR/lib/libhiredis.so" ]; then
    echo ""
    echo "[16/17] Building hiredis..."
    cd "$SRC_DIR"
    rm -rf hiredis
    git clone --depth 1 https://github.com/redis/hiredis.git
    cd hiredis
    make clean 2>/dev/null || true
    make PREFIX="$DEPS_DIR" -j$(nproc)
    make install PREFIX="$DEPS_DIR"
    cd "$SRC_DIR"
    echo "  ✓ hiredis built"
else
    echo "[16/17] hiredis already built, skipping..."
fi

# ============ 17. libmemcached (FIXED for GCC 10+) ============
if [ ! -f "$DEPS_DIR/lib/libmemcached.so" ]; then
    echo ""
    echo "[17/17] Building libmemcached (with GCC 10+ fix)..."
    
    cd "$SRC_DIR"
    rm -rf libmemcached-1.0.18
    
    if [ ! -f "libmemcached-1.0.18.tar.gz" ]; then
        wget -q --show-progress --no-check-certificate \
            "https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz" \
            -O libmemcached-1.0.18.tar.gz
    fi
    
    tar xzf libmemcached-1.0.18.tar.gz
    cd libmemcached-1.0.18
    
    # Apply fixes for GCC 10+ (multiple definition errors)
    echo "  Applying GCC 10+ compatibility fixes..."
    
    # Fix 1: clients/memflush.cc
    sed -i 's/opt_servers == false/opt_servers == 0/g' clients/memflush.cc 2>/dev/null || true
    
    # Fix 2: Add extern declarations to fix multiple definition
    # Patch clients/ms_sigsegv.c, clients/ms_task.c, clients/ms_thread.c
    for file in clients/ms_sigsegv.c clients/ms_task.c clients/ms_thread.c; do
        if [ -f "$file" ]; then
            sed -i 's/^ms_global_t ms_global;/extern ms_global_t ms_global;/g' "$file" 2>/dev/null || true
            sed -i 's/^ms_stats_t ms_stats;/extern ms_stats_t ms_stats;/g' "$file" 2>/dev/null || true
            sed -i 's/^ms_statistic_t ms_statistic;/extern ms_statistic_t ms_statistic;/g' "$file" 2>/dev/null || true
        fi
    done
    
    # Configure with -fcommon flag and disable memaslap
    CFLAGS="-I$DEPS_DIR/include -fcommon -Wno-error" \
    CXXFLAGS="-I$DEPS_DIR/include -fcommon -fpermissive -Wno-error" \
    LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib" \
    ./configure --prefix="$DEPS_DIR" \
        --disable-memcached-sasl \
        --enable-memaslap=no \
        --enable-static=no \
        --with-memcached=no
    
    # Build (ignore warnings)
    make -j$(nproc) || make
    make install
    cd "$SRC_DIR"
    echo "  ✓ libmemcached built"
else
    echo "[17/17] libmemcached already built, skipping..."
fi

# ============ Verify All Dependencies ============
echo ""
echo "========================================"
echo "Verifying PHP Dependencies"
echo "========================================"
echo ""

MISSING=0

check_lib() {
    local name="$1"
    if [ -f "$DEPS_DIR/lib/${name}.so" ] || [ -f "$DEPS_DIR/lib/${name}.a" ]; then
        echo "✓ $name"
    else
        echo "✗ $name (MISSING)"
        MISSING=$((MISSING + 1))
    fi
}

echo "Core Libraries:"
check_lib "libz"
check_lib "libssl"
check_lib "libcrypto"
check_lib "libxml2"
check_lib "libpng16"
check_lib "libjpeg"
check_lib "libwebp"
check_lib "libfreetype"
check_lib "libonig"
check_lib "libsodium"
check_lib "libzip"
check_lib "libcurl"
check_lib "libicuuc"
check_lib "libargon2"
check_lib "libiconv"

echo ""
echo "Redis & Memcached Libraries:"
check_lib "libevent"
check_lib "libhiredis"
check_lib "libmemcached"

echo ""
if [ $MISSING -eq 0 ]; then
    echo "========================================"
    echo "All PHP dependencies built successfully!"
    echo "========================================"
else
    echo "========================================"
    echo "WARNING: $MISSING dependencies missing!"
    echo "========================================"
fi

echo ""
echo "Next: ./build_php.sh"