#!/bin/bash
# Install terminal environment (tmux, Helix)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"
REPO_ROOT="$(get_repo_root)"

echo "==> Installing Terminal Environment (tmux, Helix)"

# Link tmux config
echo "==> Linking tmux config..."
backup_if_exists ~/.tmux.conf
ln -s "$REPO_ROOT/config/tmux/tmux.conf" ~/.tmux.conf

# Ensure bin/ scripts are executable
chmod +x "$REPO_ROOT/bin/"*

echo "==> Terminal environment installation complete!"
echo ""
echo "Start with: tmux"
echo ""
echo "Key bindings (prefix = Ctrl+q):"
echo "  Ctrl+q \\ / Ctrl+q -   Vertical/horizontal pane split"
echo "  Alt+h/j/k/l            Pane navigation (no prefix needed)"
echo "  M-[ / M-]              Window switch"
echo "  M-f                    Popup shell (zsh)"
echo "  Ctrl+q g               lazygit"
echo "  Ctrl+q e               Helix (hx) popup"
echo "  Ctrl+q w               tmux-worktree (select/create worktree)"
echo "  Ctrl+q l               tmux-layout (select layout)"
echo "  Ctrl+q r               Reload config"
