/// 测试结果本地缓存（仅前端缓存，不保存到服务端）。
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/assessments.dart';
import '../models/assessment.dart';

class AssessmentStore {
  const AssessmentStore();

  static const String _key = 'assessment_results_v1';

  /// 读取历史结果（按时间倒序，最多保留 20 条）。
  Future<List<AssessmentResult>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List;
      final results = <AssessmentResult>[];
      for (final e in list) {
        try {
          final json = e as Map<String, dynamic>;
          final assessment = assessmentById(json['assessment_id'] as String? ?? '');
          if (assessment == null) continue;
          results.add(AssessmentResult.fromJson(json, assessment));
        } catch (_) {
          // 跳过损坏的单条结果
        }
      }
      results.sort((a, b) => b.takenAt.compareTo(a.takenAt));
      return results;
    } catch (_) {
      return [];
    }
  }

  Future<void> add(AssessmentResult result) async {
    final results = await load();
    results.insert(0, result);
    if (results.length > 20) results.removeRange(20, results.length);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(results.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
