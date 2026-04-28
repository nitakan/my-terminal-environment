# Architect → Member: Design Instruction Message Example

Below is a concrete example of a `SendMessage` payload from architect to member.
This format ensures the member has all context needed to implement without assumptions.

## Example: Refactoring a DeepLink service class

```
SendMessage(
  to: "member-app",
  message: """
## 設計指示: タスク #6 — deeplink.dart リファクタリング

### Why
独自DeepLinkRouteクラス階層を廃止し、GoRouterに統合するため、
抽象クラスのAPIをURI直接受け渡し方式に変更する。

### What
対象ファイル: `lib/messaging/deeplink.dart`

1. クラス名を `DeepLinks` → `DeepLinkService` に変更
2. ストリーム型を `Stream<DeepLinkRoute?>` → `Stream<Uri?>` に変更
3. メソッド名変更: `navigate(Uri)` → `handleUri(Uri)`
4. プロパティ名変更: `onDynamicLink` → `onLink`
5. `addDeepLink(DeepLinkRoute)` メソッドを削除
6. `popLastDeepLink()` の戻り値を `Uri?` に変更
7. DeepLinkRoute, DeepLinkRouteType, DeepLinkRouteUri の定義を削除

最終形:
```dart
abstract class DeepLinkService {
  static final provider = Provider<DeepLinkService>(
    (ref) => throw UnimplementedError(),
  );
  Stream<Uri?> get onLink;
  Future<void> initialize();
  void handleUri(Uri uri);
  Uri? popLastDeepLink();
  void clearHistory();
  void dispose();
}
```

### Constraints
- `GroupId` は String の typedef ではなく **freezed class**。`GroupId(stringValue)` でラップが必要
- `ArticleId` も同様に freezed class
- Provider参照は `AppProviders.selectedGroupId` 経由（既存の慣習に従う）
- サブエージェントは `model: "sonnet"` で実行（単一ファイルの機械的変更のため）

### Order
このタスクが最初。完了後にタスク #7, #8 がアンブロックされる。
""",
  summary: "タスク#6 deeplink.dart 設計指示"
)
```

## Key Points

- **Why** explains the motivation so the member understands intent, not just mechanics
- **What** lists exact file paths and every specific change to make
- **Constraints** includes type information verified from actual code (not from plan assumptions)
- **Order** clarifies task dependencies so the member knows priority
- The architect specifies the subagent model (`sonnet` for simple, `opus` for complex)
