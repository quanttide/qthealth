/// 本地规则解析结果（对应 ADD「AI 可解释」输出的本地版）。
library;

/// 单个自动想法的解析结果：识别出的认知扭曲与辩驳提示。
class ParsedThought {
  const ParsedThought({
    required this.thought,
    required this.distortions,
    required this.refutationHint,
  });

  final String thought;
  final List<String> distortions;
  final String refutationHint;

  bool get hasDistortions => distortions.isNotEmpty;
}

/// 危机检测结果（对应 ADD SafetyResult 的本地版）。
class SafetyResult {
  const SafetyResult({required this.level, required this.action});

  /// critical | safe
  final String level;

  /// interrupt | continue
  final String action;

  bool get isCrisis => level == 'critical';
}

/// 情绪日记加工结果（对应 context「AI 情绪加工引擎」的结构化输出，本地规则版）。
class JournalParseResult {
  const JournalParseResult({
    required this.primaryEmotion,
    required this.intensity,
    required this.triggerEvent,
    required this.thought,
    required this.distortions,
    required this.reframeHint,
    required this.suggestion,
    required this.tags,
  });

  final String primaryEmotion; // 主要情绪
  final int intensity; // 情绪强度（0-100）
  final String triggerEvent; // 触发事件（A）
  final String thought; // 自动想法（B，本地版取日记原文）
  final List<String> distortions; // 认知扭曲（B 解析结果）
  final String reframeHint; // 换个角度想（D）
  final String suggestion; // 今天可以试试
  final List<String> tags; // 趋势标签（如 #工作 #人际）
}
