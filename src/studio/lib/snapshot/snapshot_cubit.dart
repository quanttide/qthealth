/// 单题快照 Cubit：加载历史；一轮（4 题）答完统一保存，答题过程只暂存内存。
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/snapshots.dart';
import 'snapshot_state.dart';
import 'snapshot_store.dart';

class SnapshotCubit extends Cubit<SnapshotState> {
  SnapshotCubit({DateTime? today, SnapshotStore? store})
      : _store = store ?? const SnapshotStore(),
        super(SnapshotState(history: const [], today: today ?? DateTime.now())) {
    _load();
  }

  final SnapshotStore _store;

  Future<void> _load() async {
    final history = await _store.load();
    if (isClosed) return;
    emit(SnapshotState(history: history, today: state.today));
  }

  /// 点选某题答案：一轮未答完只更新内存暂存；4 题全部有值后
  /// 一次性统一保存（之后修改任一题同样立即统一保存）。
  Future<void> answer(String questionId, int value) async {
    final s = state;
    final draft = Map<String, int>.from(s.draft)..[questionId] = value;
    final covered = {...s.savedToday.keys, ...draft.keys};

    // 一轮未答完：仅暂存，不写盘
    if (!kSnapshotQuestions.every((q) => covered.contains(q.id))) {
      emit(SnapshotState(history: s.history, today: s.today, draft: draft));
      return;
    }

    // 一轮答完：统一保存一次（同日同题去重，值取暂存优先）
    final date = fmtDate(s.today);
    final others = [
      for (final x in s.history)
        if (x.date != date) x,
    ];
    final updated = [
      ...others,
      for (final q in kSnapshotQuestions)
        DailySnapshot(
          date: date,
          questionId: q.id,
          value: draft[q.id] ?? s.savedToday[q.id]?.value ?? 0,
        ),
    ];
    await _store.save(updated);
    if (isClosed) return;
    emit(SnapshotState(history: updated, today: s.today));
  }
}
