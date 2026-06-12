# claude-playbook

An opinionated Claude Code workflow, packaged as a plugin. Not a loose bag of
utilities — a single arc your agent follows:

```
investigate → build → verify → ship → close → learn
```

The plugin self-activates: a SessionStart hook injects a bootstrap skill
(`using-playbook`) that tells Claude when to reach for each skill, and a
PreToolUse safety hook forces a confirmation prompt before destructive bash
commands — even in auto-accept modes.

## Install

```
/plugin marketplace add v3rron/claude-playbook
/plugin install playbook@claude-playbook
```

Restart the session. You'll see the playbook bootstrap in context, and
destructive commands (`rm`, `git push`, `git reset --hard`, …) will prompt
before running.

## What's inside

- **Safety hook** — `prompt-dangerous-commands`: confirmation gate for
  destructive bash commands.
- **Workflow skills** — added over time; see `using-playbook` for the current
  set and when to use each.

## Requirements

- Claude Code with plugin support
- `jq` (used by the hooks)

## License

MIT
