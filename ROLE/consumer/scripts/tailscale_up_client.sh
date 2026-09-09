#!/usr/bin/env bash
# ROLE: consumer — join the tailnet and reach the digs workshop.
#
# Usage:
#   ./tailscale_up_client.sh up                     # join as plain node (default)
#   ./tailscale_up_client.sh up --exit-node digs    # join + route via exit node
#   ./tailscale_up_client.sh down                   # leave the tailnet
#   ./tailscale_up_client.sh status
set -euo pipefail

SUDO="sudo"
[[ $(id -u) -eq 0 ]] && SUDO=""

action="${1:-up}"
shift || true

case "$action" in
  up)
    $SUDO tailscale up "$@"
    echo "[up] on the tailnet. Browse digs with:"
    echo "  tailscale serve status --self  (on digs)  /  open its serve URL"
    echo "  ssh digs@digs"
    ;;
  down)
    $SUDO tailscale down
    echo "[down] left the tailnet."
    ;;
  status)
    tailscale status
    ;;
  *)
    echo "usage: $0 {up|down|status} [extra tailscale up flags]" >&2
    exit 1
    ;;
esac
