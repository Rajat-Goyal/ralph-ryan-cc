# PRD Skill

## Overview

The PRD (Product Requirements Document) skill helps generate structured PRDs suitable for Ralph autonomous execution.

## Claude Code Usage

This skill is available via the `ralph-ryan` Claude Code skill:

```
use ralph-ryan skill, write prd for [feature description]
```

The skill will:
1. Ask 3-5 clarifying questions with lettered options
2. Generate a structured PRD with user stories
3. Save to `.claude/ralph-ryan/prd.md`

## Standalone Usage

If you need standalone skill files for customization, you can create them here. The skill should follow Claude Code plugin conventions.

## See Also

- [ralph-ryan skill documentation](https://github.com/anthropics/claude-code)
- Parent directory `README.md` for Ralph overview
