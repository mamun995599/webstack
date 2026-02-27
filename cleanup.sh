#!/bin/bash
# cleanup.sh - Remove unnecessary files to reduce size

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "WebStack Cleanup"
echo "========================================"
echo ""
echo "Current size: $(du -sh "$WEBSTACK_ROOT" | cut -f1)"
echo ""

echo "This will remove:"
echo "  - Source files (src/)"
echo "  - Archives (*.tar.gz, *.tar.xz)"
echo "  - Build artifacts (*.o, *.lo, *.la)"
echo "  - Documentation"
echo "  - Development headers"
echo "  - Old logs"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

echo ""
echo "Cleaning..."

# Stop services first
"$WEBSTACK_ROOT/webstack" stop 2>/dev/null || true

# Remove source directory
echo "  Removing source files..."
rm -rf "$WEBSTACK_ROOT/src"

# Remove archives
echo "  Removing archives..."
find "$WEBSTACK_ROOT" -name "*.tar.gz" -delete 2>/dev/null
find "$WEBSTACK_ROOT" -name "*.tar.xz" -delete 2>/dev/null
find "$WEBSTACK_ROOT" -name "*.tar.bz2" -delete 2>/dev/null
find "$WEBSTACK_ROOT" -name "*.tgz" -delete 2>/dev/null

# Remove build artifacts
echo "  Removing build artifacts..."
find "$WEBSTACK_ROOT" -name "*.o" -delete 2>/dev/null
find "$WEBSTACK_ROOT" -name "*.lo" -delete 2>/dev/null
find "$WEBSTACK_ROOT" -name "*.la" -delete 2>/dev/null
find "$WEBSTACK_ROOT" -name "*.a" -path "*/deps/*" -delete 2>/dev/null

# Remove documentation
echo "  Removing documentation..."
rm -rf "$WEBSTACK_ROOT/deps/share"/{doc,man,info,gtk-doc} 2>/dev/null
rm -rf "$WEBSTACK_ROOT/node/share"/{man,doc} 2>/dev/null
rm -rf "$WEBSTACK_ROOT/mysql/man" 2>/dev/null
rm -rf "$WEBSTACK_ROOT/mysql/mysql-test" 2>/dev/null
rm -rf "$WEBSTACK_ROOT/mysql/sql-bench" 2>/dev/null

# Remove development headers (optional - keeps only essential)
echo "  Removing headers..."
rm -rf "$WEBSTACK_ROOT/deps/include" 2>/dev/null
rm -rf "$WEBSTACK_ROOT/php/include" 2>/dev/null
rm -rf "$WEBSTACK_ROOT/node/include" 2>/dev/null

# Remove pkgconfig
rm -rf "$WEBSTACK_ROOT/deps/lib/pkgconfig" 2>/dev/null

# Strip binaries
echo "  Stripping binaries..."
find "$WEBSTACK_ROOT"/{nginx/sbin,php/bin,php/sbin,deps/bin,node/bin} -type f -executable -exec strip --strip-unneeded {} \; 2>/dev/null
find "$WEBSTACK_ROOT"/{deps/lib,php/lib} -name "*.so*" -exec strip --strip-unneeded {} \; 2>/dev/null

# Clean logs (but keep structure)
echo "  Cleaning logs..."
find "$WEBSTACK_ROOT" -name "*.log" -type f -delete 2>/dev/null
mkdir -p "$WEBSTACK_ROOT/logs/cloudflare"
mkdir -p "$WEBSTACK_ROOT/nginx/logs"
mkdir -p "$WEBSTACK_ROOT/php/var/log"

# Clean tmp
echo "  Cleaning tmp..."
rm -rf "$WEBSTACK_ROOT/tmp"/*
mkdir -p "$WEBSTACK_ROOT/tmp"

# Remove npm cache
rm -rf "$WEBSTACK_ROOT/node/lib/node_modules/npm/.cache" 2>/dev/null

# Remove .git directories
find "$WEBSTACK_ROOT" -name ".git" -type d -exec rm -rf {} \; 2>/dev/null

# Remove empty directories
find "$WEBSTACK_ROOT" -type d -empty -delete 2>/dev/null

echo ""
echo "New size: $(du -sh "$WEBSTACK_ROOT" | cut -f1)"
echo ""
echo "Breakdown:"
du -sh "$WEBSTACK_ROOT"/*/ 2>/dev/null | sort -hr | head -10
echo ""
echo "Cleanup complete!"