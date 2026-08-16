/// ⚠️ 已下线（2026-08-17）：情绪日记功能当前不在路由表中注册、无任何入口，
/// 本文件完整保留以便未来重新启用（届时在 lib/router.dart 注册
/// /record/journal 并恢复「记录」页入口即可，无需改动本文件）。
///
/// 情绪日记页：自由书写 → 本地规则自动加工 → 📊 情绪小结卡片（可修正）→ 保存。
///
/// 对应 context「AI 情绪加工引擎」（data/context/ai-emotion-processing-engine.md）：
/// 用户随便写一段话，系统加工出结构化情绪小结；模式 A（写完自动加工）为
/// 默认，用户可修改或确认（人机协同修正闭环）。客户端先行阶段由本地规则
/// 引擎实现，接入服务端 AI 后由 go-openai 管道替代。文本输入经过本地
/// 危机检测，命中即跳转危机干预页。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'record_form_cubit.dart';
import 'record_form_state.dart';
import '../constants.dart';
import '../models/abc_record.dart';
import '../services/safety.dart';

class RecordFormScreen extends StatelessWidget {
  const RecordFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecordFormCubit(),
      child: const _FormScaffold(),
    );
  }
}

class _FormScaffold extends StatelessWidget {
  const _FormScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordFormCubit, RecordFormState>(
      builder: (context, state) {
        // 保存成功后展示完成页
        final saved = state.savedRecord;
        if (saved != null) {
          return _CompletedView(record: saved);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('情绪日记（${state.step + 1}/2）'),
            // 表单从「记录」页 push 进入，返回箭头 pop 回记录页
            leading: BackButton(onPressed: () => context.pop()),
          ),
          body: SafeArea(
            child: Column(
              children: [
                LinearProgressIndicator(value: (state.step + 1) / 2),
                Expanded(
                  child: switch (state.step) {
                    0 => const _JournalView(),
                    _ => const _ProcessedView(),
                  },
                ),
                _StepNavBar(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 底部操作：写日记 → 自动梳理；加工结果 → 重新写 / 确认保存。
class _StepNavBar extends StatelessWidget {
  const _StepNavBar({required this.state});

  final RecordFormState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecordFormCubit>();
    if (state.step == 0) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Spacer(),
            FilledButton.icon(
              onPressed: state.canNext ? cubit.process : null,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('自动梳理'),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: cubit.back,
            child: const Text('重新写'),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: cubit.save,
            icon: const Icon(Icons.check),
            label: const Text('确认保存'),
          ),
        ],
      ),
    );
  }
}

/// 步骤 1：写日记（自由文本，一句话到一段话）。
class _JournalView extends StatelessWidget {
  const _JournalView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecordFormCubit>();
    // 注意：select 的类型参数必须是 Provider 提供的 Cubit（BlocProvider 提供
    // 的是 Cubit 而非 State，写 RecordFormState 会 ProviderNotFoundException）
    final selected = context.select((RecordFormCubit c) => c.state.selectedEmotion);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('今天发生了什么？', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '随便写，一句话或一段话都可以。写完后自动帮你梳理情绪、想法和行动建议。',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '今天开会时被领导当众质疑，我感觉很糟糕，我肯定觉得大家都在看我的笑话…',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            cubit.updateJournal(value);
            _guardCrisis(context, value);
          },
        ),
        const SizedBox(height: 16),
        Text('你感觉主要是哪种情绪？（可选，选择后识别更准）',
            style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final name in kEmotionOptions)
              FilterChip(
                label: Text(name),
                selected: selected == name,
                onSelected: (on) => cubit.updateSelectedEmotion(on ? name : null),
              ),
          ],
        ),
      ],
    );
  }
}

