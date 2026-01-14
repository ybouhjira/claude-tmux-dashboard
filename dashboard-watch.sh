#!/bin/bash
# Dashboard Watcher - Monitors dashboard file and renders it
# Claude writes to ~/.claude/dashboard.json, this script renders it

DASHBOARD_FILE="$HOME/.claude/dashboard.json"
REFRESH_INTERVAL=1

# Create initial dashboard file if not exists
if [ ! -f "$DASHBOARD_FILE" ]; then
    cat > "$DASHBOARD_FILE" << 'EOF'
{
  "project": "Waiting...",
  "branch": "-",
  "status": "idle",
  "progress": 0,
  "ci": "unknown",
  "changes": { "added": 0, "deleted": 0, "modified": 0 },
  "ahead": 0,
  "behind": 0,
  "stash": 0,
  "commits": [],
  "prs": [],
  "issues": [],
  "message": "Waiting for Claude Code to start...",
  "tasks": []
}
EOF
fi

# Main render loop
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while true; do
    clear
    "$SCRIPT_DIR/dashboard-render.sh"
    sleep $REFRESH_INTERVAL
done
