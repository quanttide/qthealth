/// 路由表（go_router，Path URL 策略：地址栏无 #）：
/// 常驻侧边导航外壳（记录）+ 单题快照（在记录页内，无需独立路由）。
///
/// 已下线功能（组件代码保留，勿删文件，未来重新启用时在此注册路由）：
/// - 量表作答：/assessments/:id → lib/status/assessment_quiz_screen.dart
/// - 量表列表页：/assessments → lib/status/assessment_list_screen.dart
/// - 情绪日记：/record/journal → lib/record/record_form_screen.dart
/// - 状态页：/status → lib/status/status_screen.dart
/// - 练习：/practice、/crisis → lib/practice/{practice,crisis}_screen.dart
library;

import 'package:go_router/go_router.dart';

import 'record/record_screen.dart';
import 'shell/app_shell.dart';

/// 默认路由（生产入口）。
final GoRouter appRouter = buildAppRouter();

/// 构建路由。[today] 用于测试注入「今天」（快照题目按日期轮换）。
GoRouter buildAppRouter({DateTime? today}) {
  return GoRouter(
    initialLocation: '/record',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/record',
            builder: (context, state) => RecordScreen(today: today),
          ),
        ],
      ),
    ],
  );
}
