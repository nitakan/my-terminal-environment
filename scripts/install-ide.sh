#!/bin/bash
# Install IDE environment (Zellij, Yazi, Helix)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"
REPO_ROOT="$(get_repo_root)"

echo "==> Installing IDE Environment (Zellij, Yazi, Helix)"

# Create directories
echo "==> Creating IDE directories..."
mkdir -p ~/.config/zellij/layouts
mkdir -p ~/.config/yazi-one

# Link Zellij config
echo "==> Linking Zellij config..."
backup_if_exists ~/.config/zellij/config.kdl
backup_if_exists ~/.config/zellij/layouts/ide.kdl
ln -s "$REPO_ROOT/config/zellij/config.kdl" ~/.config/zellij/config.kdl
ln -s "$REPO_ROOT/config/zellij/layouts/ide.kdl" ~/.config/zellij/layouts/ide.kdl

# Link Yazi config
echo "==> Linking Yazi config..."
backup_if_exists ~/.config/yazi-one/keymap.toml
backup_if_exists ~/.config/yazi-one/yazi.toml
ln -s "$REPO_ROOT/config/yazi-one/keymap.toml" ~/.config/yazi-one/keymap.toml
ln -s "$REPO_ROOT/config/yazi-one/yazi.toml" ~/.config/yazi-one/yazi.toml

# Link tmux config
echo "==> Linking tmux config..."
backup_if_exists ~/.tmux.conf
ln -s "$REPO_ROOT/config/tmux/tmux.conf" ~/.tmux.conf

# Ensure bin/ scripts are executable
chmod +x "$REPO_ROOT/bin/"*

echo "==> IDE environment installation complete!"
echo ""
echo "Start with: zellij"
echo ""
echo "Layout:"
echo "  - Explorer (yazi): File picker on the left"
echo "  - Editor (helix): Main editor"
echo "  - Implement: Implementation notes"
echo "  - Git + Review: Stacked panes at bottom"
echo ""
echo "Keybindings:"
echo "  - Ctrl+Shift+g: Open gitui in floating pane"
echo "  - Alt+Enter (in yazi): Open file in new Helix buffer"
