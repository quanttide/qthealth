/// 记录列表 Cubit：加载 / 新增 / 删除 / 清空本地缓存。
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/abc_record.dart';
import '../sources/record_store.dart';
import 'records_state.dart';

class RecordsCubit extends Cubit<RecordsState> {
  RecordsCubit({RecordStore? store}) : _store = store ?? const RecordStore(), super(const RecordsLoading());

  final RecordStore _store;

  /// 启动时加载本地缓存。
  Future<void> load() async {
    emit(const RecordsLoading());
    try {
      final records = await _store.load();
      emit(RecordsLoaded(records));
    } catch (e) {
      emit(RecordsLoadFailed('加载本地记录失败：$e'));
    }
  }

  /// 新增记录并持久化到本地缓存。
  Future<void> add(ABCRecord record) async {
    final current = state;
    if (current is! RecordsLoaded) return;
    try {
      await _store.add(record);
      emit(RecordsLoaded([record, ...current.records]));
    } catch (e) {
      emit(RecordsLoadFailed('保存记录失败：$e'));
    }
  }

  /// 删除记录。
  Future<void> delete(String id) async {
    final current = state;
    if (current is! RecordsLoaded) return;
    try {
      await _store.delete(id);
      emit(RecordsLoaded(current.records.where((r) => r.id != id).toList()));
    } catch (e) {
      emit(RecordsLoadFailed('删除记录失败：$e'));
    }
  }

  /// 清空全部本地数据。
  Future<void> clearAll() async {
    await _store.clear();
    emit(const RecordsLoaded([]));
  }
}
