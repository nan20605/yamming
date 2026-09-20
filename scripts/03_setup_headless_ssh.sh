#!/usr/bin/env bash
set -euo pipefail

HOSTNAME_TARGET="${1:-yam-jetson}"

sudo apt update
sudo apt install -y openssh-server avahi-daemon
sudo systemctl enable --now ssh
sudo systemctl enable --now avahi-daemon
sudo hostnamectl set-hostname "$HOSTNAME_TARGET"

echo
echo "Hostname set to: $HOSTNAME_TARGET"
echo "Current addresses:"
hostname -I || true
echo
echo "From a machine on the same LAN, try:"
echo "  ssh $USER@${HOSTNAME_TARGET}.local"
