import 'package:flutter/material.dart';

import 'app_state.dart';
import 'ui/home_page.dart';

void main() {
  runApp(HealthApp(state: AppState()));
}

/// 量潮健康客户端入口。
///
/// 参考 qtcloud-secret studio 模式：页面由 AppState 状态驱动。
class HealthApp extends StatelessWidget {
  const HealthApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '量潮健康',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
        useMaterial3: true,
      ),
      home: HomePage(state: state),
    );
  }
}
