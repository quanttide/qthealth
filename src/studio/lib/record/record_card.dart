/// 记录卡片：日期、事件摘要、情绪强度、认知扭曲标签。
library;

import 'package:flutter/material.dart';

import '../models/abc_record.dart';

class RecordCard extends StatelessWidget {
  const RecordCard({super.key, required this.record, this.onDelete});

  final ABCRecord record;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        title: Text(
          record.activatingEvent,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_fmtDate(record.date)} · 情绪强度 ${record.emotionIntensityAvg}/100'
                '${record.emotionsAfter.isNotEmpty ? ' → ${record.emotionAfterAvg}/100' : ''}',
                style: theme.textTheme.bodySmall,
              ),
              if (record.allDistortions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: record.allDistortions
                        .map((d) => Chip(
                              label: Text(d, style: theme.textTheme.labelSmall),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ),
              if (record.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: record.tags
                        .map((t) => Chip(
                              label: Text('#$t', style: theme.textTheme.labelSmall),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
        trailing: onDelete == null
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: '删除记录',
                onPressed: onDelete,
              ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
