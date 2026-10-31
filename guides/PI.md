# Pi (pi.dev) — applying the universal core

Pi-specific usage belongs here, not in the universal rules. These notes were checked against an installed Pi documentation set on 2026-10-31. Check the current installed docs/help when behavior differs; no adapter installer or extension is implemented here.

## Instructions and canonical content

Pi discovers context files from its agent directory, the working directory, and ancestor directories. Supported context names include `AGENTS.override.md`, `AGENTS.md`, and `CLAUDE.md` (with documented variants). An override replaces the ordinary context file only in the same directory; it does not suppress other ancestor/global context. Context discovery can be disabled with `--no-context-files`.

Use a thin project `AGENTS.md` to point to the canonical universal rules and private project handoff. Do not duplicate the entire rule set into every adapter. A neighboring Markdown file is not necessarily loaded automatically just because it exists: explicitly tell the agent to read referenced files and verify the startup context. This repository's `AGENTS.md` applies when working inside this repository; a sibling workspace needs its own entry point.

The default agent directory is `~/.pi/agent`, overridable by `PI_CODING_AGENT_DIR`. Configuration and discovery can change with version; inspect the installed `docs/configuration.md` rather than assuming another agent's behavior matches Pi's.

## Resume intentionally

```sh
cd /path/to/project
pi --continue
```

`--continue` selects the most recent saved session for that working directory, not necessarily the task you intended when several sessions share it. Use `pi --resume` (or interactive `/resume`) to choose, and `/name` to give sessions recognizable names. `/session` shows the current file and ID. `--session <path|id>` opens a specific session; check installed CLI semantics before cross-project recovery.

Sessions are persisted by default unless `--no-session` is used. Default storage is `~/.pi/agent/sessions/`, grouped by working directory, but settings, environment, or `--session-dir` can override it. Do not infer session identity from a guessed filename. A new session is not automatically aware of other sessions or another agent's transcripts.

## Context and parallel work

Pi supplies the active conversation branch plus its system instructions, discovered context files, and available resources. Compaction summarizes older context without deleting the original session entries. A durable project handoff still matters: read it and verify current Git/live state after resume or compaction. Refer to [the portable handoff checklist](../SESSION-HANDOFF.md).

Use `/reload` after changing instructions/resources when appropriate, or restart and confirm loaded context. Documentation edits do not guarantee that already-running sessions have read the new policy. Coordinate parallel sessions explicitly and do not overwrite their dirty files, reset/clean shared checkouts, or assume their work was committed.

## Privacy and execution boundaries

Pi tools run with the process user's operating-system permissions. Project trust controls resource loading, not tool sandboxing or mandatory per-command approval. Context files may load even when project resource trust is declined. Respect operator approval gates yourself; prompts are not an OS security boundary.

Sessions can contain prompts, tool arguments/results, file contents, and credentials. Do not commit session stores, auth/configuration stores, debug logs, or raw exports by default. In particular, do not use `/share`, `/bug` with a transcript, or public export workflows for private work without reviewing destination and content. Sharing destinations are version/settings dependent; a private project Git repo does not make a session-sharing service the same destination.

## References

Installed coding-agent README and relevant `docs/` pages: `configuration.md`, `sessions.md`, `usage.md`, `cli.md`, `how-pi-works.md`, and `security.md`. Resolve these relative to the installed package documentation, not a project's similarly named files. Upstream entry point: https://pi.dev/.

For extensions, SDK, themes, skills, or packages, read their current specific docs/examples before implementing; this guide does not claim those APIs are installed or configured.
