#!/usr/bin/env bash
# ROLE: consumer — pop into the digs herdr session from another machine
# (laptop etc.) and land on the persistent workspace where agent sessions live.
#
# Usage (on the laptop):
#   ./herdr_attach.sh digs          # ssh + herdr remote-attach to the digs session
#   ./herdr_attach.sh digs --session myname
#   ./herdr_attach.sh raw           # just ssh to digs, no herdr wrapper
set -euo pipefail

TARGET="${1:-digs}"
[ "$TARGET" = "raw" ] && { ssh "$TARGET" "@bash -lc 'exec bash -l'"; exit $?; }
shift || true

# herdr --remote lands on the remote herdr server (the persistent digs session).
# Pass through any extra herdr args (e.g. --session <name>).
echo "-> herdr --remote $TARGET $*"
herdr --remote "$TARGET" "$@" || {
  echo
  echo "herdr remote attach failed. Fallback — plain ssh to $TARGET then run:"
  echo "  herdr session attach digs   # or:  tmux attach -t digs"
  echo "  opencode                    # resume the agent conversation"
  echo
  echo "Direct:");
  ssh "$TARGET" "-t bash -lc 'herdr session attach digs || tmux attach -t digs; exec \${SHELL}'"
}