/// 路由表（go_router，Path URL 策略：地址栏无 #）：
/// 常驻侧边导航外壳（记录）+ 全屏页（量表作答）。
/// 具体量表直接列在「记录」页（/record），点击即作答（/assessments/:id）；
/// 量表列表页已移除。
///
/// 已下线功能（组件代码保留，勿删文件，未来重新启用时在此注册路由）：
/// - 量表列表页：/assessments → lib/status/assessment_list_screen.dart
/// - 情绪日记：/record/journal → lib/record/record_form_screen.dart
/// - 状态页：/status → lib/status/status_screen.dart
/// - 练习：/practice、/crisis → lib/practice/{practice,crisis}_screen.dart
library;

import 'package:go_router/go_router.dart';

import 'record/record_screen.dart';
import 'shell/app_shell.dart';
import 'status/assessment_quiz_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/record',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/record',
          builder: (context, state) => const RecordScreen(),
        ),
      ],
    ),
    // 量表作答为专注场景，全屏展示（不挂侧边导航）
    GoRoute(
      path: '/assessments/:assessmentId',
      builder: (context, state) =>
          AssessmentQuizScreen(assessmentId: state.pathParameters['assessmentId']!),
    ),
  ],
);
