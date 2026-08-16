/// 内置量表定义。
///
/// - PHQ-9（抑郁筛查）、GAD-7（焦虑筛查）：公开标准量表，结果仅供参考
/// - PSS-4、Mini-IPIP、CBI：数据来自 `data/profile`（公共领域，无版权争议）
///   — profile 档案：`data/profile/scales/{pss-4,mini-ipip,cbi}.md`
/// - 页面展示免责声明；不构成医学诊断
library;

import '../models/assessment.dart';

const List<AssessmentOption> kFrequencyOptions = [
  AssessmentOption(score: 0, label: '完全没有'),
  AssessmentOption(score: 1, label: '有几天'),
  AssessmentOption(score: 2, label: '一半以上天数'),
  AssessmentOption(score: 3, label: '几乎每天'),
];

const String kDisclaimer =
    '本测试结果仅供参考，不构成医学诊断。如有困扰，请及时联系专业心理机构或医生；'
    '若出现伤害自己或他人的念头，请立即拨打求助热线。';

/// 过去的 2 周里，您有多经常被以下问题困扰？
const Assessment kPhq9 = Assessment(
  id: 'phq9',
  title: 'PHQ-9 抑郁筛查',
  description: '评估过去两周的抑郁症状严重程度（9 题，约 2 分钟）',
  instruction: '过去的 2 周里，您有多经常被以下问题困扰？',
  disclaimer: kDisclaimer,
  bands: kPhq9Bands,
  questions: [
    AssessmentQuestion(
      text: '做事时提不起劲或没有兴趣',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '感到心情低落、沮丧或绝望',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '入睡困难、睡不安稳或睡眠过多',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '感觉疲倦或没有活力',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '食欲不振或吃太多',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '觉得自己很糟，或觉得自己很失败，或让自己或家人失望',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '对事物专注有困难，例如看报纸或看电视时',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '行动或说话速度缓慢到别人已经察觉？或正好相反——变得比平日更烦躁或坐立不安',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '有不如死掉或用某种方式伤害自己的念头',
      options: kFrequencyOptions,
      isCrisisItem: true,
    ),
  ],
);

/// PHQ-9 分级：0-4 无/轻微，5-9 轻度，10-14 中度，15-19 中重度，20-27 重度。
const List<LevelBand> kPhq9Bands = [
  LevelBand(min: 0, max: 4, name: '无明显抑郁症状'),
  LevelBand(min: 5, max: 9, name: '轻度抑郁症状'),
  LevelBand(min: 10, max: 14, name: '中度抑郁症状'),
  LevelBand(min: 15, max: 19, name: '中重度抑郁症状'),
  LevelBand(min: 20, max: 27, name: '重度抑郁症状'),
];

/// 过去的 2 周里，您有多经常被以下问题困扰？
const Assessment kGad7 = Assessment(
  id: 'gad7',
  title: 'GAD-7 焦虑筛查',
  description: '评估过去两周的广泛性焦虑症状严重程度（7 题，约 1 分钟）',
  instruction: '过去的 2 周里，您有多经常被以下问题困扰？',
  disclaimer: kDisclaimer,
  bands: kGad7Bands,
  questions: [
    AssessmentQuestion(
      text: '感觉紧张、焦虑或急切',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '不能够停止或控制担忧',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '对各种各样的事情担忧过多',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '很难放松下来',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '由于不安而无法静坐',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '变得容易烦恼或急躁',
      options: kFrequencyOptions,
    ),
    AssessmentQuestion(
      text: '感到似乎将有可怕的事情发生而害怕',
      options: kFrequencyOptions,
    ),
  ],
);

/// GAD-7 分级：0-4 无/轻微，5-9 轻度，10-14 中度，15-21 重度。
const List<LevelBand> kGad7Bands = [
  LevelBand(min: 0, max: 4, name: '无明显焦虑症状'),
  LevelBand(min: 5, max: 9, name: '轻度焦虑症状'),
  LevelBand(min: 10, max: 14, name: '中度焦虑症状'),
  LevelBand(min: 15, max: 21, name: '重度焦虑症状'),
];

// ── PSS-4 感知压力（简版）：data/profile/scales/pss-4.md ────────────────
// 公共领域（Cohen 等公开提供，注明引用即可）。第 2、3 题反向计分。

