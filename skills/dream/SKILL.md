---
name: dream
description: Use when the user wants a memory cleanup or agent-setup audit — stale or conflicting memories, broken [[links]], orphaned memory files, MEMORY.md index drift, dead paths in CLAUDE.md/settings/hooks, or installed skills drifted from their source repo. Targets Claude Code auto-memory and ~/.claude config.
---

# Dream

Maintenance sweep for Claude Code auto-memory and agent config — garbage collection + defrag.

## Phase 0 — Scope

Resolve the project memory dir: the cwd path with `/` replaced by `-`, under `~/.claude/projects/<encoded>/memory/`. Abort cleanly if it doesn't exist. Then ask the user (AskUserQuestion) which scope to dream about:

1. **Project memory** — just this project's memory dir
2. **+ project config** — adds the project `.claude/` tree (CLAUDE.md, rules/, settings, hooks) and any workspace-parent CLAUDE.md in the loaded chain
3. **+ everything** — adds global `~/.claude/`: CLAUDE.md and CLAUDE.local.md, settings.json hooks, installed skills vs their source repo, keybindings, stale `plans/`, `projects/` dirs for deleted workspaces, other projects' memory dirs

Whatever the tier, load the effective config chain (global CLAUDE.md → CLAUDE.local.md → workspace CLAUDE.md → project CLAUDE.md + rules/) as cross-check context for the memory scan.

## Phase 1 — Scan (read-only)

Memory (every tier) — run the bundled scanner for the mechanical categories (it knows both frontmatter formats); judgment categories below still require reading content:

```bash
python3 <skill-dir>/scan.py <memory-dir>
```

- **Index drift** — files missing from `MEMORY.md`; `MEMORY.md` entries pointing at missing files
- **Broken `[[links]]`** — slug matches neither a filename stem nor any frontmatter `name:`
- **Slug mismatch** — frontmatter `name:` ≠ filename stem
- **Frontmatter drift** — missing `name`/`description`/`type`. Two formats exist: spec (nested `metadata:` → `type:`) and legacy (top-level `type:`, no `metadata:` block). A top-level `type:` is not "missing" — it's legacy drift to normalize into the `metadata:` block
- **Duplicates** — two files covering the same fact
- **Conflicts & staleness** — contradictions between memories, superseded facts, relative dates never made absolute
- **Config cross-check** — memories restating or contradicting the loaded CLAUDE.md chain

Project config (tier 2+):

- File references and `@`-includes pointing at missing paths
- Instructions referencing removed skills, tools, or directories
- `rules/` files contradicting CLAUDE.md

Global (tier 3):

- `settings.json` hooks/commands pointing at missing scripts
- Skills/config: verify installed paths are symlinks into the source repo as expected; flag orphaned non-symlinked entries and uncommitted changes in the source repo (`git status`); broken cross-skill references
- Stale `plans/` files; `projects/` dirs whose workspace no longer exists; other projects' memory dirs (same memory checks)

## Phase 2 — Auto-fix (mechanical)

Fix without asking, reporting each change: sync the index, repair link slugs, align `name:` to the filename stem (the filename stem is canonical), fill missing frontmatter from the file's content.

Renaming `name:` values breaks any `[[link]]` that resolved via the old value — always re-run the link check after renames and fix the newly exposed slugs before declaring the tier clean.

## Phase 3 — Judgment (confirm first)

Present remaining findings grouped — duplicates / conflicts / stale / config contradictions / deletions — with a recommended action each. Never delete, merge, or rewrite facts or config without explicit confirmation. Skill and config fixes are edits to the source repo (installed paths are symlinks into it) and belong in a commit there.

## Phase 4 — Verify

Re-run the Phase 1 scan for the selected scope. Mechanical categories must come back clean. Summarize: fixed / confirmed-changed / deferred.

## Principles

- Prefer merge over delete; keep the richer file and fold in unique content
- Filename stem is the canonical slug — links and the index resolve by it
- Config is upstream of memory: on conflict, config wins unless the user says otherwise
- Never invent facts to resolve a conflict — ask
- Verify every judgment finding against the actual file (and against reality — run the command, check the code) before recommending it; delegated scans over-flag, especially "config restatement"
- Never touch plugin-managed dirs, caches, or credential/secret files
