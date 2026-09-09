#!/usr/bin/env bash
# TWEAKS: T1, T2, T3
# Wire up `digs` as a Tailscale exit node / subnet router with Tailscale SSH.
#
# Usage:
#   ./01_tailscale_exit_node.sh up    # apply (default)
#   ./01_tailscale_exit_node.sh down  # remove exit-node advertising/ssh
set -euo pipefail

SUDO="sudo"
[[ $(id -u) -eq 0 ]] && SUDO=""

mode="${1:-up}"
case "$mode" in
  up)
    # T1 — IP forwarding, runtime + persisted
    $SUDO sysctl -w net.ipv4.ip_forward=1
    $SUDO sysctl -w net.ipv6.conf.all.forwarding=1
    if [[ ! -f /etc/sysctl.d/99-tailscale.conf ]]; then
      echo "net.ipv4.ip_forward = 1"  | $SUDO tee /etc/sysctl.d/99-tailscale.conf
      echo "net.ipv6.conf.all.forwarding = 1" | $SUDO tee -a /etc/sysctl.d/99-tailscale.conf
    fi

    # T2 + T3 — advertise exit node/subnets, enable tailscale SSH
    $SUDO tailscale up \
      --advertise-exit-node \
      --advertise-routes=0.0.0.0/0,::/0 \
      --ssh
    echo "[up] digs advertises as exit node + tailscale SSH. Approve in admin console if prompted."
    ;;
  down)
    # Stop advertising exit node + ssh; leave the node connected.
    $SUDO tailscale up --ssh=false
    echo "[down] exit-node advertising and SSH off. Remaining on tailnet as a plain node."
    ;;
  *)
    echo "usage: $0 [up|down]" >&2
    exit 1
    ;;
esac

tailscale status | head -5
