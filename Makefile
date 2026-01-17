.PHONY: help install install-all install-homebrew install-ide install-zsh \
        uninstall uninstall-ide uninstall-zsh

# Default target
.DEFAULT_GOAL := help

install: install-ide install-zsh
	@echo ""
	@echo "==> Installation complete!"

# Install everything including Homebrew dependencies
install-all: install-homebrew install-ide install-zsh
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
	@if [[ ":$$PATH:" != *":$$HOME/.local/bin:"* ]]; then \
		echo ""; \
		echo "==> WARNING: ~/.local/bin is not in your PATH"; \
		echo "zsh config will add it automatically after restart."; \
	fi

# Uninstall everything
uninstall: uninstall-ide uninstall-zsh
	@echo ""
	@echo "==> Uninstallation complete!"
	@echo ""
	@echo "Note: Homebrew packages were not uninstalled."
	@echo "To uninstall them: brew uninstall zellij yazi helix gitui gh mise"

# Uninstall IDE environment
uninstall-ide:
	@echo "==> Uninstalling IDE Environment"
	@[ -L ~/.config/zellij/config.kdl ] && rm ~/.config/zellij/config.kdl || true
	@[ -L ~/.config/zellij/layouts/ide.kdl ] && rm ~/.config/zellij/layouts/ide.kdl || true
	@[ -L ~/.config/yazi-one/keymap.toml ] && rm ~/.config/yazi-one/keymap.toml || true
	@[ -L ~/.config/yazi-one/yazi.toml ] && rm ~/.config/yazi-one/yazi.toml || true
	@[ -L ~/.local/bin/zellij-open ] && rm ~/.local/bin/zellij-open || true
	@[ -L ~/.local/bin/yazi-one ] && rm ~/.local/bin/yazi-one || true
	@[ -L ~/.local/bin/zellij-worktree ] && rm ~/.local/bin/zellij-worktree || true
	@[ -L ~/.local/bin/git-switch ] && rm ~/.local/bin/git-switch || true
	@[ -L ~/.local/bin/github-switch ] && rm ~/.local/bin/github-switch || true
	@echo "==> IDE environment uninstalled."

# Uninstall zsh configuration
uninstall-zsh:
	@echo "==> Uninstalling zsh configuration"
	@[ -L ~/.zprofile ] && rm ~/.zprofile || true
	@[ -L ~/.zsh ] && rm ~/.zsh || true
	@echo "==> zsh configuration uninstalled."
	@echo "NOTE: ~/.zshrc was NOT removed (may contain personal settings)"
	@echo "NOTE: zsh/secrets in the repository was NOT removed (contains your API keys)"

# Show help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Install targets:"
	@echo "  install          Install IDE + zsh (default)"
	@echo "  install-all      Install everything (Homebrew + IDE + zsh)"
	@echo "  install-homebrew Install Homebrew dependencies + mise runtimes"
	@echo "  install-ide      Install IDE environment (Zellij, Yazi, Helix)"
	@echo "  install-zsh      Install zsh configuration"
	@echo ""
	@echo "Uninstall targets:"
	@echo "  uninstall        Uninstall IDE + zsh"
	@echo "  uninstall-ide    Uninstall IDE environment"
	@echo "  uninstall-zsh    Uninstall zsh configuration"
	@echo ""
	@echo "Other:"
	@echo "  help             Show this help message"
