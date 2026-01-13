# Ralph Skill

## Overview

The Ralph skill converts markdown PRDs to JSON format and manages the Ralph execution loop.

## Claude Code Usage

This skill is available via the `ralph-ryan` Claude Code skill:

```
# Convert PRD to JSON
use ralph-ryan skill, prepare files

# Run the Ralph loop
use ralph-ryan skill, run
```

## Standalone Usage

For standalone bash execution, use `ralph-cc.sh` in the parent directory:

```bash
./ralph-cc.sh [max_iterations]
```

If you need standalone skill files for customization, you can create them here. The skill should follow Claude Code plugin conventions.

## See Also

- [ralph-ryan skill documentation](https://github.com/anthropics/claude-code)
- Parent directory `README.md` for Ralph overview
- `ralph-cc.sh` for the bash execution loop
