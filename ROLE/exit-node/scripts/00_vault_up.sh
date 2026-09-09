#!/usr/bin/env bash
# TWEAK: T-all — one-shot bring-up of the digs Vault services (idempotent).
# Safe to run from a plain SSH shell (no TUI). Everything is a tagged service:
#   vault-serve  (tailscale serve --bg /home/terl/vault)
#   vault-sshd   (sshd.service on :22)
#   vault-herdr  (herdr 'digs' session server -> opencode agent w1:p1)
# plus the exit-node tailscale flags and IP forwarding.
#
#   ./00_vault_up.sh up      # bring everything up (default)
#   ./00_vault_up.sh status  # show current state of all services
#   ./00_vault_up.sh down    # stop + disable the tagged services (not tailscale)
set -euo pipefail

source "${VAULT_ENV:-/home/terl/vault/env.sh}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-up}" in
  up)
    echo "== exit-node tailscale flags (advertise exit node + ssh) =="
    "$HERE/01_tailscale_exit_node.sh"
    echo "== IP forwarding (exit-node prerequisite) =="
    sudo "$HERE/07_enable_ip_forwarding.sh"
    echo "== sshd (:22, tagged sshd.service) =="
    sudo "$HERE/06_enable_sshd.sh" enable
    echo "== vault serve ($VAULT_URL -> $VAULT_DIR) =="
    "$HERE/02_shares.sh" up
    echo "== herdr 'digs' session server (tagged vault-herdr) =="
    "$HERE/08_enable_herdr_server.sh" enable
    echo
    echo "Vault services are up. From a consumer:"
    echo "  browse:  $VAULT_URL"
    echo "  ssh:     ssh terl@digs"
    echo "  herdr:   herdr --remote terl@digs   (lands in w1:p1 opencode agent)"
    ;;
  status)
    echo "== tailscale =="; tailscale status 2>&1 | head -5
    echo "== sshd ==";     systemctl --no-pager --lines=3 status sshd 2>&1 | head -3 || true
    echo "== serve ==";    tailscale serve status 2>&1 || true
    echo "== herdr ==";    systemctl --user --no-pager --lines=3 status vault-herdr 2>&1 | head -3 || true
    ;;
  down)
    "$HERE/08_enable_herdr_server.sh" disable
    sudo "$HERE/06_enable_sshd.sh" disable
    "$HERE/02_shares.sh" down
    echo "[down] tagged vault services stopped (tailscale up flags left as-is)."
    ;;
  *)
    echo "usage: $0 {up|status|down}" >&2
    exit 1
    ;;
esac