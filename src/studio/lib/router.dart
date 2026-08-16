/// 路由表（go_router）：
/// 常驻侧边导航外壳（首页 / 写日记 / 心理测试）+ 全屏页（量表作答 / 危机干预）。
library;

import 'package:go_router/go_router.dart';

import 'screens/assessment_list_screen.dart';
import 'screens/assessment_quiz_screen.dart';
import 'screens/crisis_screen.dart';
import 'screens/home_screen.dart';
import 'screens/record_form_screen.dart';
import 'views/app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/record',
          builder: (context, state) => const RecordFormScreen(),
        ),
        GoRoute(
          path: '/assessments',
          builder: (context, state) => const AssessmentListScreen(),
        ),
      ],
    ),
    // 量表作答与危机干预为专注/干预场景，全屏展示（不挂侧边导航）
    GoRoute(
      path: '/assessments/:assessmentId',
      builder: (context, state) =>
          AssessmentQuizScreen(assessmentId: state.pathParameters['assessmentId']!),
    ),
    GoRoute(
      path: '/crisis',
      builder: (context, state) => CrisisScreen(
        message: state.extra as String? ?? '',
      ),
    ),
  ],
);
