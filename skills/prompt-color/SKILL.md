---
name: prompt-color
description: Set a per-project terminal background color (and best-effort title) that activates automatically every time a Claude Code session starts in a given repo. Use when the user wants a visual "which project am I in" cue, or asks to change/set the color of their prompt/terminal for a specific project.
---

# prompt-color

Gives a repo its own terminal background color, applied automatically by a
`SessionStart` hook every time Claude Code starts there — no shell rc file
changes, no system-wide effect, scoped to that one project only.

Written up after a long session fighting this exact problem one layer at a
time. See `neoprompt`'s own `RULES.md` (rule #3) for the general lesson;
this skill is the concrete, reusable fix.

## Why this is harder than `printf '\033]11;...'`

The obvious approach — have a hook `printf` an OSC 11 (background color) /
OSC 0 (title) escape sequence — fails silently in most agent harnesses,
for two independent reasons:

1. **The hook's subprocess usually has no controlling terminal.** Writing to
   `/dev/tty` fails with `ENXIO` ("No such device or address") even though
   the real terminal is right there on screen — the process's stdio is
   piped/captured for the agent's own display layer, not inherited raw.
2. **A real terminal device still exists; you have to find it directly.**
   The actual pty is a concrete device node (`/dev/pts/N` on Linux). You can
   write to it directly, bypassing the controlling-terminal requirement
   entirely, by walking up the process tree from the hook's own PID until
   you find an ancestor whose stdout fd resolves to `/dev/pts/*` — that's
   the real terminal, write there instead.

## Usage

Run `scripts/set-prompt-color.sh <hex-color> [project-dir]` (defaults to
the current directory) to activate this in any repo:

```bash
skills/prompt-color/scripts/set-prompt-color.sh 0b2e1a /path/to/some/repo
```

This writes/merges a `SessionStart` hook into that repo's
`.claude/settings.local.json` (creating it if needed, merging into existing
hooks if not — never clobbering unrelated settings), and adds that file to
the repo's `.gitignore` if it isn't already covered, since the color choice
is a personal/local preference, not a team-wide setting.

To activate this skill itself (make it invocable / copy its logic) in a
different project, copy this whole `skills/prompt-color/` directory into
that project's `.claude/skills/` directory, or symlink it the way this repo
does (`.claude/skills -> ../skills`).

## What it does NOT solve: the terminal title

Fighting a host application's own output (like Claude Code's terminal-title
sync, which shows the session's name/topic) with a hook that re-writes the
title after every turn is a losing, flickering race — the host re-asserts
its own state faster/more often than a lifecycle hook fires. The actual fix
for Claude Code specifically is `/rename <name>`, which sets the thing the
title-sync displays, so there's nothing left to fight. This skill only
handles the background color, which Claude Code never touches on its own.

## Caveats

- Requires a Linux `/proc` filesystem (the pty-discovery walk reads
  `/proc/<pid>/fd/1` and `/proc/<pid>/stat`). Not portable to macOS/Windows
  as written — would need a different discovery method there (e.g. `lsof`
  on macOS).
- Needs a terminal emulator that honors OSC 11 (most do: xterm, VTE-based
  terminals like GNOME Terminal/xfce4-terminal, Konsole, Alacritty, kitty).
  No automatic fallback or detection if it doesn't — the hook just silently
  has no visible effect.
- Only ever reaches a real terminal when the hook is invoked by Claude Code
  directly (not through an additionally-sandboxed tool-execution subprocess
  that pipes stdio without any pty at all — in that case even the direct
  `/dev/pts/N` write has nothing to find).
