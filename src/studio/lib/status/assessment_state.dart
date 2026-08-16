/// 心理测试状态：答题进度 + 结果（本地评分）。
library;

import 'package:equatable/equatable.dart';

import '../models/assessment.dart';

sealed class AssessmentState extends Equatable {
  const AssessmentState();

  @override
  List<Object?> get props => const [];
}

/// 测试列表（含历史结果）。
class AssessmentListState extends AssessmentState {
  const AssessmentListState({this.history = const []});

  final List<AssessmentResult> history;

  @override
  List<Object?> get props => [history];
}

/// 答题中。
class AssessmentQuizState extends AssessmentState {
  const AssessmentQuizState({
    required this.assessment,
    this.currentIndex = 0,
    this.answers = const {},
    this.result,
  });

  final Assessment assessment;
  final int currentIndex;

  /// 题目索引 -> 选项原始分。
  final Map<int, int> answers;

  /// 完成后的结果（用于展示结果视图）。
  final AssessmentResult? result;

  bool get isFinished => result != null;

  int get answeredCount => answers.length;

  int get progress => answers.length;

  bool get canNext => answers.containsKey(currentIndex);

  /// 交卷评分：反向计分转换 → 总分 → 维度得分 → 分级 → 解读。
  AssessmentResult buildResult(DateTime takenAt) {
    // 各题有效分（反向题按刻度上限翻转）
    final effective = <int, int>{};
    for (var i = 0; i < assessment.questions.length; i++) {
      effective[i] = assessment.questions[i].effectiveScore(answers[i] ?? 0);
    }
    final total = effective.values.fold<int>(0, (a, b) => a + b);
    final dimensions = _dimensionScores(effective);
    final level = _level(total, dimensions);

    return AssessmentResult(
      assessment: assessment,
      total: total,
      level: level,
      interpretation: _interpretation(assessment, total, dimensions),
      crisisFlagged: _crisisFlagged(),
      takenAt: takenAt,
      dimensionScores: dimensions,
    );
  }

  bool _crisisFlagged() {
    for (var i = 0; i < assessment.questions.length; i++) {
      final q = assessment.questions[i];
      if (q.isCrisisItem && (answers[i] ?? 0) > 0) return true;
    }
    return false;
  }

  /// 维度得分：sum（各题有效分相加，可反向解释）/ mean（各题有效分平均）。
  List<DimensionScore> _dimensionScores(Map<int, int> effective) {
    if (assessment.dimensions.isEmpty) {
      final total = effective.values.fold<int>(0, (a, b) => a + b);
      return [DimensionScore(name: '总分', score: total, level: _bandName(total))];
    }
    return [
      for (final dim in assessment.dimensions)
        _dimensionScore(dim, effective),
    ];
  }

  DimensionScore _dimensionScore(
    AssessmentDimension dim,
    Map<int, int> effective,
  ) {
    final indices = [
      for (var i = 0; i < assessment.questions.length; i++)
        if (assessment.questions[i].dimensionId == dim.id) i,
    ];
    final sum = indices.fold<int>(0, (a, i) => a + effective[i]!);
    final raw = dim.scoring == 'mean'
        ? (sum / indices.length).round()
        : sum;
    final score = dim.inverted
        ? indices.fold<int>(
                0,
                (a, i) =>
                    a +
                    assessment.questions[i].maxOptionScore +
                    assessment.questions[i].minOptionScore) -
            raw
        : raw;
    return DimensionScore(
      name: dim.name,
      score: score,
      level: _bandName(score),
    );
  }

  /// 总分分级；维度级分级（CBI）取最重维度；无分级定义时兜底参考文案。
  String _level(int total, List<DimensionScore> dimensions) {
    if (assessment.bands.isNotEmpty) {
      return _bandName(total) ?? '参考结果';
    }
    if (assessment.dimensionBands.isNotEmpty) {
      final worst = dimensions
          .where((d) => d.level != null)
          .toList()
        ..sort(
          (a, b) => _severity(b.level!).compareTo(_severity(a.level!)),
        );
      if (worst.isNotEmpty) {
        return '${worst.first.name}：${worst.first.level}（最重维度）';
      }
    }
    return '参考结果';
  }

  int _severity(String name) {
    for (var i = 0; i < assessment.dimensionBands.length; i++) {
      if (assessment.dimensionBands[i].name == name) return i;
    }
    return -1;
  }

  /// 命中分级返回名称；无分级定义（如 Mini-IPIP）返回 null。
  String? _bandName(int score) {
    for (final band in assessment.bands) {
      if (band.contains(score)) return band.name;
    }
    for (final band in assessment.dimensionBands) {
      if (band.contains(score)) return band.name;
    }
    return null;
  }

  String _interpretation(
    Assessment a,
    int total,
    List<DimensionScore> dimensions,
  ) {
    switch (a.id) {
      case 'pss4':
        if (total <= 4) return '过去一个月您的压力感知偏低。若配合 Mini-IPIP 情绪稳定性得分，可进一步判断压力倾向。';
        if (total <= 8) return '过去一个月您的压力感知中等。建议关注压力来源，尝试情绪日记记录触发事件。';
        return '过去一个月您的压力感知偏高。若 Mini-IPIP 情绪稳定性同时偏高，更倾向情境性压力；仅此高分更可能为近期环境变化所致，建议尝试情绪日记与放松练习。';
      case 'mini-ipip':
        return _miniIpipInterpretation(dimensions);
      case 'cbi':
        return '各维度得分 = 该维度所有题目得分的平均值（0-100），越高倦怠越明显。'
            '若工作倦怠达到高度以上，建议调整工作负荷、规律作息，并考虑寻求专业支持。';
      default:
        return '本测试结果仅供参考，不构成医学诊断。';
    }
  }

  String _miniIpipInterpretation(List<DimensionScore> dimensions) {
    final stability = dimensions
        .where((d) => d.name == '情绪稳定性')
        .map((d) => d.score)
        .firstOrNull;
    if (stability == null) return '各维度 4-20 分，越高越符合该特质描述。';
    if (stability >= 15) {
      return '情绪稳定性得分较高（高分=稳定），压力应对基础较好。建议与 PSS-4 对照：若压力感知偏高，更可能为近期情境性压力。';
    }
    if (stability >= 10) {
      return '情绪稳定性处于中等水平。若配合 PSS-4 持续高分，建议关注压力来源并尝试情绪日记追踪。';
    }
    return '情绪稳定性得分偏低，更容易出现焦虑、紧张、情绪起伏。建议结合 PSS-4 判断是特质还是近期情境所致，并尝试规律作息与情绪日记。';
  }

  AssessmentQuizState copyWith({
    int? currentIndex,
    Map<int, int>? answers,
    AssessmentResult? Function()? result,
  }) {
    return AssessmentQuizState(
      assessment: assessment,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      result: result != null ? result() : this.result,
    );
  }

  @override
  List<Object?> get props => [assessment.id, currentIndex, answers, result];
}
