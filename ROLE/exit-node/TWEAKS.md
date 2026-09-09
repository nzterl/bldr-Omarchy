# ROLE: exit-node & workshop file server (`digs`)

This machine is Tailscale node **`digs`** (100.117.113.81). Its job is to:

1. Offer the `~/current` workspace (`/home/terl/dev/current`) to the tailnet —
   by **`tailscale serve`** (browse over a port/URL) and **`tailscale up --ssh`**
   (SSH/scp into the box).
2. Function as an **exit node / subnet router** so a consumer that selects it
   routes 0.0.0.0/0 + ::/0 through this box (IP forwarding).

Each tweak is logged here: what, why, how, and how to revert.

## Tweak log

### T1 — Enable IP forwarding (exit-node prerequisite)
- **What**: `net.ipv4.ip_forward=1` (and ipv6) at runtime + persisted in
  `/etc/sysctl.d/99-tailscale.conf`.
- **Why**: Tailscale advertises routes but won't route until the kernel
  forwards packets. `tailscale status` flags this when off.
- **How**: `sysctl -w net.ipv4.ip_forward=1` (+ write sysctl.d file).
- **Revert**: remove `/etc/sysctl.d/99-tailscale.conf` and set
  `sysctl -w net.ipv4.ip_forward=0`.

### T2 — Advertise as exit node / subnet router
- **What**: `tailscale up --advertise-exit-node --advertise-routes=0.0.0.0/0,::/0`.
- **Why**: makes `digs` selectable as an exit node on the tailnet; consumers
  pick it to route all their traffic. (`RouteAll` already true; was advertising
  routes but `Advertise:false` → the health warning.)
- **How**: run the script `01_tailscale_exit_node.sh`; approve in the admin
  console.
- **Revert**: `tailscale up` without the advertise flags.

### T3 — Tailscale SSH (ACL-gated file access)
- **What**: `tailscale up --ssh`.
- **Why**: lets a consumer `ssh digs@digs` / `scp` / `sshfs` into the box
  without configuring `sshd`; access is ACL-controlled.
- **How**: flag in `01_tailscale_exit_node.sh`.
- **Revert**: `tailscale up` without `--ssh`.

### T4 — Serve the `~/current` workspace
- **What**: `tailscale serve /home/terl/dev/current`.
- **Why**: the laptop (or anything on the tailnet) browses the `~/current`
  tree over a tailnet URL/port — the workshop file service.
- **How**: `02_shares.sh`.
- **Revert**: `tailscale serve reset` (or `tailscale serve` the path away).

### T5 — `bldr-Omarchy` placed in the share
- **What**: this repo lives at `~/dev/current/bldr-Omarchy`.
- **Why**: it is served automatically through `~/current` (→ the >serve and
  SSH), so tailnet members can pull/replay it.
- **Revert**: move/remove the directory (affects the share listing).

## Order to apply on a fresh build
1. `01_tailscale_exit_node.sh`  (T1, T2, T3)
2. `02_shares.sh`               (T4)
3. clone/place `bldr-Omarchy` in the share (T5)
4. `03_health.sh`               (observe)
