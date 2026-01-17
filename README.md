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

## Tools

| Tool | Description |
|------|-------------|
| [Zellij](https://zellij.dev/) | Terminal multiplexer |
| [Helix](https://helix-editor.com/) | Modal text editor |
| [Yazi](https://yazi-rs.github.io/) | Terminal file manager |
| [GitUI](https://github.com/extrawurst/gitui) | Git TUI |
| [gwq](https://github.com/d-kuro/gwq) | Git worktree manager |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [fd](https://github.com/sharkdp/fd) | Fast file finder |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep |

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

## Terminal Configuration

macOSではOptionキーをAltキーとして認識させる設定が必要です。

### Ghostty

`~/.config/ghostty/config` または `~/Library/Application Support/com.mitchellh.ghostty/config`:

```
macos-option-as-alt = left
keybind = alt+left=unbind
keybind = alt+right=unbind
```

※ `alt+left`/`alt+right`のunbindはZellijのペイン移動キーバインド（`Alt+h/l`）との衝突を回避するため

### iTerm2

Preferences → Profiles → Keys → Left Option Key → `Esc+`

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
