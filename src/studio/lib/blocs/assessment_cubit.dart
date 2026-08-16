/// 心理测试 Cubit：列表（含历史）/ 答题 / 评分 / 结果保存。
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/assessment.dart';
import '../sources/assessment_store.dart';
import 'assessment_state.dart';

class AssessmentCubit extends Cubit<AssessmentState> {
  AssessmentCubit({AssessmentStore? store})
      : _store = store ?? const AssessmentStore(),
        super(const AssessmentListState());

  final AssessmentStore _store;

  // ---- 列表 ----

  /// 加载历史结果。
  Future<void> loadHistory() async {
    final history = await _store.load();
    emit(AssessmentListState(history: history));
  }

  // ---- 答题 ----

  /// 开始一个测试。
  void start(Assessment assessment) {
    emit(AssessmentQuizState(assessment: assessment));
  }

  /// 回答当前题目（选中选项即记录分数；危机项勾选后由页面跳转危机干预）。
  void answer(int optionScore) {
    final state = this.state;
    if (state is! AssessmentQuizState || state.isFinished) return;
    final answers = Map<int, int>.from(state.answers)
      ..[state.currentIndex] = optionScore;
    emit(state.copyWith(answers: answers));
  }

  void next() {
    final state = this.state;
    if (state is! AssessmentQuizState || state.isFinished) return;
    if (state.currentIndex < state.assessment.questions.length - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void previous() {
    final state = this.state;
    if (state is! AssessmentQuizState || state.isFinished) return;
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  /// 交卷：计算总分与分级，保存历史，进入结果态。
  Future<void> finish() async {
    final state = this.state;
    if (state is! AssessmentQuizState || state.isFinished) return;
    final result = state.buildResult(DateTime.now());
    await _store.add(result);
    emit(state.copyWith(result: () => result));
  }

  /// 返回列表。
  Future<void> backToList() async {
    final history = await _store.load();
    emit(AssessmentListState(history: history));
  }
}
