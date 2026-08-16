import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('应用启动渲染首页，常驻侧边导航可直接进入心理测试', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QtcloudHealthApp());
    await tester.pumpAndSettle();

    expect(find.text('量潮健康云'), findsOneWidget);
    // 常驻侧边导航：首页 / 写日记 / 心理测试 直接可见（无需打开抽屉）
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('写日记'), findsNWidgets(2)); // 侧边导航 + 首页悬浮按钮
    expect(find.text('心理测试'), findsOneWidget);

    // 数据看板已合并到首页，不再有独立入口
    expect(find.byTooltip('数据看板'), findsNothing);

    // 点击侧边导航进入心理测试列表
    await tester.tap(find.text('心理测试'));
    await tester.pumpAndSettle();
    expect(find.text('PHQ-9 抑郁筛查'), findsOneWidget);
    expect(find.text('GAD-7 焦虑筛查'), findsOneWidget);
  });
}
