# CHANGELOG

所有显著变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)（发布规范见 qtcloud-devops `docs/tutorial/source/conventions/changelog.md`）。

版本遵循语义化版本规范：0.0.x（探索期）→ 0.x.y（验证期）→ x.y.z（正式期）

---

## [Unreleased]

（待发布内容将在此累积）

---

## [0.1.1-alpha.5] - 2026-08-17

### Added

- 单题快照（替代完整量表）：每天展示 4 个核心维度（精力 / 压力 / 睡眠 / 情绪），每题按钮点选（数字 1-5 或表情），10 秒完成；点选先暂存内存，答完一轮点「保存今日快照」**统一写入一次**（本地缓存 `daily_snapshots_v1`），**保存后清空并显示完成态**；记录页展示今日快照 + 最近快照列表

### Removed

- 问卷式量表全部砍掉（PSS-4 / Mini-IPIP / CBI 作答与列表页下线），代码保留（lib/status/assessment_quiz_screen.dart、assessment_list_screen.dart 等），未来可恢复

---

## [0.1.1-alpha.4] - 2026-08-17

### Fixed

- 发布后浏览器仍显示旧版本（"线上没有变化"）：alpha.2 部署时 `main.dart.js` 被长缓存（max-age=1 年），已缓存的浏览器一直运行旧代码。修复：部署流程给 `main.dart.js` 补上 no-cache，并在 `flutter_bootstrap.js` 引用中附加构建哈希查询串（`main.dart.js?v=<hash>`）强制缓存破环——任何缓存状态的浏览器在下次刷新时都会拉取新版本

---

## [0.1.1-alpha.3] - 2026-08-17

### Changed

- URL 改为 Path 策略（`usePathUrlStrategy`），地址栏不再出现 `#`（`/record` 而非 `/#/record`）
- 侧边导航只保留「记录」；情绪日记、状态页、练习全部下线（组件代码保留在 lib/ 下，未来可重新注册路由与入口）
- 「记录」页只保留量表入口（情绪日记卡片移除）
- 量表列表只保留无版权争议的公共领域量表：PSS-4 / Mini-IPIP / CBI（来自 `data/profile`）；PHQ-9 / GAD-7 因版权原因下线

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
