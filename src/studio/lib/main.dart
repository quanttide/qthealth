import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'record/records_cubit.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  // Path URL 策略：浏览器地址栏不出现 #（/record 而非 /#/record）。
  usePathUrlStrategy();
  runApp(const QtcloudHealthApp());
}

class QtcloudHealthApp extends StatelessWidget {
  const QtcloudHealthApp({super.key, this.router});

  /// 测试注入用；为空时使用默认路由。
  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RecordsCubit()..load()),
      ],
      child: MaterialApp.router(
        title: '量潮健康',
        theme: buildTheme(),
        routerConfig: router ?? appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
