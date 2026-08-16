# CHANGELOG

所有显著变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)（发布规范见 qtcloud-devops `docs/tutorial/source/conventions/changelog.md`）。

版本遵循语义化版本规范：0.0.x（探索期）→ 0.x.y（验证期）→ x.y.z（正式期）

---

## [Unreleased]

（待发布内容将在此累积）

---

## [0.1.1-alpha.2] - 2026-08-16

### Changed

- 导航术语回归「记录」（此前被改名「日志」）；量表作为**记录的一种类型**，从「记录」页进入（情绪日记 + 量表两种类型入口），不单独设导航入口
- 「记录」页改为记录类型入口页（/record），情绪日记表单移至 /record/journal（push 进入，返回箭头回记录页）；量表列表页标题改为「量表」
- 状态页移除独立的心理测试图标（量表入口归入「记录」页）

### Fixed

- 日志页打开即崩溃（ProviderNotFoundException）：`context.select` 误用 `RecordFormState` 作为类型参数（BlocProvider 提供的是 Cubit）→ 改为 `RecordFormCubit`
- 保存完成页「返回首页」`go('/')` 无对应路由 → 改为 `go('/status')`
- 危机干预页按钮 `go('/')` 失效 → 「继续记录」返回触发页（无来源回状态页）、「联系专业帮助」弹热线对话框
- 状态页写日记 FAB 直达情绪日记表单（push），与记录页入口行为一致
---

## [0.1.1-alpha.1] - 2026-08-16

### Fixed

- 前台名称统一为「量潮健康」：应用标题（main.dart）、manifest.json、apple-mobile-web-app-title 与页面描述（此前为「量潮健康云」/ "studio"）
