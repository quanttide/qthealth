/// 记录页：记录类型入口。
///
/// 直接列出各具体量表（PSS-4 / Mini-IPIP / CBI，均无版权争议的公共领域
/// 量表），点击即进入作答（量表列表页已移除）。预留：病程跟踪 / 用药记录 /
/// 就诊记录（家庭大病管理场景，见 kRecordCategories）。
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../data/assessments.dart';
import '../models/assessment.dart';

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
          for (final assessment in kAssessments)
            _AssessmentCard(assessment: assessment),
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

/// 具体量表卡片：点击直接进入作答（/assessments/:id）。
class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.assessment});

  final Assessment assessment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          child: Icon(
            switch (assessment.id) {
              'pss4' => Icons.speed,
              'mini-ipip' => Icons.hub_outlined,
              _ => Icons.local_fire_department_outlined,
            },
          ),
        ),
        title: Text(assessment.title, style: theme.textTheme.titleMedium),
        subtitle: Text(assessment.description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/assessments/${assessment.id}'),
      ),
    );
  }
}
