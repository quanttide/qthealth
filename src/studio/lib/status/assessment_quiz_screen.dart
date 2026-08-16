/// ⚠️ 已下线（2026-08-17）：问卷式量表已砍掉，换成「单题快照」（每天一问，
/// 见 lib/snapshot/ 与 lib/data/snapshots.dart）。本文件完整保留以便未来
/// 重新启用（届时在 lib/router.dart 注册 /assessments/:assessmentId，
/// 并在记录页恢复入口即可）。
///
/// 心理测试答题页：逐题作答（点击答案自动跳转下一题）+ 结果视图。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'assessment_cubit.dart';
import 'assessment_state.dart';
import '../data/assessments.dart';
import '../models/assessment.dart';

class AssessmentQuizScreen extends StatelessWidget {
  const AssessmentQuizScreen({super.key, required this.assessmentId});

  final String assessmentId;

  @override
  Widget build(BuildContext context) {
    final assessment = assessmentById(assessmentId);
    if (assessment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('心理测试')),
        body: const Center(child: Text('未找到该测试')),
      );
    }
    return BlocProvider(
      create: (_) => AssessmentCubit()..start(assessment),
      child: const _QuizBody(),
    );
  }
}

class _QuizBody extends StatelessWidget {
  const _QuizBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssessmentCubit, AssessmentState>(
      builder: (context, state) {
        if (state is! AssessmentQuizState) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final quiz = state;
        if (quiz.isFinished) {
          return _ResultView(result: quiz.result!);
        }
        return _QuizView(quiz: quiz);
      },
    );
  }
}

/// 从作答页返回：push 进入则 pop 回记录页，深链直达则回 /record。
void _backToRecord(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/record');
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView({required this.quiz});

  final AssessmentQuizState quiz;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();
    final assessment = quiz.assessment;
    final question = assessment.questions[quiz.currentIndex];
    final selected = quiz.answers[quiz.currentIndex];
    final isLast = quiz.currentIndex == assessment.questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(assessment.title),
        leading: BackButton(onPressed: () => _backToRecord(context)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (quiz.currentIndex + 1) / assessment.questions.length,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Text(
                    '第 ${quiz.currentIndex + 1} / ${assessment.questions.length} 题',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '已答 ${quiz.answeredCount} 题',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    assessment.instruction,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.text,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<int>(
                    groupValue: selected,
                    onChanged: (value) {
                      if (value == null) return;
                      // 点击答案即记录并自动跳转下一题；最后一题自动出结果
                      cubit.answer(value);
                      if (isLast) {
                        cubit.finish();
                      } else {
                        cubit.next();
                      }
                    },
                    child: Column(
                      children: [
                        for (final option in question.options)
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: selected == option.score
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: RadioListTile<int>(
                              value: option.score,
                              title: Text(option.label),
                              selected: selected == option.score,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (quiz.currentIndex > 0)
                    OutlinedButton(
                      onPressed: cubit.previous,
                      child: const Text('上一题'),
                    )
                  else
                    Text(
                      '选择答案后自动进入下一题',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 结果视图：总分、维度得分、分级、解读、免责声明；危机标记时提示热线。
class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severe = const ['重度', '高度', '严重', '偏高']
        .any(result.level.contains);
    final multiDimension = result.dimensionScores.length > 1;
    return Scaffold(
      appBar: AppBar(
        title: Text('${result.assessment.title} · 结果'),
        leading: BackButton(onPressed: () => _backToRecord(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: severe ? const Color(0xFFFFF3E0) : null,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    multiDimension ? result.level : '总分 ${result.total}',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    multiDimension ? '维度结果见下方' : result.level,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.interpretation,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          if (multiDimension)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    for (final dim in result.dimensionScores)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.donut_small),
                        title: Text(dim.name),
                        trailing: Text(
                          dim.level == null
                              ? '${dim.score} 分'
                              : '${dim.score} · ${dim.level}',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (result.crisisFlagged)
            Card(
              color: const Color(0xFFFDECEA),
              child: ListTile(
                leading: const Icon(Icons.warning_amber, color: Colors.red),
                title: const Text('您标记了自杀意念相关条目'),
                subtitle: const Text('请立即联系专业心理机构或拨打求助热线，您并不孤单。'),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                result.assessment.disclaimer,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/record'),
            child: const Text('返回记录页'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () =>
                context.read<AssessmentCubit>().start(result.assessment),
            child: const Text('重新作答'),
          ),
        ],
      ),
    );
  }
}

