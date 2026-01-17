#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse options
INSTALL_IDE=false
INSTALL_ZSH=false
INSTALL_HOMEBREW=false

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all           Install everything (IDE + zsh + Homebrew dependencies)"
    echo "  --ide-only      Install only IDE environment (Zellij, Yazi, Helix)"
    echo "  --zsh-only      Install only zsh configuration"
    echo "  --with-homebrew Install Homebrew dependencies from Brewfile"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "If no options are provided, --all is assumed."
}

# Parse arguments
if [ $# -eq 0 ]; then
    INSTALL_IDE=true
    INSTALL_ZSH=true
else
    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                INSTALL_IDE=true
                INSTALL_ZSH=true
                ;;
            --ide-only)
                INSTALL_IDE=true
                ;;
            --zsh-only)
                INSTALL_ZSH=true
                ;;
            --with-homebrew)
                INSTALL_HOMEBREW=true
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

# Install Homebrew dependencies
install_homebrew_deps() {
    echo "==> Installing Homebrew dependencies..."
    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew is not installed. Please install it first."
        exit 1
    fi

    if [ -f "$SCRIPT_DIR/Brewfile" ]; then
        brew bundle --file="$SCRIPT_DIR/Brewfile"
    else
        echo "Warning: Brewfile not found. Skipping Homebrew installation."
    fi
}

# Install IDE environment
install_ide() {
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
    ln -s "$SCRIPT_DIR/config/zellij/config.kdl" ~/.config/zellij/config.kdl
    ln -s "$SCRIPT_DIR/config/zellij/layouts/ide.kdl" ~/.config/zellij/layouts/ide.kdl

    # Link Yazi config
    echo "==> Linking Yazi config..."
    backup_if_exists ~/.config/yazi-one/keymap.toml
    backup_if_exists ~/.config/yazi-one/yazi.toml
    ln -s "$SCRIPT_DIR/config/yazi-one/keymap.toml" ~/.config/yazi-one/keymap.toml
    ln -s "$SCRIPT_DIR/config/yazi-one/yazi.toml" ~/.config/yazi-one/yazi.toml

    # Link scripts
    echo "==> Linking IDE scripts..."
    backup_if_exists ~/.local/bin/zellij-open
    backup_if_exists ~/.local/bin/yazi-one
    backup_if_exists ~/.local/bin/zellij-worktree
    backup_if_exists ~/.local/bin/git-switch
    backup_if_exists ~/.local/bin/github-switch
    ln -s "$SCRIPT_DIR/bin/zellij-open" ~/.local/bin/zellij-open
    ln -s "$SCRIPT_DIR/bin/yazi-one" ~/.local/bin/yazi-one
    ln -s "$SCRIPT_DIR/bin/zellij-worktree" ~/.local/bin/zellij-worktree
    ln -s "$SCRIPT_DIR/bin/git-switch" ~/.local/bin/git-switch
    ln -s "$SCRIPT_DIR/bin/github-switch" ~/.local/bin/github-switch
    chmod +x "$SCRIPT_DIR/bin/zellij-open" "$SCRIPT_DIR/bin/yazi-one" "$SCRIPT_DIR/bin/zellij-worktree" "$SCRIPT_DIR/bin/git-switch" "$SCRIPT_DIR/bin/github-switch"

    echo "==> IDE environment installation complete!"
}

# Install zsh configuration
install_zsh() {
    echo "==> Installing zsh configuration"

    # Create .zshrc if it doesn't exist
    if [ ! -f ~/.zshrc ]; then
        echo "==> Creating ~/.zshrc..."
        cat > ~/.zshrc <<EOF
# Source the main zsh configuration from the repository
if [ -f "\$HOME/.zsh/main.zsh" ]; then
    source "\$HOME/.zsh/main.zsh"
fi

# Add your personal configurations below this line
EOF
    else
        echo "==> ~/.zshrc already exists, skipping creation"
        echo "    Make sure it sources ~/.zsh/main.zsh"
    fi

    # Link zprofile
    echo "==> Linking zprofile..."
    backup_if_exists ~/.zprofile
    ln -s "$SCRIPT_DIR/zsh/zprofile" ~/.zprofile

    # Link .zsh directory
    echo "==> Linking .zsh directory..."
    backup_if_exists ~/.zsh
    ln -s "$SCRIPT_DIR/zsh" ~/.zsh

    # Create secrets file if it doesn't exist
    # Note: ~/.zsh is now a symlink to $SCRIPT_DIR/zsh, so secrets will be created in the repo
    # This is intentional and .gitignore excludes it
    if [ ! -f "$SCRIPT_DIR/zsh/secrets" ]; then
        echo "==> Creating empty secrets file..."
        echo "# Add your API keys and secrets here" > "$SCRIPT_DIR/zsh/secrets"
        echo "# See $SCRIPT_DIR/zsh/secrets.example for examples"
        chmod 600 "$SCRIPT_DIR/zsh/secrets"
    fi

    # Create local.zsh from example if it doesn't exist
    if [ ! -f "$SCRIPT_DIR/zsh/local.zsh" ]; then
        echo "==> Creating local.zsh from example..."
        cp "$SCRIPT_DIR/zsh/local.zsh.example" "$SCRIPT_DIR/zsh/local.zsh"
        echo "    Customize ~/.zsh/local.zsh for this machine's specific settings"
    fi

    echo "==> zsh configuration installation complete!"
    echo ""
    echo "IMPORTANT: Edit ~/.zsh/secrets to add your API keys (see zsh/secrets.example)"
    echo "Also customize ~/.zsh/local.zsh for machine-specific settings"
    echo "Also customize bin/git-switch and bin/github-switch with your account information"
}

# Main installation flow
if [ "$INSTALL_HOMEBREW" = true ]; then
    install_homebrew_deps
fi

if [ "$INSTALL_IDE" = true ]; then
    install_ide
fi

if [ "$INSTALL_ZSH" = true ]; then
    install_zsh
fi

# Check if ~/.local/bin is in PATH
if [ "$INSTALL_IDE" = true ] || [ "$INSTALL_ZSH" = true ]; then
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo ""
        echo "==> WARNING: ~/.local/bin is not in your PATH"
        echo "If you installed zsh config, it will be added automatically."
        echo "Otherwise, add the following to your shell config:"
        echo '  export PATH="$HOME/.local/bin:$PATH"'
    fi
fi

echo ""
echo "==> Installation complete!"

if [ "$INSTALL_IDE" = true ]; then
    echo ""
    echo "IDE Environment installed."
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
fi

if [ "$INSTALL_ZSH" = true ]; then
    echo ""
    echo "zsh configuration installed."
    echo "Restart your shell or run: source ~/.zshrc"
fi
