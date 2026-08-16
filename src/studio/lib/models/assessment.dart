/// 心理测试领域模型：量表、题目、选项、维度、结果（本地评分，不构成诊断）。
///
/// 支持多维度量表（Mini-IPIP 五维、CBI 三维）、反向计分题、维度均值计分
/// 与维度级分级；量表题目数据来自 `data/profile`（公共领域，无版权争议）。
library;

/// 单个题目（含危机项标记：如 PHQ-9 第 9 题自杀意念）。
class AssessmentQuestion {
  const AssessmentQuestion({
    required this.text,
    required this.options,
    this.isCrisisItem = false,
    this.reversed = false,
    this.dimensionId,
  });

  final String text;
  final List<AssessmentOption> options;

  /// 勾选即触发危机干预（如自杀意念条目）。
  final bool isCrisisItem;

  /// 反向计分题（profile 标注 R）：有效分 = 满分刻度 − 原始分。
  final bool reversed;

  /// 所属维度（多维度量表使用，如 mini-ipip 的外向性）。
  final String? dimensionId;

  /// 本组选项的最高分（反向计分刻度上限）。
  int get maxOptionScore =>
      options.map((o) => o.score).reduce((a, b) => a > b ? a : b);

  /// 本组选项的最低分（反向计分刻度下限）。
  int get minOptionScore =>
      options.map((o) => o.score).reduce((a, b) => a < b ? a : b);

  /// 选项原始分 → 计分用有效分（反向题按全刻度翻转：如 Likert 1-5 用 6−原始分）。
  int effectiveScore(int optionScore) => reversed
      ? (maxOptionScore + minOptionScore) - optionScore
      : optionScore;
}

/// 选项：分数 + 文案。
class AssessmentOption {
  const AssessmentOption({required this.score, required this.label});

  final int score;
  final String label;
}

/// 量表维度（多维度量表：Mini-IPIP 大五、CBI 三维）。
class AssessmentDimension {
  const AssessmentDimension({
    required this.id,
    required this.name,
    this.scoring = 'sum',
    this.inverted = false,
  });

  final String id;
  final String name;

  /// 维度计分方式：sum（各题有效分相加，如 Mini-IPIP）/ mean（各题有效分平均，如 CBI）。
  final String scoring;

  /// 产品侧反向解释：分数取"满分 − 正向分"（如 Mini-IPIP 情绪稳定性，
  /// 官方维度为 Neuroticism 高分=不稳定，产品侧高分=稳定）。
  final bool inverted;
}

/// 量表定义。
class Assessment {
  const Assessment({
    required this.id,
    required this.title,
    required this.description,
    required this.instruction,
    required this.questions,
    required this.disclaimer,
    this.dimensions = const [],
    this.bands = const [],
    this.dimensionBands = const [],
  });

  final String id; // phq9 / gad7 / pss4 / mini-ipip / cbi
  final String title;
  final String description;
  final String instruction;
  final List<AssessmentQuestion> questions;
  final String disclaimer;

  /// 多维度定义（空 = 单维度量表，总分即唯一指标）。
  final List<AssessmentDimension> dimensions;

  /// 总分分级区间（PHQ-9 / GAD-7 / PSS-4）。
  final List<LevelBand> bands;

  /// 维度级分级区间（CBI：<50 低度 / 50-74 中度 / 75-99 高度 / 100 严重）。
  final List<LevelBand> dimensionBands;

  /// 理论最高总分（各题有效分上限之和）。
  int get maxScore =>
      questions.fold(0, (sum, q) => sum + q.maxOptionScore);
}

/// 分级区间。
class LevelBand {
  const LevelBand({required this.min, required this.max, required this.name});

  final int min;
  final int max;
  final String name;

  bool contains(int score) => score >= min && score <= max;

  /// 严重程度序号（bands 由轻到重排列时，序号越大越严重）。
  int severityIndex(List<LevelBand> bands) => bands.indexOf(this);
}

/// 维度得分（多维度量表结果展示）。
class DimensionScore {
  const DimensionScore({
    required this.name,
    required this.score,
    this.level,
  });

  final String name;
  final int score;

  /// 维度分级（CBI 按维度判读）。
  final String? level;

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
        if (level != null) 'level': level,
      };

  factory DimensionScore.fromJson(Map<String, dynamic> json) => DimensionScore(
        name: json['name'] as String? ?? '',
        score: json['score'] as int? ?? 0,
        level: json['level'] as String?,
      );
}

/// 测试结果：总分 + 维度得分 + 分级 + 危机标记。
class AssessmentResult {
  const AssessmentResult({
    required this.assessment,
    required this.total,
    required this.level,
    required this.interpretation,
    required this.crisisFlagged,
    required this.takenAt,
    this.dimensionScores = const [],
  });

  final Assessment assessment;
  final int total;

  /// 分级（总分分级 / 维度最重分级 / 无分级时兜底文案）。
  final String level;
  final String interpretation;
  final bool crisisFlagged;
  final DateTime takenAt;

  /// 维度得分（多维度量表；单维度量表为总分）。
  final List<DimensionScore> dimensionScores;

  Map<String, dynamic> toJson() => {
        'assessment_id': assessment.id,
        'assessment_title': assessment.title,
        'total': total,
        'level': level,
        'interpretation': interpretation,
        'crisis_flagged': crisisFlagged,
        'taken_at': takenAt.toIso8601String(),
        'dimension_scores':
            dimensionScores.map((d) => d.toJson()).toList(),
      };

  factory AssessmentResult.fromJson(
    Map<String, dynamic> json,
    Assessment assessment,
  ) {
    final takenAt = DateTime.tryParse(json['taken_at'] as String? ?? '');
    return AssessmentResult(
      assessment: assessment,
      total: json['total'] as int? ?? 0,
      level: json['level'] as String? ?? '',
      interpretation: json['interpretation'] as String? ?? '',
      crisisFlagged: json['crisis_flagged'] as bool? ?? false,
      takenAt: takenAt ?? DateTime.now(),
      // 旧缓存无维度得分（v1 早期格式）时保持可读
      dimensionScores: (json['dimension_scores'] as List?)
              ?.map((e) => DimensionScore.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
