# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## 🛠️ Tool Preferences

### Gemini CLI (Default for Q&A)

**Priority:** Use Gemini CLI first for any question or general task.

```bash
PATH="/usr/sbin:/usr/bin:/bin:/sbin:$PATH" gemini "Your prompt here"
```

**Fallback:** If Gemini CLI fails, use built-in model provider (`bailian/qwen3.5-plus`).

**Known Issues:**
- Don't specify `--model gemini-2.0-flash` explicitly (thinking config bug)
- Use default model selection (let CLI pick)
- PATH must include `/usr/sbin` for `sysctl`

**Auth:** OAuth personal (zhanglpg@gmail.com) — already configured
