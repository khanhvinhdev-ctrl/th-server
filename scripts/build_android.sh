#!/bin/bash

set -e

PROJECT_DIR="/sdcard/Projects/th_server/rust_engine"
TARGET_DIR="/tmp/thserver-target"

cd "$PROJECT_DIR"

echo "==> Building ThServer Rust Engine for Android ARM64..."

CARGO_TARGET_DIR="$TARGET_DIR" \
cargo build --target aarch64-linux-android

echo "==> Build successful."
echo "==> Binary:"
echo "$TARGET_DIR/aarch64-linux-android/debug/rust_egine"