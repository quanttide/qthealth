import 'package:flutter_test/flutter_test.dart';
import 'package:studio/status/assessment_state.dart';
import 'package:studio/data/assessments.dart';
import 'package:studio/models/assessment.dart';

/// 构造答题态并交卷（answers: 题目索引 -> 选项原始分）。
AssessmentResult score(Assessment a, Map<int, int> answers) {
  return AssessmentQuizState(assessment: a, answers: answers)
      .buildResult(DateTime(2026, 8, 16));
}

void main() {
  group('PHQ-9', () {
    test('量表结构：9 题、每题 4 档、末题为危机项', () {
      expect(kPhq9.questions.length, 9);
      expect(kPhq9.questions.last.isCrisisItem, isTrue);
      expect(kPhq9.questions.first.options.length, 4);
      expect(kPhq9.maxScore, 27);
    });

    test('分级边界：0-4 / 5-9 / 10-14 / 15-19 / 20-27', () {
      expect(levelNameFor(kPhq9, 0), '无明显抑郁症状');
      expect(levelNameFor(kPhq9, 4), '无明显抑郁症状');
      expect(levelNameFor(kPhq9, 5), '轻度抑郁症状');
      expect(levelNameFor(kPhq9, 9), '轻度抑郁症状');
      expect(levelNameFor(kPhq9, 14), '中度抑郁症状');
      expect(levelNameFor(kPhq9, 19), '中重度抑郁症状');
      expect(levelNameFor(kPhq9, 27), '重度抑郁症状');
    });
  });

  group('GAD-7', () {
    test('量表结构：7 题、无危机项', () {
      expect(kGad7.questions.length, 7);
      expect(kGad7.questions.any((q) => q.isCrisisItem), isFalse);
      expect(kGad7.maxScore, 21);
    });

    test('分级边界：0-4 / 5-9 / 10-14 / 15-21', () {
      expect(levelNameFor(kGad7, 4), '无明显焦虑症状');
      expect(levelNameFor(kGad7, 9), '轻度焦虑症状');
      expect(levelNameFor(kGad7, 14), '中度焦虑症状');
      expect(levelNameFor(kGad7, 21), '重度焦虑症状');
    });
  });

  group('PSS-4（profile：pss-4.md）', () {
    test('量表结构：4 题、5 档、满分 16', () {
      expect(kPss4.questions.length, 4);
      expect(kPss4.questions[1].reversed, isTrue); // 第 2 题反向
      expect(kPss4.questions[2].reversed, isTrue); // 第 3 题反向
      expect(kPss4.maxScore, 16);
    });

    test('反向计分：全选 4 → 有效分 4/0/0/4 → 总分 8（中等）', () {
      final r = score(kPss4, {0: 4, 1: 4, 2: 4, 3: 4});
      expect(r.total, 8);
      expect(r.level, '压力感知中等');
    });

    test('高分场景：正向题 4、反向题 0 → 总分 16（偏高）', () {
      final r = score(kPss4, {0: 4, 1: 0, 2: 0, 3: 4});
      expect(r.total, 16);
      expect(r.level, '压力感知偏高');
    });
  });

  group('Mini-IPIP（profile：mini-ipip.md）', () {
    test('量表结构：20 题、5 维 × 4 题、满分 100', () {
      expect(kMiniIpip.questions.length, 20);
      expect(kMiniIpip.dimensions.length, 5);
      for (final dim in kMiniIpip.dimensions) {
        final count = kMiniIpip.questions
            .where((q) => q.dimensionId == dim.id)
            .length;
        expect(count, 4, reason: '维度 ${dim.name} 应有 4 题');
      }
      expect(kMiniIpip.maxScore, 100);
    });

    test('反向题：外向性第 2 题（我话不多）反向计分', () {
      expect(kMiniIpip.questions[1].reversed, isTrue);
      expect(kMiniIpip.questions[1].effectiveScore(5), 1); // 6 - 5
    });

    test('维度求和计分：全选 5 → 外向性 12（2 题反向后 5+1+5+1）', () {
      final allFive = {
        for (var i = 0; i < 20; i++) i: 5,
      };
      final r = score(kMiniIpip, allFive);
      final dims = {for (final d in r.dimensionScores) d.name: d.score};
      expect(dims['外向性'], 12);
      expect(dims['宜人性'], 12);
      expect(dims['尽责性'], 12);
      expect(dims['开放性'], 8); // 3 题反向
      expect(dims['情绪稳定性'], 12); // 24 - (5+1+5+1)
    });

    test('情绪稳定性为产品侧反向解释：高分=稳定', () {
      // 情绪波动少（Q13=1）、大部分时间放松（Q14=5，反向）、
      // 不易心烦（Q15=1）、很少忧郁（Q16=5，反向）→ 原始 4 → 稳定性 24-4=20
      final r = score(kMiniIpip, {12: 1, 13: 5, 14: 1, 15: 5});
      final stability =
          r.dimensionScores.firstWhere((d) => d.name == '情绪稳定性');
      expect(stability.score, 20);
    });

    test('无分级定义 → 参考结果', () {
      final r = score(kMiniIpip, {});
      expect(r.level, '参考结果');
    });
  });

  group('CBI（profile：cbi.md）', () {
    test('量表结构：19 题、3 维（个人6/工作7/服务对象6）、工作第 7 题反向', () {
      expect(kCbi.questions.length, 19);
      expect(kCbi.dimensions.length, 3);
      expect(kCbi.questions[12].reversed, isTrue); // 工作倦怠第 7 题
      expect(kCbi.maxScore, 1900);
    });

    test('维度均值计分：全选 100 → 个人 100（严重）、工作 86（高度）、服务对象 100（严重）', () {
      final allHigh = {
        for (var i = 0; i < 19; i++) i: 100,
      };
      final r = score(kCbi, allHigh);
      // 有效分合计：个人 6×100 + 工作 6×100（第 7 题反向为 0）+ 服务对象 6×100
      expect(r.total, 1800);
      final dims = {for (final d in r.dimensionScores) d.name: d};
      expect(dims['个人倦怠']!.score, 100);
      expect(dims['个人倦怠']!.level, '严重');
      // 工作倦怠：6 题 100 + 反向题 0 → 均值 600/7 ≈ 86
      expect(dims['工作倦怠']!.score, (600 / 7).round());
      expect(dims['工作倦怠']!.level, '高度');
      expect(dims['服务对象相关倦怠']!.score, 100);
      // 总分分级：取最重维度
      expect(r.level, contains('严重'));
    });

    test('全选 0（从不）→ 个人 0 低度、工作含反向题 ≈14 低度', () {
      final allLow = {
        for (var i = 0; i < 19; i++) i: 0,
      };
      final r = score(kCbi, allLow);
      final dims = {for (final d in r.dimensionScores) d.name: d};
      expect(dims['个人倦怠']!.score, 0);
      expect(dims['工作倦怠']!.score, (100 / 7).round()); // 仅反向题 100
      expect(dims['个人倦怠']!.level, '低度');
    });

    test('判读边界：50 中度起点 / 75 高度起点 / 100 严重', () {
      expect(kCbiBands[0].contains(49), isTrue);
      expect(kCbiBands[1].contains(50), isTrue);
      expect(kCbiBands[1].contains(74), isTrue);
      expect(kCbiBands[2].contains(75), isTrue);
      expect(kCbiBands[3].contains(100), isTrue);
    });
  });

  group('AssessmentResult 序列化', () {
    test('toJson/fromJson 往返一致', () {
      final result = AssessmentResult(
        assessment: kPhq9,
        total: 12,
        level: '中度抑郁症状',
        interpretation: '建议咨询',
        crisisFlagged: false,
        takenAt: DateTime(2026, 8, 16),
      );
      final restored = AssessmentResult.fromJson(result.toJson(), kPhq9);
      expect(restored.total, 12);
      expect(restored.level, '中度抑郁症状');
      expect(restored.takenAt.year, 2026);
    });

    test('维度得分序列化往返一致', () {
      final r = score(kCbi, {
        for (var i = 0; i < 19; i++) i: 75,
      });
      final restored =
          AssessmentResult.fromJson(r.toJson(), kCbi);
      expect(restored.dimensionScores.length, 3);
      expect(restored.dimensionScores.first.name, '个人倦怠');
      expect(restored.dimensionScores.first.level, isNotNull);
    });

    test('旧缓存无维度得分字段时保持可读（fallback）', () {
      final restored = AssessmentResult.fromJson({
        'assessment_id': 'mini-ipip',
        'assessment_title': 'Mini-IPIP 人格倾向',
        'total': 52,
        'level': '参考结果',
        'interpretation': '',
        'crisis_flagged': false,
        'taken_at': '2026-08-16T10:00:00.000',
      }, kMiniIpip);
      expect(restored.dimensionScores, isEmpty);
      expect(restored.total, 52);
    });
  });
}
