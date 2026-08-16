import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studio/main.dart';

void main() {
  testWidgets('日志页：保存后「返回首页」回到状态页（无死返回箭头）', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QtcloudHealthApp());
    await tester.pumpAndSettle();

    // 从侧边导航进入日志页（go 直达，无路由栈）
    await tester.tap(find.text('日志'));
    await tester.pumpAndSettle();
    expect(find.text('情绪日记（1/2）'), findsOneWidget);
    // 标签页不显示返回箭头（侧边栏即导航）
    expect(find.byType(BackButton), findsNothing);

    // 写一段日记 → 自动梳理 → 确认保存
    await tester.enterText(find.byType(TextField).first, '今天开会方案被否决，我很沮丧');
    await tester.pumpAndSettle();
    await tester.tap(find.text('自动梳理'));
    await tester.pumpAndSettle();
    expect(find.text('情绪日记（2/2）'), findsOneWidget);
    await tester.tap(find.text('确认保存'));
    await tester.pumpAndSettle();
    expect(find.text('日记已保存'), findsOneWidget);

    // 返回首页 → 应落到状态页（此前 go('/') 无路由直接失败）
    await tester.tap(find.text('返回首页'));
    await tester.pumpAndSettle();
    expect(find.text('状态'), findsWidgets);
    expect(find.byTooltip('心理测试'), findsOneWidget);
  });
}
