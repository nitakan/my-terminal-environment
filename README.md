# My Zellij IDE Environment

Zellij + Yazi + Helix + GitUI を組み合わせたターミナルIDE環境。

参考: [ターミナルだけで開発していく夢をZellijで叶える](https://zenn.dev/spacemarket/articles/192a58e9177961)

## Layout

```
┌─────────┬──────────────────┬─────────────────────┐
│Explorer │ Editor (helix)   │ Git [collapsed]     │
│ (yazi)  │                  ├─────────────────────┤
│         ├──────────────────┤ Review [expanded]   │
│         │ Implement        │                     │
└─────────┴──────────────────┴─────────────────────┘
```

## Requirements

- macOS
- Homebrew

## Installation

```bash
git clone <this-repo> ~/projects/my-env
cd ~/projects/my-env
./install.sh
```

## Usage

```bash
zellij
```

### Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+Shift+g` | Open gitui in floating pane |
| `Enter` (in yazi) | Open file in Editor |
| `Alt+Enter` (in yazi) | Open file in new Helix buffer |

### Pane Navigation

| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Move focus between panes |
| `Alt+↑/↓` | Switch between stacked panes |
| `Ctrl+p` | Pane mode |
| `Ctrl+t` | Tab mode |

## Shell Configuration

以下を `~/.zshrc` に追加してください：

```bash
# ~/.local/bin をPATHに追加（スクリプト用）
export PATH="$HOME/.local/bin:$PATH"

# Zellij alias
alias z='zellij'

# gwq (git worktree manager)
eval "$(gwq completion zsh)"
```

## Uninstall

```bash
./uninstall.sh
```

## Files

```
my-env/
├── install.sh           # Installation script
├── uninstall.sh         # Uninstallation script
├── config/
│   ├── zellij/
│   │   ├── config.kdl   # Zellij keybindings & settings
│   │   └── layouts/
│   │       └── ide.kdl  # IDE layout
│   └── yazi-one/
│       ├── keymap.toml  # Yazi keybindings
│       └── yazi.toml    # Yazi opener settings
└── bin/
    ├── zellij-open      # Script to open files in Helix
    └── yazi-one         # Wrapper to launch Yazi with custom config
```
