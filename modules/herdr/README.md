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

## Current agent stage (this conversation)
- **`opencode`** is running as the herdr agent in the digs session pane
  **`w1:p1`** (cwd `~/Work`), resuming session
  **`ses_f801b903cffe8FIAIvmtDEMcCG`** ("HP USB boot not working" → digs node).
- Start/resume it (repeatable):
  ```bash
  # talk to the digs session's server:
  export HERDR_SOCKET_PATH=$HOME/.config/herdr/sessions/digs/herdr.sock
  herdr pane list --workspace w1
  herdr pane run w1:p1 'cd /home/terl/Work && opencode -s ses_f801b903cffe8FIAIvmtDEMcCG'
  herdr agent list          # -> opencode, idle
  ```

## From a consumer (laptop)
- Omarchy binds `SUPER CTRL + RETURN` -> Herdr (local herdr) and
  `SUPER ALT + RETURN` -> tmux.
- To pop the **digs** session from another machine:
  `herdr --remote terl@digs`  (herdr's SSH remote attach; needs sshd on digs,
  see exit-node T6)
  or the helper: `ROLE/consumer/scripts/herdr_attach.sh terl@digs`
- Inside the attached digs session you land in the `~/Work` pane where the
  `opencode` agent already runs — continue the conversation there.

## Notes
- herdr 0.9.0 is available but NOT auto-updated here; update explicitly with
  `herdr update`.
- `herdr` requires a real terminal for the TUI; use `herdr server`/sessions
  for headless operations.