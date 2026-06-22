# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

tmux + Helix + lazygit を中心としたターミナル開発環境と、再利用可能なzsh設定テンプレート、Claude Code 設定を統合したリポジトリ。
シンボリックリンクベースで設定を管理し、カスタムスクリプトでツール間を連携させる。

（元は Zellij ベースのIDE環境として出発したが、現在は tmux ベースに移行済み。参考: https://zenn.dev/spacemarket/articles/192a58e9177961）

## セットアップとテスト

```bash
# Makefileを使用（推奨）
make install          # ターミナル環境 + zsh + Claude
make install-all      # Homebrew + ターミナル環境 + zsh + Claude
make install-homebrew # Homebrew依存 + miseランタイム
make install-ide      # ターミナル環境（tmux, Helix）のみ
make install-zsh      # zsh設定のみ
make install-claude   # Claude Code設定のみ
make uninstall        # ターミナル環境 + zsh + Claude削除
make help             # ヘルプ表示

# シェルスクリプトを直接実行（レガシー）
./install.sh                   # ターミナル環境 + zsh + Claude
./install.sh --with-homebrew   # Homebrew依存も含む
./scripts/install-homebrew.sh  # Homebrew + mise
./scripts/install-ide.sh       # ターミナル環境
./scripts/install-zsh.sh       # zsh設定
./scripts/install-claude.sh    # Claude Code設定

# 動作確認
tmux  # tmux を起動
```

## アーキテクチャ

### ディレクトリ構造
- `config/`: 各ツールの設定ファイル（シンボリックリンク元）
  - `tmux/tmux.conf`: tmux設定
  - `claude/statusline-script.sh`: Claude Code ステータスライン用スクリプト
- `bin/`: tmux連携スクリプト + AIユーティリティ
  - `tmux-worktree`: worktree選択/作成して tmux 新ウィンドウで開く
  - `tmux-layout`: tmux レイアウト選択・適用
  - `tmux-layout-claude`: Claude 用レイアウト特化版
  - `aico`: AIコミットメッセージ生成
  - `aipr`: AI PR説明生成
- `scripts/`: インストールスクリプト（分割）
  - `common.sh`: 共通関数
  - `install-homebrew.sh`: Homebrew依存 + miseランタイム
  - `install-ide.sh`: ターミナル環境（tmux, Helix）
  - `install-zsh.sh`: zsh設定
  - `install-claude.sh`: Claude Code設定
- `claude/`: Claude Code設定（`~/.claude/` へのシンボリックリンク元）
  - `CLAUDE.md`: グローバル指示
  - `rules/`: プロジェクトルール群の .md
  - `settings.json`: permissions/hooks/plugins設定
  - `scripts/`: hookスクリプト（例: deny-check.sh）
  - `skills/`: カスタムskill
- `zsh/`: zsh設定テンプレート
  - `modules/`: コア設定ファイル
  - `modules/optional/`: オプショナル設定（Flutter, Bun, Deno, gcloud）
  - `git/`: Git補完・プロンプト用スクリプト
  - `main.zsh`, `zprofile`: エントリーポイント
  - `secrets.example`: 機密情報のテンプレート
  - `local.zsh.example`: マシン固有設定のテンプレート

### シンボリックリンク構造
install.shが以下を実行:

**ターミナル環境 (`--ide-only` または `--all`)**:
1. `~/.tmux.conf` ← `config/tmux/tmux.conf`

**zsh設定 (`--zsh-only` または `--all`)**:
1. `~/.zshrc` (実ファイル) - `zsh/main.zsh` を呼び出す
2. `~/.zprofile` ← `zsh/zprofile`
3. `~/.zsh/` ← `zsh/` （ディレクトリ自体をリンク）

**Claude Code設定 (`--claude-only` または `--all`)**:
1. `~/.claude/CLAUDE.md` ← `claude/CLAUDE.md`
2. `~/.claude/rules/` ← `claude/rules/`
3. `~/.claude/settings.json` ← `claude/settings.json`
4. `~/.claude/scripts/` ← `claude/scripts/`
5. `~/.claude/skills/` ← `claude/skills/`

### ツール間連携の仕組み

