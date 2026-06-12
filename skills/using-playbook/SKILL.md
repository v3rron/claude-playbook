---
name: using-playbook
description: Use when starting any conversation with the playbook plugin active — explains the workflow and when to reach for each skill.
---

# Using the Playbook

The **playbook** is an opinionated Claude Code workflow. It is a system, not a
loose bag of tools: each skill has a place in a single arc.

## The Workflow

```
investigate → build → verify → ship → close → learn
```

| Stage | Reach for | When |
|-------|-----------|------|
| investigate | (skills added via export) | Scoping a change, researching unknowns |
| build | (skills added via export) | Writing the implementation |
| verify | (skills added via export) | Before committing — safety, tests, review |
| ship | (skills added via export) | Opening and landing a PR |
| close | (skills added via export) | Wrapping up a session, handing off |
| learn | (skills added via export) | Capturing what was learned |

## Always-On Safety

The playbook ships a `PreToolUse` hook that forces a confirmation prompt before
destructive bash commands (`rm`, `git push`/`reset --hard`/`clean`/`rebase`/
`merge`/`cherry-pick`, `brew`, package publishes) — even in auto-accept modes.
It is a seatbelt, not a blocker: confirm and proceed.

## How to Use Skills

When a task matches a skill's description, invoke it via the `Skill` tool before
acting. Skills tell you *how* to approach the work; reach for them early.
