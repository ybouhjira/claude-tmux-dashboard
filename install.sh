#!/bin/bash
# One-line installer for claude-tmux-dashboard

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

INSTALL_DIR="$HOME/.claude-tmux-dashboard"

echo -e "${BLUE}╭─────────────────────────────────────╮${NC}"
echo -e "${BLUE}│  📊 Claude Tmux Dashboard Installer │${NC}"
echo -e "${BLUE}╰─────────────────────────────────────╯${NC}"
echo ""

# Check dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"
missing_deps=()
for cmd in tmux jq git; do
    if ! command -v "$cmd" &>/dev/null; then
        missing_deps+=("$cmd")
    fi
done

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo -e "${YELLOW}Missing dependencies: ${missing_deps[*]}${NC}"
    echo "Please install them first:"
    echo "  macOS: brew install ${missing_deps[*]}"
    echo "  Ubuntu/Debian: sudo apt install ${missing_deps[*]}"
    echo "  Arch: sudo pacman -S ${missing_deps[*]}"
    exit 1
fi

echo -e "${GREEN}✓ All dependencies found${NC}"

# Clone or update repository
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Updating existing installation...${NC}"
    cd "$INSTALL_DIR"
    git pull origin main
else
    echo -e "${YELLOW}Installing to $INSTALL_DIR...${NC}"
    git clone https://github.com/ybouhjira/claude-tmux-dashboard.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Make scripts executable
chmod +x *.sh

# Create symlink in ~/bin
mkdir -p "$HOME/bin"
ln -sf "$INSTALL_DIR/claude-tmux.sh" "$HOME/bin/claude-tmux"

echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo -e "Usage:"
echo -e "  ${BLUE}claude-tmux${NC}  - Start Claude Code with dashboard"
echo ""
echo -e "Make sure ${BLUE}~/bin${NC} is in your PATH:"
echo -e "  ${YELLOW}export PATH=\"\$HOME/bin:\$PATH\"${NC}"
echo ""
echo -e "For more info: ${BLUE}https://github.com/ybouhjira/claude-tmux-dashboard${NC}"
