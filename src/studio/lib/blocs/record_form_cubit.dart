/// 情绪日记 Cubit：自由书写 → 本地规则自动加工 → 人机协同修正 → 保存到本地缓存。
///
/// 对应 context「AI 情绪加工引擎」：用户随便写一段话，系统加工出结构化
/// 情绪小结（情绪识别/事件提炼/自动想法/重构提示/行为建议/趋势标签）；
/// 客户端先行阶段由本地规则实现，接入后端后由 go-openai 管道替代。
library;

import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/abc_record.dart';
import '../services/local_parser.dart';
import '../sources/record_store.dart';
import 'record_form_state.dart';

class RecordFormCubit extends Cubit<RecordFormState> {
  RecordFormCubit({RecordStore? store, LocalParser? parser})
      : _store = store ?? const RecordStore(),
        _parser = parser ?? const LocalParser(),
        super(const RecordFormState());

  final RecordStore _store;
  final LocalParser _parser;
  final Random _random = Random();

  // ---- 步骤 0：写日记 ----
  void updateJournal(String value) => emit(state.copyWith(journalText: value));

  void updateSelectedEmotion(String? name) =>
      emit(state.copyWith(selectedEmotion: () => name));

  /// 自动加工（对应 context 加工流程步骤 2；本地规则版）。
  void process() {
    final parsed = _parser.parseJournal(
      state.journalText,
      selectedEmotion: state.selectedEmotion,
    );
    emit(state.copyWith(
      step: 1,
      emotionName: parsed.primaryEmotion,
      emotionIntensity: parsed.intensity,
      triggerEvent: parsed.triggerEvent,
      thought: parsed.thought,
      distortions: parsed.distortions,
      reframeHint: parsed.reframeHint,
      suggestion: parsed.suggestion,
      tags: parsed.tags,
    ));
  }

  /// 返回重写（模式 B 的隐私偏好：不想加工就回到写日记）。
  void back() {
    if (state.step > 0) emit(state.copyWith(step: 0));
  }

  // ---- 步骤 1：加工结果（人机协同修正） ----
  void updateEmotionName(String name) => emit(state.copyWith(emotionName: name));

  void updateEmotionIntensity(int intensity) =>
      emit(state.copyWith(emotionIntensity: intensity));

  void updateTriggerEvent(String value) =>
      emit(state.copyWith(triggerEvent: value));

  /// 修改自动想法时重新解析认知扭曲与辩驳提示。
  void updateThought(String value) {
    final parsed = _parser.parse(value);
    emit(state.copyWith(
      thought: value,
      distortions: parsed.distortions,
      reframeHint: parsed.refutationHint,
    ));
  }

  void updateReframeHint(String value) => emit(state.copyWith(reframeHint: value));

  void updateSuggestion(String value) => emit(state.copyWith(suggestion: value));

  void toggleTag(String name) {
    final tags = [...state.tags];
    if (tags.contains(name)) {
      tags.remove(name);
    } else {
      tags.add(name);
    }
    emit(state.copyWith(tags: tags));
  }

  // ---- E 阶段（可选，重新评估） ----
  void updateNewThought(String value) => emit(state.copyWith(newThought: value));

  void toggleEmotionAfter(String name) {
    final emotions = [...state.emotionsAfter];
    final index = emotions.indexWhere((e) => e.name == name);
    if (index >= 0) {
      emotions.removeAt(index);
    } else {
      emotions.add(Emotion(name: name));
    }
    emit(state.copyWith(emotionsAfter: emotions));
  }

  void updateEmotionAfterIntensity(String name, int intensity) {
    final emotions = [...state.emotionsAfter];
    final index = emotions.indexWhere((e) => e.name == name);
    if (index >= 0) {
      emotions[index] = Emotion(name: name, intensity: intensity);
      emit(state.copyWith(emotionsAfter: emotions));
    }
  }

  void updateBeliefStrengthAfter(int? value) =>
      emit(state.copyWith(beliefStrengthAfter: () => value));

  /// 组装完整 ABCDE 记录并保存到本地缓存（数据不发送到服务端）。
  ///
  /// 原始日记文本与结构化数据一并入库（context 加工流程步骤 4）。
  Future<ABCRecord> save() async {
    final journal = state.journalText.trim();
    final reframe = state.reframeHint.trim();
    final record = ABCRecord(
      id: _newId(),
      date: DateTime.now(),
      activatingEvent:
          state.triggerEvent.trim().isEmpty ? journal : state.triggerEvent.trim(),
      beliefs: [
        Belief(
          thought: state.thought.trim().isEmpty ? journal : state.thought.trim(),
          cognitiveDistortions: state.distortions,
          refutationHint: reframe.isEmpty ? null : reframe,
        ),
      ],
      emotions: [Emotion(name: state.emotionName, intensity: state.emotionIntensity)],
      disputation: reframe.isEmpty ? null : reframe,
      newThought: state.newThought.trim().isEmpty ? null : state.newThought.trim(),
      emotionsAfter: state.emotionsAfter,
      beliefStrengthAfter: state.beliefStrengthAfter,
      originalText: journal,
      tags: state.tags,
      suggestion: state.suggestion.trim().isEmpty ? null : state.suggestion.trim(),
    );
    await _store.add(record);
    emit(state.copyWith(savedRecord: () => record));
    return record;
  }

  void reset() => emit(const RecordFormState());

  String _newId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return '$now-${_random.nextInt(0xFFFFFF).toRadixString(16)}';
  }
}
