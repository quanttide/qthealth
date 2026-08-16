/// 危机干预页：命中危机关键词时全屏展示（对应 IXD 危机干预页）。
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';

class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key, this.message = ''});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF7B1E1E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 72, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  '我们注意到您可能正在经历困难时期',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  '您的安全对我们很重要。请记住，您并不孤单，有人可以帮助您度过这个困难时刻。',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '检测到相关内容：「$message」',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                  ),
                ],
                const SizedBox(height: 24),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final hotline in kHotlines)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.phone, size: 18, color: Color(0xFF7B1E1E)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(hotline)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      onPressed: () => context.go('/'),
                      child: const Text('返回首页'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF7B1E1E),
                      ),
                      onPressed: () => context.go('/'),
                      child: const Text('联系专业帮助'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
