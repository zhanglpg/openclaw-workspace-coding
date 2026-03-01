# Coding Agent - Simple Usage

## Direct Claude Code CLI (Recommended)

```bash
cd /Users/lipingzhang/.openclaw/workspace-coding

# Planning
claude -p "Plan: create a weather API client" --model sonnet --permission-mode plan

# Implementation
claude -p "Implement: create a weather API client with caching" --model sonnet --permission-mode acceptEdits

# Quick tasks
claude -p "Create a hello.txt file" --model sonnet
```

## Via acpx (Alternative)

```bash
cd /Users/lipingzhang/.openclaw/workspace-coding
acpx claude exec "Your task here"
```

## Helper Script

```bash
./claude-code.sh plan "task description"
./claude-code.sh code "task description"
./claude-code.sh review "task description"
```

## From Main Agent

Just ask the main agent (Yoda) to delegate:
- "Delegate to coding agent: create a REST API client"
- "Use Claude Code CLI to implement X"

The main agent will invoke Claude Code CLI via exec on your behalf.
