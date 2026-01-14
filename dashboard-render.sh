#!/bin/bash
# Dashboard Renderer - Reads dashboard.json and renders a beautiful TUI

DASHBOARD_FILE="$HOME/.claude/dashboard.json"

# ANSI Colors
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BG_BLUE='\033[44m'
BG_GREEN='\033[42m'
BG_RED='\033[41m'
BG_YELLOW='\033[43m'

# Box drawing characters
TL='╭' TR='╮' BL='╰' BR='╯' H='─' V='│' LT='├' RT='┤' TT='┬' BT='┴' CR='┼'

# Get terminal width (force smaller for tmux panes)
COLS=$(tput cols 2>/dev/null || echo 40)
[ "$COLS" -gt 60 ] && COLS=60  # Cap at 60 for dashboard pane
INNER=$((COLS - 2))

# Helper: horizontal line
hline() {
    local char="${1:-$H}"
    printf '%*s' "$INNER" '' | tr ' ' "$char"
}

# Helper: centered text
center() {
    local text="$1"
    local len=${#text}
    local pad=$(( (INNER - len) / 2 ))
    printf '%*s%s%*s' "$pad" '' "$text" "$((INNER - pad - len))" ''
}

# Helper: progress bar
progress_bar() {
    local pct=$1
    local width=$((INNER - 20))
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    local color=$GREEN
    [ "$pct" -lt 50 ] && color=$YELLOW
    [ "$pct" -lt 25 ] && color=$RED
    printf "${color}"
    printf '%*s' "$filled" '' | tr ' ' '█'
    printf "${DIM}"
    printf '%*s' "$empty" '' | tr ' ' '░'
    printf "${RESET} %3d%%" "$pct"
}

# Read dashboard data
if [ -f "$DASHBOARD_FILE" ]; then
    PROJECT=$(jq -r '.project // "Unknown"' "$DASHBOARD_FILE")
    BRANCH=$(jq -r '.branch // "-"' "$DASHBOARD_FILE")
    STATUS=$(jq -r '.status // "idle"' "$DASHBOARD_FILE")
    PROGRESS=$(jq -r '.progress // 0' "$DASHBOARD_FILE")
    CI=$(jq -r '.ci // "unknown"' "$DASHBOARD_FILE")
    ADDED=$(jq -r '.changes.added // 0' "$DASHBOARD_FILE")
    DELETED=$(jq -r '.changes.deleted // 0' "$DASHBOARD_FILE")
    MODIFIED=$(jq -r '.changes.modified // 0' "$DASHBOARD_FILE")
    AHEAD=$(jq -r '.ahead // 0' "$DASHBOARD_FILE")
    BEHIND=$(jq -r '.behind // 0' "$DASHBOARD_FILE")
    STASH=$(jq -r '.stash // 0' "$DASHBOARD_FILE")
    MESSAGE=$(jq -r '.message // ""' "$DASHBOARD_FILE")
else
    PROJECT="No Data"
    BRANCH="-"
    STATUS="waiting"
    PROGRESS=0
    CI="unknown"
    ADDED=0 DELETED=0 MODIFIED=0
    AHEAD=0 BEHIND=0 STASH=0
    MESSAGE="Waiting for data..."
fi

# CI indicator
case "$CI" in
    success|pass*) CI_ICON="🟢" CI_TEXT="PASS" ;;
    fail*) CI_ICON="🔴" CI_TEXT="FAIL" ;;
    running|pending) CI_ICON="🟡" CI_TEXT="RUNNING" ;;
    *) CI_ICON="⚪" CI_TEXT="N/A" ;;
esac

# Status indicator
case "$STATUS" in
    working) STATUS_ICON="⚡" STATUS_COLOR=$YELLOW ;;
    success) STATUS_ICON="✅" STATUS_COLOR=$GREEN ;;
    error) STATUS_ICON="❌" STATUS_COLOR=$RED ;;
    thinking) STATUS_ICON="🤔" STATUS_COLOR=$CYAN ;;
    *) STATUS_ICON="💤" STATUS_COLOR=$DIM ;;
esac

# Render dashboard
echo -e "${BOLD}${BLUE}"
echo "$TL$(hline)$TR"

# Header
echo -e "$V${BG_BLUE}${WHITE}${BOLD}$(center "📊 CLAUDE DASHBOARD")${RESET}${BLUE}$V"
echo "$LT$(hline)$RT"

