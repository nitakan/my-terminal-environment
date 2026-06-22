# 新規画面追加時のナビゲーションパターン確認

Flutter新規画面の設計指示を出す際、**必ず既存のナビゲーション設計を事前確認**すること。

## 確認項目
1. `routes.dart` のルート定義パターン（GoRouteData, TypedGoRoute）
2. GoRouter / StatefulShellRoute の使用有無
3. 既存のモーダル遷移パターン（CustomTransitionPage + SlideTransition等）
4. 結果の受け渡し方法（context.push<T> / context.pop）

## 設計指示への反映
- 参考ファイルリストに `routes.dart` を必ず含める
- 遷移方式を既存パターンに合わせてConstraintsに明記する
- `Navigator.push` ではなく GoRouter ルート定義を指示する
