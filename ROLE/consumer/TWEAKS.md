# ROLE: consumer (laptop / other tailnet clients)

A consumer joins the tailnet, can browse the **Vault** (`/home/terl/vault`)
over **`tailscale serve`**, and can `ssh`/`scp`/`sshfs` into **`digs`** over
Tailscale SSH (or host SSH on :22). No exit-node advertising here — a consumer
may *use* the exit node instead.

## Tweaks (with revert)

### C1 — Join the tailnet as a plain node
- **What**: `tailscale up` (client default; optionally `--ssh` for the reverse).
- **Why**: makes the laptop a tailnet member that can reach `digs`.
- **Revert**: `tailscale down` / `tailscale logout`.

### C2 — (Optional) use `digs` as the exit node
- **What**: `tailscale up --exit-node digs --exit-node-allow-lan-access`.
- **Why**: route the laptop's traffic through `digs` (the "see how it functions"
  use case).
- **Revert**: `tailscale up` without `--exit-node`.

### C3 — Browse / fetch the Vault
- **What**: open the `tailscale serve` URL for `digs`
  (`https://digs.tail82a0ed.ts.net/`) in a browser, or
  `ssh digs@digs` and read `/home/terl/vault/bldr-Omarchy`.
- **Why**: browse the static Vault — the single source of truth for digs ops —
  and pull `bldr-Omarchy`. Also mirrored on GitHub (`nzterl/bldr-Omarchy`)
  for fetch without the tailnet: `git clone git@github.com:nzterl/bldr-Omarchy.git`.
- **Revert**: none (read ops).

### C4 — Pop open the digs agent session via herdr
- **What**: `herdr --remote digs` (or the helper
  `scripts/herdr_attach.sh digs`). Omarchy already binds `SUPER CTRL + RETURN`
  -> Herdr and `SUPER ALT + RETURN` -> tmux.
- **Why**: `digs` runs a persistent herdr session hosting the opencode agent
  conversation; remote-attach lands you back in it from the laptop. When you
  attach, the `~/Work` pane already runs `opencode -s ses_f801b903...`
  (the workshop build conversation) — just keep typing there.
- **How**: see `modules/herdr/README.md`. Requires tailscale SSH from the
  laptop to `digs`.
- **Revert**: none (it's just an attach).

## Order
1. `scripts/tailscale_up_client.sh up`
2. optionally `up --exit-node digs`
3. browse / pull `bldr-Omarchy` — `scripts/bootstrap_from_service.sh` (git-first, serve-fallback)
4. `scripts/herdr_attach.sh digs` to resume the digs agent session.
