#!/usr/bin/env bash
# TWEAK: T1 (root part)
# Enable + persist IP forwarding. Run with sudo (needs your password).
#   sudo ./07_enable_ip_forwarding.sh
set -euo pipefail

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

if [[ ! -f /etc/sysctl.d/99-tailscale.conf ]]; then
  umask 022
  printf 'net.ipv4.ip_forward = 1\nnet.ipv6.conf.all.forwarding = 1\n' > /etc/sysctl.d/99-tailscale.conf
fi

echo "IP forwarding enabled and persisted (/etc/sysctl.d/99-tailscale.conf)."
sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding
