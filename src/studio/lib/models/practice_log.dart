/// 练习记录模型（行为层观测数据——冥想/放松/运动）。
///
/// 与 ABC 记录同属观测数据（行为日志），进入身心灵闭环的观测时间线。
library;

class PracticeLog {
  final String type; // 练习类型（冥想/放松/运动）
  final int durationMin; // 时长（分钟）
  final DateTime at; // 时间

  const PracticeLog({
    required this.type,
    required this.durationMin,
    required this.at,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'duration_min': durationMin,
        'at': at.toIso8601String(),
      };

  factory PracticeLog.fromJson(Map<String, dynamic> json) => PracticeLog(
        type: json['type'] as String,
        durationMin: json['duration_min'] as int,
        at: DateTime.parse(json['at'] as String),
      );
}
