# neoprompt

Universal working rules and reusable guidance for AI coding agents.

The core is independent of model vendor and harness: Pi (pi.dev), Claude Code, Codex, and other agents should share the same truths, not separately maintained copies. Native entry points are thin pointers to that core. Harness-specific behavior is documented separately and checked against the relevant installed version.

## Start here

- **[RULES.md](RULES.md)** — verification, scope, narration, operator questions, persistent awareness, and safe handoffs/publication.
- **[SESSION-HANDOFF.md](SESSION-HANDOFF.md)** — portable startup/resume/exit checklist, concurrency, publication boundaries, and a reusable resume prompt.
- **[ARCHITECTURE.md](ARCHITECTURE.md)** — canonical core, thin adapters, public/private layering, implemented vs proposed integration.
- **[guides/PI.md](guides/PI.md)** — Pi context discovery, intentional session selection, privacy, parallel work, and installed-document references.
- **[AGENTS.md](AGENTS.md)** — a thin native entry point for agents working in this repository.
- **[TODO.md](TODO.md)** — outstanding ideas.

## Use from another project

Clone/install this core in a suitable location. In the project's native instruction file, refer to its actual path and the project's own spec/current-state documents. For example, adapt this text rather than copying the whole rule set:

```text
Read <neoprompt-path>/RULES.md and <neoprompt-path>/SESSION-HANDOFF.md.
Then read this project's canonical specification and current-state handoff.
Preserve approval gates and concurrent work; reverify live state before acting.
Keep project/environment details out of the public universal repository.
```

A filename reference is an instruction to read, not a guarantee that the harness automatically loaded that file. Verify context discovery for the installed agent. This repository does not yet supply an adapter installation/generation script; do not infer that documentation installs an extension or changes global settings.

## Public reusable knowledge, private operational state

Put reusable lessons, checklists, adapter guidance, and generally useful tooling here. Keep private hostnames, access procedures, credentials, raw transcripts, operator-specific state, and project execution logs in the appropriate private companion/project repository. A private exploration workspace should point to reusable material here rather than become a competing knowledge base.

A project specification describes the system and target; a current-state handoff records what is actually happening. Neither replaces verifying the live environment. Multiple agents/sessions need explicit coordination; they do not automatically share awareness.

## Contributions

Make lessons portable rather than tied to the agent that first wrote them. Keep one canonical source, label harness/version assumptions, separate observed/implemented behavior from plans, and preserve public/private and repository boundaries. Do not invent authorship history from recollection.

## License

SPDX-License-Identifier: AGPL-3.0-or-later

neoprompt is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

neoprompt is distributed without any warranty; without even the implied
warranty of merchantability or fitness for a particular purpose. See
[LICENSE](LICENSE) for the full terms.

[LICENSE-OPINION.md](LICENSE-OPINION.md) and
[LICENSE-AGENT_NOTE.md](LICENSE-AGENT_NOTE.md) are separate commentary;
they do not replace the license grant.
