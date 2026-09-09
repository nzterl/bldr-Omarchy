# module: ai_notes

The workshop is also a home for AI/notes files that other net members can
sync or browse. Layout is open; suggestions:

```
~/dev/current/
  nzterl.md            # (existing) personal notes
  citadel/             # (existing) planning dir
  bldr-Omarchy/        # this repo, replayed by consumers
  notes/               # optional shared AI notes dir
```

Nothing installed to enforce sync yet — sharing happens via
`tailscale serve` (browse) + Tailscale SSH (`scp`/`sshfs`). If a continuous
AI-notes sync is wanted, that is where a `syncthing` module would plug in.
