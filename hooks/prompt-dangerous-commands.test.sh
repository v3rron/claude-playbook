#!/usr/bin/env bash
# Behavioral test for prompt-dangerous-commands.sh
set -uo pipefail
HOOK="$(dirname "$0")/prompt-dangerous-commands.sh"
fail=0

assert_decision() {
  local desc="$1" cmd="$2" want="$3"
  local got
  got=$(printf '{"tool_input":{"command":%s}}' "$(jq -Rn --arg c "$cmd" '$c')" \
        | "$HOOK" | jq -r '.hookSpecificOutput.permissionDecision // "allow"')
  if [ "$got" = "$want" ]; then
    echo "ok   - $desc ($got)"
  else
    echo "FAIL - $desc: want $want got $got"; fail=1
  fi
}

assert_decision "rm asks"               "rm -rf build"            "ask"
assert_decision "git push asks"         "git push origin main"    "ask"
assert_decision "env-prefixed git push" "FOO=1 git push"          "ask"
assert_decision "chained rm asks"       "cd /tmp && rm -rf x"     "ask"
assert_decision "plain ls allows"       "ls -la"                  "allow"
assert_decision "git status allows"     "git status"              "allow"

exit $fail
