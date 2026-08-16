/// 记录页：记录类型入口。
///
/// 量表是记录的一种类型（测评记录），从本页进入，不单独设导航入口。
/// 情绪日记已下线（组件代码保留在 lib/record/record_form_screen.dart，
/// 未来可恢复为卡片入口）。预留：病程跟踪 / 用药记录 / 就诊记录
/// （家庭大病管理场景，见 kRecordCategories）。
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('记录')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RecordTypeCard(
            icon: Icons.psychology_outlined,
            title: '量表',
            subtitle: 'PSS-4 / Mini-IPIP / CBI 专业测评（公共领域量表）',
            onTap: () => context.push('/assessments'),
          ),
          const SizedBox(height: 8),
          Text(
            '更多记录类型规划中：${kRecordCategories.skip(1).join('、')}（家庭大病管理场景）',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _RecordTypeCard extends StatelessWidget {
  const _RecordTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: theme.colorScheme.primary, size: 32),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
