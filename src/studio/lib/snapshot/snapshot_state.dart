/// 单题快照状态：今日题目（4 个核心维度）+ 全部快照历史 + 今日暂存答案。
///
/// 答题过程只更新 [draft]（内存暂存，不写盘）；用户点「保存」后由
/// Cubit 统一写入一次并清空。
library;

import 'package:equatable/equatable.dart';

import '../data/snapshots.dart';

class SnapshotState extends Equatable {
  const SnapshotState({
    required this.history,
    required this.today,
    this.draft = const {},
  });

  /// 全部已保存的快照记录（按日期升序）。
  final List<DailySnapshot> history;

  /// 今天（可注入，测试用）。
  final DateTime today;

  /// 今日暂存答案（questionId -> 得分）：保存前只存在这里，不写盘。
  final Map<String, int> draft;

  /// 今日已保存的记录：questionId -> snapshot。
  Map<String, DailySnapshot> get savedToday {
    final date = fmtDate(today);
    return {
      for (final s in history)
        if (s.date == date) s.questionId: s,
    };
  }

  /// 每题当前值（暂存优先于已保存）；未答为 null。
  int? valueOf(String questionId) =>
      draft[questionId] ?? savedToday[questionId]?.value;

  /// 今日已答题目数（暂存 + 已保存去重）。
  int get answeredCount =>
      {...savedToday.keys, ...draft.keys}.length;

  /// 一轮是否答完（4 题均有值）——「保存」按钮可用前提。
  bool get allAnswered =>
      kSnapshotQuestions.every((q) => valueOf(q.id) != null);

  /// 今日是否已保存完整一轮（显示完成态）。
  bool get todayComplete =>
      savedToday.length == kSnapshotQuestions.length;

  @override
  List<Object?> get props => [history, today, draft];
}
