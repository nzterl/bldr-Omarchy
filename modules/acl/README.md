# module: acl — tailnet access policy

Tailscale ACLs are managed in the admin console (they cannot be fetched with
the local CLI without an API key), but they *can* be pushed via the
**Tailscale API** with a scoped API key, and versioned here. This directory
forks/versions the tailnet policy so `bldr-Omarchy` captures it as a tweak.

## Current policy — `tailnet.acl.json`

```
{
  "acls": [ { accept member -> digs:22 } ],     # host sshd (:22) reachable
  "ssh":  [ { accept member -> autogroup:self,
              users: nonroot + root } ]          # Tailscale SSH (zero-config)
}
```

This is the **consumer zero-config** part: any tailnet member can `ssh digs`
(or `tailscale ssh digs`) without managing pubkeys — host keys come from the
coordination server. The sshd :22 rule is the fallback for non-Tailscale-SSH
clients (needs a pubkey in `authorized_keys`).

## How to push it
1. Admin console → Access Controls → paste `tailnet.acl.json` (merge into your
   existing policy; the `ssh` block is the new bit for Tailscale SSH).
2. Or API: create a read-write API key (admin console → Settings → Keys),
   then:
   ```sh
   curl -X POST https://api.tailscale.com/api/v2/tailnet/nzterl.github/acl \
     -H "Authorization: Bearer $TS_API_KEY" \
     -H "Content-Type: application/json" --data-binary @tailnet.acl.json
   ```
3. `tailscale ssh digs` from any member node — no pubkey needed.

## Notes
- `autogroup:self` = the dst node accepts members; `autogroup:nonroot` lets
  non-root accounts in. Remove `root` if you want root shell only via other
  means.
- Re-approve any node that appears "requires approval" after policy changes.
- This file is only the deliberate SSH bits; the full console ACL may include
  more (custom tags, exit-node restrictions). Keep this as the fork root.