/// 步骤 2：加工结果 —— 📊 情绪小结反馈卡片（可编辑，人机协同修正闭环）。
///
/// 对应 context 加工流程步骤 3：不直接甩 JSON，转译成温暖的、可读的反馈卡片。
class _ProcessedView extends StatelessWidget {
  const _ProcessedView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecordFormCubit>();
    // select 的 T 必须是 Cubit（见 _JournalView 注释）
    final s = context.select((RecordFormCubit c) => c.state);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('📊 情绪小结', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('这是根据你的日记自动梳理的结果，可以修改后保存。',
            style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        Card(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EmotionRow(state: s),
                const SizedBox(height: 8),
                Slider(
                  value: s.emotionIntensity.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${s.emotionIntensity}',
                  onChanged: (v) => cubit.updateEmotionIntensity(v.round()),
                ),
                const Divider(height: 24),
                _EditableField(
                  label: '触发事件',
                  hint: '发生了什么？',
                  initialValue: s.triggerEvent,
                  onChanged: cubit.updateTriggerEvent,
                ),
                _EditableField(
                  label: '你当时的想法可能是',
                  hint: '自动想法',
                  initialValue: s.thought,
                  onChanged: cubit.updateThought,
                ),
                if (s.distortions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Wrap(
                      spacing: 4,
                      children: s.distortions
                          .map((d) => Chip(
                                label: Text(d, style: theme.textTheme.labelSmall),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ),
                _EditableField(
                  label: '换个角度想',
                  hint: '有没有其他可能的解释？',
                  initialValue: s.reframeHint,
                  onChanged: cubit.updateReframeHint,
                ),
                _EditableField(
                  label: '今天可以试试',
                  hint: '一件具体可执行的微行动',
                  initialValue: s.suggestion,
                  onChanged: cubit.updateSuggestion,
                ),
                const SizedBox(height: 4),
                Text('标签', style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final rule in kTagRules)
                      FilterChip(
                        label: Text(rule.name),
                        selected: s.tags.contains(rule.name),
                        onSelected: (_) => cubit.toggleTag(rule.name),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text('重新评估（可选）'),
          subtitle: const Text('换个角度后，再记录一次你的感受'),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EditableField(
                  label: '新想法',
                  hint: '经过刚才的思考，我现在觉得…',
                  initialValue: s.newThought,
                  onChanged: cubit.updateNewThought,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in kEmotionOptions)
                      FilterChip(
                        label: Text(name),
                        selected: s.emotionsAfter.any((e) => e.name == name),
                        onSelected: (_) => cubit.toggleEmotionAfter(name),
                      ),
                  ],
                ),
                for (final emotion in s.emotionsAfter)
                  Row(
                    children: [
                      SizedBox(
                        width: 56,
                        child:
                            Text(emotion.name, style: theme.textTheme.bodyMedium),
                      ),
                      Expanded(
                        child: Slider(
                          value: emotion.intensity.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: '${emotion.intensity}',
                          onChanged: (v) => cubit.updateEmotionAfterIntensity(
                              emotion.name, v.round()),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text('${emotion.intensity}',
                            style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    const Expanded(child: Text('对自动想法的相信程度')),
                    Expanded(
                      child: Slider(
                        value: (s.beliefStrengthAfter ?? 50).toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: '${s.beliefStrengthAfter ?? 50}',
                        onChanged: (v) => cubit.updateBeliefStrengthAfter(v.round()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '本分析由本地规则自动生成，仅供自我觉察参考，不构成心理或医疗建议。数据仅保存在本设备。',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// 主要情绪选择 + 强度展示。
class _EmotionRow extends StatelessWidget {
  const _EmotionRow({required this.state});

  final RecordFormState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecordFormCubit>();
    final theme = Theme.of(context);
    return Row(
      children: [
        const Icon(Icons.mood),
        const SizedBox(width: 8),
        Text('你此刻的主要情绪是', style: theme.textTheme.bodyMedium),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: state.emotionName,
          items: [
            for (final name in kEmotionOptions)
              DropdownMenuItem(value: name, child: Text(name)),
          ],
          onChanged: (v) {
            if (v != null) cubit.updateEmotionName(v);
          },
        ),
        const Spacer(),
        Text('${state.emotionIntensity}/100', style: theme.textTheme.titleMedium),
      ],
    );
  }
}

/// 可编辑字段（情绪小结卡片内的结构化条目）。
class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

/// 保存完成页：重构效果对比（对应 IXD 完成页）。
class _CompletedView extends StatelessWidget {
  const _CompletedView({required this.record});

  final ABCRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final succeeded = record.reconstructionSucceeded;
    final hasAfter = record.emotionsAfter.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('日记已保存')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                succeeded ? Icons.emoji_events : Icons.check_circle,
                size: 64,
                color: succeeded ? Colors.amber : theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                succeeded ? '认知重构成功' : '已保存到本地',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '数据仅保存在本设备，不会上传到服务端。',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              if (hasAfter)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _CompareRow(
                          label: '情绪强度',
                          before: record.emotionIntensityAvg,
                          after: record.emotionAfterAvg,
                        ),
                        const Divider(height: 24),
                        _CompareRow(
                          label: '相信程度',
                          before: record.beliefs.isEmpty
                              ? 0
                              : record.beliefs
                                      .map((b) => b.beliefStrength)
                                      .reduce((a, b) => a + b) ~/
                                  record.beliefs.length,
                          after: record.beliefStrengthAfter ?? 0,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/status'),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final int before;
  final int after;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = after - before;
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: theme.textTheme.bodyMedium)),
        Text('$before → $after', style: theme.textTheme.titleMedium),
        const Spacer(),
        Text(
          change <= 0 ? '↓ ${-change}' : '↑ $change',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: change <= 0 ? Colors.teal : Colors.orange,
          ),
        ),
      ],
    );
  }
}

/// 本地危机检测：命中即跳转危机干预页（不中断当前输入）。
void _guardCrisis(BuildContext context, String text) {
  if (const SafetyService().detect(text).isCrisis) {
    context.push('/crisis', extra: text);
  }
}
