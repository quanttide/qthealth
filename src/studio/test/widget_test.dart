import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studio/main.dart';

void main() {
  testWidgets('应用启动渲染记录页，侧边导航仅保留「记录」', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QtcloudHealthApp());
    await tester.pumpAndSettle();

    // 常驻侧边导航只保留「记录」（记录页标题 + 导航 = 2 处）
    expect(find.text('记录'), findsNWidgets(2));

    // 已下线：状态 / 练习导航、情绪日记入口均不出现
    expect(find.text('状态'), findsNothing);
    expect(find.text('练习'), findsNothing);
    expect(find.text('情绪日记'), findsNothing);
  });

  testWidgets('「记录」页直接列出具体量表（无中间列表页），点击进入作答',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QtcloudHealthApp());
    await tester.pumpAndSettle();

    // 三个公共领域量表直接列在记录页
    expect(find.text('PSS-4 压力感知'), findsOneWidget);
    expect(find.text('Mini-IPIP 人格倾向'), findsOneWidget);
    expect(find.text('CBI 职业倦怠'), findsOneWidget);

    // 不再有「量表」中间列表页与有版权争议的量表
    expect(find.text('量表'), findsNothing);
    expect(find.text('PHQ-9 抑郁筛查'), findsNothing);
    expect(find.text('GAD-7 焦虑筛查'), findsNothing);

    // 点击具体量表 → 直接进入作答页
    await tester.tap(find.text('PSS-4 压力感知'));
    await tester.pumpAndSettle();
    expect(find.text('第 1 / 4 题'), findsOneWidget);
  });

  testWidgets('作答页：点击答案自动跳转到下一题，最后一题自动出结果', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QtcloudHealthApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('PSS-4 压力感知'));
    await tester.pumpAndSettle();
    expect(find.text('第 1 / 4 题'), findsOneWidget);
    // 自动跳转模式下无「下一题」按钮
    expect(find.text('下一题'), findsNothing);

    // 依次点「从不」（0 分），每题后自动前进
    for (var i = 1; i <= 3; i++) {
      await tester.tap(find.text('从不'));
      await tester.pumpAndSettle();
      expect(find.text('第 ${i + 1} / 4 题'), findsOneWidget);
    }
    // 最后一题点选后自动出结果（全选「从不」=0 分，反向题 2、3 题折为
    // 4 分 → 总分 8 → 压力感知中等）
    await tester.tap(find.text('从不'));
    await tester.pumpAndSettle();
    expect(find.text('总分 8'), findsOneWidget);
    expect(find.text('压力感知中等'), findsOneWidget);

    // 结果页可返回记录页 / 重新作答
    expect(find.text('返回记录页'), findsOneWidget);
    expect(find.text('重新作答'), findsOneWidget);
  });
}
