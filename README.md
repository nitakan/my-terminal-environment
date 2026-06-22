# My Terminal Environment

tmux + Helix + lazygit を中心としたターミナル開発環境、再利用可能なzsh設定テンプレート、そして Claude Code 設定を統合したリポジトリ。シンボリックリンクで設定を管理する。

> 元は Zellij ベースのIDE環境（参考: [ターミナルだけで開発していく夢をZellijで叶える](https://zenn.dev/spacemarket/articles/192a58e9177961)）として出発したが、現在は tmux ベースに移行している。

## Features

- **ターミナル環境**: tmux を multiplexer に、Helix エディタと lazygit を連携
- **zsh設定**: モジュール化された設定テンプレート
- **Claude Code設定**: グローバル指示・ルール・skill・hook をシンボリックリンクで管理
- **バージョン管理**: mise による複数言語のランタイム管理

## Tools

| Tool | Description |
|------|-------------|
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| [Helix](https://helix-editor.com/) | Modal text editor |
| [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI |
| [gwq](https://github.com/d-kuro/gwq) | Git worktree manager |
| [mise](https://mise.jdx.dev/) | Runtime version manager |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [fd](https://github.com/sharkdp/fd) | Fast file finder |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep |
| [gh](https://cli.github.com/) | GitHub CLI |
| [Ghostty](https://ghostty.org/) | Terminal emulator |

## Requirements

- macOS
- Homebrew

## Installation

```bash
git clone <this-repo> ~/my-terminal-environment
cd ~/my-terminal-environment

# ヘルプ表示
make

# ターミナル環境 + zsh + Claude設定をインストール
make install

# Homebrew依存パッケージ + miseランタイムも含める
make install-all

# 個別インストール
make install-homebrew  # Homebrew + mise
make install-ide       # ターミナル環境（tmux, Helix）
make install-zsh       # zsh設定のみ
make install-claude    # Claude Code設定のみ
```

## Usage

```bash
tmux
```

### Keybindings

tmux の prefix は `Ctrl+q`。

| Key | Action |
|-----|--------|
| `Ctrl+q \` / `Ctrl+q -` | ペインを縦/横分割 |
| `Ctrl+q g` | lazygit をポップアップで起動 |
| `Ctrl+q e` | Helix (hx) をポップアップで起動 |
| `Ctrl+q w` | worktree を選択/作成して新ウィンドウで開く（tmux-worktree） |
| `Ctrl+q l` | レイアウト選択（tmux-layout） |
| `Ctrl+q r` | 設定リロード |

### Pane / Window Navigation

prefix 不要で操作できるバインドも用意している。

| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | ペイン間移動 |
| `Alt+←/↓/↑/→` | ペイン間移動（矢印キー） |
| `Alt+\` / `Alt+-` | ペインを縦/横分割 |
| `Alt+z` | ペインのズーム切り替え |
| `Alt+[` / `Alt+]` | ウィンドウ切り替え |
| `Alt+f` | ポップアップでシェル(zsh)起動 |

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

`~/.zsh/local.zsh` にマシン固有の設定を記載（`zsh/local.zsh.example` から自動生成）

### GitHubアカウント切り替え

`zsh/modules/gh-account.zsh` がリポジトリの `origin` リモートからアカウントを判定して `GH_TOKEN` を自動切替する。マッピングは `~/.zsh/local.zsh` に定義する（`zsh/local.zsh.example` を参照）。現在のリポジトリで再判定したいときは `ghs` を実行する。

## Helper Commands

`bin/` 配下のスクリプトは zsh 設定経由で PATH に追加される。

| Command | Description |
|---------|-------------|
| `aico` | AI によるコミットメッセージ生成 |
| `aipr` | AI による PR 説明生成（`-b` でベースブランチ指定） |
| `tmux-worktree` | worktree を選択/作成して tmux 新ウィンドウで開く |
| `tmux-layout` | tmux レイアウトを選択して適用 |

## Uninstall

```bash
make uninstall

# Homebrewパッケージも削除する場合
brew uninstall tmux helix lazygit gwq fzf fd ripgrep gh mise
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
│   ├── install-zsh.sh
│   └── install-claude.sh
├── config/
│   ├── tmux/
│   │   └── tmux.conf     # tmux設定
│   └── claude/
│       └── statusline-script.sh  # ステータスライン用スクリプト
├── bin/
│   ├── aico              # AIコミットメッセージ生成
│   ├── aipr              # AI PR説明生成
│   ├── tmux-worktree     # worktree選択/作成
│   ├── tmux-layout       # レイアウト選択
│   └── tmux-layout-claude # Claude用レイアウト
├── claude/               # Claude Code設定（~/.claude/ へリンク）
│   ├── CLAUDE.md         # グローバル指示
│   ├── rules/            # プロジェクトルール群
│   ├── settings.json     # permissions/hooks/plugins設定
│   ├── scripts/          # hookスクリプト
│   └── skills/           # カスタムskill
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
    │   ├── gh-account.zsh
    │   ├── completions.zsh
    │   └── optional/     # オプショナルモジュール
    ├── git/              # Git補完スクリプト
    ├── secrets.example   # 機密情報テンプレート
    └── local.zsh.example # マシン固有設定テンプレート
```
</content>
</invoke>
