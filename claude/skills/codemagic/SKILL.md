---
name: codemagic
description: >
  This skill should be used when the user wants to retrieve or monitor build
  information from Codemagic CI/CD via its REST API — listing builds, checking a
  build's status, polling a build until it finishes, inspecting build
  steps/actions, or downloading build artifacts.
  発火する発話の例:「Codemagic のビルド情報を取得」「Codemagic のビルド一覧/ステータスを確認」
  「最新ビルドの結果を見て」「ビルドの完了を監視して」「Store Upload を監視」
  「開発ビルド（iOS）の状況を確認」「Inventy のビルドを見て」
  「Codemagic のアーティファクトをダウンロード」「get/monitor Codemagic builds」
  「check Codemagic build status」。
  対象は参照系（GET）のみ。ビルドの起動・キャンセルは本スキルの範囲外。
---

# Codemagic REST API — ビルド情報取得 / 監視

Codemagic CI/CD の参照系 API を、**このスキルに同梱した検証済みスクリプト `cmapi` 経由**で叩く。
生 `curl` を都度書かず、決定論的なスクリプトに集約している。対象は GET のみ（起動・キャンセルは範囲外）。

## 目的（Why）

「最新ビルドは成功したか」「どの artifact が出たか」「Store Upload は終わったか」を、
Codemagic UI を開かずコマンドラインで確実に取得・監視する。CI 状態確認・自動化・他ツール連携に使う。

## まず使うもの: `cmapi`

実行パス（このスキルに同梱・全サブコマンド検証済み）:

```bash
CM=~/.claude/skills/codemagic/scripts/cmapi
```

- 認証は環境変数 **`CM_API_TOKEN`**（`x-auth-token` で送る。未設定なら案内して停止）。
  発行: `Teams > Personal Account > Integrations > Codemagic API > Show`。保管例: `~/.zsh/secrets`（Git管理外）。
- アプリ・ワークフローは**名前でも id でも**指定可（名前は API から解決、大小文字無視）。
- 出力は **JSON（stdout）**、進捗・エラーは stderr。`cmapi -h` で usage。

| サブコマンド | 引数 | 出力 / 用途 |
|---|---|---|
| `apps` | — | `[{id,name,last_build_id}]` |
| `workflows` | `<app>` | `[{id,name}]`（ワークフロー名↔id） |
| `builds` | `<app> [--workflow w] [--status s] [--limit N=20]` | 新しい順 `[{id,index,status,branch,tag,workflow,created_at}]` |
| `latest` | `<app> [--workflow w] [--tag t]` | 条件に合う**最新1件**の詳細 |
| `build` | `<build_id>` | 単一ビルド詳細（status / commit / artifacts 等） |
| `actions` | `<build_id>` | `[{name,status}]`（失敗ステップ特定。ログ代替） |
| `artifacts` | `<build_id> [--type t] [--url]` | artifact 一覧 / `--url` で短命DL URL |
| `wait` | `<build_id>` または `--app <app> [--workflow w]` `[--interval 30] [--max 45]` | 終端まで監視。終了コード **finished=0 / 他終端=1 / タイムアウト=2** |

実行例:

```bash
$CM apps
$CM workflows Inventy
$CM builds Inventy --workflow "App Distribution Build" --status finished --limit 5
$CM latest Inventy --workflow "Upload Store"
$CM build 6a41f3e01697b5140111b020
$CM actions 6a41f3e01697b5140111b020
$CM artifacts 6a41f3e01697b5140111b020 --type ipa --url
```

## 監視ユースケース

終端ステータス = `finished, failed, canceled, timeout, skipped`。`cmapi wait` がこれに達するまで
ポーリングし、終了コードで成否を返す（finished=0 / 他終端=1 / タイムアウト=2）。

**Claude Code 実行上の制約（重要）**:
- `wait` は内部で `sleep` する。Claude Code の**フォアグラウンド Bash は `sleep` がブロックされる**ため、
  **`wait` は必ず `run_in_background: true` で実行**する（完了時に通知が来る）。
- 単発のステータス確認（`latest` / `build`）は `sleep` なし＝フォアグラウンドで可。
- ポーリング間隔は既定30秒で十分（レート制限 5,000 req/h に余裕。Store Upload は実測 ~22分）。

### UC1: GitHub Release 後の Store Upload 監視

