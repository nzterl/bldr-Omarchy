# sudo_pipe — signed-request root command runner

bbx-style root shell for the Vault, hardened with **cryptographic authority**.

## Why

`digs` runs root-needed commands (tailscale serve, sshd, ip forwarding) that
must *not* sit behind an interactive sudo prompt for terl or agents to drive.
The bbx pattern (a root daemon watching a drop dir) gives terl/agents a root
pipe without shell access. Here the pipe is locked down so a public allowlist
grants nothing: only possession of terl's private key authorizes execution.

## Model

```
terl / agents                    digs (root)
-----------                      -------------
vaultctl <id> [opts]  --sign->   vault-exec.sh daemon
  private key iVault              pub key vault.pub
        |                                |
        +-- request object ------------> verify sig
                                           |  stale/replay? -> deny
                                           v
                                    allowlist lookup (public)
                                           |  opts whitelisted?
                                           v
                                    execute fixed argv as root
                                           v
        <------ done/{req}.{out,err,rc} --+
```

- **Request object** (one JSON line in `/run/vault-exec/queue`):
  `{"cmd":"serve-vault","opts":[],"ts":1757500000,"tok":"<ed25519 sig>"}`
- **`tok`** = ed25519 signature over the exact bytes `cmd|opts|ts`, made with
  the user's private key.
- **Allowlist** (`/etc/vault-exec/allowlist`) is *public* — peek at GitHub all
  you like; entries are `id|allowed_opts|fixed_argv` and everything except the
  `%o` slot is root-owned static text. Knowing the list grants nothing.

## Files

| file | role |
|------|------|
| `vault-exec.sh` | root daemon: verify sig, freshness, replay guard, allowlist, opts whitelist, execute |
| `vault-exec.service` | systemd unit (root, `Restart=always`) |
| `allowlist` | public command table: `id|allowed_opts|fixed_argv` |
| `vaultctl` | local client (digs): sign + queue + wait + report |
| `vaultctl-remote` | consumer client: delegate to digs over SSH (key stays on digs) |
| `vault-services.sh` | helper for `vault-serve.service` install/uninstall |
| `vault-serve.service` | boot-persistent `tailscale serve --bg /home/terl/vault` |
| `install.sh` | one-time install (generate keypair, place units, enable daemon) |
| `vault.pub` | the *public* half of the authority key (owned by root, 0600) |

## Request auth properties

- **Signature by terl only** — ed25519, `cmd|opts|ts` signed; nobody else can
  authorize a request unless they hold the private key.
- **Freshness** — `ts` must be within ±5min of the daemon clock.
- **Replay guard** — each signed message can be executed once; copies of a
  request (renamed or re-queued) are rejected via `sha256(msg)` seen-set.
- **No free args** — `opts` are checked token-by-token against the per-command
  whitelist before substitution into the `%o` slot.
- **Least privilege by design** — the daemon never shells out with request
  data; it executes only the root-owned allowlist argv.

## Install

```sh
bash modules/sudo_pipe/install.sh        # prompts for sudo once
vaultctl list                            # see ids
vaultctl serve-vault                     # serve /home/terl/vault over tailnet
vaultctl vault-serve-install             # make vault-serve boot-persistent
vaultctl serve-status                    # tailscale serve status
vaultctl serve-reset                     # stop serving
```

Re-run `install.sh` any time to refresh the installed allowlist/units; it never
replaces the private key.

## From a consumer (laptop) — delegate, don't copy

The Vault is the single truth: the signing key stays on `digs`. A consumer
reaches the actual vault over SSH and runs `vaultctl` there:

```sh
./vaultctl-remote list                # defaults to terl@digs
./vaultctl-remote ping pong           # liveness round-trip through the pipe
./vaultctl-remote serve-vault         # is the vault served? serve it
./vaultctl-remote sshd status
VAULTCTL_HOST=terl@digs ./vaultctl-remote list
```

Requires the laptop's SSH key in digs' `authorized_keys` (host sshd :22) or a
Tailscale SSH ACL approval — never the vault-exec private key. The key
material for signing never leaves digs.

## Credentials

- allowlist + vault.pub are **public** (authority = private key possession):
  `/etc/vault-exec/` is world-readable, so `vaultctl list` works for any tailnet user
- user private key: `~/.config/vault-exec/id_vault` (0600, never leaves this box)
- root public key:  `/etc/vault-exec/vault.pub` (0644, safe to share)
- queue/done:       `/run/vault-exec/queue` `/run/vault-exec/done` (1777, tmpfs)
- seen-set (replay):`/run/vault-exec/seen/`

Generate your own pair if you distrust these creds:

```sh
openssl genpkey -algorithm ed25519 -out id_vault
openssl pkey -in id_vault -pubout -out vault.pub
```