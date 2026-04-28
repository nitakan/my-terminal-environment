# Codex CLI リファレンス

## 主要サブコマンド

### `codex exec [PROMPT]` (alias: `e`) - 非インタラクティブ実行

TUIなしで実行する。Claude Codeからの利用はこのモードを使う。

オプション:
- `-c, --config <key=value>` - 設定値のオーバーライド（TOML形式）
- `--enable <FEATURE>` / `--disable <FEATURE>` - フィーチャーフラグの有効化/無効化
- `-i, --image <FILE>...` - 画像添付
- `-s, --sandbox <MODE>` - サンドボックスポリシー: `read-only`, `workspace-write`, `danger-full-access`
- `-p, --profile <PROFILE>` - `~/.codex/config.toml` のプロファイル選択
- `--full-auto` - 低摩擦自動実行（`-a on-request --sandbox workspace-write` のエイリアス）
- `-C, --cd <DIR>` - 作業ディレクトリ指定
- `--skip-git-repo-check` - Gitリポジトリ外での実行を許可
- `--add-dir <DIR>` - 追加の書き込み可能ディレクトリ
- `--ephemeral` - セッションファイルをディスクに保存しない
- `--output-schema <FILE>` - 出力のJSONスキーマ指定
- `--json` - JSONL形式でイベントを出力
- `-o, --output-last-message <FILE>` - 最後のメッセージをファイルに出力
- `--color <COLOR>` - カラー出力: `always`, `never`, `auto`
- プロンプト未指定時はstdinから読み取り

### `codex exec resume [SESSION_ID] [PROMPT]` - セッション引き継ぎ実行

以前のセッションを引き継いで非インタラクティブに実行する。

オプション:
- `--last` - 最新のセッションを即座に引き継ぎ
- `--all` - cwdフィルタを無効化し全セッション表示
- `--full-auto` - サンドボックス内自動実行
- `--ephemeral` - セッションを保存しない
- `--json` - JSONL形式で出力
- `-o <FILE>` - 最後のメッセージをファイルに出力
- セッションIDはUUIDまたはスレッド名

### `codex review [PROMPT]` - コードレビュー

非インタラクティブでコードレビューを実行する。

オプション:
- `--uncommitted` - ステージ済み・未ステージ・未追跡の変更をレビュー
- `--base <BRANCH>` - 指定ブランチとの差分をレビュー
- `--commit <SHA>` - 特定コミットの変更をレビュー
- `--title <TITLE>` - レビューサマリーに表示するタイトル

### `codex cloud` - Codex Cloud（実験的）

クラウドでタスクを実行し、結果をローカルに適用する。

サブコマンド:
- `exec` - 新しいクラウドタスクをTUIなしで投入
- `status` - タスクのステータス確認
- `list` - タスク一覧
- `apply` - クラウドタスクのdiffをローカルに適用
- `diff` - クラウドタスクのunified diffを表示

### `codex apply` (alias: `a`) - diff適用

最新のCodexエージェントが生成したdiffを `git apply` でローカルに適用する。

## その他のサブコマンド

- `codex resume [SESSION_ID]` - 対話モードでセッション再開（参考用）
- `codex fork [SESSION_ID]` - セッションを分岐（参考用）
- `codex login` / `codex logout` - 認証管理
- `codex mcp` - 外部MCPサーバー管理（`list`, `get`, `add`, `remove`）
- `codex mcp-server` - Codex自身をMCPサーバーとして起動
- `codex completion` - シェル補完スクリプト生成
- `codex sandbox` - Codexサンドボックス内でコマンド実行
- `codex debug` - デバッグツール
- `codex features` - フィーチャーフラグの確認
- `codex app` / `codex app-server` - デスクトップアプリ関連

## 設定ファイル

`~/.codex/config.toml` で永続的な設定を管理。`-c` フラグでセッション単位のオーバーライドが可能。

```toml
sandbox_permissions = ["disk-full-read-access"]

[shell_environment_policy]
inherit = "all"
```

プロファイル機能で用途別の設定を切り替え可能:
```toml
[profile.review]
# review用の設定

[profile.fast]
# 高速実行用の設定
```
