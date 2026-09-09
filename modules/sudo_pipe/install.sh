#!/usr/bin/env bash
# install.sh — one-time vault-exec (sudo_pipe) installation.
# Run as the normal user (NOT via sudo directly):
#     bash modules/sudo_pipe/install.sh
# Prompts for sudo once for the root-side install. Safe to re-run.
set -euo pipefail

[ "$(id -u)" -eq 0 ] && {
  echo "Run this as your normal user, not root (it calls sudo internally)." >&2
  echo "  bash modules/sudo_pipe/install.sh" >&2
  exit 2
}

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="$(getent passwd "$USER" | cut -d: -f6)"
VAULT_DIR="/etc/vault-exec"
KEY_DIR="$USER_HOME/.config/vault-exec"
KEY="$KEY_DIR/id_vault"
BIN="/usr/local/sbin"
UNITS="/usr/local/share/vault-exec/units"

echo "== vault-exec install ($USER) =="

# --- keypair: generate only on first install; keep existing secrets ---------
if [ ! -f "$KEY" ]; then
  echo "-- generating dedicated ed25519 keypair"
  install -d -m 0700 "$KEY_DIR"
  umask 077
  openssl genpkey -algorithm ed25519 -out "$KEY"
  chmod 0600 "$KEY"
else
  echo "-- keypair already present, reusing"
fi
openssl pkey -in "$KEY" -pubout -out "$KEY_DIR/vault.pub"
chmod 0644 "$KEY_DIR/vault.pub"

# --- root-side install (sudo) ------------------------------------------------
echo "-- installing root-side (sudo)"
sudo install -d -m 0700 "$VAULT_DIR"
sudo install -m 0644 "$KEY_DIR/vault.pub" "$VAULT_DIR/vault.pub"
sudo install -m 0644 "$SELF/allowlist" "$VAULT_DIR/allowlist"
sudo install -m 0755 "$SELF/vault-exec.sh" "$BIN/vault-exec.sh"
sudo install -m 0755 "$SELF/vault-services.sh" "$BIN/vault-services.sh"
sudo install -d -m 0755 "$UNITS"
sudo install -m 0644 "$SELF/vault-serve.service" "$UNITS/vault-serve.service"
sudo install -m 0644 "$SELF/vault-exec.service" /etc/systemd/system/vault-exec.service

echo "-- installing client"
install -d -m 0755 "$USER_HOME/.local/bin" 2>/dev/null || true
install -m 0755 "$SELF/vaultctl" "$USER_HOME/.local/bin/vaultctl"

echo "-- enabling vault-exec.service"
sudo systemctl daemon-reload
sudo systemctl enable --now vault-exec.service
sudo systemctl is-active vault-exec.service || {
  echo "service failed to start:"; sudo journalctl -u vault-exec --no-pager -n 20 | cat; exit 1
}

echo
echo "== installed =="
echo "  public key:  $VAULT_DIR/vault.pub"
echo "  private key: $KEY (keep it; only it can authorize root commands)"
echo "  try:  vaultctl list"
echo "  run:  vaultctl serve-vault        # serve /home/terl/vault over tailnet HTTPS"
echo "  run:  vaultctl vault-serve-install # make it boot-persistent"