GitHub Release を作るとタグが打たれ、Codemagic の **"Upload Store"** ワークフローがそのタグでトリガーされる。
Webhook 反映に数十秒のラグがあるため、Release 直後は**対象ビルドの出現待ち → 監視**の2段（`run_in_background:true` で実行）:

```bash
CM=~/.claude/skills/codemagic/scripts/cmapi
TAG=v3.8.0-RC04   # 作成した Release のタグ
for i in $(seq 30); do                                   # 最大 ~10分
  BID=$($CM latest Inventy --workflow "Upload Store" --tag "$TAG" 2>/dev/null | jq -r '.id // empty')
  [ -n "$BID" ] && break
  sleep 20
done
[ -n "$BID" ] && $CM wait "$BID" || echo "タグ $TAG のビルド未検出（トリガー設定を確認）"
```

タグ紐付けが不要で「Upload Store の最新ビルドを監視」だけなら1行:
`$CM wait --app Inventy --workflow "Upload Store"`（`run_in_background:true`）。

注: `app_store_connect_status` は完了ビルドでも **`null` のことがある**（実測）。成否は `status==finished` で
判断し、App Store Connect への公開可否の最終確認は ASC 側で行う。

### UC2: 開発用 iOS ビルド（App Distribution Build）の監視

```bash
CM=~/.claude/skills/codemagic/scripts/cmapi

# 最新の開発配布ビルドを完了まで監視（run_in_background:true）
$CM wait --app Inventy --workflow "App Distribution Build"

# 完了後に ipa の短命DL URL を取得
BID=$($CM latest Inventy --workflow "App Distribution Build" | jq -r .id)
$CM artifacts "$BID" --type ipa --url
```

進行中かどうかの**一発確認**（フォアグラウンド可）:
`$CM latest Inventy --workflow "App Distribution Build"`

## 検証済みの API 事実（`cmapi` が内部で吸収している罠）

スクリプトを使う限り意識不要だが、直叩き・拡張時に効く事実:

- **2系統あり、ホストが違う**。認証は両方 `x-auth-token`。
  - v3 `https://codemagic.io/api/v3` — 単一ビルド詳細 / actions / artifacts / アプリ一覧（リッチ）。
  - v1 `https://api.codemagic.io` — **ビルド一覧** `GET /builds?appId=`。
- **このアカウントは team 無し**（`/user/teams` が空）→ v3 の `/teams/{team_id}/builds` は使えず、一覧は v1。
- v1 のビルド一覧は **新しい順（先頭が最新）**。`index` はワークフロー単位の連番なので最新判定に使わない。
- フィールド名が違う: v1 `_id`/`workflowId`、v3 `id`/`workflow.name`。`nextPageUrl` は**相対 URL**。
- v1 レスポンスに制御文字が混じり、**JSON をシェル変数に往復させると壊れる** → ファイル経由で `jq`。
- レート制限 5,000 req/h（429）。タイムスタンプは ISO8601。

全フィールド / 全 enum（BuildStatus・ArtifactType 32種）/ 生 curl 例は **`references/build-api-reference.md`**。

## ベストプラクティス

- **取得・抽出は `cmapi` に任せる**（生 curl を毎回書かない）。新しい取得パターンが要るなら、その場で
  curl を書くより **`cmapi` にサブコマンドを足す**（決定論・再利用・テスト容易）。
- トークンは**環境変数のみ**。コマンド・履歴・ファイルに直書きしない。
- 監視ループ（`wait`）は **background 実行**（フォアグラウンド `sleep` ブロック対策）。
- 直近ビルドへの最短到達は `latest`（一覧を辿らない）。

## 範囲外

- **ビルドの起動・キャンセル（POST 系）**: v3 に無く v1 の `POST /builds` / `POST /builds/:id/cancel` が必要。本スキルは参照系専用。
- code signing 等のビルド時ユーティリティ「codemagic-cli-tools」（Python パッケージ）は**別物**。本スキルは REST API。

## リファレンス

- スクリプト: **`scripts/cmapi`**（`cmapi -h` で usage。参照系の全操作はこれ経由）
- API 詳細: **`references/build-api-reference.md`**
- 公式: https://codemagic.io/api/v3/schema ・ https://docs.codemagic.io/rest-api/codemagic-rest-api/
