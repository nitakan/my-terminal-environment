#!/bin/bash

set -e

# Parse options
UNINSTALL_IDE=false
UNINSTALL_ZSH=false

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all           Uninstall everything (IDE + zsh)"
    echo "  --ide-only      Uninstall only IDE environment"
    echo "  --zsh-only      Uninstall only zsh configuration"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "If no options are provided, --all is assumed."
}

# Parse arguments
if [ $# -eq 0 ]; then
    UNINSTALL_IDE=true
    UNINSTALL_ZSH=true
else
    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                UNINSTALL_IDE=true
                UNINSTALL_ZSH=true
                ;;
            --ide-only)
                UNINSTALL_IDE=true
                ;;
            --zsh-only)
                UNINSTALL_ZSH=true
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Error: Unknown option '$1'"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
fi

# Remove symlinks (only if they are symlinks)
remove_symlink() {
    local target="$1"
    if [ -L "$target" ]; then
        echo "Removing symlink: $target"
        rm "$target"
    fi
}

# Uninstall IDE environment
uninstall_ide() {
    echo "==> Uninstalling IDE Environment"

    remove_symlink ~/.config/zellij/config.kdl
    remove_symlink ~/.config/zellij/layouts/ide.kdl
    remove_symlink ~/.config/yazi-one/keymap.toml
    remove_symlink ~/.config/yazi-one/yazi.toml
    remove_symlink ~/.local/bin/zellij-open
    remove_symlink ~/.local/bin/yazi-one
    remove_symlink ~/.local/bin/zellij-worktree
    remove_symlink ~/.local/bin/git-switch
    remove_symlink ~/.local/bin/github-switch

    echo "==> IDE environment uninstalled."
}

# Uninstall zsh configuration
uninstall_zsh() {
    echo "==> Uninstalling zsh configuration"

    remove_symlink ~/.zprofile
    remove_symlink ~/.zsh

    echo "==> zsh configuration uninstalled."
    echo "NOTE: ~/.zshrc was NOT removed (may contain personal settings)"
    echo "NOTE: zsh/secrets in the repository was NOT removed (contains your API keys)"
}

# Main uninstallation flow
if [ "$UNINSTALL_IDE" = true ]; then
    uninstall_ide
fi

if [ "$UNINSTALL_ZSH" = true ]; then
    uninstall_zsh
fi

echo ""
echo "==> Uninstallation complete!"
echo ""
echo "Note: Homebrew packages were not uninstalled."
echo "To uninstall them: brew uninstall zellij yazi helix gitui gh anyenv"
