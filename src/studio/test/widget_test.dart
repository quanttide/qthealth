import 'package:flutter_test/flutter_test.dart';

import 'package:studio/app_state.dart';
import 'package:studio/main.dart';

void main() {
  testWidgets('量潮健康可渲染', (WidgetTester tester) async {
    await tester.pumpWidget(HealthApp(state: AppState()));
    await tester.pumpAndSettle();

    expect(find.text('量潮健康'), findsOneWidget);
    expect(find.text('服务状态'), findsOneWidget);
    expect(find.text('检查'), findsOneWidget);
  });
}
