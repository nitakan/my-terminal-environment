# Codemagic REST API v3 — ビルド情報取得 詳細リファレンス

出典: OpenAPI 3.1.0 スペック実体（`https://codemagic.io/api/v3/schema/openapi.json`, `info.version: "v3.0"`）。
本ファイルは enum / 全フィールド / 全エンドポイントの完全版。日常操作は親 `SKILL.md` を参照。

## ベース URL / 認証

- v3 ベース: `https://codemagic.io/api/v3`
- 認証: ヘッダー `x-auth-token: <token>`（`components.securitySchemes.api_key`: `type: apiKey, in: header`）
- トークン発行: `Teams > Personal Account > Integrations > Codemagic API > Show`
- 許可される操作はチーム内ロールに依存する

## エンドポイント一覧（参照系）

| メソッド | パス | パラメータ | 用途 |
|---|---|---|---|
| GET | `/api/v3/user/teams` | query: `page_size`, `page` | team_id 取得（ビルド一覧に必須） |
| GET | `/api/v3/user/apps` | query: `page_size`, `page` | 認証ユーザーのアプリ一覧 |
| GET | `/api/v3/teams/{team_id}/apps` | path: `team_id`; query: `page_size`, `page`, `id`(App ID 配列) | チームのアプリ一覧 |
| GET | `/api/v3/teams/{team_id}/builds` | path: `team_id`; query: `app_id`, `status`, `workflow_id`, `branch`, `tag`, `label`(配列), `cursor`, `page_size` | ビルド一覧（チーム単位） |
| GET | `/api/v3/builds/{build_id}` | path: `build_id` | 単一ビルド詳細 |
| GET | `/api/v3/builds/{build_id}/actions` | path: `build_id`; query: `page_size`, `page` | ビルドの各ステップ（アクション）一覧 |
| GET | `/api/v3/builds/{build_id}/remote-access` | path: `build_id` | リモートアクセス情報 |
| GET | `/api/v3/dashboards/{uuid}/builds` | path: `uuid` | ダッシュボード単位のビルド一覧 |
| POST | `/api/v3/builds/{build_id}/preview` | path: `build_id` | アプリプレビュー開始（参照補助） |

注:
- v3 に**ビルドログ専用の取得エンドポイントは無い**。代替は `/actions`（各ステップの `script` と `status`）か、artifacts の `log` 系 type のダウンロード。
- v3 に**ステータスのみ取得**の専用エンドポイントは無い。単一ビルド GET の `status` を見る。
- v3 に**ビルド起動・キャンセルは無い**（レガシー v1 のみ）。

## enum 定義

### BuildStatus（単一ビルドの `status` = 実行ライフサイクル全体）

```
initializing, queued, preparing, fetching, testing, building,
publishing, finishing, finished, failed, canceled, timeout, skipped
```

### BuildStatusFilter（ビルド一覧の `status` クエリで受理する値）

```
queued, building, finished, failed, canceled, timeout, skipped
```

### ArtifactType（`artifacts[].type` — 全32種）

```
apk, aab, aar, app, ipa, bundle, dsym, xcarchive, msix, pkg, snap,
windows_exe, linux_app, jar, log, logcat, xcodebuild_log,
ios_simulator_log, flutter_drive_log, lint_result, proguard_map,
test_results_bundle, coverage_data, coverage_binary, device_recording,
directory, glob_matched, static_lib, ...
```

ログ相当の type: `log`, `logcat`, `xcodebuild_log`, `ios_simulator_log`, `flutter_drive_log`。

## レスポンススキーマ

### 単一ビルド `GET /api/v3/builds/{build_id}` → `{ "data": BuildSchema }`

`data` 内（◎=必須）:
- `id`◎ (string), `app_id`◎ (string), `index`◎ (integer, ビルド番号)
- `status`◎ (BuildStatus)
- `workflow`◎ `{ id, source, name }`
- `artifacts`◎ (ArtifactSchema[])
- `labels`◎ (array), `release_notes`◎ (array)
- `created_at`◎ (string), `started_at` (string|null), `finished_at` (string|null)
- `commit` `{ hash, avatar_url, author_name, author_email, message, url }` (nullable)
- `branch` (string|null), `tag` (string|null), `pull_request` (object|null)
- `instance_type` (string|null), `config`◎ (object)
- `remote_access_enabled`◎ (bool), `build_inputs` (object), `app_store_connect_status` (nullable)

日時フィールド（`created_at`/`started_at`/`finished_at`）の型は string。ISO8601 と推定されるが、スペックに明示の format 指定は無い。

### ビルド一覧 `GET /api/v3/teams/{team_id}/builds` → `{ data: BuildSchema[], page_size, cursor }`

