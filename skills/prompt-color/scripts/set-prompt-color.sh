#!/usr/bin/env bash
# Activate the prompt-color SessionStart hook in a given project.
# Usage: set-prompt-color.sh <hex-color-no-hash> [project-dir]
#   e.g. set-prompt-color.sh 0b2e1a /path/to/repo
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <hex-color-no-hash> [project-dir]" >&2
  echo "  example: $0 0b2e1a   (dark green)" >&2
  exit 1
fi

color="$1"
project_dir="${2:-$(pwd)}"

if ! [[ "$color" =~ ^[0-9a-fA-F]{6}$ ]]; then
  echo "Error: color must be a 6-digit hex value with no leading '#' (e.g. 0b2e1a)" >&2
  exit 1
fi

if [ ! -d "$project_dir" ]; then
  echo "Error: project dir not found: $project_dir" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not installed" >&2
  exit 1
fi

claude_dir="$project_dir/.claude"
settings_file="$claude_dir/settings.local.json"
mkdir -p "$claude_dir"

# Written as a literal (single-quoted) heredoc so none of $p/$c/$np/$t get
# bash-expanded here -- they're meant to be interpreted when the hook itself
# runs later, not now. __COLOR__ is the one thing substituted at write time.
cmd_template=$(cat <<'CMDEOF'
p="$PPID"; t=""; for i in 1 2 3 4 5 6 7 8 9 10 11 12; do [ -z "$p" ] && break; [ "$p" = "0" ] && break; c=$(readlink /proc/$p/fd/1 2>/dev/null); case "$c" in /dev/pts/*|/dev/tty*) t="$c"; break ;; esac; np=$(awk '{print $4}' /proc/$p/stat 2>/dev/null); [ "$np" = "$p" ] && break; p="$np"; done; [ -n "$t" ] && printf '\033]11;#__COLOR__\007' > "$t" 2>/dev/null; true
CMDEOF
)
cmd="${cmd_template//__COLOR__/$color}"

tmp_file=$(mktemp)
trap 'rm -f "$tmp_file"' EXIT

if [ -f "$settings_file" ]; then
  cp "$settings_file" "$tmp_file"
else
  echo '{}' > "$tmp_file"
fi

# Drop any existing prompt-color hook (identified by the __COLOR__ template's
# fixed prefix) before appending the new one, so re-running this script with
# a different color replaces rather than stacks.
jq --arg cmd "$cmd" '
  .hooks //= {} |
  .hooks.SessionStart //= [] |
  .hooks.SessionStart |= (
    map(select(
      (.hooks // []) | all(.command // "" | contains("readlink /proc/$p/fd/1") | not)
    ))
    + [{"hooks": [{"type": "command", "command": $cmd}]}]
  )
' "$tmp_file" > "$tmp_file.new" && mv "$tmp_file.new" "$settings_file"

echo "Wrote SessionStart hook to $settings_file (background #$color)"

gitignore_file="$project_dir/.gitignore"
ignore_line=".claude/settings.local.json"
if [ -f "$gitignore_file" ] && grep -qxF "$ignore_line" "$gitignore_file"; then
  : # already covered
else
  {
    echo ""
    echo "# Personal Claude Code settings (prompt-color hook, etc.) - not team-wide"
    echo "$ignore_line"
  } >> "$gitignore_file"
  echo "Added $ignore_line to $gitignore_file"
fi

echo "Done. Exit and resume (or start a fresh) Claude Code session in $project_dir to see it take effect."
