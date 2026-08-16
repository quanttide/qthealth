/// 今日快照卡：4 个核心维度（精力/压力/睡眠/情绪）各 1 题，
/// 点选暂存，答完一轮统一保存，10 秒完成。
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
              '4 个核心维度 · 答完一轮自动保存 · 10 秒完成',
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
                      selected: state.valueOf(q.id) == q.values[i],
                      onSelected: (_) => cubit.answer(q.id, q.values[i]),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (state.allAnswered)
              Text(
                '✓ 今日已答 ${state.answeredCount} / ${kSnapshotQuestions.length} 题，点击可修改',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.primary),
              )
            else if (state.draft.isNotEmpty)
              Text(
                '已选 ${state.answeredCount} / ${kSnapshotQuestions.length} 题，答完一轮自动保存',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
          ],
        ),
      ),
    );
  }
}
