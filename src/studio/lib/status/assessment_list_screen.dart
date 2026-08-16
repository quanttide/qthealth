/// ⚠️ 已下线（2026-08-17）：量表列表页已移除——具体量表直接列在「记录」页
/// （lib/record/record_screen.dart），点击即作答，不再有中间列表页。
/// 本文件（含历史结果展示逻辑）完整保留，未来如需恢复列表页，在
/// lib/router.dart 注册 /assessments 并调整记录页入口即可。
///
/// 量表列表页（记录的一种类型：测评记录）+ 历史结果。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'assessment_cubit.dart';
import 'assessment_state.dart';
import '../data/assessments.dart';
import '../models/assessment.dart';

class AssessmentListScreen extends StatelessWidget {
  const AssessmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssessmentCubit()..loadHistory(),
      child: const _ListBody(),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssessmentCubit, AssessmentState>(
      builder: (context, state) {
        final history = state is AssessmentListState ? state.history : const <AssessmentResult>[];
        return Scaffold(
          appBar: AppBar(title: const Text('量表')),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              for (final assessment in kAssessments)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        switch (assessment.id) {
                          'pss4' => Icons.speed,
                          'mini-ipip' => Icons.hub_outlined,
                          _ => Icons.local_fire_department_outlined,
                        },
                      ),
                    ),
                    title: Text(assessment.title),
                    subtitle: Text(assessment.description),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      '/assessments/${assessment.id}',
                    ),
                  ),
                ),
              if (history.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text('历史结果', style: Theme.of(context).textTheme.titleMedium),
                ),
                for (final result in history.take(10))
                  ListTile(
                    dense: true,
                    leading: Icon(
                      result.crisisFlagged ? Icons.warning_amber : Icons.task_alt,
                      color: result.crisisFlagged ? Colors.red : null,
                    ),
                    title: Text(
                      result.dimensionScores.length <= 1
                          ? '${result.assessment.title}：${result.total} 分'
                          : '${result.assessment.title}：${result.level}',
                    ),
                    subtitle: Text(
                      '${result.level} · ${_fmtDate(result.takenAt)}',
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
