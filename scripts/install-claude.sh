#!/bin/bash
# Install Claude Code configuration (CLAUDE.md, rules, settings.json, scripts, skills)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"
REPO_ROOT="$(get_repo_root)"

echo "==> Installing Claude Code configuration"

# Create directory
echo "==> Creating ~/.claude directory..."
mkdir -p ~/.claude

# Link Claude Code assets (directory/file level symlinks, matching skills)
echo "==> Linking Claude Code config..."
backup_if_exists ~/.claude/CLAUDE.md
backup_if_exists ~/.claude/rules
backup_if_exists ~/.claude/settings.json
backup_if_exists ~/.claude/scripts
backup_if_exists ~/.claude/skills
ln -s "$REPO_ROOT/claude/CLAUDE.md" ~/.claude/CLAUDE.md
ln -s "$REPO_ROOT/claude/rules" ~/.claude/rules
ln -s "$REPO_ROOT/claude/settings.json" ~/.claude/settings.json
ln -s "$REPO_ROOT/claude/scripts" ~/.claude/scripts
ln -s "$REPO_ROOT/claude/skills" ~/.claude/skills

# Ensure claude/scripts are executable
chmod +x "$REPO_ROOT/claude/scripts/"*.sh

echo "==> Claude Code configuration installation complete!"
echo ""
echo "Linked into ~/.claude/:"
echo "  - CLAUDE.md     (global instructions)"
echo "  - rules/        (project rules)"
echo "  - settings.json (permissions, hooks, plugins)"
echo "  - scripts/      (hook scripts, e.g. deny-check.sh)"
echo "  - skills/       (custom skills)"
