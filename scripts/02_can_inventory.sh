#!/usr/bin/env bash
set -u

echo "=== CAN interfaces ==="
ls -l /sys/class/net/can* 2>/dev/null || {
  echo "No can* interfaces. Check USB-CAN adapters and drivers."
  exit 1
}

echo
for p in /sys/class/net/can*; do
  [ -e "$p" ] || continue
  iface="$(basename "$p")"
  echo "### $iface"
  ip -details link show "$iface" 2>/dev/null || true
  echo "-- udev serial candidates --"
  udevadm info -a -p "$p" 2>/dev/null | grep -iE 'serial|idVendor|idProduct' | head -30 || true
  echo
done

echo "Tip: plug adapters one at a time and record which serial belongs to LEFT and RIGHT."
