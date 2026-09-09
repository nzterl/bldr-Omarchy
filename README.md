# bldr-Omarchy

Modular, role-based, replayable recipes for building and operating Omarchy
machines as Tailscale nodes — a lightweight Markdown + idempotent-script
counterpart to the `bldr-*` / BuildIt family, without the Ruby gem dependency.

The canonical machine is this box: a Tailscale node named **`digs`**
(100.117.113.81) that acts as a **workshop file service** and **exit node** on
the home tailnet, serving the `~/current` workspace.

This repo lives at `~/dev/current/bldr-Omarchy` — i.e. inside the `~/current`
share root — so any tailnet member can browse and replay it.

## Layout

```
ROLE/
  exit-node/   recipes to build/operate a machine that serves + offers routing
  consumer/    recipes to join the tailnet and use the workshop service
modules/       reusable, role-agnostic pieces (tailscale, file_share, acl, ai_notes)
buildit/       reserved slot for a future BuildIt ruby crop, if it earns its place
```

## Replay on another machine (e.g. laptop)

1. Browse/`git clone` `bldr-Omarchy` from the workshop share.
2. Pick your role:
   - consumer → read `ROLE/consumer/`, run `ROLE/consumer/scripts/tailscale_up_client.sh`
   - exit-node → read `ROLE/exit-node/`, run its scripts in order.
3. Tweak to taste; each `TWEAKS.md` documents what each change does and how to revert.
