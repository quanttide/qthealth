import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'record/records_cubit.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  // Path URL 策略：浏览器地址栏不出现 #（/record 而非 /#/record）。
  usePathUrlStrategy();
  runApp(const QtcloudHealthApp());
}

class QtcloudHealthApp extends StatelessWidget {
  const QtcloudHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RecordsCubit()..load()),
      ],
      child: MaterialApp.router(
        title: '量潮健康',
        theme: buildTheme(),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
