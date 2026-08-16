/// 今日快照卡：4 个核心维度（精力/压力/睡眠/情绪）各 1 题，
/// 按钮点选即记录，10 秒完成。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/snapshots.dart';
import 'snapshot_cubit.dart';
import 'snapshot_state.dart';

class TodaySnapshotCard extends StatelessWidget {
  const TodaySnapshotCard({super.key, required this.state});

  final SnapshotState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<SnapshotCubit>();
    final answered = state.todaySnapshots;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('今日快照', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(fmtDate(state.today), style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '4 个核心维度 · 点选即记录 · 10 秒完成',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            for (final q in kSnapshotQuestions) ...[
              const SizedBox(height: 16),
              Text(q.prompt, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                key: ValueKey('snapshot-options-${q.id}'),
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < q.labels.length; i++)
                    ChoiceChip(
                      label: Text(
                        q.labels[i],
                        style: const TextStyle(fontSize: 18),
                      ),
                      selected: answered[q.id]?.value == q.values[i],
                      onSelected: (_) => cubit.answer(q.id, q.values[i]),
                    ),
                ],
              ),
            ],
            if (answered.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '✓ 今日已答 ${answered.length} / ${kSnapshotQuestions.length} 题，点击可修改',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
