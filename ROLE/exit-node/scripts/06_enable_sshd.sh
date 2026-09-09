#!/usr/bin/env bash
# TWEAK: T6 — run a real sshd on digs (managed as the tagged service sshd.service)
# Why: herdr --remote (from the laptop) shells out to ssh (port 22); Tailscale
# SSH works at the tailnet layer but doesn't give herdr/tmux+ssh a 22 listener.
# Enabling openssh's sshd makes ssh/scp/herdr --remote reach digs on the tailnet.
#
#   sudo ./06_enable_sshd.sh           # enable + start (default)
#   sudo ./06_enable_sshd.sh disable   # stop + disable
#   ./06_enable_sshd.sh status
set -euo pipefail

SUDO="sudo"
[[ $(id -u) -eq 0 ]] && SUDO=""

action="${1:-enable}"

case "$action" in
  enable)
    $SUDO systemctl enable --now sshd
    echo "[enable] sshd active"; $SUDO systemctl --no-pager --lines=5 status sshd
    echo "From a consumer: ssh terl@digs   |   herdr --remote terl@digs"
    ;;
  disable)
    $SUDO systemctl disable --now sshd
    echo "[disable] sshd stopped and disabled"
    ;;
  status)
    $SUDO systemctl --no-pager --lines=10 status sshd || true
    ;;
  *)
    echo "usage: $0 {enable|disable|status}" >&2
    exit 1
    ;;
esac