# module: acl — tailnet access policy

Tailscale ACLs are managed in the admin console (they cannot be fetched with
the local CLI without an API key). This directory is the place to **fork /
version** your tailnet policy so `bldr-Omarchy` captures it as a tweak.

## How to populate
1. In the admin console → Access Controls, copy the current ACL JSON/ACL-HCL.
2. Save it here, e.g. `tailnet.acl.json`.
3. Document the service/reach rules that matter for `digs`:
   - who may `ssh` into `digs`,
   - who may read/serve the Vault (`/home/terl/vault`) and Current share,
   - who may use `digs` as an exit node.

## Placeholder
No policy is committed yet. Add the admin-console export when you want to
track ACL changes alongside the node tweaks.
