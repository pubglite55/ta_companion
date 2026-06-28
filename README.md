# TA - AI 灵魂伴侣

一个有「真实生活」的 AI 伴侣 Android App，基于 Flutter 开发。

## 功能特性

### 核心功能
- **AI 聊天** — 支持智谱GLM / OpenAI / Claude / DeepSeek 等多种AI服务
- **自定义提示词** — 完全自定义AI的性格和说话风格
- **对话历史** — 聊天记录本地保存，重启不丢失
- **语音朗读** — AI回复可朗读，支持手动点击或自动朗读

### 关系系统
- **亲密度** — 通过聊天、点赞、评论提升亲密度
- **等级划分** — 6个等级：陌生人 → 认识 → 朋友 → 好友 → 挚友 → 灵魂伴侣
- **奖励系统** — 解锁专属昵称、每日话题、秘密分享、甜蜜告白等奖励
- **纪念日** — 记录认识天数和特别时刻

### 记忆功能
- **自动记忆** — TA会记住你说过的重要信息
- **记忆分类** — 个人信息、偏好、事件、情感四类
- **智能注入** — 记忆自动注入AI上下文，让对话更贴心

### 天气系统
- **实时天气** — GPS定位获取真实天气数据
- **小时预报** — 未来12小时天气趋势
- **自动心情** — 根据天气自动调整AI心情

### 朋友圈
- **AI 生成动态** — AI自动生成有趣的朋友圈内容
- **发布动态** — 支持文字和图片类型
- **评论互动** — 评论和回复，AI会自动回复
- **本地保存** — 所有动态和评论本地存储

### 发现页面
- **每日冷知识** — AI生成的趣味知识
- **每日名言** — AI生成的优美名言
- **每日艺术品** — 来自Met Museum的艺术品展示

### 心情系统
- **心情记录** — 随时记录当前心情
- **心情日历** — 最近7天心情可视化
- **心情统计** — 各心情占比分析

### 消息动画
- **滑入动画** — 新消息从侧面滑入
- **打字指示器** — AI思考时显示跳动圆点

### 通知提醒
- **早安问候** — 每日8点推送
- **午间关怀** — 每日12点推送
- **晚间放松** — 每日18点推送
- **晚安提醒** — 每日22点推送

### 个性化设置
- **深色模式** — 支持浅色/深色主题切换
- **伴侣名字** — 自定义AI伴侣名称
- **伴侣性格** — 自定义AI性格特征
- **提示词编辑** — 在App内直接编辑AI提示词
- **语音设置** — 开启/关闭自动朗读

## 技术栈

| 技术 | 用途 |
|------|------|
| Flutter 3.x | 跨平台UI框架 |
| Dart | 编程语言 |
| Riverpod | 状态管理 |
| Dio | 网络请求 |
| Hive | 本地存储 |
| Geolocator | GPS定位 |
| flutter_tts | 语音朗读 |
| flutter_local_notifications | 本地通知 |

## API 接口

| API | 用途 | 需要Key |
|-----|------|---------|
| Open-Meteo | 天气数据 | 否 |
| Met Museum | 艺术品 | 否 |
| 智谱GLM / OpenAI | AI对话 | 是 |

## 安装运行

### 环境要求
- Flutter 3.0+
- Android SDK 24+

### 运行步骤

```bash
# 克隆项目
git clone https://github.com/pubglite55/ta_companion.git

# 进入项目目录
cd ta_companion

# 安装依赖
flutter pub get

# 运行
flutter run
```

### 配置AI服务

1. 打开App → 设置
2. 点击「AI 服务」→ 选择服务提供商
3. 输入模型名称（如 `glm-4-flash`）
4. 输入API Key
5. 保存后即可开始聊天

## 项目结构

```
ta_companion/
├── lib/
│   ├── main.dart              # 入口
│   ├── app.dart               # App配置
│   ├── config/                # 配置文件
│   │   ├── colors.dart        # 颜色定义
│   │   └── theme.dart         # 主题配置
│   ├── models/                # 数据模型
│   │   ├── mood.dart          # 心情模型
│   │   ├── message.dart       # 消息模型
│   │   ├── post.dart          # 动态模型
│   │   ├── intimacy.dart      # 亲密值模型
│   │   ├── rewards.dart       # 奖励系统
│   │   └── memory.dart        # 记忆模型
│   ├── providers/             # 状态管理
│   │   ├── settings_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── mood_provider.dart
│   │   ├── intimacy_provider.dart
│   │   └── memory_provider.dart
│   ├── services/              # 服务层
│   │   ├── ai_service.dart    # AI对话服务
│   │   ├── weather_service.dart # 天气服务
│   │   ├── notification_service.dart # 通知服务
│   │   └── tts_service.dart   # 语音朗读服务
│   ├── screens/               # 页面
│   │   ├── home_screen.dart   # 首页
│   │   ├── chat_screen.dart   # 聊天页
│   │   ├── timeline_screen.dart # 朋友圈
│   │   ├── discover_screen.dart # 发现页
│   │   ├── mood_screen.dart   # 心情统计
│   │   ├── rewards_screen.dart # 奖励页面
│   │   ├── memory_screen.dart # 记忆页面
│   │   └── settings_screen.dart # 设置页
│   ├── widgets/               # 组件
│   │   ├── mood_avatar.dart   # 心情头像
│   │   ├── message_bubble.dart # 聊天气泡
│   │   ├── post_card.dart     # 动态卡片
│   │   └── typing_indicator.dart # 打字指示器
│   └── utils/                 # 工具
│       ├── mood_calculator.dart # 心情计算
│       └── prompt_builder.dart # 提示词构建
└── android/                   # Android配置
```

## 更新日志

### v1.1.1 (2026-06-29)
- ✨ 新增亲密度系统（6个等级，11个奖励）
- ✨ 新增记忆功能（自动提取用户信息）
- ✨ 新增语音朗读（手动/自动朗读AI回复）
- ✨ 新增消息滑入动画
- ✨ 新增打字指示器动画
- 🔧 优化首页布局（6个功能入口）

### v1.0.0 (2026-06-28)
- 🎉 初始版本发布
- 💬 AI聊天（多服务商支持）
- 🌤️ 实时天气（GPS定位）
- 📱 朋友圈（AI生成+用户发布）
- 🎨 发现页面（知识+名言+艺术品）
- 😊 心情系统（记录+统计）
- 🔔 通知提醒（每日4次）
- 🌙 深色模式
- ⚙️ 个性化设置

## 许可证

MIT License

## 致谢

- [Open-Meteo](https://open-meteo.com/) - 天气API
- [Met Museum](https://www.metmuseum.org/) - 艺术品API
- [智谱AI](https://open.bigmodel.cn/) - AI服务
