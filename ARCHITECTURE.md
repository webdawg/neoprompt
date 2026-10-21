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

## Private companion repo

`neoprompt` itself is universal and public — no project-specific or
sensitive content belongs here, ever. A separate, private repo
(`neoprompt-private`) holds that: real servers, how to actually reach
credentials (the procedure, never the plaintext secret itself), where
local git repos live, and a per-project/per-environment index — one
operator's own context, not universal truths.

**Convention**: when told to "import neoprompt and neoprompt-private,"
an agent should clone `neoprompt-private` into this repo's own
`private/` directory (already in `.gitignore` here, so it can never be
accidentally committed into the public repo) and read it alongside
`RULES.md`. Apply the universal rules first, then `private/`'s specifics
for whichever project/environment is actually active that session.

`neoprompt-private` carries its own `SPEC.md` — a fill-in-the-blank
template for documenting one environment at a time (servers, credential
*procedures*, local repo locations, known deficiencies, pointers to any
deeper project-specific knowledge base). Copy that template into a new
file per distinct environment rather than merging unrelated ones
together.
