# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Zellij + Yazi + Helix + GitUI を統合したターミナルIDE環境と、再利用可能なzsh設定テンプレート。
シンボリックリンクベースで設定を管理し、カスタムスクリプトでツール間を連携させる。

参考: https://zenn.dev/spacemarket/articles/192a58e9177961

## セットアップとテスト

```bash
# すべてインストール（IDE + zsh）
./install.sh

# オプション指定でインストール
./install.sh --ide-only      # IDE環境のみ
./install.sh --zsh-only      # zsh設定のみ
./install.sh --with-homebrew # Brewfileから依存パッケージをインストール

# 動作確認
zellij  # IDE layoutが自動起動

# アンインストール
./uninstall.sh
./uninstall.sh --ide-only    # IDE環境のみ削除
./uninstall.sh --zsh-only    # zsh設定のみ削除
```

## アーキテクチャ

### ディレクトリ構造
- `config/`: 各ツールの設定ファイル（シンボリックリンク元）
- `bin/`: ツール間連携スクリプト + Git関連ユーティリティ
- `zsh/`: zsh設定テンプレート
  - `modules/`: コア設定ファイル
  - `modules/optional/`: オプショナル設定（Flutter, Bun, Deno, gcloud）
  - `git/`: Git補完・プロンプト用スクリプト
  - `main.zsh`, `zprofile`: エントリーポイント
  - `secrets.example`: 機密情報のテンプレート
  - `local.zsh.example`: マシン固有設定のテンプレート

### シンボリックリンク構造
install.shが以下を実行:

**IDE環境 (`--ide-only` または `--all`)**:
1. `~/.config/zellij/` ← `config/zellij/`
2. `~/.config/yazi-one/` ← `config/yazi-one/`
3. `~/.local/bin/` ← `bin/` (zellij-open, yazi-one, zellij-worktree, git-switch, github-switch)

**zsh設定 (`--zsh-only` または `--all`)**:
1. `~/.zshrc` (実ファイル) - `zsh/main.zsh` を呼び出す
2. `~/.zprofile` ← `zsh/zprofile`
3. `~/.zsh/` ← `zsh/` （ディレクトリ自体をリンク）

### ツール間連携の仕組み

**Yazi → Helix 連携**:
1. `yazi.toml`: ファイル開く際に `zellij-open` スクリプトを呼び出す
2. `keymap.toml`: `Alt+Enter`/`N` で新規バッファに開く
3. `bin/zellij-open`: Zellijのaction APIを使ってHelixにコマンド送信
   - `zellij action write-chars ":open $filepath"` でHelixコマンド実行

**Zellij レイアウト** (`layouts/ide.kdl`):
```
[Explorer(yazi)] [Editor(helix)] [Git(collapsed)]
                 [Implement]     [Review(expanded)]
```

**キーバインディング** (`config.kdl`):
- `Ctrl+Shift+g`: gitui をフローティングペインで起動
- `Alt+h/j/k/l`: ペイン間移動
- `Ctrl+p`/`Ctrl+t`: ペイン/タブモード

## 設定ファイル編集時の注意

### Zellij設定 (`config/zellij/config.kdl`)
- キーバインディングは`keybinds clear-defaults=true`で完全カスタム
- `default_layout "ide"`でIDEレイアウトを自動起動
- 変更後はZellijの再起動が必要

### Yazi設定
- `yazi.toml`: opener設定（どのコマンドでファイルを開くか）
- `keymap.toml`: キーバインディング（`[[mgr.prepend_keymap]]`で既存を上書き）

### スクリプト編集 (`bin/`)
- `zellij-open`: Helix連携の中核。Zellij action APIの仕様に依存
- `yazi-one`: YAZI_CONFIG_HOME を設定して独立した設定を使用
- `zellij-worktree`: Ctrl+w で worktree 選択・作成し、IDE レイアウトのタブで開く
- `git-switch`: fzfでGitアカウントを切り替え（カスタマイズ必要）
- `github-switch`: gh CLI でGitHubアカウントを切り替え

### zsh設定 (`zsh/`)

**モジュール構成**:
- `modules/basic.zsh`: 基本設定（履歴、補完）
- `modules/exports.zsh`: PATH設定、環境変数
- `modules/alias.zsh`: エイリアス定義
- `modules/environment.zsh`: mise, Homebrew初期化
- `modules/prompts.zsh`: カスタムプロンプト（Git状態表示）
- `modules/git.zsh`: Git関連設定（ssh-add）
- `modules/completions.zsh`: 補完設定
- `modules/optional/*.zsh`: オプショナル設定（Flutter, Bun, Deno, gcloud）

**カスタマイズ方法**:
1. **機密情報**: `~/.zsh/secrets` に記載（`zsh/secrets.example`を参考に）
2. **マシン固有設定**: `~/.zsh/local.zsh` に記載（`zsh/local.zsh.example`から自動生成、Git管理外）
3. **個人設定**: `~/.zshrc` に追記（実ファイルなので自由に編集可能）
4. **アカウント情報**: `bin/git-switch` と `bin/github-switch` のTODOコメント箇所を編集

**セキュリティとGit管理**:
- `zsh/secrets.example` はテンプレート。実際のAPIキーは `~/.zsh/secrets` に記載（Git管理外）
- `zsh/local.zsh.example` はテンプレート（Git管理）。`local.zsh` はinstall.sh実行時に自動生成（Git管理外）
- `.gitignore` で `zsh/secrets` と `zsh/local.zsh` を除外済み

### **重要: 新規スクリプト追加時の必須作業**

`bin/` に新しいスクリプトを追加した場合、**必ず以下の2ファイルを更新すること**：

1. **`install.sh`** - 3箇所に追加:
   ```bash
   # 1. backup_if_exists の追加
   backup_if_exists ~/.local/bin/新規スクリプト名

   # 2. シンボリックリンク作成の追加
   ln -s "$SCRIPT_DIR/bin/新規スクリプト名" ~/.local/bin/新規スクリプト名

   # 3. chmod +x の引数に追加
   chmod +x "$SCRIPT_DIR/bin/既存スクリプト" "$SCRIPT_DIR/bin/新規スクリプト名"
   ```

2. **`uninstall.sh`** - 削除処理を追加:
   ```bash
   remove_symlink ~/.local/bin/新規スクリプト名
   ```

これを忘れると、`install.sh` を実行してもスクリプトが `~/.local/bin/` にリンクされず、コマンドが使えない。

## 依存関係

**必須ツール** (Homebrewでインストール):
- zellij (terminal multiplexer)
- helix (modal editor)
- yazi (file manager)
- gitui (git TUI)
- gwq (git worktree manager)
- fzf, fd, ripgrep (検索ツール)
- gh (GitHub CLI)
- mise (複数言語のバージョン管理)

**Brewfileで管理**: `./install.sh --with-homebrew` で一括インストール可能

**macOS固有の設定**:
- ターミナルでOptionキーをAltとして認識させる設定が必要
- Ghostty: `macos-option-as-alt = left`
- iTerm2: Preferences → Profiles → Keys → Left Option Key → `Esc+`

## 既知の制約

1. **Zellij action API依存**: `zellij-open`スクリプトはZellijのaction APIに強く依存。APIが変更されると動作しなくなる可能性
2. **macOS専用**: Optionキー設定など、macOS前提の設定がある
3. **シンボリックリンク管理**: 既存設定がある場合は`.bak`でバックアップ。手動削除が必要な場合がある
