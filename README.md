# FiveM Parallel Agent Swarm for Claude Code

Drop this into your FiveM server repo root. Five specialist agents run in parallel via `claude --print`.

## Structure

```
.claude/
  agents/
    cfx.md        # FXServer runtime, manifest, server.cfg, natives
    qbcore.md     # QBCore framework, jobs, items, player state
    ox.md         # ox_lib, ox_inventory, ox_target, oxmysql
    events.md     # Net events, commands, keymaps, rate limiting
    nui.md        # CEF browser UI, NUI callbacks, React/Vue
  settings.json   # Auto-allow subagent spawning
CLAUDE.md         # Coordinator prompt (claude reads this automatically)
dispatch.sh       # CLI for parallel dispatch
```

## Usage

### Inside Claude Code (interactive)

Just describe what you want. The coordinator (CLAUDE.md) knows the roster and will dispatch agents:

```
> Build a mechanic job resource with ox_target interactions and a React tablet NUI
```

### Via dispatch.sh (CLI)

```bash
# All agents in parallel
./dispatch.sh full "Build a gas station robbery resource with progress bars and police alerts"

# Server-side only
./dispatch.sh server "Add a fishing job with rod item requirement and fish item rewards"

# Client + NUI
./dispatch.sh client "Build a phone app NUI with contact list and messaging"

# Pick specific agents
./dispatch.sh custom "Add ox_target options to all ATM props" cfx,ox,events
```

### Direct subagent call

```bash
claude --print -p "$(cat .claude/agents/ox.md)

TASK: Register a stash at coords 123.0, 456.0, 78.0 with 50 slots for mechanic job only"
```

## Pipeline Order

When agents need each other's output, chain them:

```
Phase 1 (parallel): cfx (manifest) + events (contract design)
Phase 2 (parallel): qbcore (server logic) + ox (library calls)
Phase 3:            nui (if browser UI needed)
Phase 4:            coordinator merges and verifies
```

## TODO Handoff Convention

Agents mark cross-domain dependencies as comments:
- `-- TODO(qbcore): verify Player.Functions export name`
- `-- TODO(ox): check ox_inventory metadata format`
- `-- TODO(cfx): add to server.cfg ensure order`

The coordinator (or you) resolves these after merging.
