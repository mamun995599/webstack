#!/bin/bash
# build_nginx_deps.sh - Fixed version with better download handling

set -e

export WEBSTACK_ROOT="$HOME/webstack"
export DEPS_DIR="$WEBSTACK_ROOT/deps"
export SRC_DIR="$WEBSTACK_ROOT/src"
export PATH="$DEPS_DIR/bin:$PATH"
export PKG_CONFIG_PATH="$DEPS_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="$DEPS_DIR/lib:$LD_LIBRARY_PATH"
export CFLAGS="-I$DEPS_DIR/include -O2"
export LDFLAGS="-L$DEPS_DIR/lib -Wl,-rpath,$DEPS_DIR/lib"

mkdir -p "$SRC_DIR" "$DEPS_DIR"
cd "$SRC_DIR"

echo "========================================"
echo "Building Nginx Dependencies"
echo "========================================"
echo ""
echo "WEBSTACK_ROOT: $WEBSTACK_ROOT"
echo "DEPS_DIR: $DEPS_DIR"
echo "SRC_DIR: $SRC_DIR"
echo ""

# Improved download function with retry and verification
download_extract() {
    local url="$1"
    local file=$(basename "$url")
    local max_retries=3
    local retry=0
    
    # Check if already extracted (directory exists)
    local dir_name=$(echo "$file" | sed 's/\.tar\.\(gz\|xz\|bz2\)$//' | sed 's/\.tgz$//')
    
    # Download if file doesn't exist or is corrupted
    while [ $retry -lt $max_retries ]; do
        if [ -f "$file" ]; then
            # Verify file integrity
            case "$file" in
                *.tar.gz|*.tgz)
                    if gzip -t "$file" 2>/dev/null; then
                        break  # File is good
                    else
                        echo "  File corrupted, re-downloading..."
                        rm -f "$file"
                    fi
                    ;;
                *.tar.xz)
                    if xz -t "$file" 2>/dev/null; then
                        break  # File is good
                    else
                        echo "  File corrupted, re-downloading..."
                        rm -f "$file"
                    fi
                    ;;
            esac
        fi
        
        if [ ! -f "$file" ]; then
            echo "  Downloading $file (attempt $((retry+1))/$max_retries)..."
            
            # Try wget first, then curl
            if command -v wget &>/dev/null; then
                wget -q --show-progress --timeout=60 --tries=3 "$url" -O "$file" || rm -f "$file"
            elif command -v curl &>/dev/null; then
                curl -L --progress-bar --connect-timeout 60 --retry 3 "$url" -o "$file" || rm -f "$file"
            fi
        fi
        
        retry=$((retry + 1))
        
        if [ ! -f "$file" ] || [ ! -s "$file" ]; then
            echo "  Download failed, retrying..."
            rm -f "$file"
            sleep 2
        fi
    done
    
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        echo "  ERROR: Failed to download $file after $max_retries attempts"
        return 1
    fi
    
    # Extract
    echo "  Extracting $file..."
    rm -rf "$dir_name"  # Remove old directory if exists
    
    case "$file" in
        *.tar.gz|*.tgz)
            tar xzf "$file" || { echo "Extraction failed!"; return 1; }
            ;;
        *.tar.xz)
            tar xf "$file" || { echo "Extraction failed!"; return 1; }
            ;;
        *.tar.bz2)
            tar xjf "$file" || { echo "Extraction failed!"; return 1; }
            ;;
    esac
    
    return 0
}

# ============ 1. PCRE2 ============
if [ ! -f "$DEPS_DIR/lib/libpcre2-8.so" ]; then
    echo ""
    echo "[1/7] Building PCRE2..."
    
    download_extract "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz"
    cd pcre2-10.42
    
    ./configure --prefix="$DEPS_DIR" --enable-jit
    make -j$(nproc)
    make install
    cd "$SRC_DIR"
    echo "  ✓ PCRE2 built"
else
    echo "[1/7] PCRE2 already built, skipping..."
fi

# ============ 2. zlib ============
if [ ! -f "$DEPS_DIR/lib/libz.so" ] && [ ! -f "$DEPS_DIR/lib/libz.a" ]; then
    echo ""
    echo "[2/7] Building zlib..."
    
    # Try primary source first, then fallback
    download_extract "https://zlib.net/zlib-1.3.1.tar.gz" || \
    download_extract "https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz" || \
    download_extract "https://zlib.net/fossils/zlib-1.3.tar.gz"
    
    # Find extracted directory
    if [ -d "zlib-1.3.1" ]; then
        cd zlib-1.3.1
    elif [ -d "zlib-1.3" ]; then
        cd zlib-1.3
    else
        echo "ERROR: Could not find zlib directory"
        exit 1
    fi
    
    ./configure --prefix="$DEPS_DIR"
    make -j$(nproc)
    make install
    cd "$SRC_DIR"
    echo "  ✓ zlib built"
