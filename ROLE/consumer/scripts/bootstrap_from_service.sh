#!/usr/bin/env bash
# ROLE: consumer — bootstrap bldr-Omarchy and replay your role.
# Dual path: git-first (the portable truth), serve-fallback (the digs static
# listing) for machines that can reach the tailnet but not GitHub yet.
#
# Usage:
#   ./bootstrap_from_service.sh             # fetch repo to ./bldr-Omarchy
#   ./bootstrap_from_service.sh consumer    # fetch + print consumer run steps
#   ./bootstrap_from_service.sh exit-node   # fetch + print exit-node run steps
#
# The vault serve endpoint + git remote (the seam lives in vault/env.sh).
SERVE_URL="${SERVE_URL:-https://digs.tail82a0ed.ts.net}"
REMOTE="${REMOTE:-git@github.com:nzterl/bldr-Omarchy.git}"
REPO="bldr-Omarchy"
DEST="${1:-$REPO}"; [[ $SERVE_URL == "$DEST" ]] && DEST="$REPO"
role="${2:-}"

# --- git-first: clone the portable truth -------------------------------------
if command -v git >/dev/null 2>&1; then
  if [[ -d "$DEST/.git" ]]; then
    echo "present: $DEST — pulling"
    git -C "$DEST" pull --ff-only 2>/dev/null || true
  elif git clone --quiet "$REMOTE" "$DEST" 2>/dev/null; then
    echo "cloned from git: $DEST"
  else
    echo "git clone failed ($REMOTE) — falling back to the digs serve" >&2
  fi
fi

# --- serve fallback: static listing (needs tailnet, no git/ssh) --------------
if [[ ! -f "$DEST/README.md" ]]; then
  if command -v wget >/dev/null 2>&1; then
    wget -q --mirror -nH --cut-dirs=0 -e robots=off -r \
      "$SERVE_URL/$REPO/" -P "$DEST" 2>/dev/null \
      || { echo "wget failed; falling back to curl" >&2; }
  fi
  if [[ ! -f "$DEST/README.md" ]]; then
    mkdir -p "$DEST"
    for f in README.md \
             ROLE/consumer/TWEAKS.md \
             ROLE/consumer/scripts/tailscale_up_client.sh \
             ROLE/consumer/scripts/herdr_attach.sh \
             ROLE/exit-node/TWEAKS.md \
             ROLE/exit-node/scripts/00_vault_up.sh \
             ROLE/exit-node/scripts/01_tailscale_exit_node.sh \
             ROLE/exit-node/scripts/02_shares.sh \
             ROLE/exit-node/scripts/06_enable_sshd.sh \
             ROLE/exit-node/scripts/07_enable_ip_forwarding.sh \
             ROLE/exit-node/scripts/08_enable_herdr_server.sh \
             modules/sudo_pipe/install.sh \
             modules/sudo_pipe/README.md; do
      mkdir -p "$DEST/$(dirname "$f")"
      curl -sS -o "$DEST/$f" "$SERVE_URL/$REPO/$f"
    done
  fi
fi

echo "fetched to: $DEST"
if [[ -n "$role" && -f "$DEST/ROLE/$role/TWEAKS.md" ]]; then
  echo "now run:  $DEST/ROLE/$role/scripts/*.sh up"
  echo "review first:  $DEST/ROLE/$role/TWEAKS.md"
fi