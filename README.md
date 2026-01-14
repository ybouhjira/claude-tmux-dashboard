# 📊 Claude Tmux Dashboard

```
╭──────────────────────────────────────────────────────────╮
│              📊 CLAUDE CODE DASHBOARD                    │
├──────────────────────────────────────────────────────────┤
│  📦 my-project  ⎇ main                                   │
├──────────────────────────────────────────────────────────┤
│  ⚡ Working              🟢 CI: PASS                      │
├──────────────────────────────────────────────────────────┤
│  ████████████████████░░░░░░░░  75%                       │
├──────────────────────────────────────────────────────────┤
│  +3 -1 M2 | ^2 v0 | 0 stash                             │
├──────────────────────────────────────────────────────────┤
│  📝 COMMITS                                               │
│   • feat: add dashboard renderer                         │
│   • fix: update script paths                             │
╰──────────────────────────────────────────────────────────╯
```

A beautiful live dashboard for [Claude Code](https://claude.ai/code) that displays git status, CI results, and project info in a tmux split-pane.

## ✨ Features

- 🎨 **Beautiful TUI** - Color-coded status indicators and progress bars
- ⚡ **Real-time Updates** - Dashboard refreshes every second
- 📊 **Git Integration** - Shows branch, commits, changes, stash count
- 🔄 **CI Status** - Displays GitHub Actions results
- 📋 **Issue Tracking** - Lists open PRs and issues
- 🎯 **Task Progress** - Shows current Claude Code tasks
- 🖥️ **Tmux Split-Pane** - Claude Code on left, dashboard on right

## 📦 Installation

### One-line Install

```bash
curl -fsSL https://raw.githubusercontent.com/ybouhjira/claude-tmux-dashboard/main/install.sh | bash
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/ybouhjira/claude-tmux-dashboard.git
cd claude-tmux-dashboard

# Make scripts executable
chmod +x *.sh

# Optional: Add to PATH
mkdir -p ~/bin
ln -s "$(pwd)/claude-tmux.sh" ~/bin/claude-tmux
```

## 🚀 Usage

### Start Claude Code with Dashboard

```bash
./claude-tmux.sh
```

This creates a tmux session with:
- **Left pane (65%)**: Claude Code
- **Right pane (35%)**: Live dashboard

### Update Dashboard from Claude

Claude Code can update the dashboard by writing to `~/.claude/dashboard.json`:

```bash
# Full git status update
./dashboard-update.sh --full

# Update specific fields
./dashboard-update.sh status "working"
./dashboard-update.sh message "Analyzing code..."
./dashboard-update.sh progress 75

# Update tasks
./dashboard-update.sh tasks '[{"status":"completed","content":"Setup project"}]'
```

### Dashboard Data Format

The dashboard reads from `~/.claude/dashboard.json`:

```json
{
  "project": "my-project",
  "branch": "main",
  "status": "working",
  "progress": 75,
  "ci": "success",
  "changes": { "added": 3, "deleted": 1, "modified": 2 },
  "ahead": 2,
  "behind": 0,
  "stash": 0,
  "commits": ["feat: add feature", "fix: bug"],
  "prs": [123, 456],
  "issues": [789],
  "message": "Analyzing code...",
  "tasks": [
    {"status": "completed", "content": "Setup project"},
    {"status": "in_progress", "content": "Implement feature"}
  ]
}
```

## 🎨 Status Indicators

| Icon | Status | Meaning |
|------|--------|---------|
| ⚡ | Working | Claude is actively working |
| ✅ | Success | Task completed successfully |
| ❌ | Error | Something went wrong |
| 🤔 | Thinking | Claude is analyzing |
| 💤 | Idle | Waiting for input |

| CI Icon | Status |
|---------|--------|
| 🟢 | Pass |
| 🔴 | Fail |
| 🟡 | Running |
| ⚪ | Unknown |

## ⚙️ Configuration

### Dashboard Location

By default, the dashboard reads from `~/.claude/dashboard.json`. To change this, edit the `DASHBOARD_FILE` variable in:
- `dashboard-render.sh`
- `dashboard-update.sh`
- `dashboard-watch.sh`

### Refresh Interval

Change the refresh rate in `dashboard-watch.sh`:

```bash
REFRESH_INTERVAL=1  # seconds (default: 1)
```

### Tmux Pane Size

Adjust the dashboard pane width in `claude-tmux.sh`:

```bash
tmux split-window -h -t "$SESSION_NAME:main" -p 35  # 35% width
```

### Claude Code Flags

Customize Claude Code startup in `claude-tmux.sh`:

```bash
tmux send-keys -t "$SESSION_NAME:main.0" "claude --dangerously-skip-permissions --model opus" C-m
```

## 📋 Requirements

- **tmux** - Terminal multiplexer
- **jq** - JSON processor
- **git** - Version control
- **gh** (optional) - GitHub CLI for PR/issue tracking
- **Claude Code** - Anthropic's Claude CLI

### Install Dependencies

```bash
# macOS
brew install tmux jq gh

# Ubuntu/Debian
sudo apt install tmux jq gh

# Arch Linux
sudo pacman -S tmux jq github-cli
```

## 🔧 Troubleshooting

### Dashboard Shows "No Data"

Make sure `~/.claude/dashboard.json` exists:

```bash
./dashboard-update.sh --full
```

### Scripts Not Executable

```bash
chmod +x claude-tmux.sh dashboard-*.sh
```

### Tmux Session Already Exists

```bash
tmux kill-session -t claude-dash
./claude-tmux.sh
```

### Dashboard Not Updating

Check if the watcher is running:

```bash
ps aux | grep dashboard-watch
```

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for [Claude Code](https://claude.ai/code) by Anthropic
- Inspired by tmux dashboards and TUI design
- Unicode box-drawing characters for beautiful rendering

## 📸 Screenshots

![Claude Tmux Dashboard](docs/screenshot.png)

*Live dashboard showing git status, CI results, and project progress*

---

**Made with ❤️ for Claude Code users**

[Report Bug](https://github.com/ybouhjira/claude-tmux-dashboard/issues) · [Request Feature](https://github.com/ybouhjira/claude-tmux-dashboard/issues)
