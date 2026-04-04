# FiveM agent prompts for Claude Code

Drop this folder into your **FiveM server or resource repo**. [Claude Code](https://code.claude.com/) loads **`CLAUDE.md`** from the project root and uses it as the coordinator; specialist behavior lives in **`.claude/agents/*.md`**.

## Structure

```
.claude/
  agents/
    cfx.md          # FXServer runtime, manifest, server.cfg, natives
    qbcore.md       # QBCore framework, jobs, items, player state
    ox.md           # ox_lib, ox_inventory, ox_target, oxmysql
    events.md       # Net events, commands, keymaps, rate limiting
    nui.md          # CEF browser UI, NUI callbacks, React/Vue
    pm.md           # End-to-end verification / PM sign-off
    bug-review.md   # Common FiveM bugs and fixes
    test.md         # Lua + Vitest / JS test expansion
  settings.json     # Optional Claude Code project settings
CLAUDE.md           # Coordinator (read automatically when at repo root)
```

## Usage

Describe what you want in Claude Code. The coordinator in `CLAUDE.md` picks the right agents and **reads** the matching prompt files before implementing each layer.

Examples:

```
Build a mechanic job resource with ox_target interactions and a React tablet NUI
```

To force a specific lens for one turn, **@-mention** the agent file, e.g. `@.claude/agents/ox.md`, then ask your question.

## Pipeline

When work is sequential, follow the phase order in `CLAUDE.md` (manifest/events → server/qb+ox → NUI → tests → bug-review → pm sign-off). Skip phases that do not apply.

## TODO handoff convention

Agents mark cross-domain gaps in code comments:

- `-- TODO(qbcore): ...`
- `-- TODO(ox): ...`
- `-- TODO(cfx): ...`

Resolve these when merging layers.
