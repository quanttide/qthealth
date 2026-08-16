/// 安全护栏：危机关键词检测（ADD 第一道防线的客户端本地版）。
///
/// 客户端先行阶段无服务端，危机检测在本地完成；接入后端后由服务端
/// SafetyMiddleware 兜底，客户端检测作为第一道即时防线。
library;

import '../constants.dart';
import '../models/parsing_result.dart';

class SafetyService {
  const SafetyService();

  /// 检测文本是否含危机信号。命中即中断（interrupt），弹危机干预页。
  SafetyResult detect(String text) {
    for (final keyword in kCrisisKeywords) {
      if (text.contains(keyword)) {
        return const SafetyResult(level: 'critical', action: 'interrupt');
      }
    }
    return const SafetyResult(level: 'safe', action: 'continue');
  }
}
