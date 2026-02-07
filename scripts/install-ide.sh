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
mkdir -p ~/.local/bin

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

# Link scripts
echo "==> Linking IDE scripts..."
backup_if_exists ~/.local/bin/zellij-open
backup_if_exists ~/.local/bin/yazi-one
backup_if_exists ~/.local/bin/zellij-worktree
backup_if_exists ~/.local/bin/tmux-worktree
backup_if_exists ~/.local/bin/tmux-layout-claude
backup_if_exists ~/.local/bin/tmux-layout
backup_if_exists ~/.local/bin/git-switch
backup_if_exists ~/.local/bin/github-switch
ln -s "$REPO_ROOT/bin/zellij-open" ~/.local/bin/zellij-open
ln -s "$REPO_ROOT/bin/yazi-one" ~/.local/bin/yazi-one
ln -s "$REPO_ROOT/bin/zellij-worktree" ~/.local/bin/zellij-worktree
ln -s "$REPO_ROOT/bin/tmux-worktree" ~/.local/bin/tmux-worktree
ln -s "$REPO_ROOT/bin/tmux-layout-claude" ~/.local/bin/tmux-layout-claude
ln -s "$REPO_ROOT/bin/tmux-layout" ~/.local/bin/tmux-layout
ln -s "$REPO_ROOT/bin/git-switch" ~/.local/bin/git-switch
ln -s "$REPO_ROOT/bin/github-switch" ~/.local/bin/github-switch
chmod +x "$REPO_ROOT/bin/zellij-open" "$REPO_ROOT/bin/yazi-one" "$REPO_ROOT/bin/zellij-worktree" "$REPO_ROOT/bin/tmux-worktree" "$REPO_ROOT/bin/tmux-layout-claude" "$REPO_ROOT/bin/tmux-layout" "$REPO_ROOT/bin/git-switch" "$REPO_ROOT/bin/github-switch"

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
