#!/usr/bin/env bash
# TWEAK: T7 — keep the herdr "digs" session server up (tagged vault-herdr)
# Why: the digs herdr session hosts the opencode agent (w1:p1) that consumers
# attach to. Without a unit it dies on reboot. HERDR_SESSION=digs selects the
# named session; the server runs headless, and the TUI attaches over SSH.
#
#   ./08_enable_herdr_server.sh           # enable + start (default)
#   ./08_enable_herdr_server.sh disable   # stop + disable
#   ./08_enable_herdr_server.sh status
set -euo pipefail

UNIT="vault-herdr.service"
UNIT_PATH="$HOME/.config/systemd/user/$UNIT"

case "${1:-enable}" in
  enable)
    cat > "$UNIT_PATH" <<'EOF'
[Unit]
Description=Vault herdr 'digs' session server (hosts the opencode agent)
After=graphical-session.target

[Service]
Type=simple
Environment=HERDR_SESSION=digs
Environment=HERDR_STARTUP_CWD=/home/terl/Work
ExecStart=/usr/bin/herdr server
Restart=always
RestartSec=3

[Install]
WantedBy=graphical-session.target
EOF
    systemctl --user daemon-reload
    systemctl --user enable --now "$UNIT"
    echo "[enable] $UNIT active"
    systemctl --user --no-pager --lines=5 status "$UNIT" || true
    ;;
  disable)
    systemctl --user disable --now "$UNIT" 2>/dev/null || true
    echo "[disable] $UNIT stopped and disabled"
    ;;
  status)
    systemctl --user --no-pager --lines=10 status "$UNIT" || true
    ;;
  *)
    echo "usage: $0 {enable|disable|status}" >&2
    exit 1
    ;;
esac