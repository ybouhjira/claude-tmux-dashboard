#!/bin/bash
# Dashboard Update Script - Called by Claude to update dashboard.json
# Usage: dashboard-update.sh [key] [value]
# Or: dashboard-update.sh --full (gathers all git info)

DASHBOARD_FILE="$HOME/.claude/dashboard.json"

# Ensure file exists
if [ ! -f "$DASHBOARD_FILE" ]; then
    echo '{}' > "$DASHBOARD_FILE"
fi

update_field() {
    local key="$1"
    local value="$2"
    local tmp=$(mktemp)
    jq --arg k "$key" --arg v "$value" '.[$k] = $v' "$DASHBOARD_FILE" > "$tmp" && mv "$tmp" "$DASHBOARD_FILE"
}

update_field_json() {
    local key="$1"
    local value="$2"
    local tmp=$(mktemp)
    jq --arg k "$key" --argjson v "$value" '.[$k] = $v' "$DASHBOARD_FILE" > "$tmp" && mv "$tmp" "$DASHBOARD_FILE"
}

# Full update - gather all git info
full_update() {
    local project=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
    local branch=$(git branch --show-current 2>/dev/null || echo "-")

    # Git status
    local status_output=$(git status --porcelain 2>/dev/null)
    local added=$(echo "$status_output" | grep -c '^A\|^??' 2>/dev/null || echo 0)
    local deleted=$(echo "$status_output" | grep -c '^D' 2>/dev/null || echo 0)
    local modified=$(echo "$status_output" | grep -c '^M\|^ M' 2>/dev/null || echo 0)
    # Ensure numeric
    added=${added:-0}; added=${added//[^0-9]/}; added=${added:-0}
    deleted=${deleted:-0}; deleted=${deleted//[^0-9]/}; deleted=${deleted:-0}
    modified=${modified:-0}; modified=${modified//[^0-9]/}; modified=${modified:-0}

    # Ahead/behind
    local tracking=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    local ahead=0 behind=0
    if [ -n "$tracking" ]; then
        ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
        behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)
    fi

    # Stash count
    local stash=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
    stash=${stash:-0}; stash=${stash//[^0-9]/}; stash=${stash:-0}

    # Recent commits
    local commits=$(git log --oneline -5 2>/dev/null | jq -R -s 'split("\n") | map(select(length > 0))')

    # PRs (if gh available)
    local prs="[]"
    if command -v gh &>/dev/null; then
        prs=$(gh pr list --author @me --state open --json number --limit 5 2>/dev/null | jq '[.[].number]' || echo "[]")
    fi

    # Issues
    local issues="[]"
    if command -v gh &>/dev/null; then
        issues=$(gh issue list --assignee @me --state open --json number --limit 5 2>/dev/null | jq '[.[].number]' || echo "[]")
    fi

    # CI status
    local ci="unknown"
    if command -v gh &>/dev/null; then
        ci=$(gh run list --branch "$branch" --limit 1 --json conclusion -q '.[0].conclusion' 2>/dev/null || echo "unknown")
        [ -z "$ci" ] && ci="unknown"
    fi

    # Calculate progress (100% if clean)
    local total_changes=$((added + deleted + modified))
    local progress=100
    [ "$total_changes" -gt 0 ] && progress=$((100 - (total_changes * 10)))
    [ "$progress" -lt 0 ] && progress=0

    # Write everything
    cat > "$DASHBOARD_FILE" << EOF
{
  "project": "$project",
  "branch": "$branch",
  "status": "idle",
  "progress": $progress,
  "ci": "$ci",
  "changes": { "added": $added, "deleted": $deleted, "modified": $modified },
  "ahead": $ahead,
  "behind": $behind,
  "stash": $stash,
  "commits": $commits,
  "prs": $prs,
  "issues": $issues,
  "message": "Ready",
  "tasks": []
}
EOF
    echo "Dashboard updated for $project ($branch)"
}

# Handle arguments
case "$1" in
    --full|-f)
        full_update
        ;;
    message|msg)
        update_field "message" "$2"
        ;;
    status)
        update_field "status" "$2"
        ;;
    progress)
        update_field_json "progress" "$2"
        ;;
    tasks)
        update_field_json "tasks" "$2"
        ;;
    *)
        if [ -n "$1" ] && [ -n "$2" ]; then
            update_field "$1" "$2"
        else
            echo "Usage: dashboard-update.sh --full | [key] [value]"
            echo "Keys: message, status, progress, tasks, or any custom key"
        fi
        ;;
esac
