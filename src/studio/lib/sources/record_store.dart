/// 本地缓存仓库：ABC 记录持久化到 shared_preferences。
///
/// 客户端先行阶段**数据不保存到服务端**，仅前端缓存；键名带版本号
/// （`abc_records_v1`），格式变更时升级版本即可清缓存重建。
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/abc_record.dart';

class RecordStore {
  const RecordStore();

  /// 读取全部记录。反序列化整体保护：任何单条损坏不导致整体失败。
  Future<List<ABCRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kRecordsCacheKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) {
            try {
              return ABCRecord.fromJson(e as Map<String, dynamic>);
            } catch (_) {
              return null; // 跳过损坏的单条记录
            }
          })
          .whereType<ABCRecord>()
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return []; // 缓存整体损坏则降级为空
    }
  }

  /// 新增记录（覆盖式写入整表；本地规模小，简单可靠）。
  Future<void> add(ABCRecord record) async {
    final records = await load();
    records.insert(0, record);
    await _save(records);
  }

  /// 删除记录。
  Future<void> delete(String id) async {
    final records = await load();
    records.removeWhere((r) => r.id == id);
    await _save(records);
  }

  /// 清空全部本地数据。
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kRecordsCacheKey);
  }

  Future<void> _save(List<ABCRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      kRecordsCacheKey,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }
}
