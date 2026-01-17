#!/bin/bash
# Install zsh configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"
REPO_ROOT="$(get_repo_root)"

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
ln -s "$REPO_ROOT/zsh/zprofile" ~/.zprofile

# Link .zsh directory
echo "==> Linking .zsh directory..."
backup_if_exists ~/.zsh
ln -s "$REPO_ROOT/zsh" ~/.zsh

# Create secrets file if it doesn't exist
if [ ! -f "$REPO_ROOT/zsh/secrets" ]; then
    echo "==> Creating empty secrets file..."
    cat > "$REPO_ROOT/zsh/secrets" <<EOF
# Add your API keys and secrets here
# See $REPO_ROOT/zsh/secrets.example for examples
EOF
    chmod 600 "$REPO_ROOT/zsh/secrets"
fi

# Create local.zsh from example if it doesn't exist
if [ ! -f "$REPO_ROOT/zsh/local.zsh" ]; then
    echo "==> Creating local.zsh from example..."
    cp "$REPO_ROOT/zsh/local.zsh.example" "$REPO_ROOT/zsh/local.zsh"
    echo "    Customize ~/.zsh/local.zsh for this machine's specific settings"
fi

echo "==> zsh configuration installation complete!"
echo ""
echo "IMPORTANT: Edit ~/.zsh/secrets to add your API keys (see zsh/secrets.example)"
echo "Also customize ~/.zsh/local.zsh for machine-specific settings"
echo "Also customize bin/git-switch and bin/github-switch with your account information"
echo ""
echo "Restart your shell or run: source ~/.zshrc"
