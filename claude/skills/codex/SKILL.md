---
name: codex
description: >
  This skill should be used when the user asks to "use Codex", "run Codex",
  "Codexで実装して", "Codexにやらせて", "Codexでレビューして",
  "delegate to Codex", "Codexに委任", "codex exec", "codex review",
  "Codexセッション", "Codex Cloud", or when the user wants to delegate
  coding tasks to OpenAI's Codex agent from within Claude Code.
---

# Codex Integration Skill

OpenAI Codex CLI を Claude Code 内から Bash ツール経由で活用するためのスキル。
すべての実行は非インタラクティブモード (`codex exec`) で行う。

## 基本実行

### 新規タスクの実行

`codex exec` で非インタラクティブにタスクを実行する。`--full-auto` を付けてサンドボックス内で自動実行する。

```bash
codex exec --full-auto "タスクの指示"
```

`--full-auto` は `--sandbox workspace-write -a on-request` のエイリアス。
ファイル変更を伴う実装タスクに適する。

読み取りのみのタスク（調査、分析等）の場合:

```bash
codex exec "コードベースの依存関係を分析して"
```

### セッションの引き継ぎ

同一会話内で既にCodexを実行した場合、`codex exec resume` で前回のセッションを引き継ぐ。
Codexに蓄積されたコンテキストを活用し、一貫した作業を続行できる。

```bash
# 最新セッションを引き継いで追加指示
codex exec resume --last "テストも追加して" --full-auto

# 特定セッションIDを指定して引き継ぎ
codex exec resume <SESSION_ID> "エラーハンドリングを改善して" --full-auto
```

**セッション引き継ぎの判断基準:**
- 同一会話内で既にCodexを使った → `codex exec resume --last`
- 初回のCodex利用 → `codex exec`

### 出力の取得

最後のメッセージをファイルに保存して後続処理に使う:

```bash
codex exec --full-auto -o /tmp/codex-output.txt "タスク指示"
```

JSONL形式でイベントストリームを取得:

```bash
codex exec --full-auto --json "タスク指示"
```

## コードレビュー

```bash
# 未コミットの変更をレビュー
codex review --uncommitted

# 特定ブランチとの差分をレビュー
codex review --base main

# 特定コミットをレビュー
codex review --commit abc123

# カスタム指示付きレビュー
codex review --base main "セキュリティの観点で重点的にレビューして"
```

## Codex Cloud（実験的）

バックグラウンドでタスクを実行し、結果を後からローカルに適用する。

```bash
# タスク投入
codex cloud exec "リファクタリング: 認証モジュールをクリーンアーキテクチャに移行"

# ステータス確認・diff確認・適用
codex cloud status
codex cloud diff
codex cloud apply
```

## diff の適用

Codexが生成した最新のdiffをローカルに適用:

```bash
codex apply
```

## 重要なオプション

| オプション | 説明 |
|---|---|
| `--full-auto` | サンドボックス内自動実行（実装タスク向け） |
| `-C, --cd <DIR>` | 作業ディレクトリ指定 |
| `--skip-git-repo-check` | Gitリポジトリ外での実行を許可 |
| `--ephemeral` | セッションを保存しない |
| `-o <FILE>` | 最後のメッセージをファイルに出力 |
| `--json` | JSONL形式で出力 |
| `-i, --image <FILE>` | 画像を添付 |
| `-p, --profile <NAME>` | config.tomlのプロファイル選択 |

## タスク委任のベストプラクティス

### 効果的なプロンプト

具体的なファイルパス、スコープ、期待する結果を含める。

```
# 良い例
"src/api/users.tsのgetUser関数にキャッシュレイヤーを追加して。
 Redisクライアントはsrc/lib/redis.tsに既にある。TTLは300秒。"

# 悪い例
"キャッシュを追加して"
```

### Codexに委任すべきタスク

- 明確に定義された実装タスク（関数追加、リファクタリング等）
- コードレビュー
- テストの作成
- ドキュメント生成
- 定型的なコード変更

### Claude Code側で処理すべきタスク

- アーキテクチャの設計判断
- 複数エージェント間の調整
- ユーザーとのインタラクティブな議論
- Claude Code固有の機能（メモリ、タスク管理等）

## リファレンス

詳細なCLIオプション、全サブコマンドのヘルプは以下を参照:
- **`references/cli-reference.md`** - Codex CLI 全コマンド・オプションの詳細リファレンス
