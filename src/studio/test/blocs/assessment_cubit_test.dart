import 'package:flutter_test/flutter_test.dart';
import 'package:studio/blocs/assessment_cubit.dart';
import 'package:studio/blocs/assessment_state.dart';
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
      cubit.start(kPhq9);
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
      cubit.start(kGad7);
      for (var i = 0; i < kGad7.questions.length; i++) {
        cubit.answer(2);
        if (i < kGad7.questions.length - 1) cubit.next();
      }
      await cubit.finish();
      final quiz = cubit.state as AssessmentQuizState;
      expect(quiz.isFinished, isTrue);
      expect(quiz.result!.total, 14);
      expect(quiz.result!.level, '中度焦虑症状');
      expect(quiz.result!.crisisFlagged, isFalse);

      await cubit.backToList();
      final list = cubit.state as AssessmentListState;
      expect(list.history.length, 1);
      await cubit.close();
    });

    test('PHQ-9 勾选危机项（第 9 题 > 0）标记 crisisFlagged', () async {
      final cubit = AssessmentCubit();
      cubit.start(kPhq9);
      for (var i = 0; i < kPhq9.questions.length; i++) {
        // 第 9 题（index 8）选 1（有几天），其余选 0
        cubit.answer(i == 8 ? 1 : 0);
        if (i < kPhq9.questions.length - 1) cubit.next();
      }
      await cubit.finish();
      final quiz = cubit.state as AssessmentQuizState;
      expect(quiz.result!.crisisFlagged, isTrue);
      await cubit.close();
    });
  });
}
