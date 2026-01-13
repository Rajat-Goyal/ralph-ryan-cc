# Ralph for Claude Code - Agent Instructions

## Overview

Ralph is an autonomous AI agent loop that runs Claude Code repeatedly until all PRD items are complete. Each iteration is a fresh Claude Code instance with clean context.

This is the Claude Code version of Ralph, converted from the original Amp-based implementation.

## Commands

```bash
# Run Ralph (from this directory with prd.json)
./ralph-cc.sh [max_iterations]

# Example: Run with 10 iterations max
./ralph-cc.sh 10

# Check script syntax
bash -n ralph-cc.sh
```

## Key Files

| File | Purpose |
|------|---------|
| `ralph-cc.sh` | The bash loop that spawns fresh Claude Code instances |
| `prompt.md` | Instructions given to each Claude Code instance |
| `prd.json` | Your PRD file (copy from `prd.json.example`) |
| `prd.json.example` | Example PRD format |
| `progress.txt` | Append-only log of completed work |
| `iterations/` | Conversation exports from each iteration |

## Iteration Loop Behavior

1. Script reads `prd.json` and finds the highest priority story with `passes: false`
2. Spawns a fresh Claude Code instance with `prompt.md` as input
3. Claude Code implements ONE story, commits, updates PRD
4. Output is captured to `iterations/iteration-{N}-{timestamp}.md`
5. Loop checks for `<promise>COMPLETE</promise>` signal
6. If not complete, starts next iteration

## Conversation Export Conventions

Each iteration's output is saved to `iterations/`:
- Pattern: `iteration-{N}-{timestamp}.md`
- Contains full conversation log
- Referenced in `progress.txt` for context continuity
- Archived with PRD when branch changes

## Patterns for CLAUDE.md Updates

When implementing stories, update nearby CLAUDE.md files with:
- API patterns or conventions specific to that module
- Gotchas or non-obvious requirements
- Dependencies between files
- Testing approaches for that area

**Do NOT add:**
- Story-specific implementation details
- Temporary debugging notes

## Progress Log Format

The `progress.txt` file uses this format:
```
## Codebase Patterns
- [Reusable patterns discovered]

---

# Progress Log

## [Date/Time] - [Story ID]
Iteration Export: iterations/iteration-{N}-{timestamp}.md
- What was implemented
- Files changed
- **Key Decisions Made:**
  - [Rationale for decisions]
- **Learnings:**
  - [Patterns and gotchas]
---
```

## Differences from Amp Version

| Aspect | Amp | Claude Code |
|--------|-----|-------------|
| CLI | `amp --dangerously-allow-all` | `claude --dangerously-skip-permissions --print` |
| Pattern docs | `AGENTS.md` | `CLAUDE.md` |
| Thread refs | `$AMP_CURRENT_THREAD_ID` URLs | `iterations/` file exports |
| Browser testing | `dev-browser` skill | Playwright MCP |