else
    echo "[2/7] zlib already built, skipping..."
fi

# ============ 3. OpenSSL with QUIC ============
if [ ! -f "$DEPS_DIR/lib/libssl.so" ] && [ ! -f "$DEPS_DIR/lib/libssl.a" ]; then
    echo ""
    echo "[3/7] Building OpenSSL (with QUIC support)..."
    
    if [ ! -d "openssl-quic" ]; then
        git clone --depth 1 -b openssl-3.1.5+quic https://github.com/quictls/openssl.git openssl-quic
    fi
    
    cd openssl-quic
    make clean 2>/dev/null || true
    
    ./Configure --prefix="$DEPS_DIR" \
                --openssldir="$DEPS_DIR/ssl" \
                --libdir=lib \
                linux-x86_64 \
                enable-tls1_3 \
                shared
    
    make -j$(nproc)
    make install_sw
    cd "$SRC_DIR"
    echo "  ✓ OpenSSL built"
else
    echo "[3/7] OpenSSL already built, skipping..."
fi

# ============ 4. libatomic_ops ============
if [ ! -f "$DEPS_DIR/lib/libatomic_ops.a" ]; then
    echo ""
    echo "[4/7] Building libatomic_ops..."
    
    download_extract "https://github.com/ivmai/libatomic_ops/releases/download/v7.8.0/libatomic_ops-7.8.0.tar.gz"
    cd libatomic_ops-7.8.0
    
    ./configure --prefix="$DEPS_DIR"
    make -j$(nproc)
    make install
    cd "$SRC_DIR"
    echo "  ✓ libatomic_ops built"
else
    echo "[4/7] libatomic_ops already built, skipping..."
fi

# ============ 5. libmaxminddb (GeoIP2) ============
if [ ! -f "$DEPS_DIR/lib/libmaxminddb.so" ]; then
    echo ""
    echo "[5/7] Building libmaxminddb (GeoIP2)..."
    
    download_extract "https://github.com/maxmind/libmaxminddb/releases/download/1.9.1/libmaxminddb-1.9.1.tar.gz"
    cd libmaxminddb-1.9.1
    
    ./configure --prefix="$DEPS_DIR"
    make -j$(nproc)
    make install
    cd "$SRC_DIR"
    echo "  ✓ libmaxminddb built"
else
    echo "[5/7] libmaxminddb already built, skipping..."
fi

# ============ 6. libxml2 ============
if [ ! -f "$DEPS_DIR/lib/libxml2.so" ]; then
    echo ""
    echo "[6/7] Building libxml2..."
    
    download_extract "https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.3.tar.xz"
    cd libxml2-2.12.3
    
    ./configure --prefix="$DEPS_DIR" --without-python --with-zlib="$DEPS_DIR"
    make -j$(nproc)
    make install
    cd "$SRC_DIR"
    echo "  ✓ libxml2 built"
else
    echo "[6/7] libxml2 already built, skipping..."
fi

# ============ 7. libxslt ============
if [ ! -f "$DEPS_DIR/lib/libxslt.so" ]; then
    echo ""
    echo "[7/7] Building libxslt..."
    
    download_extract "https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.39.tar.xz"
    cd libxslt-1.1.39
    
    ./configure --prefix="$DEPS_DIR" --with-libxml-prefix="$DEPS_DIR"
    make -j$(nproc)
    make install
    cd "$SRC_DIR"
    echo "  ✓ libxslt built"
else
    echo "[7/7] libxslt already built, skipping..."
fi

# Verify
echo ""
echo "========================================"
echo "Verifying Nginx Dependencies"
echo "========================================"
echo ""

check_lib() {
    if [ -f "$DEPS_DIR/lib/$1.so" ] || [ -f "$DEPS_DIR/lib/$1.a" ]; then
        echo "✓ $1"
    else
        echo "✗ $1 (MISSING)"
    fi
}

check_lib "libpcre2-8"
check_lib "libz"
check_lib "libssl"
check_lib "libcrypto"
check_lib "libatomic_ops"
check_lib "libmaxminddb"
check_lib "libxml2"
check_lib "libxslt"

echo ""
echo "========================================"
echo "Nginx dependencies complete!"
echo "========================================"
echo ""
echo "Next: ./build_nginx.sh"