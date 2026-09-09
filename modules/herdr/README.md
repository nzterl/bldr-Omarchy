# module: herdr (terminal workspace manager for AI coding agents)

Herdr is Omarchy's agent-aware terminal multiplexer (tmux-style workspace/tab/
pane, plus per-pane agent lifecycle: `idle/working/blocked/done`). It replaces
raw tmux for agent work and can be attached *remotely* through SSH.

## On this box (`digs`)
- Config: `~/.config/herdr/config.toml` (mirrors Omarchy tmux.conf; prefix
  `ctrl+space`).
- A headless session **`digs`** runs via herdr's server:
  `~/.config/herdr/sessions/digs/` (socket + session.json). Attach from here
  with `herdr session attach digs`.
- Agent detection integration installed for opencode:
  - `~/.config/opencode/plugins/herdr-agent-state.js`
  - `~/.config/opencode/tui.jsonc` -> loads `./herdr-tui-session.js`
  - To (re)install: `herdr integration install opencode`

## From a consumer (laptop)
- Omarchy binds `SUPER CTRL + RETURN` -> Herdr (local herdr) and
  `SUPER ALT + RETURN` -> tmux.
- To pop the **digs** session from another machine:
  `herdr --remote digs`  (herdr's SSH remote attach)
  or the helper: `ROLE/consumer/scripts/herdr_attach.sh digs`
- Inside the digs session, an agent pane can be started with:
  `herdr agent start myagent --kind opencode --pane <ID>` (resume the
  conversation with `opencode` and its session list).

## Notes
- herdr 0.9.0 is available but NOT auto-updated here; update explicitly with
  `herdr update`.
- `herdr` requires a real terminal for the TUI; use `herdr server`/sessions
  for headless operations.