各要素は単一ビルドの BuildSchema とほぼ同じだが、`instance_type` / `config` / `remote_access_enabled` / `build_inputs` を**含まない**。詳細が要るときは個別に `/builds/{id}` を引く。

### ArtifactSchema（`artifacts[]` の各要素）

- `name`◎ (string), `size_in_bytes`◎ (integer)
- `type`◎ (ArtifactType)
- `short_lived_download_url`◎ (string) — 短命のダウンロード URL（取得直後に使う）
- `version_code` (string|null), `version_name` (string|null)

### AppSchema（user 版 `GET /api/v3/user/apps`）

- `id`◎, `name`◎, `last_build_id`◎ (string), `icon_url` (nullable), `archived` (bool|null)

### AppSchema（team 版 `GET /api/v3/teams/{team_id}/apps`）

- `id`◎, `name`◎, `repository`◎ `{ url }`, `settings_source`◎, `icon_url`, `project_type`, `last_build_id`, `archived`

### TeamSchema（user 版 `GET /api/v3/user/teams`）

- `id`◎, `name`◎, `icon_url`

## ページング

- **カーソル型**（ビルド一覧）: `{ data, page_size, cursor }`。次ページは前回 `cursor` を `cursor` クエリへ。`page_size` default 30 / min 1 / max 100。
- **クラシック型**（アプリ一覧・チーム一覧・actions）: `{ data, page_size, current_page, total_pages }`。`page` クエリでページ指定。

## レート制限

- 5,000 req/hour。超過で `429`。
- レスポンスヘッダー: `ratelimit-limit`, `ratelimit-remaining`, `ratelimit-reset`（リセットまでの秒数）。
- `ratelimit-remaining: 0` のときは `ratelimit-reset` 秒経過まで再試行しない。

## エラー形式（v3 ValidationErrorResponseSchema）

```json
{ "status_code": 400, "detail": "Bad Request", "extra": {} }
```

`status_code` と `detail` が必須。典型: 401/403 認証・権限、404 ID 誤り、429 レート制限。

## v1（`https://api.codemagic.io`）— ビルド一覧で使う / 操作系

認証ヘッダーは v3 と同じ `x-auth-token`。

### `GET /builds` — ユーザー単位のビルド一覧（実測で検証済み）

v3 のビルド一覧は team 単位（`/teams/{team_id}/builds`）。**個人アカウントで `/user/teams` が空のときはこれが唯一の一覧手段**。
- クエリ: `appId`（アプリで絞る）ほか。
- レスポンス: `{ applications: [...], builds: [...], nextPageUrl }`。
- ページング: `nextPageUrl`（次ページの完全 URL。末尾で `null`）。v3 のカーソル/クラシックとは別方式。
- **フィールド名が v3 と違う**: `_id`（v3 は `id`）、`workflowId`（v3 は `workflow.name`）。`status` / `index` / `branch` / `tag` は共通。
- 例:
  ```bash
  curl -s -H "x-auth-token: $CM_API_TOKEN" \
    "https://api.codemagic.io/builds?appId=<app_id>" \
    | jq '.builds[] | {id:._id, index, status, branch, tag, workflowId}'
  ```

### 操作系（本スキルの範囲外 — 参考）

- `POST /builds`（起動）, `POST /builds/:id/cancel`（キャンセル）
- `POST /artifacts/:secureFilename/public-url`（共有用の時間制限付き公開 URL。body `{"expiresAt": <unix秒>}`）

## 実測メモ（2026-06 時点、実トークンで確認）

- 認証ヘッダー `x-auth-token` で v3/v1 とも HTTP 200。
- `created_at`/`started_at`/`finished_at` は **ISO8601**（例 `2026-06-29T05:40:03.402000Z`、マイクロ秒6桁 + `Z`）。スペックに format 明記は無いが実体は ISO8601。
- 個人アカウントでは `/user/teams` が `{data:[], total_pages:0}` で空になり得る → v3 のビルド一覧は使えず v1 `GET /builds` を使う。
- `/user/apps` の各アプリは `last_build_id` を持ち、`/builds/{id}` へ直行できる（一覧を引かずに直近ビルドへ最短到達）。
- 単一ビルドの `artifacts[].type` 実例: `aab, proguard_map, ipa, app, dsym`（Flutter のストア配布ワークフロー）。

## 参照した公式 URL

- OpenAPI スペック実体: https://codemagic.io/api/v3/schema/openapi.json
- API スキーマ UI: https://codemagic.io/api/v3/schema
- REST API 概要: https://docs.codemagic.io/rest-api/codemagic-rest-api/
- Builds（v1）: https://docs.codemagic.io/rest-api/builds/
- Applications（v1）: https://docs.codemagic.io/rest-api/applications/
- Artifacts（v1）: https://docs.codemagic.io/rest-api/artifacts/
