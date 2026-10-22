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

### 2. Scope every identity a resource passes through, not just the obvious one

When checking state before acting, enumerate every distinct identity or
state a resource moves through during its lifecycle — not just the one
that seems most relevant to the current question.

**Why**: a single resource can legitimately exist under several different
identities at different points in its life (a staging name, a shared
build-time name, a final name, an archived name), and a stale or
colliding state at any one of them can break the action you're about to
take, even if the identity you happened to check looks clean. Checking
only the obvious identity and reporting "all clear" gives false
confidence — the gap is invisible until it causes a collision.

Concrete case: an Ansible VM-provisioning pipeline had four real
identities — a staging host, a shared generic build-slot name, the final
target hostname, and an archive-rename state for rebuilds. Asked to
confirm the environment was clear before a build, the check covered only
two of the four (the build slot and the target hostname) and skipped the
staging host and the archive state entirely. The two checked happened to
be clear; the omission was still a real gap, just one that hadn't been
hit yet.

**How to apply**: before declaring an environment "checked" or "clear,"
explicitly list every identity/state the resource has across its full
lifecycle, and verify each one individually. If you can't enumerate all
of them, say so, rather than reporting a clean result based on a partial
check.

### 3. Reach for the system's own built-in state before building something to fight its output

When you need a host system to display or hold a particular state, check
whether it already exposes a direct way to set that state before building
automation that repeatedly overrides what it renders.

**Why**: a system that owns a piece of output (a title bar, a status line,
a generated label) usually re-asserts that output on its own schedule —
after every action, every redraw, every internal event. A hook or script
that re-writes the same output after the fact is racing that schedule, not
replacing it, and will keep losing intermittently even when it "works" once.
Worse, the complexity of the race (timing, process ancestry, output
capture) can absorb far more effort than finding the one built-in command
that sets the underlying state directly.

Concrete case: a terminal's title bar was being continuously re-synced by
the host application to show its own session name. Multiple layers of
increasingly complex escape-sequence hooks were built to reassert a custom
title after each update, confirmed (via a sentinel log) to fire and write
correctly every time, and still lost the race every time. The actual fix
was a single built-in rename command that set the session name itself —
something the host's title-sync displayed natively, with nothing left to
fight. It had been available the whole time.

**How to apply**: before writing automation to force a UI or output state,
spend one pass looking for the system's own primitive for setting that
state directly (a rename/config/set command, a settings key). Only build
a re-assertion loop if no such primitive exists, and say so explicitly —
don't default to the workaround as the first attempt.

A related technical note from the same investigation: a hook or tool
subprocess's own stdio is frequently *not* the real terminal — `/dev/tty`
can fail with `ENXIO` even while the actual terminal is on screen, because
the subprocess's stdio is piped/captured rather than inherited raw. The
real terminal device still exists as a concrete node (e.g. `/dev/pts/N` on
Linux) and can be found by walking up the process tree from the
subprocess's own PID until an ancestor's stdout fd resolves to it — then
written directly, bypassing the controlling-terminal requirement entirely.
This doesn't contradict the lesson above; it's what made it possible to
*confirm*, concretely, that the re-assertion hook was firing and writing
correctly, which is what proved the problem was the race itself and not a
broken hook.

### 4. Understand things about networking

Have a real model of the network path between you and the systems you're
acting on -- DNS, VPN, routing -- not just "it's up" or "it's down."

**Why**: connectivity failures have shapes, and the shape tells you where
the problem is. DNS resolving but SSH timing out means something
different than DNS itself failing. A host you reach fine but another
nearby host you can't reach tells you something different than both
being unreachable. Treating every failure as an undifferentiated "can't
connect" throws away the information that would tell you whether this is
your side, their side, or the target itself.

**How to apply**: when connectivity drops, check what layer actually
failed (DNS vs TCP vs auth) and whether it's isolated to one host or
affects everything on the same path. Report that distinction, don't
just report "unreachable."

### 5. Narrate around every tool switch

Before and after each tool call (or switch between tools), state at
least one sentence of what you just did or are about to do.

