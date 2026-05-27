# 2026 MCM/ICM C题面试准备文档

[![Deploy MkDocs](https://github.com/TwinklerG/2026-MCM-C/actions/workflows/ci.yml/badge.svg)](https://github.com/TwinklerG/2026-MCM-C/actions/workflows/ci.yml)

📖 **在线文档**: https://twinklerg.github.io/2026-MCM-C/

本目录汇总了 2026 美赛 C 题 `Dancing with the Stars` 项目的面试准备材料，定位是"总览摘要 + 文档导航"。内容面向三人共用场景，默认按"所有模块都需要能独立讲清楚"的标准整理，中文为主，保留英文术语、公式和可直接复述的关键结论。

## 这套文档解决什么问题

这套材料不是论文复述，而是面向面试场景的二次整理，核心目标有三点：

- 快速建立项目全貌：题目、方法链路、核心结果、关键结论
- 系统补齐必备知识点：贝叶斯推断、MCMC、混合效应模型、投票系统设计
- 提供高频问答素材：项目概述、数学原理、工程实现、模型对比、弱点防御

项目主线可以概括为：

1. 从评委分数和淘汰结果出发，反推隐藏的粉丝投票份额
2. 解释评委偏好与粉丝偏好的结构差异
3. 评估现有赛制，并设计更公平的新投票系统

## 核心结论速览

- Task 1：将问题建模为 `constrained Bayesian inverse problem`，使用自适应 Metropolis-Hastings 重构粉丝投票份额
- 淘汰重构准确率：`93.49%`（244/261）
- 决赛排名 Kendall's `τ = 0.994`
- 冠军识别率：`100%`（34/34）
- Judges' Save 偏好：`90.5%`
- Rank 与 Percentage 方法分歧率：`10.2%`
- ICC：评委 `9.5%`，粉丝 `21.8%`
- PTFS 技术公平性：`τ = 0.749`，相对 baseline 提升 `+0.022`，`p = 0.031`
- Close Call Rate：`79.1%`

## 文档清单

### 1. 入口与需求

- [proposal.md](docs/proposal.md)：整体需求文档，定义知识点体系、题库结构、输出范围与优先级
- [qa.md](docs/qa.md)：需求澄清记录。后续若有新问题，按你的要求继续记录在这里
- [tasks.md](docs/tasks.md)：按章节拆分的任务清单，包含内容条目和质量标准

### 2. 核心学习材料

- [knowledge_base.md](docs/knowledge_base.md)：必备知识点详解，按论文 Task 组织，适合系统补理论
- [interview_questions.md](docs/interview_questions.md)：模拟面试题库，每题提供保研版、就业版、速答版三种回答

### 3. 面试表达与防守材料

- [elevator_pitch.md](docs/elevator_pitch.md)：30 秒、1 分钟、3 分钟项目介绍话术
- [model_comparison.md](docs/model_comparison.md)：模型选择论证，回答"为什么选这个而不是那个"
- [weakness_defense.md](docs/weakness_defense.md)：弱点与局限性的防守模板，覆盖数据、方法、结果与泛化问题

## 建议使用顺序

如果你要从零开始准备，建议按下面顺序阅读：

1. 先看 [首页](https://twinklerg.github.io/2026-MCM-C/)，建立全局框架
2. 看 [proposal.md](docs/proposal.md) 和 [qa.md](docs/qa.md)，明确文档定位、目标人群和输出标准
3. 通读 [knowledge_base.md](docs/knowledge_base.md)，补齐四个 Task 的理论与方法
4. 配合 [interview_questions.md](docs/interview_questions.md) 做高频问答训练
5. 用 [elevator_pitch.md](docs/elevator_pitch.md) 打磨开场表达
6. 用 [model_comparison.md](docs/model_comparison.md) 和 [weakness_defense.md](docs/weakness_defense.md) 应对追问与质疑

如果临近面试，只想高效冲刺，建议顺序改为：

1. [elevator_pitch.md](docs/elevator_pitch.md)
2. [interview_questions.md](docs/interview_questions.md)
3. [weakness_defense.md](docs/weakness_defense.md)
4. [model_comparison.md](docs/model_comparison.md)
5. 回查 [knowledge_base.md](docs/knowledge_base.md)

## 本地预览

本项目使用 [MkDocs](https://www.mkdocs.org/) 和 [Material 主题](https://squidfunk.github.io/mkdocs-material/) 构建。

```bash
# 安装依赖
pip install -r requirements.txt

# 本地预览
mkdocs serve

# 构建站点
mkdocs build
```

## 部署到 GitHub Pages

本项目已配置 GitHub Actions 自动部署。推送代码到 `main` 分支后，工作流会自动构建并部署到 GitHub Pages。

手动部署命令：

```bash
mkdocs gh-deploy --force
```

## 当前文档特点

- 面向三人共用，不按个人分工切割
- 默认按"全栈口径"准备，建模、代码、论文都需要能解释
- 中英混合表达，适配保研和就业双场景
- 题库答案分三层深度，便于按面试压力切换口径
- 强调"公式 + 直觉 + 追问 + 结果解释"一体化准备

## 项目结构

```
.
├── docs/                      # 文档目录
│   ├── index.md              # 站点首页
│   ├── proposal.md           # 需求文档
│   ├── qa.md                 # 需求澄清
│   ├── tasks.md              # 任务清单
│   ├── knowledge_base.md     # 知识点库
│   ├── interview_questions.md # 面试题库
│   ├── elevator_pitch.md     # 项目介绍话术
│   ├── model_comparison.md   # 模型对比
│   ├── weakness_defense.md   # 弱点防守
│   ├── javascripts/          # 自定义 JavaScript
│   │   └── mathjax.js        # MathJax 配置
│   └── stylesheets/          # 自定义 CSS
│       └── extra.css         # 额外样式
├── .github/
│   └── workflows/
│       └── ci.yml            # GitHub Actions 工作流
├── mkdocs.yml                # MkDocs 配置
├── requirements.txt          # Python 依赖
└── README.md                 # 项目说明
```

## 后续协作约定

- 如果你对 README 结构、标题风格、信息层次还有调整意见，我会继续直接修改
- 如果后续出现新的澄清问题，我会先提问，并按要求记录到 [qa.md](docs/qa.md)

---

**提示**: 推荐直接访问 [在线文档](https://twinklerg.github.io/2026-MCM-C/) 以获得更好的阅读体验（支持搜索、深色模式、数学公式渲染等功能）。
