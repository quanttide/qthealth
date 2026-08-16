import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studio/main.dart';

void main() {
  testWidgets('应用启动渲染状态页，常驻侧边导航可直接切换三职能', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QtcloudHealthApp());
    await tester.pumpAndSettle();

    // 常驻侧边导航：记录 / 状态 / 练习（量表不单独设入口）
    expect(find.text('记录'), findsOneWidget);
    expect(find.text('状态'), findsWidgets); // 侧边导航 + 状态页标题
    expect(find.text('练习'), findsOneWidget);
    expect(find.text('量表'), findsNothing);

    // 状态页不再有独立心理测试图标（量表从「记录」页进入）
    expect(find.byTooltip('心理测试'), findsNothing);
  });

  testWidgets('「记录」页提供记录类型入口：情绪日记 + 量表', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QtcloudHealthApp());
    await tester.pumpAndSettle();

    // 进入记录页（记录类型入口）
    await tester.tap(find.text('记录'));
    await tester.pumpAndSettle();
    expect(find.text('情绪日记'), findsOneWidget);
    expect(find.text('量表'), findsOneWidget);

    // 量表作为记录类型 → 量表列表
    await tester.tap(find.text('量表'));
    await tester.pumpAndSettle();
    expect(find.text('PHQ-9 抑郁筛查'), findsOneWidget);
    expect(find.text('GAD-7 焦虑筛查'), findsOneWidget);
  });
}
