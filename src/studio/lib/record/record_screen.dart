/// 记录页：今日快照（每天 1 题，10 秒完成）+ 最近快照列表。
///
/// 问卷式量表已下线（lib/status/assessment_quiz_screen.dart 等保留），
/// 改为单题快照：精力 / 压力 / 睡眠 / 情绪按日期轮换，按钮点选即记录。
/// 预留：病程跟踪 / 用药记录 / 就诊记录（家庭大病管理场景，见 kRecordCategories）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants.dart';
import '../data/snapshots.dart';
import '../snapshot/snapshot_cubit.dart';
import '../snapshot/snapshot_state.dart';
import '../snapshot/today_snapshot_card.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key, this.today});

  /// 「今天」（测试注入用；为空时取当前日期）。
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('记录')),
      body: BlocProvider(
        create: (_) => SnapshotCubit(today: today),
        child: const _RecordBody(),
      ),
    );
  }
}

class _RecordBody extends StatelessWidget {
  const _RecordBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<SnapshotCubit, SnapshotState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TodaySnapshotCard(state: state),
            if (state.history.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 4),
                child: Text('最近快照', style: theme.textTheme.titleMedium),
              ),
              for (final s in state.history.reversed.take(7))
                _SnapshotTile(snapshot: s),
            ],
            const SizedBox(height: 8),
            Text(
              '更多记录类型规划中：${kRecordCategories.skip(1).join('、')}（家庭大病管理场景）',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        );
      },
    );
  }
}

/// 最近快照条目：题目 + 日期 + 所选值。
class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({required this.snapshot});

  final DailySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final question = questionById(snapshot.questionId);
    final label = question == null
        ? '${snapshot.value}'
        : question.labels[question.values.indexOf(snapshot.value)];
    return ListTile(
      dense: true,
      leading: const Icon(Icons.check_circle_outline),
      title: Text(question?.prompt ?? snapshot.questionId),
      subtitle: Text(snapshot.date),
      trailing: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