const List<AssessmentOption> kPss4Options = [
  AssessmentOption(score: 0, label: '从不'),
  AssessmentOption(score: 1, label: '几乎不'),
  AssessmentOption(score: 2, label: '有时'),
  AssessmentOption(score: 3, label: '经常'),
  AssessmentOption(score: 4, label: '非常频繁'),
];

/// PSS-4 显示分级（相对参考，非临床标准）：0-16 分，越高压力感知越强。
const List<LevelBand> kPss4Bands = [
  LevelBand(min: 0, max: 4, name: '压力感知偏低'),
  LevelBand(min: 5, max: 8, name: '压力感知中等'),
  LevelBand(min: 9, max: 16, name: '压力感知偏高'),
];

const Assessment kPss4 = Assessment(
  id: 'pss4',
  title: 'PSS-4 压力感知',
  description: '评估过去一个月的压力感知程度（4 题，约 1 分钟）',
  instruction: '在过去一个月中，您多久会有以下感觉？',
  disclaimer: kDisclaimer,
  bands: kPss4Bands,
  questions: [
    AssessmentQuestion(
      text: '无法控制生活中重要的事情？',
      options: kPss4Options,
    ),
    AssessmentQuestion(
      text: '对自己处理个人问题的能力有信心？',
      options: kPss4Options,
      reversed: true,
    ),
    AssessmentQuestion(
      text: '觉得事情都顺心如意？',
      options: kPss4Options,
      reversed: true,
    ),
    AssessmentQuestion(
      text: '觉得困难堆积如山、无法克服？',
      options: kPss4Options,
    ),
  ],
);

// ── Mini-IPIP 短版大五人格：data/profile/scales/mini-ipip.md ────────────
// 公共领域（IPIP 官方明确标注）。5 点李克特；R 题按 6 − 原始分 转换；
// 各维度 4 题（转换后）相加（4-20 分）。情绪稳定性为产品侧反向解释
// （官方 Neuroticism 高分=不稳定，产品侧高分=稳定）。

const List<AssessmentOption> kLikert5Options = [
  AssessmentOption(score: 1, label: '非常不准'),
  AssessmentOption(score: 2, label: '不准'),
  AssessmentOption(score: 3, label: '中性（既不准也不对）'),
  AssessmentOption(score: 4, label: '准'),
  AssessmentOption(score: 5, label: '非常准'),
];

const List<AssessmentDimension> kMiniIpipDimensions = [
  AssessmentDimension(id: 'extraversion', name: '外向性'),
  AssessmentDimension(id: 'agreeableness', name: '宜人性'),
  AssessmentDimension(id: 'conscientiousness', name: '尽责性'),
  AssessmentDimension(id: 'stability', name: '情绪稳定性', inverted: true),
  AssessmentDimension(id: 'openness', name: '开放性'),
];

