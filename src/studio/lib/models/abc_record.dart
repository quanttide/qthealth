/// ABC 记录领域模型（对齐 PRD 的 ABCDE JSON 数据模型，仅客户端本地使用）。
library;

/// B 阶段自动想法（含认知扭曲与辩驳提示）。
class Belief {
  const Belief({
    required this.thought,
    this.cognitiveDistortions = const [],
    this.beliefStrength = 50,
    this.refutationHint,
  });

  final String thought;
  final List<String> cognitiveDistortions;
  final int beliefStrength; // 0-100
  final String? refutationHint;

  Belief copyWith({
    String? thought,
    List<String>? cognitiveDistortions,
    int? beliefStrength,
    String? refutationHint,
  }) {
    return Belief(
      thought: thought ?? this.thought,
      cognitiveDistortions: cognitiveDistortions ?? this.cognitiveDistortions,
      beliefStrength: beliefStrength ?? this.beliefStrength,
      refutationHint: refutationHint ?? this.refutationHint,
    );
  }

  Map<String, dynamic> toJson() => {
        'thought': thought,
        'cognitive_distortions': cognitiveDistortions,
        'belief_strength': beliefStrength,
        if (refutationHint != null) 'refutation_hint': refutationHint,
      };

  factory Belief.fromJson(Map<String, dynamic> json) => Belief(
        thought: json['thought'] as String? ?? '',
        cognitiveDistortions: (json['cognitive_distortions'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        // 反序列化路径必须有 fallback（见 platform flutter/apps.md）
        beliefStrength: json['belief_strength'] as int? ?? 50,
        refutationHint: json['refutation_hint'] as String?,
      );
}

/// C/E 阶段的情绪（名称 + 强度 0-100）。
class Emotion {
  const Emotion({required this.name, this.intensity = 50});

  final String name;
  final int intensity;

  Map<String, dynamic> toJson() => {'name': name, 'intensity': intensity};

  factory Emotion.fromJson(Map<String, dynamic> json) => Emotion(
        name: json['name'] as String? ?? '',
        intensity: json['intensity'] as int? ?? 50,
      );
}

/// ABCDE 完整记录。字段与 PRD 数据模型一致，重构指标由 C/E 推导；
/// 情绪日记场景下 A/B/C/D 由自动加工产出，原始文本与结构化数据一并入库
/// （对应 context「AI 情绪加工引擎」步骤 4 存档）。
class ABCRecord {
  const ABCRecord({
    required this.id,
    required this.date,
    required this.activatingEvent,
    this.beliefs = const [],
    this.emotions = const [],
    this.behaviors = const [],
    this.disputation,
    this.newThought,
    this.emotionsAfter = const [],
    this.beliefStrengthAfter,
    this.originalText,
    this.tags = const [],
    this.suggestion,
  });

  final String id; // 本地 UUID（客户端先行，无服务端）
  final DateTime date;
  final String activatingEvent; // A 诱发事件（自动加工的事件提炼）

  final List<Belief> beliefs; // B 自动想法
  final List<Emotion> emotions; // C 情绪后果
  final List<String> behaviors; // C 行为

  final String? disputation; // D 辩驳（换个角度想）
  final String? newThought; // E 新想法
  final List<Emotion> emotionsAfter; // E 情绪重评
  final int? beliefStrengthAfter; // E 相信程度重评

  /// 情绪日记原始文本（context：原始文本 + 结构化数据一并入库）。
  final String? originalText;

  /// 趋势标签（如 #工作 #人际，context 的趋势标记）。
  final List<String> tags;

  /// 行为建议（context 的 suggestion_action）。
  final String? suggestion;

  /// C 阶段平均情绪强度。
  int get emotionIntensityAvg {
    if (emotions.isEmpty) return 0;
    return emotions.map((e) => e.intensity).reduce((a, b) => a + b) ~/ emotions.length;
  }

  /// E 阶段平均情绪强度。
  int get emotionAfterAvg {
    if (emotionsAfter.isEmpty) return emotionIntensityAvg;
    return emotionsAfter.map((e) => e.intensity).reduce((a, b) => a + b) ~/
        emotionsAfter.length;
  }

  /// 重构效果：情绪强度变化（负值表示下降）。
  int get emotionChange => emotionAfterAvg - emotionIntensityAvg;

  /// 重构是否成功：E 阶段情绪强度下降超过 30%（对应 PRD 核心指标）。
  bool get reconstructionSucceeded =>
      emotionsAfter.isNotEmpty && emotionIntensityAvg > 0 &&
      (emotionIntensityAvg - emotionAfterAvg) / emotionIntensityAvg > 0.3;

  /// 全部认知扭曲（跨 B 阶段想法去重）。
  List<String> get allDistortions {
    final seen = <String>{};
    for (final b in beliefs) {
      for (final d in b.cognitiveDistortions) {
        seen.add(d);
      }
    }
    return seen.toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'activating_event': activatingEvent,
        'beliefs': beliefs.map((b) => b.toJson()).toList(),
        'emotions': emotions.map((e) => e.toJson()).toList(),
        'behaviors': behaviors,
        if (disputation != null) 'disputation': disputation,
        if (newThought != null) 'new_thought': newThought,
        'emotions_after': emotionsAfter.map((e) => e.toJson()).toList(),
        if (beliefStrengthAfter != null)
          'belief_strength_after': beliefStrengthAfter,
        if (originalText != null) 'original_text': originalText,
        'tags': tags,
        if (suggestion != null) 'suggestion': suggestion,
      };

  factory ABCRecord.fromJson(Map<String, dynamic> json) {
    // 日期解析带 fallback：旧数据可能缺失或格式不同
    DateTime? parsedDate;
    final raw = json['date'];
    if (raw is String) {
      parsedDate = DateTime.tryParse(raw);
    }
    return ABCRecord(
      id: json['id'] as String? ?? '',
      date: parsedDate ?? DateTime.now(),
      activatingEvent: json['activating_event'] as String? ?? '',
      beliefs: (json['beliefs'] as List?)
              ?.map((e) => Belief.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      emotions: (json['emotions'] as List?)
              ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      behaviors: (json['behaviors'] as List?)?.map((e) => e as String).toList() ??
          const [],
      disputation: json['disputation'] as String?,
      newThought: json['new_thought'] as String?,
      emotionsAfter: (json['emotions_after'] as List?)
              ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      beliefStrengthAfter: json['belief_strength_after'] as int?,
      // 新字段全部带 fallback：旧缓存（v1 早期格式）无这些键时保持可读
      originalText: json['original_text'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ??
          const [],
      suggestion: json['suggestion'] as String?,
    );
  }
}
