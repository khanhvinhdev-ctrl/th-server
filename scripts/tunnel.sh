#!/bin/bash

set -e

CLOUDFLARED="/tmp/cloudflared"
LOCAL_URL="http://127.0.0.1:8080"

if [ ! -f "$CLOUDFLARED" ]; then
    echo "Error: cloudflared binary not found."
    echo "Expected: $CLOUDFLARED"
    exit 1
fi

chmod +x "$CLOUDFLARED"

echo "==> Starting Cloudflare Tunnel..."
echo "==> Forwarding: $LOCAL_URL"

exec "$CLOUDFLARED" tunnel --url "$LOCAL_URL"