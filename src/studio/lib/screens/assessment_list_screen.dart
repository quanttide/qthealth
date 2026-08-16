/// 心理测试列表页：内置量表 + 历史结果。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/assessment_cubit.dart';
import '../blocs/assessment_state.dart';
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
          appBar: AppBar(title: const Text('心理测试')),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              for (final assessment in kAssessments)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        switch (assessment.id) {
                          'phq9' => Icons.cloud_outlined,
                          'gad7' => Icons.waves,
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
