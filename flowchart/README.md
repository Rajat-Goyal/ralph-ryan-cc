# Ralph for Claude Code - Flowchart

## Visual Flowchart

The main README contains a **Mermaid diagram** that GitHub renders automatically.

**[View Flowchart in README](../README.md#flowchart)**

## ASCII Flowchart

For terminal/text environments:

```
┌─────────────────────────────────────────────────────────────────┐
│                      RALPH EXECUTION FLOW                        │
└─────────────────────────────────────────────────────────────────┘

                            ┌─────────┐
                            │  START  │
                            └────┬────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │  Check Prerequisites   │
                    │  (claude CLI, jq)      │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │   Validate prd.json    │
                    │   (exists, valid JSON) │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │  All stories pass?     │
                    └───────────┬────────────┘
                                │
                    ┌───────────┴───────────┐
                    │ YES                   │ NO
                    ▼                       ▼
            ┌───────────────┐     ┌─────────────────────┐
            │     EXIT      │     │  Archive if branch  │
            │  (nothing to  │     │     changed         │
            │     do)       │     └──────────┬──────────┘
            └───────────────┘                │
                                             ▼
                              ┌──────────────────────────┐
                              │   FOR each iteration     │
                              │   (1 to MAX_ITERATIONS)  │
                              └────────────┬─────────────┘
                                           │
                                           ▼
                              ┌──────────────────────────┐
                              │  Spawn fresh Claude Code │
                              │  instance with prompt.md │
                              └────────────┬─────────────┘
                                           │
                                           ▼
                              ┌──────────────────────────┐
                              │  Claude Code implements  │
                              │  ONE story:              │
                              │  1. Read prd.json        │
                              │  2. Pick highest priority│
                              │     failing story        │
                              │  3. Implement it         │
                              │  4. Run quality checks   │
                              │  5. Commit if passing    │
                              │  6. Update prd.json      │
                              │  7. Log to progress.txt  │
                              └────────────┬─────────────┘
                                           │
                                           ▼
                              ┌──────────────────────────┐
                              │  Save output to          │
                              │  iterations/iteration-N  │
                              └────────────┬─────────────┘
                                           │
                                           ▼
                              ┌──────────────────────────┐
                              │  Check for COMPLETE      │
                              │  promise signal          │
                              └────────────┬─────────────┘
                                           │
                              ┌────────────┴────────────┐
                              │ YES                     │ NO
                              ▼                         ▼
                    ┌─────────────────┐     ┌─────────────────────┐
                    │  EXIT SUCCESS   │     │  Continue to next   │
                    │  All tasks done │     │     iteration       │
                    └─────────────────┘     └──────────┬──────────┘
                                                       │
                                                       │ (loop)
                                                       ▼
                                           ┌─────────────────────┐
                                           │  Max iterations     │
                                           │  reached?           │
                                           └──────────┬──────────┘
                                                      │
                                           ┌──────────┴──────────┐
                                           │ YES                 │ NO
                                           ▼                     │
                                   ┌───────────────┐             │
                                   │  EXIT FAILURE │             │
                                   │  (incomplete) │             │
                                   └───────────────┘             │
                                                                 │
                                                       (back to iteration loop)
```

## Key Concepts

### Fresh Context Each Iteration

Each iteration spawns a **completely new Claude Code instance**. There is no memory carried over except:
- Git history (commits)
- `progress.txt` (learnings)
- `prd.json` (story status)
- `iterations/` (conversation exports)

### Memory Persistence Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    MEMORY BETWEEN ITERATIONS                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────────┐   │
│   │  Git Repo   │   │ progress.txt│   │   prd.json      │   │
│   │  (commits)  │   │ (learnings) │   │   (status)      │   │
│   └─────────────┘   └─────────────┘   └─────────────────┘   │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              iterations/                             │   │
│   │   iteration-1.md  iteration-2.md  iteration-3.md    │   │
│   │   (full conversation exports for reference)          │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Architecture Origin

This implements the [Ralph pattern](https://ghuntley.com/ralph/) by Geoffrey Huntley, ported to Claude Code from [snarktank/ralph](https://github.com/snarktank/ralph).
