#!/bin/bash
# Ralph for Claude Code - Long-running AI agent loop
# Usage: ./ralph-cc.sh [max_iterations]

set -e

MAX_ITERATIONS=${1:-10}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD_FILE="$SCRIPT_DIR/prd.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
ITERATIONS_DIR="$SCRIPT_DIR/iterations"
LAST_BRANCH_FILE="$SCRIPT_DIR/.last-branch"

# =============================================================================
# Validation Functions
# =============================================================================

check_prerequisites() {
  local missing=()

  # Check for claude CLI
  if ! command -v claude &> /dev/null; then
    missing+=("claude CLI (install from https://claude.com/claude-code)")
  fi

  # Check for jq
  if ! command -v jq &> /dev/null; then
    missing+=("jq (install with: brew install jq)")
  fi

  if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: Missing required tools:"
    for tool in "${missing[@]}"; do
      echo "  - $tool"
    done
    exit 1
  fi
}

validate_prd() {
  # Check prd.json exists
  if [ ! -f "$PRD_FILE" ]; then
    echo "ERROR: prd.json not found at $PRD_FILE"
    echo ""
    echo "To get started:"
    echo "  1. Copy prd.json.example to prd.json"
    echo "  2. Edit prd.json with your user stories"
    echo "  3. Run ./ralph-cc.sh again"
    exit 1
  fi

  # Validate JSON syntax
  if ! jq empty "$PRD_FILE" 2>/dev/null; then
    echo "ERROR: prd.json is not valid JSON"
    echo ""
    echo "Please fix the JSON syntax in $PRD_FILE"
    echo "You can validate with: jq . $PRD_FILE"
    exit 1
  fi

  # Check for required fields
  local branch_name=$(jq -r '.branchName // empty' "$PRD_FILE")
  if [ -z "$branch_name" ]; then
    echo "ERROR: prd.json is missing required field 'branchName'"
    exit 1
  fi

  local stories_count=$(jq '.userStories | length' "$PRD_FILE")
  if [ "$stories_count" -eq 0 ]; then
    echo "ERROR: prd.json has no user stories"
    exit 1
  fi
}

check_all_stories_pass() {
  local failing_count=$(jq '[.userStories[] | select(.passes == false)] | length' "$PRD_FILE")

  if [ "$failing_count" -eq 0 ]; then
    echo "All stories already pass! Nothing to do."
    echo ""
    echo "Story status:"
    jq -r '.userStories[] | "  [\(if .passes then "PASS" else "FAIL" end)] \(.id): \(.title)"' "$PRD_FILE"
    exit 0
  fi

  echo "Found $failing_count story/stories to implement"
}

# =============================================================================
# Main Script
# =============================================================================

echo "Ralph for Claude Code"
echo "====================="
echo ""

# Run validation checks
echo "Checking prerequisites..."
check_prerequisites
echo "  All prerequisites found"

echo "Validating prd.json..."
validate_prd
echo "  PRD is valid"

echo "Checking story status..."
check_all_stories_pass
echo ""

# Archive previous run if branch changed
if [ -f "$PRD_FILE" ] && [ -f "$LAST_BRANCH_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

  if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
    # Archive the previous run
    DATE=$(date +%Y-%m-%d)
    # Strip "ralph/" prefix from branch name for folder
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    [ -f "$PRD_FILE" ] && cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    [ -d "$ITERATIONS_DIR" ] && cp -r "$ITERATIONS_DIR" "$ARCHIVE_FOLDER/"
    echo "   Archived to: $ARCHIVE_FOLDER"

    # Reset progress file for new run
    echo "## Codebase Patterns" > "$PROGRESS_FILE"
    echo "" >> "$PROGRESS_FILE"
    echo "(Patterns discovered during implementation will be added here)" >> "$PROGRESS_FILE"
    echo "" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
    echo "" >> "$PROGRESS_FILE"
    echo "# Progress Log" >> "$PROGRESS_FILE"
    echo "" >> "$PROGRESS_FILE"

    # Clear iterations directory for new run
    rm -rf "$ITERATIONS_DIR"
  fi
fi

# Track current branch
if [ -f "$PRD_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  if [ -n "$CURRENT_BRANCH" ]; then
    echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
  fi
fi

# Initialize progress file if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "## Codebase Patterns" > "$PROGRESS_FILE"
  echo "" >> "$PROGRESS_FILE"
  echo "(Patterns discovered during implementation will be added here)" >> "$PROGRESS_FILE"
  echo "" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
  echo "" >> "$PROGRESS_FILE"
  echo "# Progress Log" >> "$PROGRESS_FILE"
  echo "" >> "$PROGRESS_FILE"
fi

# Create iterations directory
mkdir -p "$ITERATIONS_DIR"

echo "Starting Ralph for Claude Code - Max iterations: $MAX_ITERATIONS"

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "═══════════════════════════════════════════════════════"
  echo "  Ralph CC Iteration $i of $MAX_ITERATIONS"
  echo "═══════════════════════════════════════════════════════"

  # Generate timestamp for iteration file
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  ITERATION_FILE="$ITERATIONS_DIR/iteration-${i}-${TIMESTAMP}.md"

  # Run claude with the ralph prompt, capturing output to iteration file
  OUTPUT=$(cat "$SCRIPT_DIR/prompt.md" | claude --dangerously-skip-permissions --print 2>&1 | tee "$ITERATION_FILE" | tee /dev/stderr) || true

  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "Ralph completed all tasks!"
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    echo "Iteration logs saved to: $ITERATIONS_DIR"
    exit 0
  fi

  echo "Iteration $i complete. Output saved to: $ITERATION_FILE"
  echo "Continuing..."
  sleep 2
done

echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
echo "Iteration logs available at: $ITERATIONS_DIR"
exit 1
