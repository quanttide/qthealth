/// ⚠️ 已下线（2026-08-17）：练习页当前不在路由表中注册、无任何入口，
/// 本文件完整保留以便未来重新启用（届时在 lib/router.dart 注册 /practice
/// 并在 AppShell 恢复导航入口即可，无需改动本文件）。
///
/// 练习页——干预层入口（身心灵闭环的"干预"环）。
///
/// 冥想 / 放松 / 正念练习入口；量表结果（焦虑高→冥想、压力高→放松）
/// 可跳转至此。完成练习可记录时长（行为日志——进入观测时间线）。
library;

import 'package:flutter/material.dart';

import '../models/practice_log.dart';
import '../sources/practice_store.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  static const List<({IconData icon, String name, String desc})> _practices = [
    (
      icon: Icons.self_improvement,
      name: '冥想',
      desc: '正念练习——焦虑缓解',
    ),
    (
      icon: Icons.spa_outlined,
      name: '放松练习',
      desc: '压力缓解——呼吸/身体扫描',
    ),
    (
      icon: Icons.directions_run,
      name: '运动/瑜伽',
      desc: '行为激活——抑郁缓解（规划中）',
    ),
  ];

  Future<void> _recordPractice(BuildContext context, String name) async {
    final controller = TextEditingController(text: '10');
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('完成 $name'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '时长（分钟）'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              int.tryParse(controller.text) ?? 10,
            ),
            child: const Text('记录'),
          ),
        ],
      ),
    );
    if (minutes == null || !context.mounted) return;
    await const PracticeStore().add(
      PracticeLog(type: name, durationMin: minutes, at: DateTime.now()),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已记录 $name $minutes 分钟（行为记录）')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('练习')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final p in _practices)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(p.icon, color: Theme.of(context).colorScheme.primary),
                title: Text(p.name),
                subtitle: Text(p.desc),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _recordPractice(context, p.name),
              ),
            ),
        ],
      ),
    );
  }
}
