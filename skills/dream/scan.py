#!/usr/bin/env python3
"""Read-only mechanical scan for a Claude Code auto-memory directory.

Usage: scan.py <memory-dir>

Reports (never fixes):
  FRONTMATTER   missing frontmatter / name / description / type
  LEGACY-FORMAT top-level `type:` with no `metadata:` block (normalize to spec)
  SLUG          frontmatter name != filename stem (stem is canonical)
  INDEX-DEAD    MEMORY.md entry pointing at a missing file
  UNINDEXED     memory file absent from MEMORY.md
  BROKEN-LINK   [[slug]] matching neither a filename stem nor any name:

Exit 0 when clean, 1 when issues found.
"""
import os
import re
import sys


def frontmatter(text):
    m = re.match(r"^---\n(.*?)\n---", text, re.S)
    return m.group(1) if m else None


def main(memdir):
    os.chdir(memdir)
    files = sorted(f for f in os.listdir(".") if f.endswith(".md") and f != "MEMORY.md")
    stems = {os.path.splitext(f)[0] for f in files}
    names, issues = {}, 0

    def report(kind, detail):
        nonlocal issues
        print(f"{kind}: {detail}")
        issues += 1

    for f in files:
        text = open(f).read()
        fm = frontmatter(text)
        if fm is None:
            report("FRONTMATTER", f"{f} (no frontmatter block)")
            continue
        name = re.search(r'^name:\s*"?([^"\n]+)"?\s*$', fm, re.M)
        names[f] = name.group(1).strip() if name else None
        nested_type = re.search(r"^\s+type:\s*\S+", fm, re.M)
        legacy_type = re.search(r"^type:\s*\S+", fm, re.M)
        missing = []
        if not name:
            missing.append("name")
        if not re.search(r"^description:", fm, re.M):
            missing.append("description")
        if not nested_type and not legacy_type:
            missing.append("type")
        if missing:
            report("FRONTMATTER", f"{f} missing {missing}")
        if legacy_type and not nested_type:
            report("LEGACY-FORMAT", f"{f} (top-level type:, no metadata block)")
        if name and name.group(1).strip() != os.path.splitext(f)[0]:
            report("SLUG", f"{f} name={name.group(1).strip()}")

    idx = open("MEMORY.md").read() if os.path.exists("MEMORY.md") else ""
    idx_targets = re.findall(r"\]\(([^)]+\.md)\)", idx)
    for t in idx_targets:
        if t not in files:
            report("INDEX-DEAD", t)
    for f in files:
        if f not in idx_targets:
            report("UNINDEXED", f)

    namevals = {n for n in names.values() if n}
    for f in files:
        for slug in re.findall(r"\[\[([^\]|#]+)", open(f).read()):
            slug = slug.strip()
            if slug not in stems and slug not in namevals:
                report("BROKEN-LINK", f"{f}: [[{slug}]]")

    print(f"\n{'CLEAN' if issues == 0 else f'{issues} issues'} — "
          f"{len(files)} files, {len(idx_targets)} index entries")
    return 1 if issues else 0


if __name__ == "__main__":
    if len(sys.argv) != 2 or not os.path.isdir(sys.argv[1]):
        sys.exit(__doc__.strip())
    sys.exit(main(sys.argv[1]))
