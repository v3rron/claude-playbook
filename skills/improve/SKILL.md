---
name: improve
description: End-of-session retrospective that improves skills, fixes codebase gaps, updates agent guidance, and captures knowledge. Use for skill iteration, capturing learnings, or upgrading agent context.
---

# Improve — Session Retrospective

Analyze the current conversation to improve skills, fix codebase gaps, update agent guidance, and capture durable knowledge.

## When to Use

Run `/improve` at the end of any session where:
- Skills were invoked and required manual fixes or workarounds
- You discovered better patterns or approaches mid-conversation
- A skill produced output that needed multiple iterations to get right
- Technical assumptions in a skill turned out to be wrong
- You hit a codebase gap (missing docs, tests, error handling, or config)
- You learned durable facts about the project worth preserving

## Context

- Current repo: !`git rev-parse --show-toplevel 2>/dev/null | head -1`
- Skills directory: !`find agents/skills -maxdepth 2 -name SKILL.md 2>/dev/null | head -30`
- Knowledge base exists: !`ls .context/knowledge/index.md 2>/dev/null | head -1`
- Knowledge index: !`cat .context/knowledge/index.md 2>/dev/null | head -30`

## Instructions

### Step 1: Identify Skills Used

Scan the full conversation for:
- Explicit skill invocations (`/review`, `/test`, `/pr`, etc.)
- CLAUDE.md or AGENTS.md instructions that were followed or should have been followed
- Recurring manual steps that could be codified into a skill

List each skill used with a brief note on what it did in this session.

### Step 2: Extract Learnings per Skill

For each skill identified, analyze:

1. **What worked well** — smooth execution, no issues
2. **Friction points** — where did the user need to iterate, correct, or re-run?
3. **Technical discoveries** — new knowledge about how the underlying tool/script works
4. **Incorrect assumptions** — anything the skill file says that turned out wrong
5. **Missing capabilities** — things the user asked for that the skill did not cover

### Step 3: Classify Each Skill by Location

For each skill with proposed changes, determine where it lives:

1. **Read the SKILL.md** — note its path
2. **Resolve symlinks** — run `readlink -f <path>` to get the real path. Skill directories like `~/.claude/skills/` are often symlinks into a separate repo.
3. **Check if the resolved path is inside the current worktree** — compare against `git rev-parse --show-toplevel`.
4. **Classify:**
   - **Local skill** — resolved path is inside the current worktree. Changes can be applied directly.
   - **External skill** — resolved path falls outside the current worktree. **Never edit external skills directly.** Generate a handoff prompt instead.

### Step 4: Propose Improvements

For each skill with learnings, draft specific changes:

- **Fix factual errors** (wrong library name, outdated API)
- **Add learned patterns** (e.g., "when exporting tables, use proportional column widths")
- **Add missing instructions** (e.g., "can also accept `--input` flag")
- **Add troubleshooting tips** (e.g., "if tests timeout, check for missing DB migration")
- **Flag new skill opportunities** — if a recurring pattern has no skill, detail it in Step 6

Present each proposed change as a before/after diff for the user to review.

### Step 5: Apply or Hand Off

**For local skills:**
1. Ask the user which changes to apply (default: all)
2. Edit the skill files with the approved changes
3. Summarize what was updated

**For external skills:**
Generate a copy-pasteable handoff prompt:

```
## Skill Improvement Handoff: /<skill-name>

**Skill location:** <real path to SKILL.md>
**Source repo:** <git repo that owns the skill>

### Proposed Changes

1. **<change type>: <title>** — <description>
   - Before: <relevant excerpt>
   - After: <proposed replacement>

### Context

<1-3 sentences explaining what session behavior motivated these changes>
```

### Step 6: Check for New Skill Opportunities

Review the session for patterns **not covered by any existing skill** that would benefit from one:

- Multi-step workflows done manually (3+ steps in a predictable pattern)
- Recurring command sequences in consistent order
- User corrections that reveal an undocumented process

**Threshold test** — only propose if at least 2 of:
1. **Repeatable** — would recur in future sessions
2. **Non-trivial** — enough steps or domain knowledge that an agent without the skill would get it wrong
3. **Self-contained** — clear input-to-output process with defined success criteria

For each proposal:
```
**Proposed Skill: /<name>**
- **What it does:** <1-2 sentences>
- **Trigger:** When would a user invoke this?
- **Key steps:** <numbered list>
- **Local or cross-project?** <local (default) or cross-project with rationale>
```

### Step 7: Fix Codebase Gaps & Update Agent Guidance

Review the session for codebase gaps discovered or worked around:

- **Missing or outdated documentation** — CLAUDE.md, AGENTS.md, README
- **Missing tests** — code paths exercised manually but with no test coverage
- **Missing error handling** — failures that surfaced because a code path had no guard
- **Configuration gaps** — env vars, CI steps, linter rules that caused friction

Also check for agent guidance updates:
- New conventions or patterns established during the session
- Corrected assumptions an agent would get wrong by default
- Tool/infra quirks that caused friction
- Process rules that should be followed every time

For each gap:
1. Describe the gap and how it caused friction
2. Propose a specific fix (as a diff when possible)
3. Apply straightforward fixes directly. Pause for approval on risky changes.

### Step 8: Capture Knowledge

**Skip this step if no `.context/knowledge/` directory exists.** Suggest running `/mem init` first.

If a knowledge base exists, review the session for durable knowledge worth preserving:
- Architectural decisions or constraints
- Project-specific patterns (naming conventions, API quirks, deploy procedures)
- Debugging insights that would recur
- Non-obvious tool or dependency behavior

To capture:
1. Read `.context/knowledge/index.md` to see existing topics
2. Identify which topic file the new knowledge belongs in (or propose a new one)
3. Propose additions as diffs
4. Apply after user approval
5. Update the Last Updated date in the index

**Do NOT capture:**
- Anything already in CLAUDE.md or AGENTS.md
- Session-specific transients (file paths being worked on, temp state)
- Operational items (todos, plans in progress)
- Information that duplicates existing knowledge entries
- User preferences (that's what auto-memory is for)

### Step 9: Report

```
# Session Improvement Report

## Skills Used
1. /<skill> — <what it did this session>

## Proposed Improvements

### /<skill> — N changes (local/external)
1. **<change type>: <title>** — <description>

## New Skill Proposals
(if any)

## Codebase Gaps Fixed
1. **<file>: <description>** — <what was fixed>

## Agent Guidance Updated
1. **<file>: <description>** — <what was added>

## Knowledge Captured
- Added to .context/knowledge/<topic>.md: <summary>

## Apply all? (y/n)
```

## Philosophy

Each `/improve` run should leave the system measurably better than it found it. The goal is compounding: each session's learnings reduce friction in all future sessions.

- **Small bets, high frequency** — small targeted changes applied often over large rewrites
- **Escalate, do not patch forever** — if the same skill keeps getting patched, restructure it
- **Close the loop** — check whether past improvements actually helped