# Project info
echo -e "$V ${BOLD}📦 $PROJECT${RESET}  ${DIM}⎇ $BRANCH${RESET}$(printf '%*s' $((INNER - ${#PROJECT} - ${#BRANCH} - 10)) '')${BLUE}$V"
echo "$LT$(hline)$RT"

# Status bar
STATUS_UPPER=$(echo "$STATUS" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
echo -e "$V ${STATUS_COLOR}${STATUS_ICON} ${STATUS_UPPER}${RESET}$(printf '%*s' $((INNER - ${#STATUS} - 15)) '')$CI_ICON CI: $CI_TEXT ${BLUE}$V"
echo "$LT$(hline)$RT"

# Progress bar
echo -e "$V $(progress_bar $PROGRESS)${BLUE} $V"
echo "$LT$(hline)$RT"

# Git stats row (compact)
STATS="+$ADDED -$DELETED M$MODIFIED | ^$AHEAD v$BEHIND | $STASH stash"
padding=$((INNER - ${#STATS} - 1))
[ $padding -lt 0 ] && padding=0
echo -e "$V ${CYAN}$STATS${RESET}$(printf '%*s' $padding '')${BLUE}$V"
echo "$LT$(hline)$RT"

# Commits section
echo -e "$V ${BOLD}📝 COMMITS${RESET}$(printf '%*s' $((INNER - 12)) '')${BLUE}$V"
if [ -f "$DASHBOARD_FILE" ]; then
    jq -r '.commits[:3][]? // empty' "$DASHBOARD_FILE" 2>/dev/null | while read -r commit; do
        max_len=$((INNER - 5))
        commit_short="${commit:0:$max_len}"
        [ ${#commit} -gt $max_len ] && commit_short="${commit_short:0:$((max_len-2))}.."
        padding=$((INNER - ${#commit_short} - 3))
        [ $padding -lt 0 ] && padding=0
        echo -e "${BLUE}$V ${DIM}• $commit_short${RESET}$(printf '%*s' $padding '')${BLUE}$V"
    done
fi
echo "$LT$(hline)$RT"

# PRs & Issues
echo -e "$V ${BOLD}🔗 PRs${RESET}"
if [ -f "$DASHBOARD_FILE" ]; then
    PRS=$(jq -r '.prs[]? // empty | "#\(.)"' "$DASHBOARD_FILE" 2>/dev/null | tr '\n' ' ')
    [ -z "$PRS" ] && PRS="None"
fi
echo -e "${BLUE}$V   ${GREEN}$PRS${RESET}$(printf '%*s' $((INNER - ${#PRS} - 4)) '')${BLUE}$V"

echo -e "$V ${BOLD}📋 Issues${RESET}"
if [ -f "$DASHBOARD_FILE" ]; then
    ISSUES=$(jq -r '.issues[]? // empty | "#\(.)"' "$DASHBOARD_FILE" 2>/dev/null | tr '\n' ' ')
    [ -z "$ISSUES" ] && ISSUES="None"
fi
echo -e "${BLUE}$V   ${YELLOW}$ISSUES${RESET}$(printf '%*s' $((INNER - ${#ISSUES} - 4)) '')${BLUE}$V"
echo "$LT$(hline)$RT"

# Current message
echo -e "$V ${MAGENTA}💬 $MESSAGE${RESET}$(printf '%*s' $((INNER - ${#MESSAGE} - 4)) '')${BLUE}$V"

# Footer
echo "$BL$(hline)$BR"
echo -e "${RESET}"

# Tasks section (if any)
if [ -f "$DASHBOARD_FILE" ]; then
    TASK_COUNT=$(jq '.tasks | length' "$DASHBOARD_FILE" 2>/dev/null || echo 0)
    if [ "$TASK_COUNT" -gt 0 ]; then
        echo -e "${BOLD}📋 TASKS${RESET}"
        jq -r '.tasks[]? | "\(.status) \(.content)"' "$DASHBOARD_FILE" 2>/dev/null | while read -r task; do
            case "$task" in
                completed*) echo -e "  ${GREEN}✅${task#completed }${RESET}" ;;
                in_progress*) echo -e "  ${YELLOW}🔄${task#in_progress }${RESET}" ;;
                *) echo -e "  ${DIM}○${task#pending }${RESET}" ;;
            esac
        done
    fi
fi

echo -e "\n${DIM}Last update: $(date '+%H:%M:%S')${RESET}"
