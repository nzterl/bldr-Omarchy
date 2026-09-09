#!/usr/bin/env bash
# TWEAK: T6 — run a real sshd on digs
# Why: herdr --remote (from the laptop) shells out to ssh (port 22); Tailscale
# SSH works at the tailnet layer but doesn't give herdr/tmux+ssh a 22 listener.
# Enabling openssh's sshd makes ssh/scp/herdr --remote reach digs on the tailnet.
#
#   sudo ./06_enable_sshd.sh
set -euo pipefail

systemctl enable --now sshd
systemctl --no-pager --lines=5 status sshd

echo
echo "sshd now listening on :22 (tailnet). From a consumer:"
echo "  ssh terl@digs"
echo "  herdr --remote terl@digs        # or: ./scripts/herdr_attach.sh terl@digs"