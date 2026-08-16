import 'package:flutter_test/flutter_test.dart';
import 'package:studio/blocs/record_form_cubit.dart';
import 'package:studio/sources/record_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RecordFormCubit 情绪日记流程', () {
    test('写日记 → 自动加工 → 生成情绪小结', () {
      final cubit = RecordFormCubit();
      cubit.updateJournal('今天开会时被领导当众质疑，我感觉很糟糕，我肯定觉得大家都在看我的笑话');
      expect(cubit.state.canNext, isTrue);

      cubit.process();
      final s = cubit.state;
      expect(s.step, 1);
      expect(s.emotionName, '沮丧'); // 关键词「糟糕」
      expect(s.triggerEvent, '今天开会时被领导当众质疑'); // 第一句
      expect(s.distortions, contains('读心术')); // 「肯定觉得」
      expect(s.tags, contains('工作'));
      expect(s.suggestion, isNotEmpty);
      expect(s.reframeHint, isNotEmpty);
      expect(s.thought, cubit.state.journalText); // 原始文本作为自动想法底稿

      cubit.close();
    });

    test('日记为空时不能进入加工', () {
      final cubit = RecordFormCubit();
      expect(cubit.state.canNext, isFalse);
      cubit.process(); // 空文本也允许加工，但兜底为平静
      expect(cubit.state.step, 1);
      expect(cubit.state.emotionName, '平静');
      cubit.close();
    });

    test('用户自选情绪优先于自动识别', () {
      final cubit = RecordFormCubit();
      cubit.updateJournal('今天没什么特别的事');
      cubit.updateSelectedEmotion('平静');
      cubit.process();
      expect(cubit.state.emotionName, '平静');
      cubit.close();
    });

    test('加工结果可退回重写（保留日记原文）', () {
      final cubit = RecordFormCubit();
      cubit.updateJournal('今天很累');
      cubit.process();
      expect(cubit.state.step, 1);

      cubit.back();
      expect(cubit.state.step, 0);
      expect(cubit.state.journalText, '今天很累');
      cubit.close();
    });

    test('修改自动想法时重新解析认知扭曲', () {
      final cubit = RecordFormCubit();
      cubit.updateJournal('今天很累');
      cubit.process();
      cubit.updateThought('我肯定觉得他不喜欢我');
      expect(cubit.state.distortions, contains('读心术'));
      expect(cubit.state.reframeHint, isNotEmpty);
      cubit.close();
    });

    test('确认保存：原始文本与结构化数据一并入库', () async {
      final store = RecordStore();
      final cubit = RecordFormCubit(store: store);
      cubit.updateJournal('孩子生病了，我很担心，感觉都是我的错');
      cubit.updateSelectedEmotion('焦虑');
      cubit.process();
      final record = await cubit.save();

      expect(record.originalText, '孩子生病了，我很担心，感觉都是我的错');
      expect(record.activatingEvent, '孩子生病了');
      expect(record.emotions.single.name, '焦虑');
      expect(record.tags, containsAll(['家庭', '健康']));
      expect(record.disputation, isNotNull); // 换个角度想入库为 D 阶段
      expect(cubit.state.savedRecord, same(record));

      final loaded = await store.load();
      expect(loaded, hasLength(1));
      expect(loaded.single.originalText, record.originalText);
      expect(loaded.single.tags, ['家庭', '健康']);

      cubit.close();
    });

    test('E 阶段重新评估后保存，重构指标可计算', () async {
      final cubit = RecordFormCubit();
      cubit.updateJournal('今天开会方案被否决，我感觉很沮丧');
      cubit.process();
      cubit.toggleEmotionAfter('平静');
      cubit.updateEmotionAfterIntensity('平静', 40);
      cubit.updateBeliefStrengthAfter(30);
      final record = await cubit.save();

      expect(record.emotionsAfter.single.name, '平静');
      expect(record.emotionsAfter.single.intensity, 40);
      expect(record.beliefStrengthAfter, 30);
      expect(record.emotionChange, lessThan(0));

      cubit.close();
    });
  });
}
