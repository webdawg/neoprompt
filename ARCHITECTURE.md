# Architecture (scope, not yet fully built)

Goal: `neoprompt` is the one place these universal truths and reusable
tools live. Each AI coding agent reads its own native config format, so
thin adapters translate `RULES.md` + `skills/` into whatever each one
actually reads, without duplicating content — symlink/include, not
copy-paste, so there's exactly one copy to keep correct.

## Agent-agnostic core (already exists)

- `RULES.md` — the universal truths themselves, no tool-specific framing
- `skills/` — concrete reusable tooling (e.g. `prompt-color`), plain
  scripts where possible so any agent's shell-execution tool can run them

## Adapters (per agent's native convention)

### Claude Code — done
Reads `.claude/skills/*/SKILL.md` and `CLAUDE.md`. Already wired:
`.claude/skills -> ../skills` symlink in this repo; same pattern applies
when activating a skill in another project.

### Codex + Pi (pi.dev) — share one adapter, not yet built
Both read an `AGENTS.md` file: Codex at repo root, Pi at repo root *and*
a global `~/.pi/agent/AGENTS.md` (Pi also accepts `CLAUDE.md` as a
fallback, so there's some overlap with the Claude adapter above). A single
`adapters/agents-md/` generating or symlinking an `AGENTS.md` that
includes `RULES.md`'s content should cover both — confirmed via Pi's own
docs: https://pi.dev/.

Open question before building this one: whether Codex's `AGENTS.md` and
Pi's `AGENTS.md` expect the same shape/conventions (e.g. does either one
read a neighboring `skills/`-equivalent, or is it pure instructions-only
with no reusable-tool concept at all). Not yet researched.

## Not yet done

- No adapter directories created yet, no generation script, no symlink
  wiring beyond Claude's. This file is the plan, not the implementation.
