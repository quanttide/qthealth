/// 应用主题：柔和健康色（Material 3）。
library;

import 'package:flutter/material.dart';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3E8E7E), // 沉稳的医疗青绿
    brightness: Brightness.light,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Color(0x14000000)),
      ),
    ),
  );
}
