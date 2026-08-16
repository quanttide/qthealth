import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studio/main.dart';

void main() {
  testWidgets('应用启动渲染状态页，常驻侧边导航可直接切换三职能', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QtcloudHealthApp());
    await tester.pumpAndSettle();

    // 常驻侧边导航：记录 / 状态 / 练习 直接可见（无需打开抽屉）
    expect(find.text('记录'), findsOneWidget);
    expect(find.text('状态'), findsWidgets); // 侧边导航 + 状态页标题
    expect(find.text('练习'), findsOneWidget);

    // 状态页 AppBar 提供心理测试入口
    expect(find.byTooltip('心理测试'), findsOneWidget);
  });
}
