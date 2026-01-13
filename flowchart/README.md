# Ralph Flowchart

## Interactive Flowchart

**[View Interactive Flowchart](https://snarktank.github.io/ralph/)** - Click through to see each step with animations.

The original Ralph implementation includes an interactive React Flow visualization that explains how Ralph works. The Claude Code version follows the same conceptual flow.

## Conceptual Equivalence

The execution flow is **identical** between the Amp and Claude Code versions of Ralph. The only differences are in the specific CLI commands and file conventions used:

| Step | Amp Version | Claude Code Version |
|------|-------------|---------------------|
| Invoke CLI | `amp --dangerously-allow-all` | `claude --dangerously-skip-permissions --print` |
| Read patterns | `AGENTS.md` | `CLAUDE.md` |
| Log thread | `$AMP_CURRENT_THREAD_ID` URL | `iterations/iteration-{N}.md` file |

## Text Flowchart

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

### Memory Persistence

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

## Building the Original Flowchart Locally

If you want to run the original interactive flowchart locally:

```bash
# Clone the original ralph repository
git clone https://github.com/snarktank/ralph.git
cd ralph/flowchart

# Install dependencies
npm install

# Run development server
npm run dev
```

The flowchart is built with React Flow and designed for presentations.
