#!/bin/bash

set -e

echo "==> Uninstalling Zellij IDE Environment"

# Remove symlinks (only if they are symlinks)
remove_symlink() {
    local target="$1"
    if [ -L "$target" ]; then
        echo "Removing symlink: $target"
        rm "$target"
    fi
}

remove_symlink ~/.config/zellij/config.kdl
remove_symlink ~/.config/zellij/layouts/ide.kdl
remove_symlink ~/.config/yazi-one/keymap.toml
remove_symlink ~/.config/yazi-one/yazi.toml
remove_symlink ~/.local/bin/zellij-open
remove_symlink ~/.local/bin/yazi-one
remove_symlink ~/.local/bin/zellij-worktree

echo ""
echo "==> Symlinks removed."
echo "Note: Homebrew packages (zellij, yazi, helix, gitui) were not uninstalled."
echo "To uninstall them: brew uninstall zellij yazi helix gitui"
