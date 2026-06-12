# CLAUDE.md

This file guides Claude Code when **contributing to this repository**. Note: a
plugin's root `CLAUDE.md` is *not* loaded as runtime context for people who
install the plugin — it guides contributors here, not consumers of the plugin.

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
   - `prompt-dangerous-commands.sh` (PreToolUse: `Bash`) is a **safety gate**: it
     forces a confirmation prompt (`permissionDecision: "ask"`) before destructive
     commands even in auto-accept modes, and `exit 0`s otherwise. The exact
     denylist and command-parsing live in the script (its `case` statement) —
     read it there rather than duplicating the logic here.

3. **`skills/`** — one directory per skill, each with a `SKILL.md` carrying
   YAML frontmatter (`name`, `description`). Skills are organized around a single
   arc — **investigate → build → verify → ship → close → learn** — documented in
   `skills/using-playbook/SKILL.md`, which is the canonical map of when to reach
   for each skill. A few skills ship helper scripts alongside the markdown (e.g.
   `skills/dream/scan.py`).

## Conventions specific to this repo

- **Skills here are sanitized public exports, not the source of truth.** They
  originate in a private source repo and are published via a sanitizing export
  step. **Do not hand-edit a `SKILL.md` here to change behavior** — the next
  export overwrites it. Fix it in the source repo and re-run the export. Edits
  made *only* here are lost.
- When a skill *does* legitimately change here, keep it **portable and public**:
  no internal hostnames, employer names, private paths, or personal workflow
  assumptions. Content that only makes sense for one person's machine does not
  belong here.
- The `using-playbook` skill is **load-bearing**: it is the text the
  SessionStart hook injects. If you add, remove, or rename a workflow skill,
  update the stage→skill table in `skills/using-playbook/SKILL.md` to match, or
  the injected guidance will be wrong.
- Keep hooks dependency-light (bash + `jq`) and idiomatic: a PreToolUse hook
  that wants to allow a command should just `exit 0` with no output, not emit an
  `"allow"` JSON payload — the test suite asserts this behavior.
