/// 数据看板图表：认知扭曲分布饼图 + 情绪趋势折线图。
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/abc_record.dart';

/// 认知扭曲分布饼图（对应 IXD 数据看板页）。
class DistortionPieChart extends StatelessWidget {
  const DistortionPieChart({super.key, required this.records});

  final List<ABCRecord> records;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final r in records) {
      for (final d in r.allDistortions) {
        counts[d] = (counts[d] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) {
      return const _EmptyChart(message: '暂无数据，完成第一条 ABC 记录后可见');
    }

    final colors = [
      Colors.teal, Colors.orange, Colors.indigo,
      Colors.pink, Colors.amber, Colors.cyan, Colors.purple,
    ];
    final entries = counts.entries.toList();
    final total = entries.fold<int>(0, (acc, e) => acc + e.value);

    return PieChart(
      PieChartData(
        sections: [
          for (var i = 0; i < entries.length; i++)
            PieChartSectionData(
              value: entries[i].value.toDouble(),
              color: colors[i % colors.length],
              title:
                  '${(entries[i].value / total * 100).toStringAsFixed(0)}%',
              radius: 56,
              titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
            ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 32,
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}

/// 情绪趋势折线图（近 30 天平均情绪强度，对应 IXD 情绪趋势曲线）。
class EmotionTrendChart extends StatelessWidget {
  const EmotionTrendChart({super.key, required this.records});

  final List<ABCRecord> records;

  @override
  Widget build(BuildContext context) {
    // 按天聚合平均情绪强度
    final byDay = <DateTime, List<int>>{};
    final now = DateTime.now();
    for (final r in records) {
      final day = DateTime(r.date.year, r.date.month, r.date.day);
      if (now.difference(day).inDays > 30) continue;
      byDay.putIfAbsent(day, () => []).add(r.emotionIntensityAvg);
    }
    final days = byDay.keys.toList()..sort();
    if (days.isEmpty) {
      return const _EmptyChart(message: '暂无数据，完成第一条 ABC 记录后可见');
    }

    final spots = <FlSpot>[
      for (var i = 0; i < days.length; i++)
        FlSpot(
          i.toDouble(),
          byDay[days[i]]!.reduce((a, b) => a + b) / byDay[days[i]]!.length,
        ),
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.teal,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.teal.withValues(alpha: 0.08),
            ),
          ),
        ],
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: days.length > 7,
              interval:
                  (days.length / 7).ceilToDouble().clamp(1.0, 1 << 31).toDouble(),
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${days[i].month}/${days[i].day}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
