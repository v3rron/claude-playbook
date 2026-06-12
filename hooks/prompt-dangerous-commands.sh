#!/bin/bash
# PreToolUse hook: forces a confirmation prompt for dangerous bash commands.
# Returns permissionDecision: "ask" for dangerous commands, exits 0 (allow) otherwise.

COMMAND=$(jq -r '.tool_input.command' < /dev/stdin)

# Extract the first command in pipes/chains by stripping everything after shell
# operators. Leading VAR=value assignments are stripped first so env-prefixed
# commands (FOO=1 git push) can't dodge the patterns.
BASE_CMD=$(echo "$COMMAND" | sed -E 's/^([A-Za-z_][A-Za-z0-9_]*=[^ ]* +)+//' | sed 's/[;&|].*//' | xargs)

# Check each dangerous pattern
case "$BASE_CMD" in
  rm\ *|rm)
    REASON="File deletion: rm" ;;
  rmdir\ *|rmdir)
    REASON="Directory deletion: rmdir" ;;
  git\ push*|git\ -C\ *push*)
    REASON="Git push" ;;
  git\ reset\ --hard*|git\ -C\ *reset\ --hard*)
    REASON="Git reset --hard" ;;
  git\ clean*|git\ -C\ *clean*)
    REASON="Git clean" ;;
  git\ rebase*|git\ -C\ *rebase*)
    REASON="Git rebase" ;;
  git\ merge*|git\ -C\ *merge*)
    REASON="Git merge" ;;
  git\ cherry-pick*|git\ -C\ *cherry-pick*)
    REASON="Git cherry-pick" ;;
  brew\ *)
    REASON="Homebrew command" ;;
  npm\ publish*|gem\ push*|yarn\ publish*)
    REASON="Package publish" ;;
  *)
    # Also check for dangerous commands embedded after && or || or ; or |
    if echo "$COMMAND" | grep -qE '(^|[;&|]\s*)([A-Za-z_][A-Za-z0-9_]*=[^ ]+ +)*(rm|rmdir)\s'; then
      REASON="Embedded file deletion detected"
    elif echo "$COMMAND" | grep -qE '(^|[;&|]\s*)([A-Za-z_][A-Za-z0-9_]*=[^ ]+ +)*git\s+(commit|push|reset\s+--hard|clean|rebase|merge|cherry-pick)'; then
      REASON="Embedded dangerous git command detected"
    else
      exit 0
    fi
    ;;
esac

jq -n --arg reason "$REASON" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: $reason
  }
}'
