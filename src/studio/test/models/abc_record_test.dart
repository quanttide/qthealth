import 'package:flutter_test/flutter_test.dart';
import 'package:studio/models/abc_record.dart';

void main() {
  group('ABCRecord', () {
    test('toJson/fromJson 往返一致', () {
      final record = ABCRecord(
        id: 'r1',
        date: DateTime(2026, 8, 16, 10, 30),
        activatingEvent: '开会方案被否决',
        beliefs: [
          Belief(
            thought: '领导肯定觉得我很无能',
            cognitiveDistortions: ['读心术', '灾难化'],
            beliefStrength: 80,
            refutationHint: '有没有可能别人想法不同？',
          ),
        ],
        emotions: [const Emotion(name: '沮丧', intensity: 80)],
        behaviors: ['工作走神'],
        disputation: '方案需要更多数据支持',
        newThought: '一次否决不代表能力问题',
        emotionsAfter: [const Emotion(name: '平静', intensity: 40)],
        beliefStrengthAfter: 35,
      );

      final restored = ABCRecord.fromJson(record.toJson());
      expect(restored.id, 'r1');
      expect(restored.activatingEvent, '开会方案被否决');
      expect(restored.beliefs.single.cognitiveDistortions, ['读心术', '灾难化']);
      expect(restored.emotions.single.intensity, 80);
      expect(restored.emotionsAfter.single.name, '平静');
      expect(restored.beliefStrengthAfter, 35);
    });

    test('反序列化缺失字段有 fallback', () {
      final record = ABCRecord.fromJson({
        'id': 'r2',
        'date': 'bad-format',
        'activating_event': null,
      });
      expect(record.id, 'r2');
      expect(record.activatingEvent, '');
      expect(record.beliefs, isEmpty);
      expect(record.emotions, isEmpty);
    });

    test('情绪日记字段（originalText/tags/suggestion）往返一致', () {
      final record = ABCRecord(
        id: 'r6',
        date: DateTime(2026, 8, 16, 20, 0),
        activatingEvent: '今天开会时被领导当众质疑',
        beliefs: [
          Belief(
            thought: '今天开会时被领导当众质疑，我感觉很糟糕',
            cognitiveDistortions: ['读心术'],
            refutationHint: '有没有可能别人的想法和你的猜测不同？',
          ),
        ],
        emotions: [const Emotion(name: '沮丧', intensity: 80)],
        disputation: '有没有可能别人的想法和你的猜测不同？',
        originalText: '今天开会时被领导当众质疑，我感觉很糟糕，我肯定觉得大家都在看我的笑话',
        tags: ['工作'],
        suggestion: '做一件 5 分钟就能完成的小事，找回一点掌控感。',
      );

      final restored = ABCRecord.fromJson(record.toJson());
      expect(restored.originalText, record.originalText);
      expect(restored.tags, ['工作']);
      expect(restored.suggestion, record.suggestion);
    });

    test('旧缓存无情绪日记字段时保持可读（fallback）', () {
      final record = ABCRecord.fromJson({
        'id': 'r7',
        'date': '2026-08-01T10:00:00.000',
        'activating_event': '开会方案被否决',
      });
      expect(record.originalText, isNull);
      expect(record.tags, isEmpty);
      expect(record.suggestion, isNull);
    });

    test('重构指标：E 阶段情绪下降超 30% 判定成功', () {
      final record = ABCRecord(
        id: 'r3',
        date: DateTime.now(),
        activatingEvent: 'a',
        emotions: [const Emotion(name: '沮丧', intensity: 80)],
        emotionsAfter: [const Emotion(name: '平静', intensity: 40)],
      );
      expect(record.emotionChange, -40);
      expect(record.reconstructionSucceeded, isTrue);
    });

    test('未做 E 阶段重评不算重构成功', () {
      final record = ABCRecord(
        id: 'r4',
        date: DateTime.now(),
        activatingEvent: 'a',
        emotions: [const Emotion(name: '沮丧', intensity: 80)],
      );
      expect(record.emotionsAfter, isEmpty);
      expect(record.reconstructionSucceeded, isFalse);
      expect(record.emotionAfterAvg, record.emotionIntensityAvg);
    });

    test('allDistortions 跨想法去重', () {
      final record = ABCRecord(
        id: 'r5',
        date: DateTime.now(),
        activatingEvent: 'a',
        beliefs: [
          Belief(thought: 't1', cognitiveDistortions: ['读心术']),
          Belief(thought: 't2', cognitiveDistortions: ['读心术', '灾难化']),
        ],
      );
      expect(record.allDistortions, ['读心术', '灾难化']);
    });
  });
}
