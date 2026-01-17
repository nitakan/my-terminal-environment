#!/bin/bash
# Install Homebrew dependencies and mise runtimes

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"
REPO_ROOT="$(get_repo_root)"

echo "==> Installing Homebrew dependencies..."

if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed. Please install it first."
    exit 1
fi

if [ -f "$REPO_ROOT/Brewfile" ]; then
    brew bundle --file="$REPO_ROOT/Brewfile"
else
    echo "Warning: Brewfile not found. Skipping Homebrew installation."
    exit 1
fi

# Install mise runtimes if mise.toml exists
if [ -f "$REPO_ROOT/mise.toml" ] && command -v mise &> /dev/null; then
    echo "==> Installing mise runtimes..."
    cd "$REPO_ROOT"
    mise install
fi

echo "==> Homebrew dependencies installation complete!"
