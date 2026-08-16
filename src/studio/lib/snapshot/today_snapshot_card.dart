/// 今日快照卡：每天 1 题（按日期轮换），按钮点选即记录，10 秒完成。
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
    final q = state.question;
    final today = state.todaySnapshot;
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
              '每天一问 · 10 秒完成',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 12),
            Text(q.prompt, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < q.labels.length; i++)
                  ChoiceChip(
                    label: Text(
                      q.labels[i],
                      style: const TextStyle(fontSize: 18),
                    ),
                    selected: today?.value == q.values[i],
                    onSelected: (_) => cubit.answer(q.values[i]),
                  ),
              ],
            ),
            if (today != null) ...[
              const SizedBox(height: 8),
              Text(
                '✓ 已记录，点击可修改',
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
