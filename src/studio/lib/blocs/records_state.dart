/// 记录列表状态：三态（Loading / Loaded / LoadFailed）。
library;

import 'package:equatable/equatable.dart';

import '../models/abc_record.dart';

sealed class RecordsState extends Equatable {
  const RecordsState();

  @override
  List<Object?> get props => const [];
}

/// 加载中。
class RecordsLoading extends RecordsState {
  const RecordsLoading();
}

/// 加载成功。
class RecordsLoaded extends RecordsState {
  const RecordsLoaded(this.records);

  final List<ABCRecord> records;

  /// 今日记录数（对应 IXD 首页卡片）。
  int get todayCount {
    final now = DateTime.now();
    return records
        .where((r) =>
            r.date.year == now.year &&
            r.date.month == now.month &&
            r.date.day == now.day)
        .length;
  }

  /// 平均情绪强度（对应 PRD 核心指标 AVG(C_intensity)）。
  int get avgEmotionIntensity {
    if (records.isEmpty) return 0;
    final sum = records.fold<int>(0, (acc, r) => acc + r.emotionIntensityAvg);
    return sum ~/ records.length;
  }

  /// 连续使用天数（按记录日期去重后从最近一天向前数）。
  int get continuousDays {
    if (records.isEmpty) return 0;
    final days = records.map((r) => DateTime(r.date.year, r.date.month, r.date.day)).toSet().toList()
      ..sort();
    var count = 0;
    var cursor = DateTime.now();
    for (final day in days.reversed) {
      final diff = cursor.difference(day).inDays;
      if (diff <= 1) {
        count++;
        cursor = day;
      } else {
        break;
      }
    }
    return count;
  }

  /// 重构成功率：E 阶段情绪下降超 30% 的记录占比（对应 PRD 核心指标）。
  double get reconstructionRate {
    if (records.isEmpty) return 0;
    final done = records.where((r) => r.emotionsAfter.isNotEmpty).toList();
    if (done.isEmpty) return 0;
    return done.where((r) => r.reconstructionSucceeded).length / done.length;
  }

  /// 高频认知扭曲 TOP 3（对应 PRD 核心指标）。
  List<(String, int)> get topDistortions {
    final counts = <String, int>{};
    for (final r in records) {
      for (final d in r.allDistortions) {
        counts[d] = (counts[d] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => (e.key, e.value)).toList();
  }

  @override
  List<Object?> get props => [records];
}

/// 加载失败。
class RecordsLoadFailed extends RecordsState {
  const RecordsLoadFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
