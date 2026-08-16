/// 本地规则解析：情绪日记加工（情绪识别/事件提炼/认知扭曲/行动建议/标签）
/// + 认知扭曲识别与辩驳提示生成。
///
/// 对应 context「AI 情绪加工引擎」：用户随便写一段话，系统加工出结构化
/// 情绪小结。客户端先行阶段无 AI 服务端，采用关键词规则实现；接入后端后
/// 由 go-openai 结构化 Prompt 管道替代，接口保持一致。
library;

import '../constants.dart';
import '../models/parsing_result.dart';

class LocalParser {
  const LocalParser();

  /// 对单个自动想法做规则解析：识别认知扭曲类型，取第一条命中的
  /// 辩驳提示作为引导（对应 ADD 的 refutation_hint）。
  ParsedThought parse(String thought) {
    final distortions = <String>[];
    String? hint;

    for (final rule in kDistortionRules) {
      final hit = rule.keywords.any(thought.contains);
      if (hit) {
        distortions.add(rule.name);
        hint ??= rule.refutationHint;
      }
    }

    return ParsedThought(
      thought: thought,
      distortions: distortions,
      refutationHint: hint ?? '试着换个角度：有没有其他可能的解释？',
    );
  }

  /// 情绪日记自动加工：一句话到一段话 → 结构化情绪小结。
  ///
  /// [selectedEmotion] 为用户自选的情绪标签（非必须，选择可提高准确率，
  /// 对应 context 加工流程步骤 1 的可选项）。
  JournalParseResult parseJournal(String text, {String? selectedEmotion}) {
    final t = text.trim();
    final emotion = selectedEmotion ?? _detectEmotion(t);
    final thought = parse(t);
    return JournalParseResult(
      primaryEmotion: emotion,
      intensity: _detectIntensity(t, emotion),
      triggerEvent: _firstClause(t),
      thought: t,
      distortions: thought.distortions,
      reframeHint: thought.refutationHint,
      suggestion:
          kSuggestionByEmotion[emotion] ?? kSuggestionByEmotion['平静']!,
      tags: _detectTags(t),
    );
  }

  /// 主要情绪：命中关键词最多的规则胜出，平手取规则表顺序靠前者。
  String _detectEmotion(String text) {
    var best = '平静';
    var bestHits = 0;
    for (final rule in kEmotionRules) {
      final hits = rule.keywords.where(text.contains).length;
      if (hits > bestHits) {
        bestHits = hits;
        best = rule.name;
      }
    }
    return best;
  }

  /// 情绪强度（0-100）：基础 70，按强度修饰词加权；平静情绪默认低强度。
  int _detectIntensity(String text, String emotion) {
    var score = emotion == '平静' ? 30 : 70;
    for (final w in const ['极其', '非常', '特别', '超级', '彻底', '完全', '太']) {
      if (text.contains(w)) score += 15;
    }
    if (text.contains('很')) score += 10;
    for (final w in const ['有点', '稍微', '不太', '一点点']) {
      if (text.contains(w)) score -= 20;
    }
    return score.clamp(10, 100);
  }

  /// 触发事件：取第一句（按中英文句读切分），对应 context 的事件提炼。
  String _firstClause(String text) {
    final parts = text.split(RegExp(r'[，。！？,!?；;]'));
    for (final p in parts) {
      if (p.trim().isNotEmpty) return p.trim();
    }
    return text;
  }

  /// 趋势标签：按标签规则命中归类，最多 3 个，无命中归「其他」。
  List<String> _detectTags(String text) {
    final tags = <String>[];
    for (final rule in kTagRules) {
      if (rule.keywords.any(text.contains)) tags.add(rule.name);
    }
    if (tags.isEmpty) tags.add('其他');
    return tags.take(3).toList();
  }
}
