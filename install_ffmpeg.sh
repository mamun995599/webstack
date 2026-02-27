#!/bin/bash
# install_ffmpeg.sh - Download portable static FFmpeg

set -e

WEBSTACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
DEPS_DIR="$WEBSTACK_ROOT/deps"

echo "========================================"
echo "Installing Portable FFmpeg"
echo "========================================"
echo ""

mkdir -p "$DEPS_DIR/bin"
cd "$DEPS_DIR"

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  FFMPEG_ARCH="amd64" ;;
    aarch64) FFMPEG_ARCH="arm64" ;;
    armv7l)  FFMPEG_ARCH="armhf" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Architecture: $ARCH ($FFMPEG_ARCH)"
echo ""

# Download latest static build from johnvansickle.com (most reliable)
echo "[1/3] Downloading FFmpeg static build..."

FFMPEG_URL="https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-${FFMPEG_ARCH}-static.tar.xz"
FFMPEG_FILE="ffmpeg-release-${FFMPEG_ARCH}-static.tar.xz"

if [ ! -f "$FFMPEG_FILE" ]; then
    wget "$FFMPEG_URL" -O "$FFMPEG_FILE" || {
        echo "Primary source failed, trying alternative..."
        # Alternative: BtbN builds (GitHub)
        FFMPEG_URL="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz"
        wget "$FFMPEG_URL" -O "$FFMPEG_FILE"
    }
fi

echo "[2/3] Extracting..."
tar xf "$FFMPEG_FILE"

# Find extracted directory
FFMPEG_DIR=$(ls -d ffmpeg-*-static 2>/dev/null | head -1) || \
FFMPEG_DIR=$(ls -d ffmpeg-*-linux* 2>/dev/null | head -1)

if [ -z "$FFMPEG_DIR" ]; then
    echo "ERROR: Could not find extracted FFmpeg directory"
    ls -la
    exit 1
fi

echo "[3/3] Installing binaries..."

# Copy binaries
cp "$FFMPEG_DIR/ffmpeg" "$DEPS_DIR/bin/"
cp "$FFMPEG_DIR/ffprobe" "$DEPS_DIR/bin/"

# ffplay might not exist in all builds
[ -f "$FFMPEG_DIR/ffplay" ] && cp "$FFMPEG_DIR/ffplay" "$DEPS_DIR/bin/"

# Make executable
chmod +x "$DEPS_DIR/bin/ffmpeg"
chmod +x "$DEPS_DIR/bin/ffprobe"
[ -f "$DEPS_DIR/bin/ffplay" ] && chmod +x "$DEPS_DIR/bin/ffplay"

# Cleanup
rm -rf "$FFMPEG_DIR"
rm -f "$FFMPEG_FILE"

# Create symlinks in webstack root for convenience
ln -sf "$DEPS_DIR/bin/ffmpeg" "$WEBSTACK_ROOT/ffmpeg"
ln -sf "$DEPS_DIR/bin/ffprobe" "$WEBSTACK_ROOT/ffprobe"

# Verify
echo ""
echo "========================================"
echo "FFmpeg Installed!"
echo "========================================"
echo ""
echo "Version:"
"$DEPS_DIR/bin/ffmpeg" -version | head -1
echo ""
echo "Location:"
echo "  ffmpeg:  $DEPS_DIR/bin/ffmpeg"
echo "  ffprobe: $DEPS_DIR/bin/ffprobe"
echo ""
echo "Encoders available:"
"$DEPS_DIR/bin/ffmpeg" -encoders 2>/dev/null | grep -E "^\s*[VAS]" | head -20
echo "  ... and more"
echo ""
echo "To use: ./ffmpeg or $DEPS_DIR/bin/ffmpeg"
