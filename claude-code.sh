#!/bin/bash
# Claude Code CLI Wrapper for Coding Agent
# Usage: ./claude-code.sh [plan|code|review] "your task description"

set -e

WORKSPACE="/Users/lipingzhang/.openclaw/workspace-coding"
CLAUDE_CMD="/Users/lipingzhang/.local/bin/claude"
MODEL="sonnet"

# Parse mode
MODE="${1:-plan}"
shift || true

# Get task prompt
PROMPT="$*"

if [ -z "$PROMPT" ]; then
    echo "Usage: $0 [plan|code|review|chat] \"your task description\""
    echo ""
    echo "Modes:"
    echo "  plan   - Create a detailed plan (permission-mode: plan)"
    echo "  code   - Implement code changes (permission-mode: acceptEdits)"
    echo "  review - Review code (permission-mode: default)"
    echo "  chat   - Interactive chat (no -p flag)"
    exit 1
fi

# Set permission mode based on task type
case "$MODE" in
    plan)
        PERMISSION_MODE="plan"
        ;;
    code|implement)
        PERMISSION_MODE="acceptEdits"
        ;;
    review|analyze)
        PERMISSION_MODE="default"
        ;;
    chat|interactive)
        # Interactive mode - don't use -p
        cd "$WORKSPACE"
        exec "$CLAUDE_CMD" --model "$MODEL" "$PROMPT"
        ;;
    *)
        PERMISSION_MODE="default"
        ;;
esac

# Change to workspace directory
cd "$WORKSPACE"

# Execute Claude Code CLI
echo "🤖 Running Claude Code CLI (mode: $MODE, model: $MODEL)..."
echo "Workspace: $WORKSPACE"
echo "---"

exec "$CLAUDE_CMD" \
    -p \
    --model "$MODEL" \
    --permission-mode "$PERMISSION_MODE" \
    --workspace "$WORKSPACE" \
    "$PROMPT"
