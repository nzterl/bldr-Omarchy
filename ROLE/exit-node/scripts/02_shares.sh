#!/usr/bin/env bash
# TWEAK: T4
# Serve the static Vault over the tailnet so a consumer can browse it.
# --bg makes the serve config persist (a foreground `tailscale serve` dies
# with its launching shell — the bug that took the URL down initially).
#
# Usage:
#   ./02_shares.sh up      # (re)serve the vault (default; path serve needs root)
#   ./02_shares.sh down    # stop serving (tailscale serve reset)
#   ./02_shares.sh status
set -euo pipefail

source "${VAULT_ENV:-/home/terl/vault/env.sh}"
action="${1:-up}"

case "$action" in
  up)
    [[ -d "$VAULT_DIR" ]] || { echo "vault not found: $VAULT_DIR" >&2; exit 1; }
    sudo tailscale serve --bg "$VAULT_DIR"
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
    echo "usage: $0 {up|down|status}" >&2
    exit 1
    ;;
esac