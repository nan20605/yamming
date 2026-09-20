#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: sudo bash $0 <LEFT_USB_SERIAL> <RIGHT_USB_SERIAL>"
  exit 2
fi

LEFT="$1"
RIGHT="$2"
RULE="/etc/udev/rules.d/90-yamming-can.rules"

cat > "$RULE" <<EOF
SUBSYSTEM=="net", ACTION=="add", ATTRS{serial}=="$LEFT", NAME="can_left"
SUBSYSTEM=="net", ACTION=="add", ATTRS{serial}=="$RIGHT", NAME="can_right"
EOF

udevadm control --reload-rules
udevadm trigger

echo "Installed $RULE"
cat "$RULE"
echo
echo "Unplug/replug the two USB-CAN adapters, then run: ip link show"
