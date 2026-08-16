/// 应用外壳：常驻侧边导航（NavigationRail）+ 内容区。
///
/// 导航：记录（观测）。量表作为记录的一种类型，从「记录」页进入，
/// 不单独设导航入口。已下线：状态（反馈）/ 练习（干预）——组件代码
/// 保留在 lib/status/、lib/practice/，未来可重新注册路由与导航入口。
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  /// 当前路由对应的子页面。
  final Widget child;

  static const List<({
    IconData icon,
    IconData selectedIcon,
    String label,
    String path,
  })> _destinations = [
    (
      icon: Icons.edit_note,
      selectedIcon: Icons.edit_note,
      label: '记录',
      path: '/record',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = GoRouter.of(context).state.uri.path;
    final rawIndex = _destinations.indexWhere((d) => d.path == path);
    final selectedIndex = rawIndex < 0 ? 0 : rawIndex;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => context.go(_destinations[i].path),
            labelType: NavigationRailLabelType.all,
            groupAlignment: -0.9,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Icon(
                Icons.favorite,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: '数据说明',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('当前版本数据仅缓存于本设备（前端缓存），不保存到服务端。'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
