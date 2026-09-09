#!/usr/bin/env bash
# vault-services.sh — root-side helper backing vault-tagged service installs.
# Installed to /usr/local/sbin by install.sh. argv is fixed root-owned; nothing
# here takes request input.
set -euo pipefail

UNIT_SRC="/usr/local/share/vault-exec/units"

case "${1:-}" in
  install)
    install -m 0644 "$UNIT_SRC/vault-serve.service" /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable --now vault-serve.service
    echo "vault-serve.service installed, enabled, started"
    ;;
  uninstall)
    systemctl disable --now vault-serve.service 2>/dev/null || true
    rm -f /etc/systemd/system/vault-serve.service
    systemctl daemon-reload
    echo "vault-serve.service removed"
    ;;
  *)
    echo "usage: $0 {install|uninstall}" >&2
    exit 2
    ;;
esac