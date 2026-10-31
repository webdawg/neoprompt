# Portable session handoff

This checklist applies to any coding agent, model, editor, or harness. A saved conversation is useful evidence, not a substitute for a concise, maintained project handoff. Multiple sessions do not automatically know one another's work.

## Before starting or resuming

1. Read the applicable native entry-point instructions and the canonical rules, specification, and current-state document they identify. Follow the required reading order. Search for existing state documents before creating another.
2. Verify the actual working directory, host, repository boundaries, branch, status, and relevant active work. Distinguish a parent workspace from independent nested repositories.
3. State what is directly observed, what is operator intent, what is a historical claim, and what remains unverified.
4. Preserve the scope of each policy: a controller mandated for one shared repository is not automatically required for unrelated projects or Git hosting access.
5. Answer new operator questions before continuing operational work. Preserve the requested approval granularity: planning, editing, committing, pushing, rebooting, and destructive operations are distinct actions.

## Minimum handoff contents

- **Goal and decisions:** selected approach, rejected alternatives and why, constraints, and unresolved questions.
- **Authority and location:** canonical spec/state paths, repository locations, remotes/visibility without credentials, and which repository owns each change.
- **Verified state:** observations with time/context where available; exact identities needed for the task, but no unnecessary sensitive identifiers.
- **Completed vs proposed:** actual commands/outcomes and edits, separate from plans. Explicitly say what has not happened.
- **Publication state:** files written, staged/unstaged changes, commit IDs, push result, and independent remote verification where possible. One repository's push does not publish sibling changes.
- **Concurrency:** known parallel sessions, shared dirty files, active jobs/locks, and conflicts requiring coordination. Unknown session state stays unknown.
- **Next steps:** the smallest safe next action, its preconditions, approval gate, expected output, and stop conditions.
- **Recovery:** backups, rollback limits, where instructions can be accessed if the target environment is unavailable, and what has not been tested.
- **Access:** how to obtain authorized credentials from the existing approved private source, without duplicating secrets into the handoff.

## Keep the layers separate

- Universal rules belong in public, environment-neutral documentation.
- Harness-specific discovery, CLI commands, and session behavior belong in a clearly labeled adapter/guide, checked against the installed version.
- Environment access procedures and host/project state belong in private environment or project repositories.
- Raw transcripts, tool logs, auth stores, credentials, and backup archives are not automatically suitable for any Git repository, even a private one.
- A private remote is an access boundary, not permission to upload every local file.

## Safe publication of a workspace

Before initializing a parent repository, identify nested repositories, secrets, large artifacts, unrelated work, session exports, and ignored files. Agree on the backup/versioning scope. Use an allowlist or explicit staging, and inspect the actual index before committing. Do not vendor nested `.git` trees or create accidental gitlinks. Do not assume `.gitignore` removes already tracked content or history.

Keep credentials out of remote URLs, command output, and committed scripts. Use existing approved authentication with TLS/host-key verification intact. Verify remote visibility and that the intended commit reached the intended branch. Preserve excluded local material; exclusion is not deletion or credential rotation.

## Before exit or a disruptive operation

Update the existing current-state document rather than producing competing awareness files. Commit and push only the authorized scope. Report pending changes honestly. Keep recovery instructions accessible independently of storage/network being modified. If the next session requires excluded private material, document its secure reprovisioning procedure and do not claim that cloning the repo alone fully restores the workspace.

## Resume prompt template

> Read the native entry point, then the canonical rules, specification, and current-state documents in their stated order. Do not display credentials. Summarize the goal, completed vs pending work, repository/commit/push state, known concurrent changes, and next approval gate. Reverify live state before acting. Do not resume operational changes solely because an old plan lists them.
