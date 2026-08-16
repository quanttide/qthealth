/// 情绪日记表单状态：写日记 → 自动加工（情绪小结）→ 确认保存。
///
/// 对应 context「AI 情绪加工引擎」模式 A（写完自动加工）：自由书写 →
/// 结构化情绪小结 → 用户可修改或确认（人机协同修正闭环）。
library;

import 'package:equatable/equatable.dart';

import '../models/abc_record.dart';

class RecordFormState extends Equatable {
  const RecordFormState({
    this.step = 0,
    this.journalText = '',
    this.selectedEmotion,
    this.emotionName = '平静',
    this.emotionIntensity = 50,
    this.triggerEvent = '',
    this.thought = '',
    this.distortions = const [],
    this.reframeHint = '',
    this.suggestion = '',
    this.tags = const [],
    this.newThought = '',
    this.emotionsAfter = const [],
    this.beliefStrengthAfter,
    this.savedRecord,
  });

  /// 当前步骤：0=写日记 1=加工结果。
  final int step;

  // 步骤 0：日记原文
  final String journalText;
  final String? selectedEmotion; // 用户自选情绪（可选，选择可提高识别准确率）

  // 步骤 1：加工结果（可编辑，人机协同修正）
  final String emotionName; // 主要情绪（C）
  final int emotionIntensity; // 情绪强度 0-100（C）
  final String triggerEvent; // 触发事件（A）
  final String thought; // 自动想法（B）
  final List<String> distortions; // 认知扭曲（B 解析结果）
  final String reframeHint; // 换个角度想（D）
  final String suggestion; // 今天可以试试
  final List<String> tags; // 趋势标签

  // E 阶段（可选，重新评估）
  final String newThought;
  final List<Emotion> emotionsAfter;
  final int? beliefStrengthAfter;

  /// 保存成功后携带的记录（用于跳转完成页）。
  final ABCRecord? savedRecord;

  bool get canNext => step == 0 ? journalText.trim().isNotEmpty : true;

  RecordFormState copyWith({
    int? step,
    String? journalText,
    String? Function()? selectedEmotion,
    String? emotionName,
    int? emotionIntensity,
    String? triggerEvent,
    String? thought,
    List<String>? distortions,
    String? reframeHint,
    String? suggestion,
    List<String>? tags,
    String? newThought,
    List<Emotion>? emotionsAfter,
    int? Function()? beliefStrengthAfter,
    ABCRecord? Function()? savedRecord,
  }) {
    return RecordFormState(
      step: step ?? this.step,
      journalText: journalText ?? this.journalText,
      selectedEmotion: selectedEmotion != null
          ? selectedEmotion()
          : this.selectedEmotion,
      emotionName: emotionName ?? this.emotionName,
      emotionIntensity: emotionIntensity ?? this.emotionIntensity,
      triggerEvent: triggerEvent ?? this.triggerEvent,
      thought: thought ?? this.thought,
      distortions: distortions ?? this.distortions,
      reframeHint: reframeHint ?? this.reframeHint,
      suggestion: suggestion ?? this.suggestion,
      tags: tags ?? this.tags,
      newThought: newThought ?? this.newThought,
      emotionsAfter: emotionsAfter ?? this.emotionsAfter,
      beliefStrengthAfter: beliefStrengthAfter != null
          ? beliefStrengthAfter()
          : this.beliefStrengthAfter,
      savedRecord: savedRecord != null ? savedRecord() : this.savedRecord,
    );
  }

  @override
  List<Object?> get props => [
        step,
        journalText,
        selectedEmotion,
        emotionName,
        emotionIntensity,
        triggerEvent,
        thought,
        distortions,
        reframeHint,
        suggestion,
        tags,
        newThought,
        emotionsAfter,
        beliefStrengthAfter,
        savedRecord,
      ];
}
