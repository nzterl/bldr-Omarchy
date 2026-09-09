# bldr-Omarchy

Modular, role-based, replayable recipes for building and operating Omarchy
machines as Tailscale nodes — a lightweight Markdown + idempotent-script
counterpart to the `bldr-*` / BuildIt family, without the Ruby gem dependency.

The canonical machine is this box: a Tailscale node named **`digs`**
(100.117.113.81) that acts as a **vault file service** and **exit node** on
the home tailnet, serving the **static Vault** and the Current dev share.

This repo lives at `~/vault/bldr-Omarchy` — inside the **static Vault**,
the single source of truth for digs home-ops. It is served over the tailnet
(`https://digs.tail82a0ed.ts.net/bldr-Omarchy/`) and mirrored on
GitHub (`nzterl/bldr-Omarchy`), so any tailnet member — or anyone with
GitHub access — can browse and replay it.

## Layout

```
ROLE/
  exit-node/   recipes to build/operate a machine that serves + offers routing
  consumer/    recipes to join the tailnet and use the workshop service
modules/       reusable, role-agnostic pieces (sudo_pipe, herdr, tailscale, file_share, acl)
buildit/       reserved slot for a future BuildIt ruby crop, if it earns its place
```

## Replay on another machine (e.g. laptop)

No extras needed — `ROLE/consumer/README.md` is the zero-to-session walkthrough
(git-clone → tailnet → ssh → herdr attach lands back in the digs agent pane).
Quick start:

1. Fetch: `git clone git@github.com:nzterl/bldr-Omarchy.git` (public, no tailnet).
2. Join + reach digs (consumer role): `ROLE/consumer/scripts/tailscale_up_client.sh up`.
3. `ssh terl@digs` (sshd :22 with your key, or Tailscale SSH ACL).
4. Land in the agent session: `ROLE/consumer/scripts/herdr_attach.sh digs`.

The `modules/sudo_pipe` signed-request runner is the root shell: `vaultctl
ping pong` round-trips a signed request through a root daemon, letting terl/
agents drive root work (tailscale serve, sshd) without interactive sudo.
