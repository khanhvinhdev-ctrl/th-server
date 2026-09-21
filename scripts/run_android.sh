#!/bin/bash

set -e

BINARY="/tmp/thserver-target/aarch64-linux-android/debug/rust_egine"

if [ ! -f "$BINARY" ]; then
    echo "Error: Rust Engine binary not found."
    echo "Run ./scripts/build_android.sh first."
    exit 1
fi

chmod +x "$BINARY"

echo "==> Starting ThServer Rust Engine..."
echo "==> Listening on http://0.0.0.0:8080"

exec "$BINARY"