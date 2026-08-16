/// 单题快照存储：SharedPreferences 本地缓存（仅前端缓存，不落服务端）。
///
/// 键带版本号（daily_snapshots_v1），格式变更时换键清旧数据，
/// 见 platform flutter/apps.md 缓存版本约定。
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/snapshots.dart';

class SnapshotStore {
  const SnapshotStore();

  static const String cacheKey = 'daily_snapshots_v1';

  Future<List<DailySnapshot>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cacheKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return [for (final e in list) DailySnapshot.fromJson(e)];
    } catch (_) {
      // 旧格式/损坏数据：降级为空，不阻塞页面
      return const [];
    }
  }

  Future<void> save(List<DailySnapshot> snapshots) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      cacheKey,
      jsonEncode([for (final s in snapshots) s.toJson()]),
    );
  }
}
