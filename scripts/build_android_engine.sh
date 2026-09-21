#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

RUST_DIR="$PROJECT_ROOT/rust_engine"
FLUTTER_DIR="$PROJECT_ROOT/flutter_app"

TARGET="aarch64-linux-android"
BINARY_NAME="rust_egine"
ANDROID_BINARY_NAME="librust_egine.so"

NDK_VERSION="30.0.16248370"
ANDROID_NDK_HOME="/root/android-sdk/ndk/$NDK_VERSION"

SOURCE_BINARY="$RUST_DIR/target/$TARGET/release/$BINARY_NAME"

DEST_DIR="$FLUTTER_DIR/android/app/src/main/jniLibs/arm64-v8a"
DEST_BINARY="$DEST_DIR/$ANDROID_BINARY_NAME"

echo "======================================"
echo " ThServer - Build Android Engine"
echo "======================================"
echo
echo "Rust project : $RUST_DIR"
echo "Flutter app  : $FLUTTER_DIR"
echo "Target       : $TARGET"
echo "NDK          : $NDK_VERSION"
echo "Destination  : $DEST_BINARY"
echo

if [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "ERROR: Android NDK not found:"
    echo "$ANDROID_NDK_HOME"
    exit 1
fi

cd "$RUST_DIR"

echo "[1/3] Building Rust Engine..."
echo

export ANDROID_NDK_HOME

cargo build \
    --target "$TARGET" \
    --release

echo
echo "[2/3] Copying engine into Android jniLibs..."
echo

if [ ! -f "$SOURCE_BINARY" ]; then
    echo "ERROR: Build succeeded but binary was not found:"
    echo "$SOURCE_BINARY"
    exit 1
fi

mkdir -p "$DEST_DIR"

cp "$SOURCE_BINARY" "$DEST_BINARY"

chmod +x "$DEST_BINARY"

echo
echo "[3/3] Verifying binary..."
echo

file "$DEST_BINARY"

echo
echo "======================================"
echo " Android Engine build completed"
echo "======================================"
echo
echo "Binary:"
echo "$DEST_BINARY"
echo
ls -lh "$DEST_BINARY"
echo