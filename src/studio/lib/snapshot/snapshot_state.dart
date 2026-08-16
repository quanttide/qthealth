/// 单题快照状态：今日题目（4 个核心维度）+ 全部快照历史。
library;

import 'package:equatable/equatable.dart';

import '../data/snapshots.dart';

class SnapshotState extends Equatable {
  const SnapshotState({required this.history, required this.today});

  /// 全部快照记录（按日期升序）。
  final List<DailySnapshot> history;

  /// 今天（可注入，测试用）。
  final DateTime today;

  /// 今日已答记录：questionId -> snapshot。
  Map<String, DailySnapshot> get todaySnapshots {
    final date = fmtDate(today);
    return {
      for (final s in history)
        if (s.date == date) s.questionId: s,
    };
  }

  /// 今日已答题目数。
  int get answeredCount => todaySnapshots.length;

  @override
  List<Object?> get props => [history, today];
}