const Assessment kMiniIpip = Assessment(
  id: 'mini-ipip',
  title: 'Mini-IPIP 人格倾向',
  description: '大五人格短版，提供压力倾向基线（20 题，约 4 分钟）',
  instruction: '请评价下列描述与您的符合程度——1=非常不准，2=不准，3=中性，4=准，5=非常准。',
  disclaimer: kDisclaimer,
  dimensions: kMiniIpipDimensions,
  questions: [
    // 外向性（4 题）
    AssessmentQuestion(
      text: '我是聚会中的灵魂人物。',
      options: kLikert5Options,
      dimensionId: 'extraversion',
    ),
    AssessmentQuestion(
      text: '我话不多。',
      options: kLikert5Options,
      dimensionId: 'extraversion',
      reversed: true,
    ),
    AssessmentQuestion(
      text: '在聚会上我会和很多人交谈。',
      options: kLikert5Options,
      dimensionId: 'extraversion',
    ),
    AssessmentQuestion(
      text: '我习惯待在幕后、不引人注目。',
      options: kLikert5Options,
      dimensionId: 'extraversion',
      reversed: true,
    ),
    // 宜人性（4 题）
    AssessmentQuestion(
      text: '我能体会他人的感受。',
      options: kLikert5Options,
      dimensionId: 'agreeableness',
    ),
    AssessmentQuestion(
      text: '我对别人的问题不感兴趣。',
      options: kLikert5Options,
      dimensionId: 'agreeableness',
      reversed: true,
    ),
    AssessmentQuestion(
      text: '我能感受到他人的情绪。',
      options: kLikert5Options,
      dimensionId: 'agreeableness',
    ),
    AssessmentQuestion(
      text: '我对别人其实不感兴趣。',
      options: kLikert5Options,
      dimensionId: 'agreeableness',
      reversed: true,
    ),
    // 尽责性（4 题）
    AssessmentQuestion(
      text: '我会立即完成手头的杂务。',
      options: kLikert5Options,
      dimensionId: 'conscientiousness',
    ),
    AssessmentQuestion(
      text: '我经常忘记把东西放回原位。',
      options: kLikert5Options,
      dimensionId: 'conscientiousness',
      reversed: true,
    ),
    AssessmentQuestion(
      text: '我喜欢秩序（井井有条）。',
      options: kLikert5Options,
      dimensionId: 'conscientiousness',
    ),
    AssessmentQuestion(
      text: '我常把事情弄得一团糟。',
      options: kLikert5Options,
      dimensionId: 'conscientiousness',
      reversed: true,
    ),
    // 情绪稳定性（4 题，产品侧反向解释：高分=稳定）
    AssessmentQuestion(
      text: '我情绪波动频繁。',
      options: kLikert5Options,
      dimensionId: 'stability',
    ),
    AssessmentQuestion(
      text: '我大部分时间都很放松。',
      options: kLikert5Options,
      dimensionId: 'stability',
      reversed: true,
    ),
    AssessmentQuestion(
      text: '我很容易心烦意乱。',
      options: kLikert5Options,
      dimensionId: 'stability',
    ),
    AssessmentQuestion(
      text: '我很少感到忧郁。',
      options: kLikert5Options,
      dimensionId: 'stability',
      reversed: true,
    ),
    // 开放性（4 题）
    AssessmentQuestion(
      text: '我有丰富的想象力。',
      options: kLikert5Options,
      dimensionId: 'openness',
    ),
    AssessmentQuestion(
      text: '我对抽象的想法不感兴趣。',
      options: kLikert5Options,
      dimensionId: 'openness',
      reversed: true,
    ),
    AssessmentQuestion(
      text: '我难以理解抽象的概念。',
      options: kLikert5Options,
      dimensionId: 'openness',
      reversed: true,
    ),
    AssessmentQuestion(
      text: '我的想象力不好。',
      options: kLikert5Options,
      dimensionId: 'openness',
      reversed: true,
    ),
  ],
);

// ── CBI 哥本哈根倦怠量表：data/profile/scales/cbi.md ───────────────────
// 丹麦 NFA 公开分发、免费商用（MBI 免费替代）。程度/频率类选项均对应
// 100/75/50/25/0；工作倦怠第 7 题反向（100 − 原始分）；各维度得分 =
// 该维度所有题目得分的平均值（0-100）；判读 <50 低度 / 50-74 中度 /
// 75-99 高度 / 100 严重。

const List<AssessmentOption> kDegreeOptions = [
  AssessmentOption(score: 100, label: '极高程度'),
  AssessmentOption(score: 75, label: '高程度'),
  AssessmentOption(score: 50, label: '中等'),
  AssessmentOption(score: 25, label: '低程度'),
  AssessmentOption(score: 0, label: '极低程度'),
];

const List<AssessmentOption> kCbiFrequencyOptions = [
  AssessmentOption(score: 100, label: '总是'),
  AssessmentOption(score: 75, label: '经常'),
  AssessmentOption(score: 50, label: '有时'),
  AssessmentOption(score: 25, label: '很少'),
  AssessmentOption(score: 0, label: '从不或几乎从不'),
];

const List<LevelBand> kCbiBands = [
  LevelBand(min: 0, max: 49, name: '低度'),
  LevelBand(min: 50, max: 74, name: '中度'),
  LevelBand(min: 75, max: 99, name: '高度'),
  LevelBand(min: 100, max: 100, name: '严重'),
];

const List<AssessmentDimension> kCbiDimensions = [
  AssessmentDimension(id: 'personal', name: '个人倦怠', scoring: 'mean'),
  AssessmentDimension(id: 'work', name: '工作倦怠', scoring: 'mean'),
  AssessmentDimension(
      id: 'client', name: '服务对象相关倦怠', scoring: 'mean'),
];

