import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  testWidgets('今日快照：逐题点选先暂存，答完一轮统一保存', (tester) async {
    // 高视口：避免 ListView 懒加载把「最近快照」挤出视口
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final today = DateTime(2026, 8, 17);
    await tester.pumpWidget(
      QtcloudHealthApp(router: buildAppRouter(today: today)),
    );
    await tester.pumpAndSettle();

    // 4 个核心维度都在今日快照卡中
    expect(find.text('今日快照'), findsOneWidget);
    expect(find.text('今天精力怎么样？'), findsOneWidget);
    expect(find.text('今天压力大吗？'), findsOneWidget);
    expect(find.text('昨晚睡得好吗？'), findsOneWidget);
    expect(find.text('今天情绪偏向哪边？'), findsOneWidget);

    // 答前 3 题：只暂存（内存），不写存储
    await _tapOption(tester, 'energy', '3');
    await _tapOption(tester, 'stress', '2');
    await _tapOption(tester, 'sleep', '4');
    expect(find.textContaining('已选 3 / 4 题'), findsOneWidget);
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SnapshotStore.cacheKey), isNull);

    // 第 4 题答完：一轮完成，统一保存一次（存储出现完整 4 条）
    await _tapOption(tester, 'mood', '🙂');
    expect(find.textContaining('已答 4 / 4 题'), findsOneWidget);
    prefs = await SharedPreferences.getInstance();
    final saved = jsonDecode(prefs.getString(SnapshotStore.cacheKey)!) as List;
    expect(saved.length, 4);
    expect(saved.map((e) => e['questionId']).toSet(),
        {'energy', 'stress', 'sleep', 'mood'});

    // 全部出现在最近快照（卡内 1 处 + 历史 1 处）
    expect(find.text('最近快照'), findsOneWidget);
    expect(find.text('今天精力怎么样？'), findsNWidgets(2));
    expect(find.text('今天情绪偏向哪边？'), findsNWidgets(2));

    // 修改答案：统一保存一次，不产生重复记录
    await _tapOption(tester, 'energy', '5');
    expect(find.textContaining('已答 4 / 4 题'), findsOneWidget);
    prefs = await SharedPreferences.getInstance();
    final afterEdit = jsonDecode(prefs.getString(SnapshotStore.cacheKey)!) as List;
    expect(afterEdit.length, 4);
    expect(
      (afterEdit.firstWhere((e) => e['questionId'] == 'energy'))['value'],
      5,
    );
    expect(find.text('今天精力怎么样？'), findsNWidgets(2));
  });

  testWidgets('最近快照展示历史记录（含日期与所选值）', (tester) async {
    // 高视口：避免 ListView 懒加载把「最近快照」挤出视口
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
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
    expect(find.text('今天情绪偏向哪边？'), findsNWidgets(2)); // 今日卡 + 08-16
    expect(find.text('昨晚睡得好吗？'), findsNWidgets(2)); // 今日卡 + 08-15
    expect(find.text('2026-08-16'), findsOneWidget);
    expect(find.text('🙂'), findsNWidgets(2)); // 今日卡 mood 选项 + 08-16 历史值
  });
}

/// 点击指定快照题的选项（用选项行 Key 定位，避免多题同文案歧义）。
Future<void> _tapOption(
  WidgetTester tester,
  String questionId,
  String label,
) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(ValueKey('snapshot-options-$questionId')),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}
