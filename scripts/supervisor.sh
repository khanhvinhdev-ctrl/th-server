#!/bin/bash

set -e

PROJECT_DIR="/sdcard/Projects/th_server"
RUST_SCRIPT="$PROJECT_DIR/scripts/run_android.sh"
TUNNEL_SCRIPT="$PROJECT_DIR/scripts/tunnel.sh"

RUNTIME_DIR="/tmp/thserver"
RUST_LOG="$RUNTIME_DIR/rust.log"
TUNNEL_LOG="$RUNTIME_DIR/tunnel.log"

mkdir -p "$RUNTIME_DIR"

start_rust() {
    if pgrep -f "aarch64-linux-android/debug/rust_egine" > /dev/null; then
        echo "Rust Engine is already running."
        return
    fi

    bash "$RUST_SCRIPT" > "$RUST_LOG" 2>&1 &
    echo $! > "$RUNTIME_DIR/rust.pid"

    echo "Rust Engine started."
}

start_tunnel() {
    if pgrep -f "/tmp/cloudflared tunnel --url http://127.0.0.1:8080" > /dev/null; then
        echo "Cloudflare Tunnel is already running."
        return
    fi

    bash "$TUNNEL_SCRIPT" > "$TUNNEL_LOG" 2>&1 &
    echo $! > "$RUNTIME_DIR/tunnel.pid"

    echo "Cloudflare Tunnel started."
}

start() {
    echo "==> Starting ThServer..."

    start_rust

    sleep 1

    start_tunnel

    echo "==> ThServer started."
}

stop() {
    echo "==> Stopping ThServer..."

    if [ -f "$RUNTIME_DIR/tunnel.pid" ]; then
        kill "$(cat "$RUNTIME_DIR/tunnel.pid")" 2>/dev/null || true
        rm -f "$RUNTIME_DIR/tunnel.pid"
    fi

    if [ -f "$RUNTIME_DIR/rust.pid" ]; then
        kill "$(cat "$RUNTIME_DIR/rust.pid")" 2>/dev/null || true
        rm -f "$RUNTIME_DIR/rust.pid"
    fi

    echo "==> ThServer stopped."
}

status() {
    echo "==> ThServer status"

    if pgrep -f "aarch64-linux-android/debug/rust_egine" > /dev/null; then
        echo "Rust Engine: RUNNING"
    else
        echo "Rust Engine: STOPPED"
    fi

    if pgrep -f "/tmp/cloudflared tunnel --url http://127.0.0.1:8080" > /dev/null; then
        echo "Cloudflare Tunnel: RUNNING"
    else
        echo "Cloudflare Tunnel: STOPPED"
    fi
}

monitor() {
    echo "==> ThServer monitor started."

    while true; do

        if ! pgrep -f "aarch64-linux-android/debug/rust_egine" > /dev/null; then
            echo "Rust Engine process not found. Restarting..."
            start_rust
        else
            if ! curl -sf --max-time 3 http://127.0.0.1:8080/health > /dev/null; then
                echo "Rust Engine health check failed. Restarting..."

                pkill -f "aarch64-linux-android/debug/rust_egine" 2>/dev/null || true

                sleep 1

                start_rust
            fi
        fi

        if ! pgrep -f "/tmp/cloudflared tunnel --url http://127.0.0.1:8080" > /dev/null; then
            echo "Cloudflare Tunnel stopped. Restarting..."
            start_tunnel
        fi

        sleep 5
    done
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    monitor)
        monitor
        ;;
    *)
        echo "Usage: bash supervisor.sh {start|stop|status|monitor}"
        exit 1
        ;;
esac