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
| investigate | `spike`, `review-prd` | Time-boxed research; reviewing a PRD/design doc before building |
| build | `arch-solid` | Writing code — SOLID principles, composition, clean module boundaries |
| verify | `guard`, `test`, `review` | Before committing — secret/safety scan, run the right tests, review the diff |
| ship | `pr` | Open a PR and loop until CI is green and review threads are resolved |
| close | `wrapup`, `handoff` | Session closeout checklist; hand context to the next agent/session |
| learn | `improve`, `mem`, `dream` | Capture learnings; manage the knowledge base; GC stale memory/config |

Invoke a skill as `/playbook:<name>` (e.g. `/playbook:spike`).

## Always-On Safety

The playbook ships a `PreToolUse` hook that forces a confirmation prompt before
destructive bash commands (`rm`, `git push`/`reset --hard`/`clean`/`rebase`/
`merge`/`cherry-pick`, `brew`, package publishes) — even in auto-accept modes.
It is a seatbelt, not a blocker: confirm and proceed.

## How to Use Skills

When a task matches a skill's description, invoke it via the `Skill` tool before
acting. Skills tell you *how* to approach the work; reach for them early.
