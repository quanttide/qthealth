/// 单题快照 Cubit：加载历史 + 记录/修改今日各维度答案。
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

  /// 记录/修改今日某维度答案（同日同题多次点选以最后一次为准）。
  Future<void> answer(String questionId, int value) async {
    final s = state;
    final date = fmtDate(s.today);
    final others = [
      for (final x in s.history)
        if (!(x.date == date && x.questionId == questionId)) x,
    ];
    final updated = [
      ...others,
      DailySnapshot(date: date, questionId: questionId, value: value),
    ];
    await _store.save(updated);
    if (isClosed) return;
    emit(SnapshotState(history: updated, today: s.today));
  }
}
