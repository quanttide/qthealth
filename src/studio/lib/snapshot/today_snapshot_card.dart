/// 今日快照卡：4 个核心维度（精力/压力/睡眠/情绪）各 1 题，
/// 点选暂存 → 答完一轮点「保存」统一写入 → 保存后清空（完成态）。
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
              '4 个核心维度 · 10 秒完成',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            // 保存后清空：显示完成态，不再展示可作答表单
            if (state.todayComplete)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '✓ 今日快照已保存',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '明天再来记录新的一天',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              )
            else ...[
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
              const SizedBox(height: 16),
              Row(
                children: [
                  if (state.draft.isNotEmpty)
                    Expanded(
                      child: Text(
                        '已选 ${state.answeredCount} / ${kSnapshotQuestions.length} 题，答完一轮点保存',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ),
                  FilledButton.icon(
                    key: const ValueKey('snapshot-save-button'),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('保存今日快照'),
                    onPressed: state.allAnswered ? cubit.save : null,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
