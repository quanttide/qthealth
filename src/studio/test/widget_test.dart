import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studio/data/snapshots.dart';
import 'package:studio/main.dart';
import 'package:studio/router.dart';
import 'package:studio/snapshot/snapshot_store.dart';

void main() {
  testWidgets('应用启动渲染记录页，侧边导航仅保留「记录」', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QtcloudHealthApp());
    await tester.pumpAndSettle();

    // 常驻侧边导航只保留「记录」（记录页标题 + 导航 = 2 处）
    expect(find.text('记录'), findsNWidgets(2));

    // 已下线：状态 / 练习导航、情绪日记、量表均不出现
    expect(find.text('状态'), findsNothing);
    expect(find.text('练习'), findsNothing);
    expect(find.text('情绪日记'), findsNothing);
    expect(find.text('PSS-4 压力感知'), findsNothing);
  });

  testWidgets('今日快照：每天一问（按日期轮换），点选即记录、可修改', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final today = DateTime(2026, 8, 17);
    await tester.pumpWidget(
      QtcloudHealthApp(router: buildAppRouter(today: today)),
    );
    await tester.pumpAndSettle();

    // 今日题目 = 按日期轮换的题
    final q = questionForDate(today);
    expect(find.text('今日快照'), findsOneWidget);
    expect(find.text(q.prompt), findsOneWidget);

    // 点选第一个选项 → 已记录，且出现在最近快照
    final firstLabel = q.labels.first;
    await tester.tap(find.text(firstLabel));
    await tester.pumpAndSettle();
    expect(find.textContaining('已记录'), findsOneWidget);
    expect(find.text('最近快照'), findsOneWidget);
    expect(find.text(q.prompt), findsNWidgets(2)); // 今日卡 + 历史条目

    // 修改答案（选最后一个选项）→ 仍已记录
    await tester.tap(find.text(q.labels.last));
    await tester.pumpAndSettle();
    expect(find.textContaining('已记录'), findsOneWidget);
  });

  testWidgets('最近快照展示历史记录（含日期与所选值）', (tester) async {
    final today = DateTime(2026, 8, 17);
    SharedPreferences.setMockInitialValues({
      SnapshotStore.cacheKey: jsonEncode([
        {'date': '2026-08-16', 'questionId': 'mood', 'value': 3},
        {'date': '2026-08-15', 'questionId': 'sleep', 'value': 2},
      ]),
    });
    await tester.pumpWidget(
      QtcloudHealthApp(router: buildAppRouter(today: today)),
    );
    await tester.pumpAndSettle();

    expect(find.text('最近快照'), findsOneWidget);
    expect(find.text('今天情绪偏向哪边？'), findsOneWidget); // 08-16
    expect(find.text('昨晚睡得好吗？'), findsOneWidget); // 08-15
    expect(find.text('2026-08-16'), findsOneWidget);
    expect(find.text('🙂'), findsOneWidget); // mood value 3
  });
}
