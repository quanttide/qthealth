import 'package:flutter_test/flutter_test.dart';
import 'package:studio/services/local_parser.dart';
import 'package:studio/services/safety.dart';

void main() {
  const safety = SafetyService();

  group('SafetyService', () {
    test('命中危机关键词返回 critical/interrupt', () {
      expect(safety.detect('我真的不想活了').isCrisis, isTrue);
      expect(safety.detect('我想跳楼').isCrisis, isTrue);
      expect(safety.detect('他威胁要报复我').isCrisis, isTrue);
    });

    test('正常文本返回 safe/continue', () {
      final result = safety.detect('今天开会方案被否决，有点沮丧');
      expect(result.isCrisis, isFalse);
      expect(result.action, 'continue');
    });
  });

  const parser = LocalParser();

  group('LocalParser.parse', () {
    test('识别读心术并给出辩驳提示', () {
      final parsed = parser.parse('领导肯定觉得我很无能');
      expect(parsed.distortions, contains('读心术'));
      expect(parsed.refutationHint, isNotEmpty);
    });

    test('识别灾难化', () {
      final parsed = parser.parse('这次失败说明我人生完了');
      expect(parsed.distortions, contains('灾难化'));
    });

    test('识别个人化', () {
      final parsed = parser.parse('他不高兴一定是我做错了什么');
      expect(parsed.distortions, contains('个人化'));
    });

    test('无扭曲时给出兜底提示', () {
      final parsed = parser.parse('今天天气不错');
      expect(parsed.distortions, isEmpty);
      expect(parsed.refutationHint, isNotEmpty);
    });
  });

  group('LocalParser.parseJournal（情绪日记自动加工）', () {
    test('一句话日记加工出完整情绪小结', () {
      final parsed = parser.parseJournal(
          '今天开会时被领导当众质疑，我感觉很糟糕，我肯定觉得大家都在看我的笑话');
      expect(parsed.primaryEmotion, '沮丧'); // 关键词「糟糕」
      expect(parsed.intensity, greaterThanOrEqualTo(70)); // 「很」加权
      expect(parsed.triggerEvent, '今天开会时被领导当众质疑'); // 第一句
      expect(parsed.distortions, contains('读心术')); // 「肯定觉得」
      expect(parsed.reframeHint, isNotEmpty);
      expect(parsed.suggestion, isNotEmpty); // 微行动建议
      expect(parsed.tags, contains('工作')); // #工作
    });

    test('用户自选情绪优先于自动识别', () {
      final parsed = parser.parseJournal('今天没什么特别的事', selectedEmotion: '平静');
      expect(parsed.primaryEmotion, '平静');
    });

    test('无情绪关键词时兜底为平静', () {
      final parsed = parser.parseJournal('今天天气不错');
      expect(parsed.primaryEmotion, '平静');
      expect(parsed.intensity, lessThanOrEqualTo(30));
    });

    test('强度修饰词调整强度', () {
      final low = parser.parseJournal('今天有点难过');
      final high = parser.parseJournal('今天极其愤怒，非常生气');
      expect(low.intensity, lessThan(high.intensity));
      expect(high.intensity, greaterThanOrEqualTo(100)); // 70 + 15*2 + 10 = 110 → 100
    });

    test('触发事件取第一句', () {
      final parsed = parser.parseJournal('今天很累。回家倒头就睡');
      expect(parsed.triggerEvent, '今天很累');
    });

    test('标签按规则归类，无命中归其他', () {
      expect(parser.parseJournal('跟朋友吵架了').tags, contains('人际'));
      expect(parser.parseJournal('孩子生病了').tags, containsAll(['家庭', '健康']));
      expect(parser.parseJournal('今天没什么特别的事').tags, ['其他']);
    });

    test('解析结果可直接映射为 ABCDE 记录字段', () {
      final parsed = parser.parseJournal('我不该跟家人生气，我肯定觉得自己是个很差劲的人');
      expect(parsed.primaryEmotion, '愤怒'); // 关键词「生气」
      expect(parsed.tags, contains('家庭')); // 「家人」
      expect(parsed.distortions, contains('读心术')); // 「肯定觉得」
    });
  });
}
