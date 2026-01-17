# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Zellij + Yazi + Helix + GitUI を統合したターミナルIDE環境。
シンボリックリンクベースで設定を管理し、カスタムスクリプトでツール間を連携させる。

参考: https://zenn.dev/spacemarket/articles/192a58e9177961

## セットアップとテスト

```bash
# 環境構築
./install.sh

# 動作確認
zellij  # IDE layoutが自動起動

# アンインストール
./uninstall.sh
```

## アーキテクチャ

### ディレクトリ構造
- `config/`: 各ツールの設定ファイル（シンボリックリンク元）
- `bin/`: ツール間連携スクリプト

### シンボリックリンク構造
install.shが以下を実行:
1. `~/.config/zellij/` ← `config/zellij/`
2. `~/.config/yazi-one/` ← `config/yazi-one/`
3. `~/.local/bin/` ← `bin/`

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

**macOS固有の設定**:
- ターミナルでOptionキーをAltとして認識させる設定が必要
- Ghostty: `macos-option-as-alt = left`
- iTerm2: Preferences → Profiles → Keys → Left Option Key → `Esc+`

## 既知の制約

1. **Zellij action API依存**: `zellij-open`スクリプトはZellijのaction APIに強く依存。APIが変更されると動作しなくなる可能性
2. **macOS専用**: Optionキー設定など、macOS前提の設定がある
3. **シンボリックリンク管理**: 既存設定がある場合は`.bak`でバックアップ。手動削除が必要な場合がある
