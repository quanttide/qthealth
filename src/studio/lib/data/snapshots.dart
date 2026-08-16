/// 单题快照：每天只问 1 题（10 秒完成），代替完整量表。
///
/// 题集按日期轮换：精力 → 压力 → 睡眠 → 情绪 → 循环。
/// 选项为按钮点选（数字 1-5 或表情），前端无问卷感。
library;

/// 快照题：一天一问，按日期轮换。
class SnapshotQuestion {
  const SnapshotQuestion({
    required this.id,
    required this.prompt,
    required this.labels,
    required this.values,
  });

  final String id;

  /// 题目文案（如「今天精力怎么样？」）。
  final String prompt;

  /// 按钮文案：数字（1-5）或表情（😞 😐 🙂）。
  final List<String> labels;

  /// 选项对应得分（与 labels 等长对齐）。
  final List<int> values;
}

/// 单日快照记录。
class DailySnapshot {
  const DailySnapshot({
    required this.date,
    required this.questionId,
    required this.value,
  });

  /// 记录日期（yyyy-MM-dd）。
  final String date;
  final String questionId;
  final int value;

  Map<String, dynamic> toJson() => {
        'date': date,
        'questionId': questionId,
        'value': value,
      };

  factory DailySnapshot.fromJson(Map<String, dynamic> json) => DailySnapshot(
        date: json['date'] as String? ?? '',
        questionId: json['questionId'] as String? ?? '',
        value: json['value'] as int? ?? 0,
      );
}

/// 快照题集：4 个核心维度，按日期轮换（每天只问 1 题）。
const List<SnapshotQuestion> kSnapshotQuestions = [
  SnapshotQuestion(
    id: 'energy',
    prompt: '今天精力怎么样？',
    labels: ['1', '2', '3', '4', '5'],
    values: [1, 2, 3, 4, 5],
  ),
  SnapshotQuestion(
    id: 'stress',
    prompt: '今天压力大吗？',
    labels: ['1', '2', '3', '4', '5'],
    values: [1, 2, 3, 4, 5],
  ),
  SnapshotQuestion(
    id: 'sleep',
    prompt: '昨晚睡得好吗？',
    labels: ['1', '2', '3', '4', '5'],
    values: [1, 2, 3, 4, 5],
  ),
  SnapshotQuestion(
    id: 'mood',
    prompt: '今天情绪偏向哪边？',
    labels: ['😞', '😐', '🙂'],
    values: [1, 2, 3],
  ),
];

/// 按日期取今日题目（自 2026-01-01 起按天数轮换）。
SnapshotQuestion questionForDate(DateTime date) {
  final days = date.difference(DateTime(2026, 1, 1)).inDays;
  return kSnapshotQuestions[days % kSnapshotQuestions.length];
}

/// 按 id 取题（历史记录展示用）；未知 id 返回 null。
SnapshotQuestion? questionById(String id) {
  for (final q in kSnapshotQuestions) {
    if (q.id == id) return q;
  }
  return null;
}

/// 格式化为 yyyy-MM-dd。
String fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
