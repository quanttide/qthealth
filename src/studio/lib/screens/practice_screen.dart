/// 练习页——干预层入口（身心灵闭环的"干预"环）。
///
/// 冥想 / 放松 / 正念练习入口；量表结果（焦虑高→冥想、压力高→放松）
/// 可跳转至此。骨架阶段：入口卡片 + 占位。
library;

import 'package:flutter/material.dart';

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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${p.name}练习（占位——待内容接入）')),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
