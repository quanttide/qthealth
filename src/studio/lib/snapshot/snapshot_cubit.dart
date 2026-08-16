/// 单题快照 Cubit：加载历史；点选只暂存内存，点「保存」统一写入一次。
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

  /// 点选某题答案：仅更新内存暂存，不写盘（保存由 [save] 统一执行）。
  void answer(String questionId, int value) {
    final s = state;
    emit(SnapshotState(
      history: s.history,
      today: s.today,
      draft: {...s.draft, questionId: value},
    ));
  }

  /// 保存今日快照：一轮（4 题）答完后统一写入一次存储，
  /// 保存成功后清空（draft 归零，页面转为完成态）。
  Future<void> save() async {
    final s = state;
    if (!s.allAnswered) return;
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
          value: s.valueOf(q.id)!,
        ),
    ];
    await _store.save(updated);
    if (isClosed) return;
    emit(SnapshotState(history: updated, today: s.today));
  }
}
