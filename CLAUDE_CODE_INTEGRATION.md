# Claude Code CLI Integration Plan

## Goal
Configure the coding agent to always use Claude Code CLI for planning and executing coding tasks.

## Research Summary

### Claude Code CLI Capabilities
- **Location:** `/Users/lipingzhang/.local/bin/claude`
- **Modes:**
  - Interactive (default): `claude` - starts interactive session
  - Non-interactive: `claude -p "prompt"` - prints response and exits
  - Resume session: `claude -c` or `claude -r <session-id>`
  - With specific model: `claude --model sonnet` or `claude --model opus`

### Key Options for Integration
- `-p, --print`: Print response and exit (perfect for CLI integration)
- `--model <model>`: Specify model (sonnet, opus, etc.)
- `--workspace <dir>`: Set working directory
- `--permission-mode <mode>`: Control permissions (default, plan, acceptEdits, bypassPermissions)
- `--system-prompt <prompt>`: Custom system prompt
- `--append-system-prompt <prompt>`: Append to default system prompt

## Implementation Strategy

### Option 1: Direct CLI Invocation (Recommended)
Configure coding agent to invoke `claude -p` directly via exec for all coding tasks.

**Pros:**
- Simple, direct integration
- Full control over prompts and context
- No additional runtime dependencies

**Cons:**
- Requires careful context management
- Need to handle session state manually

### Option 2: ACP Runtime with Claude Model
Configure ACP runtime to use Claude models via Anthropic API.

**Pros:**
- Native OpenClaw integration
- Better session management

**Cons:**
- ACP runtime not currently configured
- Uses API directly, not Claude Code CLI features

## Implementation Plan

### Phase 1: Configure Coding Agent Defaults
1. Update coding agent's `AGENTS.md` with Claude Code CLI workflow
2. Create helper script for Claude Code CLI invocation
3. Set default model to Claude Sonnet

### Phase 2: Create Integration Script
1. Create `/Users/lipingzhang/.openclaw/workspace-coding/.claudeforce` or similar
2. Script wraps `claude -p` with proper context and permissions
3. Handle workspace directory, system prompts, and output parsing

### Phase 3: Update Agent Configuration
1. Set coding agent to use Claude Code CLI by default
2. Configure permission mode for safe execution
3. Add verification tests

## Configuration Files to Create/Update

1. **workspace-coding/AGENTS.md** - Add Claude Code CLI workflow rules
2. **workspace-coding/claude-code-wrapper.sh** - Helper script
3. **workspace-coding/.claude/settings.json** - Claude Code settings (if needed)

## Verification Steps

1. Test basic Claude Code CLI invocation
2. Test with coding task
3. Verify output parsing works
4. Test permission handling
5. Confirm session state management

## Next Steps

Implement Phase 1-3 and verify the integration works end-to-end.