**tmux キーバインド** (`config/tmux/tmux.conf`、prefix = `Ctrl+q`):
- `Ctrl+q \` / `Ctrl+q -`（prefix不要版 `Alt+\` / `Alt+-`）: ペインを縦/横分割
- `Alt+h/j/k/l`（および矢印キー）: ペイン間移動（prefix不要）
- `Alt+z`: ペインのズーム切り替え（prefix不要）
- `Alt+[` / `Alt+]`: ウィンドウ切り替え（prefix不要）
- `Alt+f`（または `Ctrl+q f`）: ポップアップでシェル(zsh)起動
- `Ctrl+q g`: lazygit をポップアップ起動
- `Ctrl+q e`: Helix (hx) をポップアップ起動
- `Ctrl+q w`: tmux-worktree（worktree 選択/作成して新ウィンドウで開く）
- `Ctrl+q l`: tmux-layout（レイアウト選択）
- `Ctrl+q r`: 設定リロード

**worktree 連携** (`bin/tmux-worktree`):
- `gwq list --json` の結果を `jq` でパースし、fzf で worktree を選択（新規作成・既存ブランチからの作成も可能）
- 選択した worktree を tmux の新ウィンドウで開く（`Ctrl+q w` から起動）

**レイアウト適用** (`bin/tmux-layout` / `bin/tmux-layout-claude`):
- `tmux-layout` が fzf でレイアウトを選択し、対応するスクリプトを呼び出す（`Ctrl+q l` から起動）
- `tmux-layout-claude` は `tmux split-window` / `tmux send-keys` でペインを構成する Claude 用レイアウト

**ポップアップ連携**:
- lazygit / Helix はそれぞれ `display-popup -E` でフローティング起動する（tmux.conf 内で定義）

## 設定ファイル編集時の注意

### tmux設定 (`config/tmux/tmux.conf`)
- prefix は `Ctrl+q`（`unbind C-b` で既定の `Ctrl+b` を無効化）
- prefix不要のバインドは `bind -n`（例: `Alt+h/j/k/l` でペイン移動）
- lazygit / Helix / シェル / worktree / レイアウトは `display-popup -E` でポップアップ起動
- 変更後は `Ctrl+q r`（`source-file ~/.tmux.conf`）でリロード

### スクリプト編集 (`bin/`)
- `tmux-worktree`: `gwq` + `jq` + fzf で worktree を選択/作成し、tmux 新ウィンドウで開く（`Ctrl+q w`）
- `tmux-layout`: fzf でレイアウトを選択し、対応する適用スクリプトを呼び出す（`Ctrl+q l`）
- `tmux-layout-claude`: `tmux split-window` / `send-keys` で Claude 用レイアウトを構成
- `aico`: AIコミットメッセージ生成
- `aipr`: AI PR説明生成（`-b` でベースブランチ指定可能）

### GitHubアカウント切り替え (`zsh/modules/gh-account.zsh`)
- リポジトリの `origin` リモートから gh アカウントを判定し `GH_TOKEN` を自動切替（`chpwd` フック）
- マッピングは `~/.zsh/local.zsh`（Git管理外）に定義する（`zsh/local.zsh.example` を参照）
- `ghs` で現在のリポジトリのアカウントを再判定・確認できる

### zsh設定 (`zsh/`)

**モジュール構成**:
- `modules/basic.zsh`: 基本設定（履歴、補完）
- `modules/exports.zsh`: PATH設定、環境変数
- `modules/alias.zsh`: エイリアス定義
- `modules/environment.zsh`: mise, Homebrew初期化
- `modules/prompts.zsh`: カスタムプロンプト（Git状態表示）
- `modules/git.zsh`: Git関連設定（ssh-add）
- `modules/gh-account.zsh`: リポジトリ単位の GitHub アカウント自動切替
- `modules/completions.zsh`: 補完設定
- `modules/optional/*.zsh`: オプショナル設定（Flutter, Bun, Deno, gcloud）

**カスタマイズ方法**:
1. **機密情報**: `~/.zsh/secrets` に記載（`zsh/secrets.example`を参考に）
2. **マシン固有設定**: `~/.zsh/local.zsh` に記載（`zsh/local.zsh.example`から自動生成、Git管理外）
3. **個人設定**: `~/.zshrc` に追記（実ファイルなので自由に編集可能）
4. **GitHubアカウント情報**: `~/.zsh/local.zsh` に `GH_ACCOUNT_RULES` / `GH_ACCOUNT_DEFAULT` を定義（`gh-account.zsh` が参照）

**セキュリティとGit管理**:
- `zsh/secrets.example` はテンプレート。実際のAPIキーは `~/.zsh/secrets` に記載（Git管理外）
- `zsh/local.zsh.example` はテンプレート（Git管理）。`local.zsh` はinstall.sh実行時に自動生成（Git管理外）
- `.gitignore` で `zsh/secrets` と `zsh/local.zsh` を除外済み

### bin/ スクリプトのPATH管理

`bin/` ディレクトリはリポジトリから直接PATHに追加される（`~/.zsh` symlinkからリポジトリルートを逆算）。
新しいスクリプトを `bin/` に追加するだけで自動的に使えるようになる。個別のsymlink登録は不要。

## 依存関係

**必須ツール** (Homebrewでインストール):
- tmux (terminal multiplexer)
- helix (modal editor)
- lazygit (git TUI)
- gwq (git worktree manager / `d-kuro/tap/gwq`)
- fzf, fd, ripgrep (検索ツール)
- gh (GitHub CLI)
- mise (複数言語のバージョン管理)
- ghostty (ターミナルエミュレータ / cask)

**mise.tomlで管理**: `mise install` でランタイムをインストール

**Brewfileで管理**: `./install.sh --with-homebrew` で一括インストール可能

**macOS固有の設定**:
- ターミナルでOptionキーをAltとして認識させる設定が必要
- Ghostty: `macos-option-as-alt = left`
- iTerm2: Preferences → Profiles → Keys → Left Option Key → `Esc+`

## 既知の制約

1. **tmux前提のキーバインド**: `Alt+*` のバインドはターミナル側で Option を Alt として送る設定が前提（macOS では下記の設定が必要）
2. **macOS専用**: Optionキー設定など、macOS前提の設定がある
3. **シンボリックリンク管理**: 既存設定がある場合は`.bak`でバックアップ。手動削除が必要な場合がある
