# 美赛面试准备 — 任务清单

> 基于 `docs/proposal.md` 拆解，按章节粒度划分。
> 每个任务包含 **内容条目**（需覆盖哪些点）和 **质量标准**（完成的定义）。

---

## Task 1 · knowledge_base — Task 1 贝叶斯推断与 MCMC

**输出位置**: `docs/knowledge_base.md` § Task 1  
**优先级**: P0  
**涉及知识点**: M1, M2, M3, M4, M5, M9, M14, M15, E2, E11, I1, I2, I7

### Checklist — 内容条目

- [x] 贝叶斯推断基本原理：后验 ∝ 似然 × 先验，完整公式推导
- [x] 似然函数设计：为什么用指示函数（indicator likelihood），物理含义
- [x] 先验选择：Dirichlet 先验 / 均匀先验 / 数据驱动先验，对比分析
- [x] 单纯形约束（Simplex Constraint）：为什么需要、如何实现
- [x] MCMC 采样原理：Metropolis-Hastings 算法步骤、接受率推导
- [x] 自适应步长：目标接受率 0.35 的来源、调节机制
- [x] Log-space proposal：为什么在 log 空间做提议、数值稳定性
- [x] 时间平滑先验：正则化项设计、防止相邻周突变
- [x] 收敛诊断：ESS 计算方法、自相关分析、burn-in 设置
- [x] 约束贝叶斯逆问题：从淘汰结果反推投票份额的建模思路
- [x] 核心结果解读：93.49% 准确率、τ=0.994 的含义
- [x] 敏感性分析：先验选择对结果的影响（I7）

### Checklist — 质量标准

- [x] 每个知识点含完整数学公式（LaTeX）
- [x] 每个知识点含直觉解释（一句话能说清的 intuition）
- [x] 列出面试常见追问及简答
- [x] 三人均能看懂（不假设读者有贝叶斯背景）

---

## Task 2 · knowledge_base — Task 2 规则效果评估

**输出位置**: `docs/knowledge_base.md` § Task 2  
**优先级**: P0  
**涉及知识点**: M11, I8, I9

### Checklist — 内容条目

- [x] Judges' Save 规则定义及原理
- [x] DiffProb 指标设计：定义、公式、含义
- [x] JFEG 指标设计：定义、公式、含义
- [x] 二项检验在评估中的应用：90.5% 偏好的统计显著性
- [x] 规则"失效"结论的推导逻辑
- [x] 两种投票方法（Rank vs Percentage）的比较框架
- [x] 10.2% 分歧率的解读：多还是少、为什么

### Checklist — 质量标准

- [x] 指标设计含公式及计算示例
- [x] 含假设检验的完整步骤（零假设、备择、p值解读）
- [x] 结论有数据支撑，能快速引用关键数字

---

## Task 3 · knowledge_base — Task 3 混合效应模型

**输出位置**: `docs/knowledge_base.md` § Task 3  
**优先级**: P0  
**涉及知识点**: M6, M7, M8, M13, I3, I6, E6

### Checklist — 内容条目

- [x] 线性混合效应模型（LMM）原理：固定效应 vs 随机效应
- [x] 模型公式：y = Xβ + Zu + ε，各项含义
- [x] ICC（组内相关系数）：定义、公式、为什么能衡量"舞伴重要性"
- [x] BLUP（最佳线性无偏预测）：含义及用途
- [x] 双轨分层模型设计动机：分离技术评价与人气的思路（I3）
- [x] 多重共线性诊断：方法及处理
- [x] "运动员悖论"发现与解释（I6）：ICC 评委 9.5% vs 粉丝 21.8%
- [x] statsmodels 实现要点

### Checklist — 质量标准

- [x] 含固定效应 vs 混合效应 vs 随机效应的对比表
- [x] ICC 含数值计算示例
- [x] "运动员悖论"有清晰的因果解释链
- [x] 三人均能看懂（不假设读者有混合效应模型背景）

---

## Task 4 · knowledge_base — Task 4 投票系统设计

**输出位置**: `docs/knowledge_base.md` § Task 4  
**优先级**: P0  
**涉及知识点**: M9, M11, M12, I4, I5, I10, E12

### Checklist — 内容条目

- [x] 社会选择理论背景：Arrow 不可能定理简述
- [x] PTFS 系统设计：动态权重线性递增的公式与动机
- [x] 多维评价框架：公平性 + 参与度 + 鲁棒性三维度
- [x] Kendall's τ 在系统评估中的应用
- [x] 假设检验：PTFS τ=0.749、Δτ=0.022 (p=0.031) 的显著性论证
- [x] Close Call Rate 79.1%：悬念度指标设计
- [x] 为什么选线性递增而不是阶梯/指数函数
- [x] 参数调优方法（网格搜索）

### Checklist — 质量标准

- [x] 含 PTFS 公式推导
- [x] 含与 baseline 的定量对比表
- [x] 设计选择有明确 justification（不只是"效果好"）
- [x] Arrow 定理解释简洁，非数学专业队友也能复述

---

## Task 5 · interview_questions — 项目概述类

