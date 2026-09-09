# module: file_share

How the **static Vault** (the single source of truth for digs ops) is shared
to the tailnet. Tailscale-native — no samba/syncthing installed.

## Mechanisms
1. **`tailscale serve --bg`** — browse the Vault over a tailnet URL:
   `https://digs.tail82a0ed.ts.net/` serves `/home/terl/vault` (root).
   Driven by `..scripts/02_shares.sh up`, or the signed root pipe:
   `vaultctl serve-vault` / `vaultctl serve-current` (see `modules/sudo_pipe`).
2. **Tailscale SSH** (`tailscale up --ssh`) + host `sshd` on :22 — `ssh digs@digs`
   / `scp` / `sshfs` ACL-gated file access.

## Serve roots
- **Vault**   `/home/terl/vault`        → serve root (URL `/`)
- **Current** `/home/terl/dev/current`  → dev workspace share (`serve-current`)

`/home/terl/dev/current` holds the moving dev tree (symlinks to `shiny`,
`ya_crud`, ...); the Vault is the static truth. Any file dropped in
`/home/terl/vault` appears at the serve root automatically.

## Future alternates (not installed, only if needed)
- samba (SMB) for Windows-native browsing.
- syncthing for continuous notes sync.