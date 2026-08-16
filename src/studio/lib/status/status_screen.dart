/// ⚠️ 已下线（2026-08-17）：状态页当前不在路由表中注册、无任何入口，
/// 本文件完整保留以便未来重新启用（届时在 lib/router.dart 注册 /status
/// 并在 AppShell 恢复导航入口即可，无需改动本文件）。
///
/// 首页：概览指标 + 数据看板（认知扭曲分布 / 情绪趋势 / 高频扭曲）+ 最近日记。
///
/// 数据看板已合并到首页：指标四格 → 认知扭曲分布 → 情绪趋势 → 高频扭曲
/// TOP 3 → 最近日记；常驻侧边导航由 AppShell 提供。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../record/records_cubit.dart';
import '../record/records_state.dart';
import 'analytics_charts.dart';
import '../record/record_card.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('状态'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: '清空本地数据',
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: BlocBuilder<RecordsCubit, RecordsState>(
        builder: (context, state) {
          return switch (state) {
            RecordsLoading() => const Center(child: CircularProgressIndicator()),
            RecordsLoadFailed() => _ErrorView(
                message: state.message,
                onRetry: () => context.read<RecordsCubit>().load(),
              ),
            RecordsLoaded() => _Dashboard(state: state),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        // 写日记直达情绪日记表单（量表从「记录」页进入）
        onPressed: () => context.push('/record/journal'),
        icon: const Icon(Icons.edit_note),
        label: const Text('写日记'),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空本地数据'),
        content: const Text('将删除设备上的全部情绪日记（仅前端缓存，不影响任何服务端数据）。此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<RecordsCubit>().clearAll();
    }
  }
}

/// 首页仪表盘：指标四格 + 图表 + 高频扭曲 + 最近日记。
class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.state});

  final RecordsLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = state;
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Column(
            children: [
              Row(
                children: [
                  _MetricCard(
                    icon: Icons.today,
                    value: '${s.todayCount}',
                    label: '今日记录',
                  ),
                  _MetricCard(
                    icon: Icons.mood,
                    value: '${s.avgEmotionIntensity}',
                    label: '平均情绪强度',
                  ),
                ],
              ),
              Row(
                children: [
                  _MetricCard(
                    icon: Icons.trending_down,
                    value: '${(s.reconstructionRate * 100).toStringAsFixed(0)}%',
                    label: '重构成功率',
                  ),
                  _MetricCard(
                    icon: Icons.local_fire_department,
                    value: '${s.continuousDays}',
                    label: '连续使用天数',
                  ),
                ],
              ),
            ],
          ),
        ),
        _SectionCard(
          title: '认知扭曲分布（近 30 天）',
          child: SizedBox(height: 200, child: DistortionPieChart(records: s.records)),
        ),
        _SectionCard(
          title: '情绪趋势（近 30 天）',
          child: SizedBox(height: 220, child: EmotionTrendChart(records: s.records)),
        ),
        if (s.topDistortions.isNotEmpty)
          _SectionCard(
            title: '高频认知扭曲 TOP 3',
            child: Column(
              children: [
                for (final (name, count) in s.topDistortions)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.tag),
                    title: Text(name),
                    trailing: Text('$count 次'),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text('最近日记', style: theme.textTheme.titleMedium),
        ),
        if (s.records.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('还没有日记，点击「写日记」开始记录你的心情')),
          )
        else
          for (final record in s.records.take(10))
            RecordCard(
              record: record,
              onDelete: () => context.read<RecordsCubit>().delete(record.id),
            ),
      ],
    );
  }
}

/// 数据看板区块卡片（图表容器）。
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(height: 8),
              Text(value, style: theme.textTheme.headlineSmall),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