**输出位置**: `docs/interview_questions.md` § 项目概述  
**优先级**: P0  
**涉及知识点**: 全局

### Checklist — 内容条目

- [x] "介绍一下你的美赛项目"：30秒版 / 1分钟版 / 3分钟版
- [x] "你们解决了什么问题？"
- [x] "你的主要贡献是什么？"
- [x] "为什么选择这道题？"

### Checklist — 质量标准

- [x] 每题含三个版本答案：保研版 / 就业版 / 速答版
- [x] 30秒版能一口气说完、结构清晰（问题→方法→结果）
- [x] 突出关键词：贝叶斯推断、MCMC、混合效应模型、投票系统设计
- [x] 数据支撑：至少引用 2-3 个核心指标

---

## Task 6 · interview_questions — 数学原理深挖类

**输出位置**: `docs/interview_questions.md` § 数学原理深挖  
**优先级**: P0  
**涉及知识点**: M1-M15

### Checklist — 内容条目

- [x] 贝叶斯公式推导：后验 ∝ 似然 × 先验
- [x] MCMC 为什么能工作？收敛性证明思路
- [x] MH 接受率为什么是 min(1, P*/P)？
- [x] 似然函数为什么是指示函数？连续化是否更好？
- [x] 混合效应 vs 固定效应的本质区别
- [x] ICC 的统计含义？为什么衡量"舞伴重要性"？
- [x] 为什么选 Kendall's τ 而不是 Pearson r？
- [x] 怎么处理多重共线性？
- [x] 模型可识别性如何保证？

### Checklist — 质量标准

- [x] 每题含三个版本答案：保研版（含推导）/ 就业版（含实践）/ 速答版
- [x] 保研版含完整数学推导步骤
- [x] 每题列出 1-2 个可能的追问及应对

---

## Task 7 · interview_questions — 工程实现类

**输出位置**: `docs/interview_questions.md` § 工程实现  
**优先级**: P0  
**涉及知识点**: E1-E12

### Checklist — 内容条目

- [x] MCMC 采样器怎么实现的？
- [x] 自适应步长调整机制？目标接受率 0.35 来源？
- [x] 采样在 log-space 的理由？
- [x] ESS 怎么计算？ESS 太低怎么办？
- [x] 数据预处理 pipeline？
- [x] 如何处理缺失值和异常值？
- [x] 代码模块划分逻辑？
- [x] 计算量多大？怎么优化性能？
- [x] 怎么保证结果可复现？

### Checklist — 质量标准

- [x] 每题含三个版本答案：保研版 / 就业版（含代码片段）/ 速答版
- [x] 就业版含具体技术选型理由（如 Polars vs Pandas）
- [x] 能给出量化数据（如采样量、运行时间、ESS 数值）

---

## Task 8 · interview_questions — 模型选择与对比类

**输出位置**: `docs/interview_questions.md` § 模型选择  
**优先级**: P0  
**涉及知识点**: I1-I10

### Checklist — 内容条目

- [x] 为什么用 MCMC 而不是 MLE？
- [x] 为什么不用变分推断？
- [x] 先验怎么选的？选错了会怎样？
- [x] Task 3 为什么不用贝叶斯而用频率学派？
- [x] PTFS 为什么选线性递增？
- [x] 模型有什么 limitations？
- [x] 如果重做，什么地方会改进？

### Checklist — 质量标准

- [x] 每题含三个版本答案：保研版 / 就业版 / 速答版
- [x] 每个选择包含"选了什么 + 为什么 + 不选另一个的理由"三段式
- [x] limitations 部分诚实但有防御策略

---

## Task 9 · interview_questions — 结果解读与 insight 类

**输出位置**: `docs/interview_questions.md` § 结果解读  
**优先级**: P0  
**涉及知识点**: 核心数据速查表

### Checklist — 内容条目

- [x] 93.49% 准确率说明什么？剩下 6.5% 是什么？
- [x] "运动员悖论"怎么回事？解释是什么？
- [x] Judges' Save 为什么"失效"？
- [x] 10% 分歧率——多还是少？
- [x] Δτ=0.022 为什么有意义？
- [x] 对争议选手（Bobby Bones）的预测如何？

### Checklist — 质量标准

- [x] 每题含三个版本答案：保研版 / 就业版 / 速答版
- [x] 每个回答引用具体数据（见核心数据速查表）
- [x] insight 有因果逻辑链，不只是描述现象

---

## Task 10 · interview_questions — 延伸扩展类

**输出位置**: `docs/interview_questions.md` § 延伸扩展  
**优先级**: P1  
**涉及知识点**: 跨领域关联

### Checklist — 内容条目

- [x] 与推荐系统的联系？
- [x] 数据量大 100 倍能否 scale？
- [x] 如何推广到其他竞赛？
- [x] 贝叶斯推断的工业应用场景？
- [x] 混合效应模型的常见领域？
- [x] A/B 实验与因果推断的关联？
- [x] 社交媒体数据如何融入？

### Checklist — 质量标准

