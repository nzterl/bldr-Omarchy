# ROLE: exit-node & workshop file server (`digs`)

This machine is Tailscale node **`digs`** (100.117.113.81). Its job is to:

1. Offer the **static Vault** (`/home/terl/vault`) to the tailnet —
   by **`tailscale serve`** (browse over a tailnet URL) and **`tailscale up --ssh`**
   (SSH/scp into the box), with **`sshd` on :22** for herdr/plain ssh.
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

### T4 — Serve the static Vault
- **What**: `tailscale serve --bg /home/terl/vault`.
- **Why**: the laptop (or anything on the tailnet) browses the Vault — the
  single source of truth for digs ops — over a tailnet URL
  (`https://digs.tail82a0ed.ts.net/`). The `--bg` flag persists the config;
  a foreground `tailscale serve` dies with its launching shell.
- **How**: `02_shares.sh up` (or via the sudo pipe: `vaultctl serve-vault`).
- **Revert**: `vaultctl serve-reset` / `tailscale serve reset`.

### T7 — sudo_pipe root runner (bbx pattern, ed25519 authority)
- **What**: `vault-exec.service` watches a drop queue for signed request
  objects; `vaultctl` signs them with the user private key and the daemon
  verifies with the root-held public key, then runs an allowlisted fixed argv.
- **Why**: terl/agents drive root work (serve, sshd, ip-forward) through one
  safe pipe instead of interactive sudo; the allowlist is public but grants
  nothing without the private key.
- **How**: `bash modules/sudo_pipe/install.sh` (one-time, idempotent).
- **Revert**: `systemctl disable --now vault-exec.service`, delete
  `/etc/vault-exec` + `/usr/local/sbin/vault-exec*`.

### T6 — sshd on port 22 (for ssh/scp/herdr --remote from the laptop)
- **What**: `systemctl enable --now sshd` (openssh already installed).
- **Why**: Tailscale SSH works at the tailnet layer, but herdr `--remote` and
  plain `ssh`/`scp`/`sshfs` need a port-22 listener. Enabling sshd gives the
  laptop a real `ssh terl@digs` + `herdr --remote terl@digs` path.
- **How**: `sudo ./scripts/06_enable_sshd.sh`.
- **Revert**: `sudo systemctl disable --now sshd`.

### T5 — `bldr-Omarchy` in the Vault
- **What**: this repo lives at `/home/terl/vault/bldr-Omarchy`, the Vault root.
- **Why**: it is served automatically through the Vault serve, so tailnet
  members can browse/replay it; mirrored on GitHub (`nzterl/bldr-Omarchy`),
  the portable truth for non-tailnet fetch.
- **Revert**: move/remove the directory (affects the serve listing).

## Order to apply on a fresh build
1. `01_tailscale_exit_node.sh`  (T1, T2, T3)
2. `06_enable_sshd.sh`          (T6) — needed before herdr remote/ssh
3. `modules/sudo_pipe/install.sh` (T7) — root pipe for the rest
4. `02_shares.sh`               (T4)
5. `08_enable_herdr_server.sh`  — vault-herdr user unit (digs session)
6. `03_health.sh`               (observe)

Note: `00_vault_up.sh up` runs all of the above idempotently.
