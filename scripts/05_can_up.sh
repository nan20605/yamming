#!/usr/bin/env bash
set -euo pipefail

IFACE="${1:-}"
if [ -z "$IFACE" ]; then
  echo "Usage: sudo bash $0 <can_interface>"
  exit 2
fi

ip link set "$IFACE" down 2>/dev/null || true
ip link set "$IFACE" up type can bitrate 1000000 restart-ms 100

echo "=== $IFACE ==="
ip -details link show "$IFACE"
