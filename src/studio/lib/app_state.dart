/// 应用状态（参考 qtcloud-secret 的 AppState 模式——状态驱动页面）。
library;

import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  String _providerStatus = '未连接';
  bool _checking = false;

  String get providerStatus => _providerStatus;
  bool get checking => _checking;

  /// 检查 provider 状态（占位：真实接入 qthealth-provider API）
  Future<void> check() async {
    _checking = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _checking = false;
    _providerStatus = '待接入 provider API（骨架）';
    notifyListeners();
  }
}
