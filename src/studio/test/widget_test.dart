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

  testWidgets('「记录」页仅提供量表入口：量表列表只含无版权争议的公共领域量表',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QtcloudHealthApp());
    await tester.pumpAndSettle();

    // 记录类型入口：量表（情绪日记已下线）
    expect(find.text('量表'), findsOneWidget);

    // 量表作为记录类型 → 量表列表
    await tester.tap(find.text('量表'));
    await tester.pumpAndSettle();
    expect(find.text('PSS-4 压力感知'), findsOneWidget);
    expect(find.text('Mini-IPIP 人格倾向'), findsOneWidget);
    expect(find.text('CBI 职业倦怠'), findsOneWidget);

    // 有版权争议的量表已下线
    expect(find.text('PHQ-9 抑郁筛查'), findsNothing);
    expect(find.text('GAD-7 焦虑筛查'), findsNothing);
  });
}
