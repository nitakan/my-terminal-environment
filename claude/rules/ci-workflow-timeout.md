# GitHub Actions ワークフローのタイムアウト必須

`.github/workflows/*.yml` のジョブを作成・編集するときは、各ジョブに `timeout-minutes` を設定する（未設定だとハング時にジョブ上限の6時間まで浪費するため）。
