#!/bin/bash
# Main installation script - delegates to individual scripts in scripts/

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
    echo "  --all           Install everything (IDE + zsh)"
    echo "  --ide-only      Install only IDE environment (Zellij, Yazi, Helix)"
    echo "  --zsh-only      Install only zsh configuration"
    echo "  --with-homebrew Install Homebrew dependencies from Brewfile + mise runtimes"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "If no options are provided, --all is assumed."
    echo ""
    echo "Individual scripts can also be run directly:"
    echo "  ./scripts/install-homebrew.sh  # Homebrew + mise"
    echo "  ./scripts/install-ide.sh       # IDE environment"
    echo "  ./scripts/install-zsh.sh       # zsh configuration"
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

# Make scripts executable
chmod +x "$SCRIPT_DIR/scripts/"*.sh

# Main installation flow
if [ "$INSTALL_HOMEBREW" = true ]; then
    "$SCRIPT_DIR/scripts/install-homebrew.sh"
fi

if [ "$INSTALL_IDE" = true ]; then
    "$SCRIPT_DIR/scripts/install-ide.sh"
fi

if [ "$INSTALL_ZSH" = true ]; then
    "$SCRIPT_DIR/scripts/install-zsh.sh"
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
