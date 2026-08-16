/// 练习记录本地缓存（行为日志——仅前端缓存，同 ABC 记录模式）。
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/practice_log.dart';

class PracticeStore {
  const PracticeStore();

  static const _key = 'practice_logs_v1';

  Future<List<PracticeLog>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(PracticeLog.fromJson).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
  }

  Future<void> add(PracticeLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadAll();
    existing.add(log);
    await prefs.setString(
      _key,
      jsonEncode([for (final e in existing) e.toJson()]),
    );
  }
}
