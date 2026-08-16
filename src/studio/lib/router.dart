/// 路由表（go_router）：
/// 常驻侧边导航外壳（记录 / 状态 / 练习）+ 全屏页（量表作答 / 危机干预）。
library;

import 'package:go_router/go_router.dart';

import 'status/assessment_list_screen.dart';
import 'status/assessment_quiz_screen.dart';
import 'practice/crisis_screen.dart';
import 'practice/practice_screen.dart';
import 'record/record_form_screen.dart';
import 'status/status_screen.dart';
import 'shell/app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/status',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/record',
          builder: (context, state) => const RecordFormScreen(),
        ),
        GoRoute(
          path: '/status',
          builder: (context, state) => const StatusScreen(),
        ),
        GoRoute(
          path: '/practice',
          builder: (context, state) => const PracticeScreen(),
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