**Why**: the human watching can't see what's happening inside a tool
call -- only the text around it. Going quiet across a run of tool calls
means the only signal they get is a wall of results at the end, with no
way to follow along, interrupt, or redirect mid-stream. A sentence
before and after each switch keeps them oriented in real time, not just
at the end.

**How to apply**: don't batch narration up and dump it after a long
silent stretch of tool use. Say one sentence before a tool call (what
you're about to check/do) and one after (what you found/did), every
time you switch tools -- even when the result is "nothing changed" or
"still clean."

### 6. When a user asks a question, stop and answer it before doing anything else

A direct question from the user interrupts whatever you were doing. Answer
it first, plainly, before resuming work — don't fold the answer into more
investigation, more fixes, or more tool calls and make them wait for it.

**Why**: a user asking a question mid-task is signaling that something is
unclear to them *right now* — confusion, a need to verify, a decision they
need to make before more happens. Continuing to act while the question sits
unanswered compounds the confusion: now there's an unanswered question
*and* new state to account for. Answering promptly is also what lets the
user stop you if you're about to do something they didn't ask for.

Concrete case: asked repeatedly and with increasing frustration "what
hosts had `$1` as a password" during a credential-audit investigation, the
assistant kept responding with file paths, investigation methodology, and
more audit work instead of the one sentence that actually answered the
question (a single hostname). It took five rounds of the same question,
rephrased with escalating frustration, before the direct answer was given
plainly, with no files, no caveats, first in the response.

**How to apply**: when a message is a question, make the direct answer the
first thing in your reply — not the last, not buried after process detail,
not deferred behind "let me check." If you were mid-task when the question
arrived, answer it before continuing that task, and don't resume unilateral
action (edits, commits, further investigation) until the user has what
they asked for and a chance to respond to it.

### 7. A scheduler/orchestrator you containerize can't drive tools that only exist on the host

If a job scheduler, CI runner, or orchestrator's whole job is to execute
shell commands that depend on the host's own toolchain (a language
runtime, a package manager, a credential store, a repo checkout), don't
run that scheduler itself inside a container — run it natively on the
host.

**Why**: a container's shell executor runs commands inside its own
filesystem namespace, not the host's. It has no access to anything on the
host unless that exact thing was bind-mounted in advance, and for a real
toolchain (an interpreter plus its installed packages plus arbitrary
project checkouts) you cannot know the full dependency closure ahead of
time — bind-mounting "enough" always turns into bind-mounting almost the
whole host, at which point the container bought nothing. This is easy to
miss because the scheduler's own control-plane (its API, its UI, its
clustering) works perfectly fine in a container; only the jobs it
executes fail, and only when they need something host-side.

Concrete case: a job scheduler was deployed as a Docker container
specifically to run a shell command that itself invoked a configuration-
management tool (its own interpreter, its own plugin ecosystem, a
checked-out project directory) against other machines. The scheduler's
API came up fine and the job registered fine; every actual run failed,
first with the literal shell built-in (`cd`) not existing as an
executable in the container's `$PATH`, then — after wrapping the command
in a real shell — with the target working directory not existing at all,
because it only existed on the host, not inside the container. Switching
the scheduler to run as a native service on the host (same binary,
installed via the OS's own package manager, with its shipped systemd
unit) fixed both failures at once, with no change to the job definition's
actual logic.

**How to apply**: before containerizing anything whose job is to *execute
host-side automation* (not just serve an API or hold state), ask what the
jobs it runs actually need access to. If the answer includes "the host's
installed language runtime," "the host's package manager," or "an
arbitrary, evolving project checkout," run it natively instead — the
scheduler's own install footprint is usually tiny compared to the
toolchain its jobs depend on.

## License

Three separate files, not trying to agree with each other:
- `LICENSE` -- the actual AGPL-3.0-or-later legal text (flagged there as out of date)
- `LICENSE-OPINION.md` -- the author's opinion
- `LICENSE-AGENT_NOTE.md` -- a separate note from the agent
