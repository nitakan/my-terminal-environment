# My Terminal Environment

Zellij + Yazi + Helix + GitUI を統合したターミナルIDE環境と、再利用可能なzsh設定テンプレート。

参考: [ターミナルだけで開発していく夢をZellijで叶える](https://zenn.dev/spacemarket/articles/192a58e9177961)

## Features

- **IDE環境**: Zellij レイアウトでエディタ・ファイラー・Git UIを統合
- **zsh設定**: モジュール化された設定テンプレート
- **バージョン管理**: mise による複数言語のランタイム管理

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
| [mise](https://mise.jdx.dev/) | Runtime version manager |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [fd](https://github.com/sharkdp/fd) | Fast file finder |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep |

## Requirements

- macOS
- Homebrew

## Installation

```bash
git clone <this-repo> ~/my-terminal-environment
cd ~/my-terminal-environment

# ヘルプ表示
make

# IDE + zsh設定をインストール
make install

# Homebrew依存パッケージ + miseランタイムも含める
make install-all

# 個別インストール
make install-homebrew  # Homebrew + mise
make install-ide       # IDE環境のみ
make install-zsh       # zsh設定のみ
```

## Usage

```bash
zellij
```

### Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+Shift+g` | Open gitui in floating pane |
| `Ctrl+w` | Open worktree selector |
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

### iTerm2

Preferences → Profiles → Keys → Left Option Key → `Esc+`

## Customization

### 機密情報

`~/.zsh/secrets` にAPIキー等を記載（`zsh/secrets.example` を参照）

### マシン固有設定

`~/.zsh/local.zsh` にマシン固有の設定を記載

### Gitアカウント切り替え

`bin/git-switch` と `bin/github-switch` のTODOコメント箇所を編集

## Uninstall

```bash
make uninstall

# Homebrewパッケージも削除する場合
brew uninstall zellij yazi helix gitui gh mise
```

## Files

```
my-terminal-environment/
├── Makefile              # インストール/アンインストール
├── Brewfile              # Homebrew依存パッケージ
├── mise.toml             # ランタイムバージョン定義
├── install.sh            # インストールスクリプト（レガシー）
├── uninstall.sh          # アンインストールスクリプト（レガシー）
├── scripts/
│   ├── common.sh         # 共通関数
│   ├── install-homebrew.sh
│   ├── install-ide.sh
│   └── install-zsh.sh
├── config/
│   ├── zellij/
│   │   ├── config.kdl    # Zellij設定
│   │   └── layouts/
│   │       └── ide.kdl   # IDEレイアウト
│   └── yazi-one/
│       ├── keymap.toml   # Yaziキーバインド
│       └── yazi.toml     # Yaziオープナー設定
├── bin/
│   ├── zellij-open       # Helix連携スクリプト
│   ├── yazi-one          # Yaziラッパー
│   ├── zellij-worktree   # Worktree選択
│   ├── git-switch        # Gitアカウント切り替え
│   └── github-switch     # GitHubアカウント切り替え
└── zsh/
    ├── main.zsh          # エントリーポイント
    ├── zprofile          # ログインシェル設定
    ├── modules/          # コアモジュール
    │   ├── basic.zsh
    │   ├── exports.zsh
    │   ├── alias.zsh
    │   ├── environment.zsh
    │   ├── prompts.zsh
    │   ├── git.zsh
    │   ├── completions.zsh
    │   └── optional/     # オプショナルモジュール
    ├── git/              # Git補完スクリプト
    ├── secrets.example   # 機密情報テンプレート
    └── local.zsh.example # マシン固有設定テンプレート
```
