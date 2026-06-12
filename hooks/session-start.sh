#!/usr/bin/env bash
# SessionStart hook for the playbook plugin.
# Injects the using-playbook bootstrap skill into context so the workflow
# self-activates. Mirrors the approach used by the superpowers plugin.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

bootstrap_content=$(cat "${PLUGIN_ROOT}/skills/using-playbook/SKILL.md" 2>&1 \
  || echo "Error reading using-playbook skill")

# Escape a string for embedding in a JSON string value (single-pass each).
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

bootstrap_escaped=$(escape_for_json "$bootstrap_content")
session_context="<IMPORTANT>\nThe playbook plugin is active.\n\n**Below is the full content of your 'playbook:using-playbook' skill — your guide to this workflow. For all other skills, use the 'Skill' tool:**\n\n${bootstrap_escaped}\n</IMPORTANT>"

# Claude Code consumes hookSpecificOutput.additionalContext.
printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$session_context"
exit 0
