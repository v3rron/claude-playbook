# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

`claude-playbook` is a **Claude Code plugin**, distributed via the plugin
marketplace mechanism. It is not application code — it is a packaged workflow of
hooks + skills that other people install into their own Claude Code sessions:

```
/plugin marketplace add v3rron/claude-playbook
/plugin install playbook@claude-playbook
```

There is no build step, no compiler, no dependency manager. The "product" is the
set of markdown skills and bash hooks that Claude Code loads at runtime.

## Commands

- **Run the hook test suite:** `bash hooks/prompt-dangerous-commands.test.sh`
  (exit 0 = pass; prints `ok` / `FAIL` per case). This is the only automated
  test in the repo — run it after any change to `prompt-dangerous-commands.sh`.
- **Smoke-test a hook by hand:** pipe a fake tool event to it, e.g.
  `printf '{"tool_input":{"command":"rm -rf x"}}' | bash hooks/prompt-dangerous-commands.sh`
- Hooks depend on `jq` being on PATH.

## Architecture

Three top-level pieces, wired together by `hooks/hooks.json`:

1. **`.claude-plugin/`** — plugin identity. `plugin.json` is the installable
   plugin manifest; `marketplace.json` is the marketplace listing that points at
   it (`source: "."`). **Both carry a `version` — bump them together.**

2. **`hooks/`** — two runtime hooks declared in `hooks.json`:
   - `session-start.sh` (SessionStart: `startup|clear|compact`) reads
     `skills/using-playbook/SKILL.md`, JSON-escapes it, and emits it as
     `hookSpecificOutput.additionalContext`. This is the **self-activation
     mechanism**: every session boots with the playbook's table-of-contents in
     context, so Claude knows which skill maps to which stage of the workflow.
   - `prompt-dangerous-commands.sh` (PreToolUse: `Bash`) is a **safety gate**.
     It parses the proposed command, strips leading `VAR=val` assignments and
     anything after shell operators to find the base command, and matches it
     against a denylist (`rm`, `git push`/`reset --hard`/`clean`/`rebase`/
     `merge`/`cherry-pick`, `brew`, package publishes). On a match it returns
     `permissionDecision: "ask"` to force a confirmation prompt even in
     auto-accept modes; otherwise it `exit 0`s (the idiomatic "allow/defer"
     signal — bare exit, no JSON). It also re-scans the full command for the
     same patterns embedded after `&&`/`||`/`;`/`|`.

3. **`skills/`** — one directory per skill, each with a `SKILL.md` carrying
   YAML frontmatter (`name`, `description`). Skills are organized around a single
   arc — **investigate → build → verify → ship → close → learn** — documented in
   `skills/using-playbook/SKILL.md`, which is the canonical map of when to reach
   for each skill. A few skills ship helper scripts alongside the markdown (e.g.
   `skills/dream/scan.py`).

## Conventions specific to this repo

- **Skills here are sanitized public exports**, not the source of truth. They
  originate in the maintainer's private `dots` repo and are published here via
  the `export-to-starter` skill, which strips personal/company/project-specific
  content. When editing or adding a skill, keep it **portable and public**: no
  internal hostnames, employer names, private paths, or personal workflow
  assumptions. Content that only makes sense for one person's machine does not
  belong here.
- The `using-playbook` skill is **load-bearing**: it is the text the
  SessionStart hook injects. If you add, remove, or rename a workflow skill,
  update the stage→skill table in `skills/using-playbook/SKILL.md` to match, or
  the injected guidance will be wrong.
- Keep hooks dependency-light (bash + `jq`) and idiomatic: a PreToolUse hook
  that wants to allow a command should just `exit 0` with no output, not emit an
  `"allow"` JSON payload — the test suite asserts this behavior.
