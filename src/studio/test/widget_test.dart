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

  testWidgets('今日快照：点选先暂存，答完一轮点「保存」统一写入，保存后清空', (tester) async {
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

    // 未答任何题：保存按钮禁用，存储无写入
    final saveButton = find.byKey(const ValueKey('snapshot-save-button'));
    expect(
      tester.widget<FilledButton>(saveButton).onPressed,
      isNull,
    );
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SnapshotStore.cacheKey), isNull);

    // 答前 3 题：仍只暂存（存储无写入），保存按钮仍禁用
    await _tapOption(tester, 'energy', '3');
    await _tapOption(tester, 'stress', '2');
    await _tapOption(tester, 'sleep', '4');
    expect(find.textContaining('已选 3 / 4 题'), findsOneWidget);
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SnapshotStore.cacheKey), isNull);

    // 答完第 4 题：保存按钮可用；点保存 → 统一写入 4 条
    await _tapOption(tester, 'mood', '🙂');
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    prefs = await SharedPreferences.getInstance();
    final saved = jsonDecode(prefs.getString(SnapshotStore.cacheKey)!) as List;
    expect(saved.length, 4);
    expect(
      saved.map((e) => e['questionId']).toSet(),
      {'energy', 'stress', 'sleep', 'mood'},
    );

    // 保存后清空：表单消失，显示完成态
    expect(find.text('✓ 今日快照已保存'), findsOneWidget);
    expect(find.text('今天精力怎么样？'), findsOneWidget); // 仅最近快照列表
    expect(find.byKey(const ValueKey('snapshot-save-button')), findsNothing);

    // 最近快照出现今日 4 条（表单已清空，题目仅出现在历史列表；
    // 日期共 5 处：卡头 1 + 历史 4）
    expect(find.text('最近快照'), findsOneWidget);
    expect(find.text('今天情绪偏向哪边？'), findsOneWidget);
    expect(find.text('2026-08-17'), findsNWidgets(5));
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
