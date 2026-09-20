#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT/logs"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$ROOT/logs/diagnostics_${STAMP}.txt"

{
  echo "=== YAMMING DIAGNOSTICS ==="
  date -Is
  echo
  echo "=== OS ==="
  cat /etc/os-release 2>/dev/null || true
  echo
  echo "=== KERNEL / ARCH ==="
  uname -a
  echo
  echo "=== JETSON ==="
  cat /etc/nv_tegra_release 2>/dev/null || true
  command -v nvidia-smi >/dev/null && nvidia-smi || true
  echo
  echo "=== HOST ==="
  hostname
  hostname -I 2>/dev/null || true
  echo
  echo "=== NETWORK ==="
  ip -brief address 2>/dev/null || true
  echo
  echo "=== USB ==="
  lsusb 2>/dev/null || true
  echo
  echo "=== CAN SYSFS ==="
  ls -l /sys/class/net/can* 2>/dev/null || echo "No can* interfaces found"
  echo
  echo "=== CAN LINKS ==="
  ip -details link show type can 2>/dev/null || true
  echo
  echo "=== PYTHON ==="
  python3 --version 2>/dev/null || true
  echo
  echo "=== ROS ==="
  printenv ROS_DISTRO || true
  command -v ros2 >/dev/null && ros2 --help >/dev/null && echo "ros2 command available" || true
} | tee "$OUT"

echo
echo "Saved: $OUT"
