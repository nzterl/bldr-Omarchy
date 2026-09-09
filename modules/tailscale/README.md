# module: tailscale

Reusable, role-agnostic Tailscale pieces. The exit-node/consumer scripts call
into these conventions.

## Common prefs (this node, `digs`)
- `OperatorUser: terl` — tailscale operated as the user; daemon runs as root.
- `RouteAll: true` — accept routes advertised by others.
- `AdvertiseRoutes: [0.0.0.0/0, ::/0]` — advertises full routing (exit node).
- `CorpDNS: true` — MagicDNS on.
- `NetfilterMode: 2` — nftables firewall.

## Which up-flags do what
| flag | role use |
|------|----------|
| `--advertise-exit-node` | exit-node: offer full-route exit |
| `--advertise-routes=0.0.0.0/0,::/0` | exit-node: subnet routes |
| `--ssh` | both: ACL-gated Tailscale SSH |
| `--exit-node digs` | consumer: route via digs |
| `--accept-routes` | consumer: accept advertised subnets |

## Health checks
- `tailscale status` — the header (node, IP, last seen) and health line.
- `tailscale serve status` — what's served.
- `sysctl net.ipv4.ip_forward` — forwarding state (exit-node prerequisite).
