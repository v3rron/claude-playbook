---
name: review-prd
description: Interactive PRD/spike/design doc review. Use when the user shares a doc link and wants to review it collaboratively, or explicitly asks to review a PRD. Fetches the doc, walks through it section by section, and builds inline comments through Q&A.
---

# PRD Review Workflow

This is an interactive, structured review process. Do NOT dump all feedback at once. Work through it step by step with the user.

## Phase 1: Fetch and Summarize

1. Fetch the doc via the appropriate means (an MCP doc-fetch tool, a URL fetch, or pasted content)
2. Present a **short overview** (2-3 sentences: what is this doc, what is it proposing)
3. Present a **section-by-section summary** — each section gets 1-3 sentences max
4. Wait for the user to ask questions before proceeding

## Phase 2: Interactive Q&A

- The user asks questions, you answer based on the doc
- If the doc is unclear or doesn't address something: **flag it immediately** and ask "Should we leave a comment asking about this?"
- If the user says yes: note it internally as a pending comment, do NOT post anything, continue the conversation
- If you notice the user is confused about something the doc already covers: point them to the exact section
- If you notice the user is confused and the doc is genuinely unclear: say so and ask if it should be a comment
- Keep answers short and direct
- When referencing doc content, quote the exact text so the user can verify

## Phase 3: Compile Comments

Only when the user is ready (they'll say so, or you can ask after Q&A winds down), present:

### Inline Comments Table

| # | Comment | Cmd+F text |
|---|---------|------------|
| 1 | The comment text | Exact searchable text from the doc |

Rules for comments:
- **Collaborative tone** — questions and observations, not directives
- Frame as "could we...", "what if...", "I noticed...", "is this intentionally..."
- Acknowledge existing work when suggesting changes
- Never sound like you're telling the author what to do

### Summary Comment (for end of doc)

Structure as a sandwich:
1. **Acknowledge the work** — what's strong, what stood out
2. **Overall feedback** — synthesize all inline comments into high-level themes
3. **Positive close** — reassuring, forward-looking

## Important Reminders

- Keep things concise, direct, and structured. Use bullet points.
- Never dump walls of text. If a section is complex, break it into smaller pieces.
- If the user seems to lose context, re-anchor them: "We're looking at section X, which is about Y"
- This is a collaboration review, not a top-down critique. The author is a teammate.
- Re-fetch the doc if the user asks to check for updates
