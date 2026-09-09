# buildit — reserved slot

This is where a future **BuildIt ruby crop** would go if this grows beyond
Markdown + scripts and earns the gem dependency.

## Why it's a placeholder
- BuildIt (`~/dev/buildit`) generates a `bldr.bash` installer from a tree
  (`data/`, `index/`, `modules/`, `config/Crop.yaml`), modeled on `bldr-HS` /
  `bldr-linux`.
- We're gauging whether that complexity is worth it right now. For a handful
  of idempotent tailscale/share tweaks, plain Markdown + scripts (see `ROLE/`)
  is lighter and has no Ruby-gem install step.

## When to promote
- When the tweak set grows (many machines, many modules, systemd units,
  package installs, path-aware file copies) — then model a crop on
  `~/dev/bldr-linux`.

## If promoted
- `require 'buildit'` needs the gem (install `buildit` from `~/dev/buildit`,
  or `$LOAD_PATH` to it).
- Add `config/Crop.yaml` mapping the tree types (pacman/systemd/file_copy).
