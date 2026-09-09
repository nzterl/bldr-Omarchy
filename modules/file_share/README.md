# module: file_share

How the `~/current` workspace is shared to the tailnet. Backend choice here is
**Tailscale-native** — no samba/syncthing installed.

## Mechanisms
1. **`tailscale serve`** — browse `~/current` over a tailnet URL/port.
   Exit-node role runs `..scripts/02_shares.sh up`.
2. **Tailscale SSH** (`tailscale up --ssh`) — `ssh digs@digs` / `scp` /
   `sshfs` ACL-gated file access, no `sshd` config.

## Share root
`~/current` → symlink → `/home/terl/dev/current`.

Anything placed in `/home/terl/dev/current` (e.g. the `bldr-Omarchy` repo)
appears automatically in the share.

## Future alternates (not installed, only if needed)
- samba (SMB) for Windows-native browsing.
- syncthing for continuous notes sync.
