import 'package:flutter_test/flutter_test.dart';
import 'package:studio/blocs/records_cubit.dart';
import 'package:studio/blocs/records_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RecordsCubit', () {
    test('load 空缓存 -> RecordsLoaded([])', () async {
      final cubit = RecordsCubit();
      await cubit.load();
      expect(cubit.state, isA<RecordsLoaded>());
      expect((cubit.state as RecordsLoaded).records, isEmpty);
      await cubit.close();
    });

    test('add 后记录出现且倒序', () async {
      final cubit = RecordsCubit();
      await cubit.load();
      final loaded = cubit.state as RecordsLoaded;
      expect(loaded.continuousDays, 0);
      await cubit.close();
    });
  });
}