- [x] 每题含三个版本答案：保研版 / 就业版 / 速答版
- [x] 延伸方向有具体思路（不只是"可以做"）
- [x] 展示知识面广度，但不过度发散

---

## Task 11 · interview_questions — 团队协作类

**输出位置**: `docs/interview_questions.md` § 团队协作  
**优先级**: P1  
**涉及知识点**: 软技能

### Checklist — 内容条目

- [x] 三人怎么分工？
- [x] 遇到的最大困难？怎么解决？
- [x] 4 天时间紧迫如何做取舍？
- [x] 论文写作与代码实现怎么并行？
- [x] 思路冲突怎么办？

### Checklist — 质量标准

- [x] 每题含三个版本答案：保研版 / 就业版 / 速答版
- [x] 答案含 STAR 结构（Situation-Task-Action-Result）
- [x] 体现领导力/协调能力/快速迭代

---

## Task 12 · elevator_pitch

**输出位置**: `docs/elevator_pitch.md`  
**优先级**: P1  

### Checklist — 内容条目

- [x] 30 秒版本：核心问题 + 核心方法 + 核心结果（一句话）
- [x] 1 分钟版本：问题背景 + 四个 Task 概述 + 关键数据 + 收获
- [x] 3 分钟版本：完整叙事（问题→建模→实现→结果→反思）
- [x] 英文版 30 秒 pitch（备用）

### Checklist — 质量标准

- [x] 每个版本实际朗读一遍确认时长合理
- [x] 突出简历关键词：贝叶斯推断、MCMC、混合效应、投票系统
- [x] 有 hook（开头吸引注意力）
- [x] 结尾有 takeaway（面试官记住什么）

---

## Task 13 · model_comparison

**输出位置**: `docs/model_comparison.md`  
**优先级**: P1  

### Checklist — 内容条目

- [x] MCMC vs MLE vs 变分推断：对比表 + 选择理由
- [x] 混合效应 vs 固定效应 vs 贝叶斯层次模型：对比表 + 选择理由
- [x] 线性递增 vs 阶梯函数 vs 指数函数（PTFS 权重）：对比 + 选择理由
- [x] Kendall's τ vs Pearson r vs Spearman ρ：适用场景对比
- [x] 指示函数似然 vs 连续似然：trade-off 分析
- [x] Dirichlet 先验 vs 均匀先验 vs 数据驱动先验：对比

### Checklist — 质量标准

- [x] 每个对比含"我们选了什么 / 为什么 / 替代方案为什么不选"
- [x] 含对比表格（可快速扫描）
- [x] 诚实承认 trade-off（不需要假装完美）
- [x] 能在面试中 30 秒内说清任一对比

---

## Task 14 · weakness_defense

**输出位置**: `docs/weakness_defense.md`  
**优先级**: P2  

### Checklist — 内容条目

- [x] 模型局限性清单（主动列出）
- [x] 数据局限：34 赛季、无真实投票数据
- [x] 方法局限：指示函数似然的信息损失、计算开销
- [x] 结果局限：Δτ=0.022 的实际意义讨论
- [x] 泛化局限：特定节目 → 其他场景的适用性
- [x] 每个弱点的防御策略："承认 + 解释合理性 + 提出改进方向"

### Checklist — 质量标准

- [x] 每个弱点有"三段式防御"：承认→合理化→未来改进
- [x] 防御不回避问题（面试官能感受到诚实）
- [x] 改进方向具体可行（不是空话）
- [x] 练习自然的表达（不像在背稿）

---

## 依赖关系

```
Task 1-4 (knowledge_base) → Task 5-11 (interview_questions)
                          → Task 12 (elevator_pitch)
                          → Task 13 (model_comparison)
                          → Task 14 (weakness_defense)
```

> knowledge_base 是基础，面试题的答案依赖知识点的整理。建议先完成 Task 1-4，再并行推进后续任务。

---

## 进度追踪

| Task | 标题 | 优先级 | 状态 |
|------|------|--------|------|
| 1 | knowledge_base — Task 1 贝叶斯/MCMC | P0 | ✅ 已完成 |
| 2 | knowledge_base — Task 2 规则效果 | P0 | ✅ 已完成 |
| 3 | knowledge_base — Task 3 混合效应 | P0 | ✅ 已完成 |
| 4 | knowledge_base — Task 4 系统设计 | P0 | ✅ 已完成 |
| 5 | interview_questions — 项目概述 | P0 | ✅ 已完成 |
| 6 | interview_questions — 数学深挖 | P0 | ✅ 已完成 |
| 7 | interview_questions — 工程实现 | P0 | ✅ 已完成 |
| 8 | interview_questions — 模型选择 | P0 | ✅ 已完成 |
| 9 | interview_questions — 结果解读 | P0 | ✅ 已完成 |
| 10 | interview_questions — 延伸扩展 | P1 | ✅ 已完成 |
| 11 | interview_questions — 团队协作 | P1 | ✅ 已完成 |
| 12 | elevator_pitch | P1 | ✅ 已完成 |
| 13 | model_comparison | P1 | ✅ 已完成 |
| 14 | weakness_defense | P2 | ✅ 已完成 |
