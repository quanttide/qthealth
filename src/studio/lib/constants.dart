/// 全局常量：认知扭曲规则、危机关键词、求助热线。
library;

/// 认知扭曲类型与本地规则（关键词 + 辩驳提示模板）。
class DistortionRule {
  const DistortionRule({
    required this.name,
    required this.keywords,
    required this.refutationHint,
  });

  final String name;
  final List<String> keywords;
  final String refutationHint;
}

/// 本地规则引擎的认知扭曲规则表（对应 ADD「规则引擎」与 PRD 七类扭曲）。
const List<DistortionRule> kDistortionRules = [
  DistortionRule(
    name: '非黑即白',
    keywords: ['要么', '完全不', '彻底', '一无是处', '完美'],
    refutationHint: '事情一定只有两个极端吗？中间地带在哪里？',
  ),
  DistortionRule(
    name: '灾难化',
    keywords: ['完了', '毁掉', '最糟糕', '人生', '永远好不了'],
    refutationHint: '最坏的情况发生的概率有多大？过去类似的担心成真过吗？',
  ),
  DistortionRule(
    name: '读心术',
    keywords: ['肯定觉得', '一定认为', '他们肯定', '肯定以为'],
    refutationHint: '有没有可能别人的想法和你的猜测不同？你验证过吗？',
  ),
  DistortionRule(
    name: '过度概括',
    keywords: ['总是', '每次都', '从不', '一直这样'],
    refutationHint: '这一次能代表所有情况吗？有没有反例？',
  ),
  DistortionRule(
    name: '个人化',
    keywords: ['都是我', '一定是我', '都怪我', '因为我'],
    refutationHint: '这件事里有哪些因素与你无关？别人会怎样归因？',
  ),
  DistortionRule(
    name: '应该陈述',
    keywords: ['应该', '必须', '不应该', '不得不'],
    refutationHint: '这个「应该」是事实，还是你对自己的要求？换成「最好」会怎样？',
  ),
  DistortionRule(
    name: '情绪化推理',
    keywords: ['感觉自己', '觉得自己是', '一定是个失败'],
    refutationHint: '感觉不等于事实。有什么证据支持，又有什么证据反对？',
  ),
];

/// 危机关键词（对应 ADD 安全护栏第一道防线）。
const List<String> kCrisisKeywords = [
  '不想活了', '伤害自己', '割腕', '跳楼',
  '想死', '活着没意思', '结束生命',
  '打他', '杀了他', '报复',
];

/// 求助热线（对应 IXD 危机干预页）。
const List<String> kHotlines = [
  '全国心理援助热线：400-161-9995',
  '北京心理危机研究与干预中心：010-82951332',
  '生命热线：400-161-9995',
];

/// 常用情绪标签（对应 IXD 情绪选择器）。
const List<String> kEmotionOptions = [
  '沮丧', '焦虑', '愤怒', '失望', '自责', '害怕', '平静', '内疚', '孤独', '疲惫',
];

/// 情绪识别规则（本地规则版，对应 context「AI 情绪加工引擎」情绪识别；
/// 接入服务端 AI 后由结构化 Prompt 替代）。
class EmotionRule {
  const EmotionRule({required this.name, required this.keywords});

  final String name;
  final List<String> keywords;
}

const List<EmotionRule> kEmotionRules = [
  EmotionRule(name: '焦虑', keywords: ['焦虑', '担心', '紧张', '不安', '烦躁', '着急', '心慌']),
  EmotionRule(name: '愤怒', keywords: ['生气', '愤怒', '恼火', '气死', '火大', '憋屈', '不爽']),
  EmotionRule(name: '沮丧', keywords: ['沮丧', '难过', '低落', '郁闷', '伤心', '灰心', '糟糕']),
  EmotionRule(name: '失望', keywords: ['失望', '遗憾', '落空']),
  EmotionRule(name: '自责', keywords: ['自责', '怪自己', '都怪我', '怨自己']),
  EmotionRule(name: '内疚', keywords: ['内疚', '愧疚', '对不起', '亏欠']),
  EmotionRule(name: '害怕', keywords: ['害怕', '恐惧', '惊慌', '发怵']),
  EmotionRule(name: '孤独', keywords: ['孤独', '孤单', '寂寞', '没人理']),
  EmotionRule(name: '疲惫', keywords: ['疲惫', '很累', '好累', '筋疲力尽', '没力气', '耗竭']),
  EmotionRule(name: '平静', keywords: ['平静', '还好', '没事', '放松', '不错', '挺好']),
];

/// 微行动建议池（对应 context 的 suggestion_action：一条具体可执行的微行动）。
const Map<String, String> kSuggestionByEmotion = {
  '焦虑': '做 3 次深呼吸，列出接下来要完成的 3 件最小任务。',
  '愤怒': '先离开现场 5 分钟，喝杯水，再决定怎么回应。',
  '沮丧': '做一件 5 分钟就能完成的小事，找回一点掌控感。',
  '失望': '把期望写下来，看看哪些可以调整到更现实。',
  '自责': '写下三条支持自己的证据，像安慰朋友一样安慰自己。',
  '内疚': '如果朋友遇到同样的事，你会怎么安慰他？把这句话说给自己听。',
  '害怕': '把最担心的结果写下来，评估它真实发生的概率。',
  '孤独': '给一个信任的人发条消息，哪怕只是打个招呼。',
  '疲惫': '休息 10 分钟，站起来走一走，喝点水。',
  '平静': '记录一下今天做得好的地方，保持这份觉察。',
};

/// 趋势标签规则（对应 context 的 tags：如 #工作 #人际 #健康）。
class TagRule {
  const TagRule({required this.name, required this.keywords});

  final String name;
  final List<String> keywords;
}

const List<TagRule> kTagRules = [
  TagRule(name: '工作', keywords: ['工作', '开会', '老板', '同事', '项目', '上班', '客户', '绩效', '加班', '领导', '任务']),
  TagRule(name: '家庭', keywords: ['家里', '回家', '在家', '家人', '父母', '孩子', '老公', '老婆', '媳妇', '爸妈']),
  TagRule(name: '人际', keywords: ['朋友', '吵架', '对象', '恋爱', '分手', '室友', '聚会']),
  TagRule(name: '健康', keywords: ['睡眠', '失眠', '生病', '疼痛', '体检', '吃药', '医院', '感冒', '发烧']),
  TagRule(name: '学习', keywords: ['考试', '学习', '作业', '成绩', '论文', '复习']),
];

/// 记录类别（家庭大病管理场景预留）。
const List<String> kRecordCategories = [
  '情绪记录', '病程跟踪', '用药记录', '就诊记录',
];

/// 本地缓存键（带版本号，格式变更时清缓存，见 platform flutter/apps.md 缓存版本约定）。
const String kRecordsCacheKey = 'abc_records_v1';
