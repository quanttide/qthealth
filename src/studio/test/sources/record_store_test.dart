import 'package:flutter_test/flutter_test.dart';
import 'package:studio/models/abc_record.dart';
import 'package:studio/sources/record_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const store = RecordStore();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('空缓存返回空列表', () async {
    expect(await store.load(), isEmpty);
  });

  test('add 后 load 返回记录（按日期倒序）', () async {
    final older = ABCRecord(
      id: 'old',
      date: DateTime(2026, 8, 1),
      activatingEvent: '旧事件',
      emotions: [const Emotion(name: '沮丧', intensity: 70)],
    );
    final newer = ABCRecord(
      id: 'new',
      date: DateTime(2026, 8, 16),
      activatingEvent: '新事件',
      emotions: [const Emotion(name: '焦虑', intensity: 60)],
    );
    await store.add(older);
    await store.add(newer);

    final records = await store.load();
    expect(records.length, 2);
    expect(records.first.id, 'new');
    expect(records.first.activatingEvent, '新事件');
  });

  test('delete 后记录移除', () async {
    await store.add(ABCRecord(
      id: 'a',
      date: DateTime.now(),
      activatingEvent: '事件',
    ));
    await store.add(ABCRecord(
      id: 'b',
      date: DateTime.now(),
      activatingEvent: '事件2',
    ));
    await store.delete('a');
    final records = await store.load();
    expect(records.length, 1);
    expect(records.single.id, 'b');
  });

  test('缓存损坏时降级为空而非崩溃', () async {
    SharedPreferences.setMockInitialValues({'abc_records_v1': '{not-json'});
    expect(await store.load(), isEmpty);
  });

  test('clear 清空全部', () async {
    await store.add(ABCRecord(
      id: 'a',
      date: DateTime.now(),
      activatingEvent: '事件',
    ));
    await store.clear();
    expect(await store.load(), isEmpty);
  });
}
