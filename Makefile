.PHONY: help install install-all install-homebrew install-ide install-zsh install-claude \
        uninstall uninstall-ide uninstall-zsh uninstall-claude

# Default target
.DEFAULT_GOAL := help

install: install-ide install-zsh install-claude
	@echo ""
	@echo "==> Installation complete!"

# Install everything including Homebrew dependencies
install-all: install-homebrew install-ide install-zsh install-claude
	@echo ""
	@echo "==> Full installation complete!"

# Install Homebrew dependencies and mise runtimes
install-homebrew:
	@./scripts/install-homebrew.sh

# Install IDE environment
install-ide:
	@./scripts/install-ide.sh

# Install zsh configuration
install-zsh:
	@./scripts/install-zsh.sh

# Install Claude Code configuration
install-claude:
	@./scripts/install-claude.sh

# Uninstall everything
uninstall: uninstall-ide uninstall-zsh uninstall-claude
	@echo ""
	@echo "==> Uninstallation complete!"
	@echo ""
	@echo "Note: Homebrew packages were not uninstalled."
	@echo "To uninstall them: brew uninstall tmux helix lazygit gwq fzf fd ripgrep gh mise"

# Uninstall terminal environment
uninstall-ide:
	@echo "==> Uninstalling Terminal Environment"
	@[ -L ~/.tmux.conf ] && rm ~/.tmux.conf || true
	@echo "==> Terminal environment uninstalled."

# Uninstall zsh configuration
uninstall-zsh:
	@echo "==> Uninstalling zsh configuration"
	@[ -L ~/.zprofile ] && rm ~/.zprofile || true
	@[ -L ~/.zsh ] && rm ~/.zsh || true
	@echo "==> zsh configuration uninstalled."
	@echo "NOTE: ~/.zshrc was NOT removed (may contain personal settings)"
	@echo "NOTE: zsh/secrets in the repository was NOT removed (contains your API keys)"

# Uninstall Claude Code configuration
uninstall-claude:
	@echo "==> Uninstalling Claude Code configuration"
	@[ -L ~/.claude/CLAUDE.md ] && rm ~/.claude/CLAUDE.md || true
	@[ -L ~/.claude/rules ] && rm ~/.claude/rules || true
	@[ -L ~/.claude/settings.json ] && rm ~/.claude/settings.json || true
	@[ -L ~/.claude/scripts ] && rm ~/.claude/scripts || true
	@[ -L ~/.claude/skills ] && rm ~/.claude/skills || true
	@echo "==> Claude Code configuration uninstalled."
	@echo "NOTE: assets remain in the repository under claude/"

# Show help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Install targets:"
	@echo "  install          Install IDE + zsh + Claude (default)"
	@echo "  install-all      Install everything (Homebrew + IDE + zsh + Claude)"
	@echo "  install-homebrew Install Homebrew dependencies + mise runtimes"
	@echo "  install-ide      Install terminal environment (tmux, Helix)"
	@echo "  install-zsh      Install zsh configuration"
	@echo "  install-claude   Install Claude Code configuration"
	@echo ""
	@echo "Uninstall targets:"
	@echo "  uninstall        Uninstall IDE + zsh + Claude"
	@echo "  uninstall-ide    Uninstall terminal environment"
	@echo "  uninstall-zsh    Uninstall zsh configuration"
	@echo "  uninstall-claude Uninstall Claude Code configuration"
	@echo ""
	@echo "Other:"
	@echo "  help             Show this help message"
