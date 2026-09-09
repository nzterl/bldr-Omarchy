# ROLE: consumer — from zero to this session

The path from a blank Omarchy laptop to sitting in the digs agent session.
`bldr-Omarchy` is **public on GitHub**, so step 1 works with no tailnet at all.

## 1. Fetch the repo (git-first, public — no tailnet needed)

```sh
git clone git@github.com:nzterl/bldr-Omarchy.git
cd bldr-Omarchy
```

No git/SSH yet? Use the GitHub web UI, or the static serve once on the tailnet:
`https://digs.tail82a0ed.ts.net/bldr-Omarchy/`.

## 2. Join the tailnet (reach digs)

```sh
sudo tailscale up           # consumer role: plain node
tailscale status            # see digs + nomad
```

Not the Omarchy laptop (no Tailscale shipped)? Get it first:
`curl -fsSL https://tailscale.com/install.sh | sh` — then `tailscale up`.

## 3. SSH into digs

Two paths (both live on digs now):

- **host sshd :22** — needs your laptop pubkey in digs `~/.ssh/authorized_keys`
  (one-time; ask terl to add it, or `ssh-copy-id terl@digs` once allowed).
- **Tailscale SSH** — `tailscale up --ssh` on the laptop, ACL approval in the
  admin console. No keys to manage.

```sh
ssh terl@digs
```

## 4. Drive digs root work from the laptop (optional)

Delegate, don't copy — the signing key stays on digs:

```sh
./modules/sudo_pipe/vaultctl-remote ping pong      # -> pong
./modules/sudo_pipe/vaultctl-remote serve-status   # vault URL + paths
./modules/sudo_pipe/vaultctl-remote serve-vault    # ensure the vault is served
```

## 5. Attach to the digs agent session (this conversation)

digs runs a persistent herdr session hosting the opencode agent in pane `w1:p1`.
Land in it from the laptop:

```sh
# the whole attach (ssh + herdr remote-attach)
./ROLE/consumer/scripts/herdr_attach.sh digs

# ...or the explicit parts:
herdr --remote terl@digs
# inside that herdr TUI, the digs session pane w1:p1 is already running:
#   cd /home/terl/Work && opencode -s ses_f801b903cffe8FIAIvmtDEMcCG
```

Once herdr lands you in the digs session, the agent pane `w1:p1` resumes the
same opencode conversation — just keep typing.

## Order recap (all in one)

```sh
git clone git@github.com:nzterl/bldr-Omarchy.git && cd bldr-Omarchy
./ROLE/consumer/scripts/tailscale_up_client.sh up
ssh terl@digs                                  # needs key or tailscale ssh ACL
./ROLE/consumer/scripts/herdr_attach.sh digs   # lands in w1:p1 agent pane
```

## If the laptop is truly zero (no Omarchy, no keys)

1. Install Tailscale: `curl -fsSL https://tailscale.com/install.sh | sh`
   then `tailscale up` and approve your node in the tailnet.
2. Install herdr (Omarchy ships it; elsewhere: `herdr` via its install script —
   it's what `herdr --remote` needs).
3. Do step 4's SSH option and have terl add your laptop pubkey to digs.
4. `herdr_attach.sh digs` from the repo.