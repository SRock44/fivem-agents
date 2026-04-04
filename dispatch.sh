#!/usr/bin/env bash
# dispatch.sh - Run FiveM specialist agents in parallel
# Usage: ./dispatch.sh <pattern> "<task description>" [file context...]
#
# Patterns:
#   full     - Implementation: cfx, qbcore, ox, events, nui
#   server   - Server-side: cfx + qbcore + ox + events
#   client   - Client-side: cfx + events + nui
#   backend  - Data layer: qbcore + ox
#   verify   - PM master review only
#   bugs     - bug-review only
#   tests    - test agent only
#   release  - pm + bug-review + test (post-implementation gate)
#   custom   - Specify agents: ./dispatch.sh custom "task" cfx,qbcore

set -euo pipefail

AGENTS_DIR=".claude/agents"
OUT_DIR="/tmp/fivem-agents"
mkdir -p "$OUT_DIR"

PATTERN="${1:?Usage: ./dispatch.sh <pattern> \"<task>\" [agents if custom]}"
TASK="${2:?Provide a task description}"
CUSTOM_AGENTS="${3:-}"

# Resolve agent list from pattern
case "$PATTERN" in
  full)    AGENTS="cfx qbcore ox events nui" ;;
  server)  AGENTS="cfx qbcore ox events" ;;
  client)  AGENTS="cfx events nui" ;;
  backend) AGENTS="qbcore ox" ;;
  verify)  AGENTS="pm" ;;
  bugs)    AGENTS="bug-review" ;;
  tests)   AGENTS="test" ;;
  release) AGENTS="pm bug-review test" ;;
  custom)  AGENTS="${CUSTOM_AGENTS//,/ }" ;;
  *)
    echo "Unknown pattern: $PATTERN"
    echo "Patterns: full, server, client, backend, verify, bugs, tests, release, custom"
    exit 1
    ;;
esac

echo "=== FiveM Agent Dispatch ==="
echo "Pattern: $PATTERN"
echo "Agents:  $AGENTS"
echo "Task:    $TASK"
echo ""

PIDS=""

for AGENT in $AGENTS; do
  PROMPT_FILE="$AGENTS_DIR/$AGENT.md"
  if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "[WARN] Agent file not found: $PROMPT_FILE -- skipping"
    continue
  fi

  echo "[START] $AGENT agent..."
  (
    claude --print -p "$(cat "$PROMPT_FILE")

TASK:
$TASK" > "$OUT_DIR/$AGENT-result.md" 2>"$OUT_DIR/$AGENT-error.log"
    echo "[DONE]  $AGENT agent"
  ) &
  PIDS="$PIDS $!"
done

echo ""
echo "Waiting for all agents to complete..."
FAIL=0
for PID in $PIDS; do
  wait "$PID" || FAIL=$((FAIL + 1))
done

echo ""
echo "=== Results ==="
for AGENT in $AGENTS; do
  RESULT="$OUT_DIR/$AGENT-result.md"
  if [[ -f "$RESULT" && -s "$RESULT" ]]; then
    echo ""
    echo "--- $AGENT ---"
    cat "$RESULT"
  else
    ERR="$OUT_DIR/$AGENT-error.log"
    echo ""
    echo "--- $AGENT [FAILED] ---"
    [[ -f "$ERR" ]] && cat "$ERR"
  fi
done

if [[ $FAIL -gt 0 ]]; then
  echo ""
  echo "[WARN] $FAIL agent(s) failed. Check $OUT_DIR/*-error.log"
fi
