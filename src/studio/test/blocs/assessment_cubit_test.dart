import 'package:flutter_test/flutter_test.dart';
import 'package:studio/status/assessment_cubit.dart';
import 'package:studio/status/assessment_state.dart';
import 'package:studio/data/assessments.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AssessmentCubit', () {
    test('初始为列表态，loadHistory 后历史为空', () async {
      final cubit = AssessmentCubit();
      await cubit.loadHistory();
      expect(cubit.state, isA<AssessmentListState>());
      expect((cubit.state as AssessmentListState).history, isEmpty);
      await cubit.close();
    });

    test('start 进入答题态，answer/next 逐题推进', () {
      final cubit = AssessmentCubit();
      cubit.start(kPss4);
      final quiz = cubit.state as AssessmentQuizState;
      expect(quiz.currentIndex, 0);
      expect(quiz.canNext, isFalse);

      cubit.answer(1);
      expect((cubit.state as AssessmentQuizState).canNext, isTrue);
      cubit.next();
      expect((cubit.state as AssessmentQuizState).currentIndex, 1);
      cubit.close();
    });

    test('全答后 finish 计算总分与分级并保存历史', () async {
      final cubit = AssessmentCubit();
      cubit.start(kPss4);
      for (var i = 0; i < kPss4.questions.length; i++) {
        cubit.answer(2);
        if (i < kPss4.questions.length - 1) cubit.next();
      }
      await cubit.finish();
      final quiz = cubit.state as AssessmentQuizState;
      expect(quiz.isFinished, isTrue);
      expect(quiz.result!.total, 8); // 4 题 × 2（无反向净变化）
      expect(quiz.result!.level, '压力感知中等');
      expect(quiz.result!.crisisFlagged, isFalse);

      await cubit.backToList();
      final list = cubit.state as AssessmentListState;
      expect(list.history.length, 1);
      await cubit.close();
    });
  });
}
