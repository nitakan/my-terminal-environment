#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing Zellij IDE Environment"

# Install dependencies via Homebrew
# Reference: https://zenn.dev/spacemarket/articles/192a58e9177961
echo "==> Installing dependencies..."
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed. Please install it first."
    exit 1
fi

brew install zellij helix yazi fzf fd ripgrep gitui
brew install d-kuro/tap/gwq

# Create directories
echo "==> Creating directories..."
mkdir -p ~/.config/zellij/layouts
mkdir -p ~/.config/yazi-one
mkdir -p ~/.local/bin

# Backup existing configs if they exist and are not symlinks
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up $target to ${target}.bak"
        mv "$target" "${target}.bak"
    elif [ -L "$target" ]; then
        rm "$target"
    fi
}

# Link Zellij config
echo "==> Linking Zellij config..."
backup_if_exists ~/.config/zellij/config.kdl
backup_if_exists ~/.config/zellij/layouts/ide.kdl
ln -s "$SCRIPT_DIR/config/zellij/config.kdl" ~/.config/zellij/config.kdl
ln -s "$SCRIPT_DIR/config/zellij/layouts/ide.kdl" ~/.config/zellij/layouts/ide.kdl

# Link Yazi config
echo "==> Linking Yazi config..."
backup_if_exists ~/.config/yazi-one/keymap.toml
backup_if_exists ~/.config/yazi-one/yazi.toml
ln -s "$SCRIPT_DIR/config/yazi-one/keymap.toml" ~/.config/yazi-one/keymap.toml
ln -s "$SCRIPT_DIR/config/yazi-one/yazi.toml" ~/.config/yazi-one/yazi.toml

# Link scripts
echo "==> Linking scripts..."
backup_if_exists ~/.local/bin/zellij-open
backup_if_exists ~/.local/bin/yazi-one
backup_if_exists ~/.local/bin/zellij-worktree
ln -s "$SCRIPT_DIR/bin/zellij-open" ~/.local/bin/zellij-open
ln -s "$SCRIPT_DIR/bin/yazi-one" ~/.local/bin/yazi-one
ln -s "$SCRIPT_DIR/bin/zellij-worktree" ~/.local/bin/zellij-worktree
chmod +x "$SCRIPT_DIR/bin/zellij-open" "$SCRIPT_DIR/bin/yazi-one" "$SCRIPT_DIR/bin/zellij-worktree"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo ""
    echo "==> WARNING: ~/.local/bin is not in your PATH"
    echo "Add the following to your shell config (~/.zshrc or ~/.bashrc):"
    echo '  export PATH="$HOME/.local/bin:$PATH"'
fi

echo ""
echo "==> Installation complete!"
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
