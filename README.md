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

No extras needed — just ssh into digs and read:

1. Talk to digs over SSH; the vault is at `/home/terl/vault/bldr-Omarchy`.
2. Or fetch it yourself (git-first, serve-fallback):
   `./ROLE/consumer/scripts/bootstrap_from_service.sh`
3. Pick your role:
   - consumer → read `ROLE/consumer/`, follow `ROLE/consumer/TWEAKS.md`
   - exit-node → read `ROLE/exit-node/`, run `ROLE/exit-node/scripts/00_vault_up.sh up`
4. Tweak to taste; each `TWEAKS.md` documents what each change does and how to revert.

The `modules/sudo_pipe` signed-request runner is the root shell: `vaultctl
ping pong` round-trips a signed request through a root daemon, letting terl/
agents drive root work (tailscale serve, sshd) without interactive sudo.
