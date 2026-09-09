# ROLE: consumer (laptop / other tailnet clients)

A consumer joins the tailnet, can browse the `~/current` workshop over
**`tailscale serve`**, and can `ssh`/`scp`/`sshfs` into **`digs`** over
Tailscale SSH. No exit-node advertising here — a consumer may *use* the exit
node instead.

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

### C3 — Browse / fetch the workshop
- **What**: open the `tailscale serve` URL for `digs` (browser), or
  `ssh digs@digs` / `scp -r digs@digs:current/bldr-Omarchy .` / `sshfs`.
- **Why**: "cruise" the `~/current` share and pull `bldr-Omarchy`.
- **Revert**: none (read ops).

## Order
1. `scripts/tailscale_up_client.sh up`
2. optionally `up --exit-node digs`
3. browse / pull `bldr-Omarchy` from the `digs` serve URL or over SSH.
