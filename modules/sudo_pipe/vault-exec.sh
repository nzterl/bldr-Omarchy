#!/usr/bin/env bash
# vault-exec: signed-request root command runner (bbx sudo-pipe, ed25519).
# A root systemd daemon watches a drop dir for request objects:
#   {"cmd":"serve-up","opts":[],"ts":1757500000,"tok":"<base64 ed25519 sig>"}
# Signature is over the exact bytes "cmd|opts|ts", made with the terl-held
# private key; this daemon verifies with /etc/vault-exec/vault.pub.
# On success it resolves cmd via the public allowlist, validates opts against
# the per-command spec, executes as root, and writes done/{req}.{out,err,rc}.
#
# Public pieces (allowlist = command definitions, peekable) grant nothing;
# authority = possession of the private key that signs tok.
set -euo pipefail

Q="${VAULT_EXEC_QUEUE:-/run/vault-exec/queue}"
D="${VAULT_EXEC_DONE:-/run/vault-exec/done}"
PUB="${VAULT_EXEC_PUB:-/etc/vault-exec/vault.pub}"
ALLOW="${VAULT_EXEC_ALLOW:-/etc/vault-exec/allowlist}"
FRESH="${VAULT_EXEC_FRESH:-300}"
WORK="${VAULT_EXEC_WORK:-/run/vault-exec/work}"
SEEN="${VAULT_EXEC_SEEN:-/run/vault-exec/seen}"
FIFO="${VAULT_EXEC_FIFO:-/run/vault-exec/queue.wake}"
mkdir -p "$Q" "$D" "$WORK" "$SEEN"
chmod 1777 "$Q" "$D"
if [ -p "$FIFO" ]; then rm -f "$FIFO"; fi
mkfifo "$FIFO" && chmod 0666 "$FIFO"
exec 3<> "$FIFO"              # keep it open both ways; no SIGPIPE, no reader race

[ -r "$PUB" ]   || { echo "fatal: no verify key $PUB" >&2;  exit 1; }
[ -r "$ALLOW" ] || { echo "fatal: no allowlist $ALLOW" >&2; exit 1; }

log() { printf '[%(%F %T)T] %s\n' -1 "$*"; }

deny() { printf 'denied: %s\n' "$2" > "$D/$1.out"; printf '1' > "$D/$1.rc"; rm -f -- "$Q/$1"; return 0; }

# clean stale results (tmpfs), never pending requests
rm -f "$D"/* "$WORK"/*

while true; do
  # block until a client wakes us (each request write also touches the FIFO);
  # -t 1 is only a fallback tick in case a wake byte was missed.
  IFS= read -r -t 1 -u 3 _ || true

  for req in "$Q"/*; do
    [ -f "$req" ] || continue
    base=$(basename "$req")

    # --- parse request JSON + extract raw signature ----------------------
    if ! python3 - "$req" "$WORK/sig.raw" "$WORK/meta" <<'PYEOF'
import json, sys, base64
try:
    d = json.load(open(sys.argv[1]))
    tok = base64.b64decode(str(d.get("tok") or ""))
    with open(sys.argv[2], "wb") as f:
        f.write(tok)
    cmd  = str(d.get("cmd") or "")
    opts = " ".join(str(o) for o in (d.get("opts") or []))
    ts   = str(d.get("ts") or "")
    with open(sys.argv[3], "w") as f:
        f.write(f"{cmd}|{opts}|{ts}\n")
except Exception:
    sys.exit(1)
PYEOF
    then
      log "DENIED unparseable $base"
      deny "$base" bad-request
      continue
    fi
    IFS='|' read -r cmd opts ts < "$WORK/meta"

    # --- verify signature over exact "cmd|opts|ts" bytes ------------------
    printf '%s|%s|%s' "$cmd" "$opts" "$ts" > "$WORK/msg.raw"
    if ! openssl pkeyutl -verify -pubin -inkey "$PUB" -rawin \
                      -in "$WORK/msg.raw" -sigfile "$WORK/sig.raw" >/dev/null 2>&1; then
      log "DENIED bad signature $base ($cmd)"
      deny "$base" bad-signature
      continue
    fi
    # replay guard: keyed on the signed message bytes, so a copied request
    # file (new filename, same signature) is still rejected.
    digest=$(sha256sum "$WORK/msg.raw" | cut -d' ' -f1)
    if [ -e "$SEEN/$digest" ]; then
      log "DENIED replay $base"
      deny "$base" replay
      continue
    fi
    : > "$SEEN/$digest"

    # --- freshness (anti-replay of copied requests) -------------------------
    now=$(date +%s)
    if [ "$ts" -lt $((now - FRESH)) ] || [ "$ts" -gt $((now + FRESH)) ]; then
      log "DENIED stale ts $base ts=$ts now=$now"
      deny "$base" stale-timestamp
      continue
    fi

    # --- resolve command in allowlist -----------------------------------------
    line=$(awk -F'|' -v c="$cmd" '$1==c {print; f=1; exit} END {exit !f}' "$ALLOW") || { line=""; }
    if [ -z "$line" ]; then
      log "DENIED unknown cmd $base ($cmd)"
      deny "$base" unknown-command
      continue
    fi
    spec=$(printf '%s' "$line" | cut -d'|' -f2)
    argv=$(printf '%s' "$line" | cut -d'|' -f3-)

    # --- validate opts against the per-command spec ---------------------------
    allowed=1
    if [[ "$argv" == "-" ]]; then argv=""; fi
    if [ -n "$opts" ]; then
      if [ "$spec" = "-" ]; then allowed=0; fi
      for o in $opts; do
        if [ "$allowed" -eq 0 ] || ! [[ ",$spec," == *",$o,"* ]]; then allowed=0; break; fi
      done
      [ "$allowed" -eq 1 ] || { log "DENIED bad opts $base ($cmd: $opts)"; deny "$base" bad-options; continue; }
    fi
    # substitute the validated opts into the %o slot (or drop it)
    if [[ "$argv" == *%o* ]]; then
      argv="${argv//%o/$opts}"
    else
      argv="$argv $opts"
    fi

    # --- execute (argv fixed by root allowlist; opts whitelisted) -------------
    log "RUN $base ($cmd${opts:+ opts: $opts})"
    # shellcheck disable=SC2086  # argv from root-owned allowlist only
    set -- $argv
    if "$@" > "$D/$base.out" 2> "$D/$base.err" < /dev/null; then rc=0
    else rc=$?
    fi
    printf '%s' "$rc" > "$D/$base.rc"
    rm -f "$req"
    log "DONE $base rc=$rc"
  done
  sleep 1
done