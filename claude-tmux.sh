#!/bin/bash
# Claude Code + tmux Dashboard Launcher
# Creates a split-pane session with Claude Code + live dashboard

SESSION_NAME="claude-dash"
DASHBOARD_PANE="dashboard"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if session exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${YELLOW}Session '$SESSION_NAME' already exists. Attaching...${NC}"
    tmux attach -t "$SESSION_NAME"
    exit 0
fi

# Create new session with Claude Code in main pane
echo -e "${GREEN}Creating tmux session: $SESSION_NAME${NC}"
tmux new-session -d -s "$SESSION_NAME" -n "main"

# Split horizontally (dashboard on right, 35% width)
tmux split-window -h -t "$SESSION_NAME:main" -p 35

# Name the panes for easy reference
tmux select-pane -t "$SESSION_NAME:main.0" -T "claude"
tmux select-pane -t "$SESSION_NAME:main.1" -T "dashboard"

# Start dashboard watcher in right pane
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmux send-keys -t "$SESSION_NAME:main.1" "$SCRIPT_DIR/dashboard-watch.sh" C-m

# Focus on Claude pane (left)
tmux select-pane -t "$SESSION_NAME:main.0"

# Start Claude Code in left pane (with preferred flags)
tmux send-keys -t "$SESSION_NAME:main.0" "claude --dangerously-skip-permissions --model opus" C-m

# Attach to session
tmux attach -t "$SESSION_NAME"
