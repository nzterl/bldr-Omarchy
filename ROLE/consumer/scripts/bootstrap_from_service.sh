#!/usr/bin/env bash
# ROLE: consumer — bootstrap bldr-Omarchy straight off the digs workshop service
# and replay your role. This is the "run from service" path: the recipes live
# on the service, and you pull them from it.
#
# Usage:
#   ./bootstrap_from_service.sh             # fetch repo to ./bldr-Omarchy
#   ./bootstrap_from_service.sh consumer    # fetch + run consumer scripts
#   ./bootstrap_from_service.sh exit-node   # fetch + run exit-node scripts
#
# Base URL of the workshop service (the digs serve endpoint).
SERVE_URL="${SERVE_URL:-https://digs.tail82a0ed.ts.net}"
REPO="bldr-Omarchy"
DEST="${1:-$REPO}"; [[ $SERVE_URL == "$DEST" ]] && DEST="$REPO"
role="${2:-}"

# Serve is a static listing, so use wget --recursive (or curl each file).
if command -v wget >/dev/null 2>&1; then
  wget -q --mirror -nH --cut-dirs=0 -e robots=off -r \
    "$SERVE_URL/$REPO/" -P "$DEST" 2>/dev/null \
    || { echo "wget failed; falling back to curl" >&2; }
fi

# Fallback: recursively curl the guessed file set (kept simple: README + scripts).
if [[ ! -f "$DEST/README.md" ]]; then
  mkdir -p "$DEST"
  for f in README.md \
           ROLE/consumer/TWEAKS.md \
           ROLE/consumer/scripts/tailscale_up_client.sh \
           ROLE/exit-node/TWEAKS.md \
           ROLE/exit-node/scripts/01_tailscale_exit_node.sh \
           ROLE/exit-node/scripts/02_shares.sh \
           ROLE/exit-node/scripts/07_enable_ip_forwarding.sh; do
    mkdir -p "$DEST/$(dirname "$f")"
    curl -sS -o "$DEST/$f" "$SERVE_URL/$REPO/$f"
  done
fi

echo "fetched to: $DEST"
if [[ -n "$role" && -f "$DEST/ROLE/$role/TWEAKS.md" ]]; then
  echo "now run:  $DEST/ROLE/$role/scripts/*.sh up"
  echo "review first:  $DEST/ROLE/$role/TWEAKS.md"
fi