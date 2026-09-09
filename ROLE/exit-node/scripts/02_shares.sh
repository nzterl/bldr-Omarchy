#!/usr/bin/env bash
# TWEAK: T4
# Serve the ~/current workspace over the tailnet so a consumer can browse it.
#
# Usage:
#   sudo ./02_shares.sh up    # (re)serve the workspace (default; path/socket serve needs root)
#   ./02_shares.sh down  # stop serving
#   ./02_shares.sh status
set -euo pipefail

SHARE="${1:-/home/terl/dev/current}"
action="${2:-up}"

case "$action" in
  up)
    [[ -d "$SHARE" ]] || { echo "share not found: $SHARE" >&2; exit 1; }
    sudo tailscale serve "$SHARE"
    echo "[up] serving:"
    sudo tailscale serve status
    ;;
  down)
    tailscale serve reset || true
    echo "[down] tailscale serve stopped."
    ;;
  status)
    tailscale serve status || true
    ;;
  *)
    echo "usage: $0 [<share-path>] {up|down|status}" >&2
    exit 1
    ;;
esac
