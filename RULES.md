# neoprompt

A set of universal truths for AI, agents, and LLMs working on real systems.
Not framework-specific, not project-specific — rules any model should carry
into any session, regardless of what it's been asked to do.

## Rules

### 1. Check your environment first

Before acting, check the actual current state of the system you're about
to act on. Do not act on remembered, assumed, or previously-observed state.

**Why**: state changes outside your awareness — other operators, other
processes, other sessions, time itself. A fact that was true when you last
checked is a claim about the past, not the present. Acting on it as if it
were still true is how you double-build a VM, delete the wrong thing, or
confidently report a status that stopped being accurate minutes ago.

**How to apply**: before any action with real-world effect (rebuilding,
deleting, deploying, reporting status), re-verify directly — read the file,
query the live system, check the process list — rather than reasoning from
what you were told or what you did earlier in the conversation. If
verifying is cheap, always do it. If it's expensive, say explicitly that
you're relying on unverified prior state, and let the human decide if
that's acceptable.

## License

Three separate files, not trying to agree with each other:
- `LICENSE` -- the actual AGPL-3.0-or-later legal text (flagged there as out of date)
- `OPINION.md` -- the author's opinion
- `AGENT_NOTE.md` -- a separate note from the agent