const Assessment kCbi = Assessment(
  id: 'cbi',
  title: 'CBI 职业倦怠',
  description: '哥本哈根倦怠量表——职业倦怠筛查（19 题，约 5 分钟）',
  instruction: '请根据您的实际情况选择最符合的选项。',
  disclaimer: kDisclaimer,
  dimensions: kCbiDimensions,
  dimensionBands: kCbiBands,
  questions: [
    // 个人倦怠（6 题，频率类）
    AssessmentQuestion(
      text: '您多久会感到疲倦？',
      options: kCbiFrequencyOptions,
      dimensionId: 'personal',
    ),
    AssessmentQuestion(
      text: '您多久会感到身体疲惫不堪？',
      options: kCbiFrequencyOptions,
      dimensionId: 'personal',
    ),
    AssessmentQuestion(
      text: '您多久会感到情绪耗竭（心力交瘁）？',
      options: kCbiFrequencyOptions,
      dimensionId: 'personal',
    ),
    AssessmentQuestion(
      text: '您多久会想"我再也撑不下去了"？',
      options: kCbiFrequencyOptions,
      dimensionId: 'personal',
    ),
    AssessmentQuestion(
      text: '您多久会感到精疲力竭？',
      options: kCbiFrequencyOptions,
      dimensionId: 'personal',
    ),
    AssessmentQuestion(
      text: '您多久会感到身体虚弱、容易生病？',
      options: kCbiFrequencyOptions,
      dimensionId: 'personal',
    ),
    // 工作倦怠（7 题：1-3 程度类，4-7 频率类，第 7 题反向）
    AssessmentQuestion(
      text: '工作是否让您感到情绪耗竭？',
      options: kDegreeOptions,
      dimensionId: 'work',
    ),
    AssessmentQuestion(
      text: '您是否因工作而感到倦怠（燃尽）？',
      options: kDegreeOptions,
      dimensionId: 'work',
    ),
    AssessmentQuestion(
      text: '工作是否让您感到挫败？',
      options: kDegreeOptions,
      dimensionId: 'work',
    ),
    AssessmentQuestion(
      text: '一天工作结束后，您是否感到精疲力竭？',
      options: kCbiFrequencyOptions,
      dimensionId: 'work',
    ),
    AssessmentQuestion(
      text: '早上想到又要上班，您是否感到疲惫不堪？',
      options: kCbiFrequencyOptions,
      dimensionId: 'work',
    ),
    AssessmentQuestion(
      text: '您是否觉得每个工作小时都很累人？',
      options: kCbiFrequencyOptions,
      dimensionId: 'work',
    ),
    AssessmentQuestion(
      text: '闲暇时您是否有足够的精力陪伴家人和朋友？',
      options: kCbiFrequencyOptions,
      dimensionId: 'work',
      reversed: true,
    ),
    // 服务对象相关倦怠（6 题，可跳过；1-4 程度类，5-6 频率类）
    AssessmentQuestion(
      text: '您是否觉得与服务对象打交道很困难？',
      options: kDegreeOptions,
      dimensionId: 'client',
    ),
    AssessmentQuestion(
      text: '您是否觉得服务对象让您感到挫败？',
      options: kDegreeOptions,
      dimensionId: 'client',
    ),
    AssessmentQuestion(
      text: '与服务对象打交道是否消耗您的精力？',
      options: kDegreeOptions,
      dimensionId: 'client',
    ),
    AssessmentQuestion(
      text: '与服务对象相处时，您是否觉得付出多于回报？',
      options: kDegreeOptions,
      dimensionId: 'client',
    ),
    AssessmentQuestion(
      text: '您是否厌倦了与服务对象打交道？',
      options: kCbiFrequencyOptions,
      dimensionId: 'client',
    ),
    AssessmentQuestion(
      text: '您是否有时会想自己还能与服务对象共事多久？',
      options: kCbiFrequencyOptions,
      dimensionId: 'client',
    ),
  ],
);

/// 全部内置量表（PHQ-9 / GAD-7 / PSS-4 / Mini-IPIP / CBI）。
const List<Assessment> kAssessments = [
  kPhq9,
  kGad7,
  kPss4,
  kMiniIpip,
  kCbi,
];

/// 按 id 取量表。
Assessment? assessmentById(String id) {
  for (final a in kAssessments) {
    if (a.id == id) return a;
  }
  return null;
}

/// 按总分取分级名称（无分级定义时返回参考文案）。
String levelNameFor(Assessment assessment, int total) {
  for (final band in assessment.bands) {
    if (band.contains(total)) return band.name;
  }
  return assessment.bands.isEmpty ? '参考结果' : '未知';
}
