/// 单题快照状态：今日题目 + 全部快照历史。
library;

import 'package:equatable/equatable.dart';

import '../data/snapshots.dart';

class SnapshotState extends Equatable {
  const SnapshotState({required this.history, required this.today});

  /// 全部快照记录（按日期升序）。
  final List<DailySnapshot> history;

  /// 今天（可注入，测试用）。
  final DateTime today;

  /// 今日题目（按日期轮换）。
  SnapshotQuestion get question => questionForDate(today);

  /// 今日已答记录；未答为 null。
  DailySnapshot? get todaySnapshot {
    final date = fmtDate(today);
    for (final s in history) {
      if (s.date == date) return s;
    }
    return null;
  }

  bool get answeredToday => todaySnapshot != null;

  @override
  List<Object?> get props => [history, today];
}
