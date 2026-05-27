# 美赛面试知识库

本文按论文四个 Task 组织，面向三人共用的面试准备场景。表述以中文为主，保留核心英文术语、公式与可直接复述的结论。

## Task 1 · 贝叶斯推断与 MCMC

### 1.1 问题重述：为什么这是一个 constrained Bayesian inverse problem

我们真正观测到的是每周的评委分数 `judges' scores` 和淘汰结果 `elimination outcome`，但看不到选手的真实粉丝投票份额 `fan share`。因此任务不是“直接预测未来谁淘汰”，而是“根据已经发生的淘汰结果，反推出一组最可能的隐变量”。

数学上，把第 \(t\) 周选手的粉丝投票份额写成

$$
\mathbf{f}_t=(f_{1,t},\dots,f_{n_t,t}), \quad f_{i,t}>0, \quad \sum_{i=1}^{n_t} f_{i,t}=1.
$$

后验分布写成

$$
p(\mathbf{f}_{1:T}\mid \mathbf{J}_{1:T},\mathbf{E}_{1:T})
\propto
p(\mathbf{E}_{1:T}\mid \mathbf{f}_{1:T},\mathbf{J}_{1:T})
\, p(\mathbf{f}_{1:T}) .
$$

进一步拆成逐周结构：

$$
p(\mathbf{f}_{1:T}\mid \mathbf{J}_{1:T},\mathbf{E}_{1:T})
\propto
\prod_{t=1}^T p(E_t\mid \mathbf{f}_t,\mathbf{J}_t)
\cdot p(\mathbf{f}_1)
\cdot \prod_{t=2}^T p(\mathbf{f}_t\mid \mathbf{f}_{t-1}).
$$

直觉解释：我们拿“淘汰结果”做硬约束，拿“先验”和“时间平滑”去补足信息缺失，所以这是一个带约束的贝叶斯逆问题。

常见追问：

- 问：为什么叫 inverse problem？
  答：正向过程是“粉丝投票 + 评委分数 -> 淘汰结果”，我们做的是反向推断“淘汰结果 -> 粉丝份额”。
- 问：为什么不是普通监督学习？
  答：因为没有真实投票份额标签，只有由潜变量诱导出的淘汰结果。

### 1.2 贝叶斯推断基本原理：posterior \(\propto\) likelihood \(\times\) prior

Bayes 公式是

$$
p(\theta\mid y)=\frac{p(y\mid \theta)p(\theta)}{p(y)}.
$$

其中 \(\theta\) 是参数，\(y\) 是观测。因为

$$
p(y)=\int p(y\mid \theta)p(\theta)\,d\theta
$$

与具体的 \(\theta\) 取值无关，所以在采样和比较不同参数点时可以写成

$$
p(\theta\mid y)\propto p(y\mid \theta)p(\theta).
$$

在本题里，把 \(\theta\) 换成全部周次的粉丝份额 \(\mathbf{f}_{1:T}\)，把 \(y\) 换成评委分与淘汰结果，就得到

$$
p(\mathbf{f}_{1:T}\mid \mathbf{J}_{1:T},\mathbf{E}_{1:T})
\propto
p(\mathbf{E}_{1:T}\mid \mathbf{f}_{1:T},\mathbf{J}_{1:T})
\cdot p(\mathbf{f}_{1:T}).
$$

直觉解释：后验分布就是“哪些粉丝份额既符合淘汰事实，又符合我们的先验认知”。

面试快答：

- `posterior`：综合数据后的信念。
- `likelihood`：这组参数生成当前观测有多合理。
- `prior`：在看数据之前对参数的先验判断。

常见追问：

- 问：分母 \(p(y)\) 有什么作用？
  答：它是归一化常数，保证后验积分为 1；MCMC 只需比例关系，不必显式算出。
- 问：贝叶斯和频率学派的核心区别？
  答：贝叶斯把参数看成随机变量并输出完整不确定性分布，频率学派通常把参数当固定未知量。

### 1.3 似然函数设计：为什么用 indicator likelihood

本项目的关键设计是把似然写成指示函数 `indicator likelihood`。若某组粉丝份额和评委分组合后，能导出真实发生的淘汰事件，则似然为 1，否则为 0：

$$
p(E_t\mid \mathbf{f}_t,\mathbf{J}_t)=
\mathbb{I}\bigl\{\mathcal{A}(\mathbf{f}_t,\mathbf{J}_t)=E_t\bigr\}.
$$

这里 \(\mathcal{A}(\cdot)\) 表示节目规则下的淘汰映射。

对 S1-S27 的单人淘汰情形，可写成

$$
p(E_t\mid \mathbf{f}_t,\mathbf{J}_t)=
\begin{cases}
1, & E_t=\operatorname{Bottom}\text{-}k\bigl(\operatorname{Score}(\mathbf{f}_t,\mathbf{J}_t)\bigr),\\
0, & \text{otherwise}.
\end{cases}
$$

对 S28+ 的 `Judges' Save`，因为评委会在 bottom 2 中二选一，所以约束放宽为“实际淘汰者必须落在 bottom 2 内”：

$$
p(E_t\mid \mathbf{f}_t,\mathbf{J}_t)=
\mathbb{I}\bigl\{E_t\cap \operatorname{Bottom2}(\operatorname{Score}(\mathbf{f}_t,\mathbf{J}_t))\neq \varnothing\bigr\}.
$$

物理含义：我们没有真实投票数，也不知道节目组的全部细节，但知道“这组隐变量至少必须解释已发生的淘汰结果”。

直觉解释：似然不是在拟合连续误差，而是在筛掉所有与真实淘汰不一致的候选解。

为什么不是连续似然：

- 可观测量本身是离散淘汰事件，不是带高斯噪声的连续量。
- 用硬约束可以直接嵌入真实节目规则。
- 代价是信息利用较粗，只利用了“是否一致”，没利用“差多少”。

计算示例：

- 假设某周 4 位选手综合得分为 \((0.31,0.27,0.23,0.19)\)，实际淘汰第 4 位，则该样本似然为 1。
- 若另一组候选粉丝份额导致综合得分变成 \((0.29,0.28,0.18,0.25)\)，淘汰变成第 3 位，则该样本似然为 0。

常见追问：

- 问：连续化是不是更好？
  答：连续似然能提供更平滑的信息，但需要额外假设“离 bottom 的距离如何转成概率”，在缺乏真实投票数据时会引入新的模型偏差。
- 问：指示函数会不会导致采样困难？
  答：会，尤其后验边界很尖锐，所以我们配合 log-space proposal、自适应步长和时间平滑来改善混合。

### 1.4 先验选择：Dirichlet / uniform / data-driven prior

由于 \(\mathbf{f}_t\) 处在 simplex 上，最自然的共轭先验是 Dirichlet 分布：

$$
\mathbf{f}_t \sim \operatorname{Dirichlet}(\boldsymbol{\alpha}),
$$

其密度为

$$
p(\mathbf{f}_t)=\frac{1}{B(\boldsymbol{\alpha})}\prod_{i=1}^{n_t} f_{i,t}^{\alpha_i-1},
\quad f_{i,t}>0,\ \sum_i f_{i,t}=1.
$$

其中

$$
B(\boldsymbol{\alpha})=
\frac{\prod_{i=1}^{n_t}\Gamma(\alpha_i)}{\Gamma\!\left(\sum_{i=1}^{n_t}\alpha_i\right)}.
$$

三类先验可以这样理解：

| 先验 | 数学形式 | 优点 | 风险 | 适用说法 |
| --- | --- | --- | --- | --- |
| Dirichlet / uniform | \(\alpha_i=1\) | 最中性，不偏向任何选手 | 忽略历史结构 | 适合做 baseline |
| 对称 Dirichlet | \(\alpha_i=\alpha\) | 可调浓度，控制稀疏性 | 仍然不区分个体 | 适合敏感性分析 |
| 数据驱动先验 | \(\alpha_i\propto \mu_i\) | 利用行业、年龄、历史生存信息 | 可能引入历史偏见 | 适合主模型 |

本项目实际实现采用“数据驱动均值 + simplex 归一化”的先验思想。可写成

$$
\mu_i = \pi_{\text{industry}(i)} \cdot
\left(0.9 + 0.1\exp\left[-\left(\frac{\text{age}_i-40}{30}\right)^2\right]\right),
$$

再将这些均值缩放到当周选手集合上，形成 prior center。

敏感性分析结果：

- 数据驱动先验的重构准确率约为 \(93.49\%\)；
- 均匀先验约为 \(97.70\%\)；
- 两者准确率差约 \(4.21\%\)，但幸存选手分布差异很小，平均 KL 约 \(0.0014\)，平均 MAD 约 \(0.0040\)。

面试建议说法：主结论对先验并不脆弱，先验会影响局部估计，但不会推翻整体排序与关键 insight。

直觉解释：先验像“冷启动偏好”，数据越强，后验越由淘汰约束主导；数据越弱，先验影响越明显。

常见追问：

- 问：为什么不直接全部用均匀先验？
  答：均匀先验更中性，但会丢失历史结构；我们保留数据驱动主模型，同时用均匀先验做 robustness check。
- 问：先验选错会怎样？
  答：早期周次和边界案例更容易受影响，所以必须做敏感性分析，而不是只报告单一结果。

### 1.5 Simplex constraint：为什么需要、如何实现

粉丝投票份额本质上是概率向量，因此必须满足

$$
f_{i,t}>0, \qquad \sum_{i=1}^{n_t}f_{i,t}=1.
$$

如果没有 simplex constraint，会出现两类问题：

- 份额可能为负，没有物理意义；
- 各选手份额总和可能不等于 1，无法解释成投票占比。

实现上，我们在 log-space 里做 proposal，再通过 softmax-like 归一化映射回 simplex：

$$
z_i^* = \log f_i^{(k)} + \varepsilon_i, \qquad \varepsilon_i\sim \mathcal{N}(0,\sigma^2),
$$

$$
\tilde{f}_i^* = \exp(z_i^* - \max_j z_j^*),
$$

$$
f_i^* = \frac{\max(\tilde{f}_i^*,10^{-6})}{\sum_j \max(\tilde{f}_j^*,10^{-6})}.
$$

这样天然保证所有分量为正且和为 1。

直觉解释：simplex 是“概率空间的合法边界”，log-space proposal 是一种先走到无约束空间、再映射回合法区域的方法。

常见追问：

- 问：为什么不直接在原空间上加噪声？
  答：原空间很容易违反非负和求和为 1 的约束，修补会破坏 proposal 的稳定性。
- 问：这和 softmax 有什么关系？
  答：本质上就是 softmax/归一化思想，只是加入了数值下界避免极小值下溢。

### 1.6 MCMC 原理：Metropolis-Hastings 怎么工作

目标是从难以直接采样的后验分布 \(\pi(\theta)\) 中取样。MH 算法构造一个以 \(\pi\) 为平稳分布的马尔可夫链。

设当前状态为 \(\theta\)，从 proposal distribution \(q(\theta^*\mid \theta)\) 生成候选点 \(\theta^*\)。接受概率为

$$
\alpha(\theta,\theta^*)=
\min\left(1,
\frac{\pi(\theta^*)q(\theta\mid\theta^*)}{\pi(\theta)q(\theta^*\mid\theta)}
\right).
$$

若 proposal 对称，即

$$
q(\theta^*\mid\theta)=q(\theta\mid\theta^*),
$$

则简化为

$$
\alpha(\theta,\theta^*)=
\min\left(1,\frac{\pi(\theta^*)}{\pi(\theta)}\right).
$$

本项目用对数形式实现：

$$
\log r = \log \pi(\theta^*) - \log \pi(\theta),
$$

$$
\alpha = \min(1,e^{\log r}).
$$

算法步骤：

1. 从当前样本生成 proposal。
2. 如果违反淘汰约束，直接拒绝。
3. 否则计算后验比值。
4. 生成 \(u\sim U(0,1)\)，若 \(\log u<\log r\) 则接受，否则保留原状态。

为什么接受率是 \(\min(1,P^*/P)\)：因为要满足 detailed balance

$$
\pi(\theta)P(\theta\to\theta^*)=
\pi(\theta^*)P(\theta^*\to\theta),
$$

这能保证 \(\pi\) 是链的平稳分布。取这个接受率是满足 detailed balance 的最简方案之一。

直觉解释：如果新点后验更高就优先接受；如果更差也有概率接受，这样才能跳出局部区域并近似整个后验分布。

常见追问：

- 问：MCMC 为什么能收敛到后验？
  答：只要链满足不可约、非周期和 detailed balance，且目标分布可归一化，就会以目标后验为平稳分布。
- 问：为什么不用拒绝采样？
  答：高维 simplex 加硬约束场景下接受率会极低，拒绝采样几乎不可用。

### 1.7 自适应步长：目标接受率 0.35 从哪里来

随机游走型 MH 存在典型权衡：

- 步长太小，接受率很高，但链移动很慢，自相关大；
- 步长太大，提议点经常落到低密度区，接受率很低。

文献中对随机游走 MH 的最优接受率有经典结果，低维情况下经验上落在 \(0.2\sim 0.4\) 比较合理；高维极限常见值约为 \(0.234\)。本项目在受约束、维度中等、离散规则很硬的设定下，把目标接受率设在 `0.35`，是一个更实用的折中点。

实现上，每隔 50 步统计窗口接受率 \(\hat\alpha\)，在 warm-up 阶段调整 proposal standard deviation：

$$
\sigma_{\text{new}}=
\begin{cases}
1.3\sigma, & \hat\alpha>0.40,\\
0.7\sigma, & \hat\alpha<0.30,\\
\sigma, & \text{otherwise}.
\end{cases}
$$

并限制在区间 \([0.02,0.6]\) 内。

当前结果中，平均接受率约为 \(0.347\)，和目标值基本一致。

直觉解释：0.35 不是神奇常数，而是“移动速度”和“接受概率”之间的工程平衡点。

常见追问：

- 问：为什么不是 0.234？
  答：0.234 是高维随机游走 MH 的渐近结果，这里有 simplex 约束和硬规则，经验上 0.35 更适合实际混合。
- 问：适应会不会破坏马尔可夫性？
  答：会，所以通常只在 burn-in/warm-up 阶段适应，正式采样阶段固定参数。

### 1.8 Log-space proposal：为什么在 log 空间提议

若直接对 \(f_i\) 做高斯扰动，容易产生负数或过度依赖投影修补。对正变量更自然的做法是先取对数：

$$
z_i = \log f_i.
$$

然后在 \(z\) 空间中做高斯随机游走：

$$
z_i^*=z_i+\varepsilon_i, \qquad \varepsilon_i\sim \mathcal{N}(0,\sigma^2).
$$

最后再映射回 simplex。

数值稳定性的关键是减去最大值：

$$
\exp(z_i^* - \max_j z_j^*),
$$

这样可以避免 `overflow`。同时给每个分量设置 \(10^{-6}\) 下界，避免出现 \(\log 0\) 或极端数值下溢。

直觉解释：log-space 把“乘法尺度”的变化变成“加法尺度”的变化，更适合处理占比类变量。

常见追问：

- 问：为什么说更稳定？
  答：因为 very small probabilities 在原空间里很脆弱，在对数空间里只是较大的负数，更容易比较和更新。
- 问：会不会引入 Jacobian？
  答：如果把变换完整写成独立参数化，需要考虑 Jacobian；这里实际采用的是“在 log-space 上构造 proposal，再归一化”的工程实现，核心仍由 MH 接受率修正。

### 1.9 时间平滑先验：为什么需要 temporal smoothing

粉丝基础不可能一周内无缘无故剧烈震荡，因此相邻周之间应有平滑约束。设相邻周都在场的选手集合为 \(\mathcal{C}_{t,t-1}\)，平滑项写成

$$
p(\mathbf{f}_t\mid \mathbf{f}_{t-1})
\propto
\exp\left[-\lambda\sum_{i\in \mathcal{C}_{t,t-1}}(f_{i,t}-f_{i,t-1})^2\right].
$$

对应对数项为

$$
\log p(\mathbf{f}_t\mid \mathbf{f}_{t-1})
=
-\lambda\sum_{i\in \mathcal{C}_{t,t-1}}(f_{i,t}-f_{i,t-1})^2 + C.
$$

这里 \(\lambda=0.5\)。

作用：

- 减少不合理的周间跳变；
- 在单周约束信息不足时提供结构性信息；
- 改善采样稳定性，降低多峰和极端尖点问题。

直觉解释：时间平滑相当于给“粉丝支持率曲线”加了一个不要乱抖的 regularizer。

常见追问：

- 问：是不是会过度平滑，掩盖真实爆发？
  答：有这个风险，所以 \(\lambda\) 不能过大，而且只对相邻周共同存活选手生效。
- 问：为什么用二次惩罚？
  答：二次项可微、稳定、解释简单，是最常见的平滑正则形式。

### 1.10 收敛诊断：ESS、自相关与 burn-in

MCMC 样本有自相关，不能把 \(N\) 个样本都当成独立样本。有效样本量 `effective sample size, ESS` 定义为

$$
\operatorname{ESS}=\frac{N}{1+2\sum_{k=1}^{K^*}\rho_k},
$$

其中 \(\rho_k\) 是滞后 \(k\) 的自相关系数，\(K^*\) 通常取到首次负自相关处或按初始单调序列截断。

自相关可写为

$$
\rho_k=
\frac{\sum_{t=1}^{N-k}(X_t-\bar X)(X_{t+k}-\bar X)}{\sum_{t=1}^{N}(X_t-\bar X)^2}.
$$

本项目配置：

- warm-up / burn-in：3000；
- 采样数：10000；
- thinning：5；
- 目标最小 ESS：100。

实际诊断结果：

- 平均 ESS 约 \(191\)；
- 最小 ESS 约 \(115.6\)；
- 平均接受率约 \(34.7\%\)。

如果 ESS 太低，处理方法包括：

- 增加总采样长度；
- 延长 burn-in；
- 降低 proposal 标准差；
- 减小 smoothing 权重以改善混合；
- 降低 thinning 或重跑增强配置。

直觉解释：ESS 衡量的不是“你抽了多少次”，而是“这些样本里真正有多少独立信息”。

常见追问：

- 问：为什么要 burn-in？
  答：初始状态通常不在平稳分布上，前一段样本带有初始化偏差，需要丢弃。
- 问：thinning 一定有必要吗？
  答：不一定。理论上增加总样本更重要，但在存储和后处理成本受限时 thinning 是实用折中。

### 1.11 核心结果解读：93.49% accuracy 与 \(\tau=0.994\)

Task 1 的核心验证数字来自 `draft/wmh/task1/outputs/results.json`：

$$
\text{Reconstruction Accuracy}=\frac{244}{261}=93.49\%.
$$

它表示在 261 个有淘汰结果的周次中，有 244 周模型导出的淘汰结果和真实记录一致。

另一个关键指标是决赛 Kendall's \(\tau\)：

$$
\tau=0.9941.
$$

Kendall's \(\tau\) 的定义是

$$
\tau = \frac{C-D}{\binom{n}{2}},
$$

其中 \(C\) 是 concordant pairs 数，\(D\) 是 discordant pairs 数。\(\tau\) 接近 1，说明预测排序与真实排序几乎完全一致。

还可快速引用：

- 冠军识别率 \(34/34=100\%\)；
- `bottom-2 recall` 为 \(98.85\%\)；
- `constraint satisfaction rate` 为 \(99.23\%\)。

如何解释剩余 \(6.51\%\) 误差：

- Judges' Save 阶段引入了评委二次决策；
- 某些节目周存在额外规则或噪声；
- 我们只看到淘汰结果，没有真实投票数，因此可识别信息本身不完整。

直觉解释：93.49% 说明模型已经抓住主要淘汰机制，\(\tau=0.994\) 说明它对最终名次结构的解释几乎完全正确。

常见追问：

- 问：为什么不是 95.02%？
  答：仓库中不同草稿版本有不同实验记录；当前主结果文件 `results.json` 的正式数值是 93.49%，应以这一版为准。
- 问：93.49% 是不是过高，说明过拟合？
  答：这是重构精度而非传统预测精度，而且任务本身就利用了已知淘汰约束；我们还报告了先验敏感性和结构漂移，避免“只报高分”。

### 1.12 Task 1 面试常见追问速查

| 追问 | 简答 |
| --- | --- |
| 为什么用 MCMC 而不是 MLE？ | 因为后验由硬约束和 simplex 构成，参数空间复杂，MLE 只能给点估计，MCMC 能给不确定性。 |
| 为什么用贝叶斯？ | 没有真实投票标签时，先验和结构信息很重要，而且我们需要 credible intervals。 |
| 为什么用 Kendall's \(\tau\)？ | 排名任务比绝对值任务更自然，\(\tau\) 对 pairwise order 最敏感。 |
| 你们的模型可识别性怎么保证？ | 依靠 simplex 约束、真实淘汰硬约束、时间平滑和跨周信息共同缩小可行空间。 |

## Task 2 · 规则效果评估

### 2.1 Judges' Save 规则定义及原理

在 S28+，节目先根据评委分与观众投票确定 `bottom 2`，再由评委在这两人中决定谁淘汰。这个规则的原始动机是：

- 给评委一次纠偏机会；
- 防止技术更好的选手因为人气波动过早出局。

用集合语言表示：若某周 bottom 2 为 \(B_t=\{a,b\}\)，最终淘汰者 \(e_t\in B_t\)。

也就是说，`Judges' Save` 并不推翻前面的投票聚合，只是在最后一步加入评委人工决策。

直觉解释：它试图把“观众选择”与“专业纠偏”叠加起来。

常见追问：

- 问：为什么说它可能失效？
  答：如果评委大多数时候救下的本来就是粉丝更高的选手，那它没有真正起到纠偏作用。

### 2.2 DiffProb 指标：定义、公式、含义

DiffProb 用来衡量两种投票聚合方法是否会导出不同淘汰结果。定义为

$$
\operatorname{DiffProb}_t=
\mathbb{I}\{e_t^{(\text{rank})}\neq e_t^{(\text{pct})}\}.
$$

对全部有淘汰的周取平均：

$$
\overline{\operatorname{DiffProb}}=
\frac{1}{T}\sum_{t=1}^{T}\operatorname{DiffProb}_t.
$$

其中

- \(e_t^{(\text{rank})}\)：Rank-based 方法下预测淘汰者；
- \(e_t^{(\text{pct})}\)：Percentage-based 方法下预测淘汰者。

已知结果：

$$
\overline{\operatorname{DiffProb}}=\frac{30}{295}\approx 10.2\%.
$$

计算示例：

- 若某周 Rank 淘汰 `A`，Percentage 淘汰 `B`，则 \(\operatorname{DiffProb}_t=1\)；
- 若两种方法都淘汰 `A`，则 \(\operatorname{DiffProb}_t=0\)。

直觉解释：DiffProb 直接回答“改规则会不会改人”。

如何解读 10.2%：

- 不是“很小可以忽略”；
- 也不是“系统完全不同”；
- 更准确的说法是：约 90% 的周两种方法一致，但约 10% 的边界周规则选择会真实改变淘汰者，说明规则确实有实质影响。

### 2.3 JFEG 指标：定义、公式、含义

JFEG 可以理解为 `Judge-Fan Elimination Gap`，用来量化评委偏好和粉丝偏好之间的淘汰偏差。一个简洁表述是比较“评委更支持谁”和“粉丝更支持谁”是否一致。

若把 bottom 2 中两位选手记为 \(a,b\)，定义评委分差和粉丝份额差：

$$
\Delta_J = \tilde J_a - \tilde J_b,
\qquad
\Delta_F = \tilde F_a - \tilde F_b.
$$

可把周级 JFEG 写成方向乘积的符号函数：

$$
\operatorname{JFEG}_t=\operatorname{sign}(\Delta_J)\cdot \operatorname{sign}(\Delta_F).
$$

其中：

- \(\operatorname{JFEG}_t=1\) 表示评委与粉丝方向一致；
- \(\operatorname{JFEG}_t=-1\) 表示评委与粉丝方向相反；
- 也可进一步按差值幅度定义连续版本。

在本项目语境里，更重要的是用它服务于“评委是否真的在逆着粉丝纠偏”。如果评委选择大多数时候都与粉丝高份额方向一致，则规则纠偏作用有限。

直觉解释：JFEG 衡量的是 `judge preference` 和 `fan preference` 之间到底是同向还是反向。

说明：仓库草稿更强调 DiffProb 和 FSAI，JFEG 在面试中可以按上述方向性定义讲清原理，不必强行编造未在主结果中单独汇报的数值。

### 2.4 二项检验：90.5% 偏好的统计显著性

问题是：评委在 `Judges' Save` 中救下“粉丝份额更高者”的比例为 90.5%，这是否只是随机现象？

设在所有 `Judges' Save` 场景中，共有 \(n\) 次决策，其中 \(k\) 次评委救下了粉丝份额更高者。原假设与备择假设为

$$
H_0:p=0.5,
\qquad
H_1:p>0.5.
$$

其中 \(p\) 是评委“偏向粉丝更高者”的真实概率。

样本比例为

$$
\hat p = \frac{k}{n}=0.905.
$$

在 \(H_0\) 下，

$$
K\sim \operatorname{Binomial}(n,0.5).
$$

单侧 p 值为

$$
p\text{-value}=P(K\ge k\mid n,0.5)=\sum_{j=k}^{n}\binom{n}{j}0.5^n.
$$

若 p 值很小，则说明“90.5% 只是随机波动”这个解释不成立。

面试说法：即使不知道精确的 \(n\)，只要样本量不极小，90.5% 相比 50% 的偏离已经非常大，统计上通常会显著。

直觉解释：如果评委真是在随机二选一，长期看不可能稳定地有 90.5% 都偏向同一类选手。

### 2.5 “规则失效”结论的推导逻辑

逻辑链如下：

1. `Judges' Save` 的制度目标是让评委把技术更好的选手救回来。
2. 若规则有效，评委的选择应经常与粉丝偏好不同，体现 professional correction。
3. 但数据表明，评委有约 90.5% 的概率救下粉丝份额更高的选手。
4. 因此评委大多数时候并没有纠偏，而是在追认已有的人气优势。

所以“失效”并不是说规则完全没影响，而是说它没有实现设计初衷中的那部分纠偏功能。

直觉解释：它看起来像是评委在救技术，但结果更像是在替高人气选手背书。

### 2.6 Rank vs Percentage：比较框架

两种方法定义：

- Rank-based：把评委排名和粉丝排名相加；
- Percentage-based：把评委得分占比和粉丝投票占比直接相加。

比较维度可以统一成三层：

| 维度 | Rank-based | Percentage-based |
| --- | --- | --- |
| 信息粒度 | 只保留顺序信息 | 保留份额强弱信息 |
| 对极端差距的敏感性 | 低 | 高 |
| 对粉丝信号的机械放大 | 更强 | 相对更弱 |
| 结果稳定性 | 较弱 | 较强 |

草稿分析中给出 FSAI 方向性结论：Percentage 相对压缩粉丝信号，Rank 机械上更放大粉丝投票影响。

直觉解释：Rank 只看名次，所以把“第一名领先很多”和“第一名只领先一点”都当成一样；Percentage 能保留这种幅度差异。

### 2.7 Task 2 面试常见追问速查

| 追问 | 简答 |
| --- | --- |
| 10.2% 分歧率大不大？ | 对制度评估来说不小，因为它表示约每 10 周就有 1 周会因为换规则而换掉一个人。 |
| 为什么要用二项检验？ | 因为每次 Judges' Save 可以看成“是否偏向粉丝高者”的 Bernoulli 事件。 |
| 规则失效是不是太绝对？ | 更准确说法是“纠偏目标未达成”，不是说规则完全不起作用。 |

## Task 3 · 混合效应模型

### 3.1 为什么用 linear mixed-effects model

Task 3 研究的问题是：职业舞伴、明星年龄和行业等因素，对评委打分与粉丝投票是否产生不同影响。数据天然有层级结构：

- level 1：选手-周观测；
- level 2：职业舞伴分组。

若忽略分组结构，直接用普通线性回归，会把同一舞伴带来的相关性误当成独立样本，低估标准误。于是使用 `linear mixed-effects model, LMM`：

$$
\mathbf{y}=X\beta+Zu+\varepsilon.
$$

其中：

- \(X\beta\) 是 fixed effects；
- \(Zu\) 是 random effects；
- \(\varepsilon\) 是残差项。

直觉解释：固定效应回答“某类特征整体上怎样影响结果”，随机效应回答“不同舞伴组之间有没有系统偏差”。

### 3.2 固定效应 vs 随机效应：核心区别

| 模型 | 适用问题 | 解释重点 | 本项目是否主用 |
| --- | --- | --- | --- |
| Fixed-effects model | 只关心总体平均效应，假设样本独立 | 年龄、行业、周次的平均影响 | 否 |
| Random-effects model | 只建组间随机波动，不强调具体协变量 | 舞伴之间的方差结构 | 否 |
| Mixed-effects model | 同时建协变量效应和组间异质性 | 总体规律 + 舞伴差异 | 是 |

固定效应：参数是每一类因素的总体平均影响，例如年龄每增加 1 岁对评委分的影响。

随机效应：参数不是给每位舞伴单独设固定系数，而是假设舞伴效应来自一个总体分布，例如

$$
u_p\sim \mathcal{N}(0,\sigma_u^2).
$$

这样既能建模组间差异，又不会因为每组样本太少而过拟合。

直觉解释：固定效应看“平均规律”，随机效应看“组别偏移”。

### 3.3 模型公式：\(y=X\beta+Zu+\varepsilon\)

评委模型：

$$
Y_{i,t}^{J} = \beta_0^J + \beta_{age}^J\,\text{Age}_i^{c} + \beta_{week}^J\,\text{Week}_t
+ \sum_k \beta_k^J\,\text{Industry}_{k,i} + u_{p(i)}^J + \varepsilon_{i,t}^J.
$$

粉丝模型：

$$
Y_{i,t}^{F} = \beta_0^F + \beta_{age}^F\,\text{Age}_i^{c} + \beta_{week}^F\,\text{Week}_t
+ \gamma Y_{i,t}^{J} + \sum_k \beta_k^F\,\text{Industry}_{k,i} + u_{p(i)}^F + \varepsilon_{i,t}^F.
$$

这里：

- \(Y_{i,t}^{J}\)：评委得分；
- \(Y_{i,t}^{F}=\log(\hat f_{i,t}+\epsilon)\)：对数粉丝份额；
- \(u_{p(i)}\)：舞伴随机截距；
- \(\gamma\)：表现向人气的转化率。

估计结果可快速引用：

- 评委模型中 `age_centered` 系数约 \(-0.0328\)；
- 粉丝模型中 `age_centered` 系数约 \(-0.00185\)；
- 粉丝模型中 `judge_score` 系数原模型下约 \(0.0037\)，不显著。

直觉解释：同一个明星特征，可能在“专业评价系统”和“粉丝投票系统”里表现出完全不同的方向和强度。

### 3.4 ICC：为什么能衡量“舞伴重要性”

组内相关系数 `intraclass correlation coefficient, ICC` 定义为

$$
\operatorname{ICC}=\frac{\sigma_u^2}{\sigma_u^2+\sigma_\varepsilon^2}.
$$

它表示总方差中有多少比例来自组间差异。在本题里，组就是职业舞伴，因此 ICC 越高，说明“和谁搭档”越重要。

数值计算示例：

评委模型中

$$
\sigma_{u,J}^2=0.0951,\qquad \sigma_{\varepsilon,J}^2=0.9074,
$$

所以

$$
\operatorname{ICC}_J=
\frac{0.0951}{0.0951+0.9074}
\approx 0.0949=9.5\%.
$$

粉丝模型中

$$
\sigma_{u,F}^2=0.0141,\qquad \sigma_{\varepsilon,F}^2=0.0508,
$$

所以

$$
\operatorname{ICC}_F=
\frac{0.0141}{0.0141+0.0508}
\approx 0.2177=21.8\%.
$$

进一步有

$$
\frac{\operatorname{ICC}_F}{\operatorname{ICC}_J}
\approx \frac{0.2177}{0.0949}\approx 2.3.
$$

这就是“舞伴对粉丝的影响约为对评委的 2.3 倍”。

直觉解释：如果 ICC 高，说明同一舞伴带的选手在结果上更像彼此，舞伴身份本身就更有解释力。

常见追问：

- 问：为什么 ICC 可以解释成“舞伴重要性”？
  答：因为分组变量就是舞伴，ICC 就是在测由舞伴分组带来的方差占比。
- 问：ICC 高是不是因果关系？
  答：不是。ICC 是方差分解，不是严格因果识别，只能说相关结构更强。

### 3.5 BLUP：含义与用途

BLUP 是 `Best Linear Unbiased Prediction`，在线性混合模型里用于估计随机效应的条件期望：

$$
\hat u_p = E(u_p\mid \mathbf{y},\hat\beta,\hat\sigma^2).
$$

它给出每位职业舞伴在控制了固定效应之后的净偏移：

- 在评委模型中，\(\hat u_p^J\) 可解释为 `technical boost`；
- 在粉丝模型中，\(\hat u_p^F\) 可解释为 `popularity boost`。

用途：

- 对舞伴做排名；
- 比较“技术加成”和“流量加成”是否一致；
- 进行四象限分类，例如 `Kingmaker`、`Technician`、`Fan Favorite`、`Underperformer`。

直觉解释：BLUP 是“扣掉年龄、行业、周次这些平均因素后，这位舞伴还额外贡献了多少”。

### 3.6 双轨分层模型：为什么要分离技术评价与人气

如果把所有结果混在一个模型里，很容易把“技术能力”和“观众偏好”混为一谈。因此本项目做了双轨建模：

- Track 1：评委评分模型，代表技术评价系统；
- Track 2：粉丝投票模型，代表人气评价系统。

设计动机是 I3：把 `technical merit` 和 `popularity appeal` 分开建模，才能回答“同样一个因素在两套评价体系中是否方向相反”。

这一步直接导出了后面的 `Athlete Paradox` 和 PTFS 设计。

直觉解释：不把两条轨道拆开，就看不出节目到底是在奖赏技术，还是在奖赏人设与流量。

### 3.7 多重共线性：怎么诊断、怎么解释

Task 3 中最典型的共线性问题出现在 `judge_score` 和 `week`。因为随着周次推进，评委分数通常上升，所以两者高度相关。

诊断方法：

- 查看相关矩阵和 VIF；
- 做替代模型比较；
- 看核心系数在不同规格下是否翻转或显著性突变。

草稿结果显示：

- 原模型里 \(\gamma\approx 0.0037\)，不显著；
- 去掉 `week` 后，\(\gamma\approx 0.1613\)，显著；
- 加交互项后，`judge_score` 与 `judge_score × week` 都显著。

这说明 `week` 吸收了相当一部分“表现越好、留得越久”的联合效应。

直觉解释：粉丝不是完全不看表现，而是“表现”和“活得更久”这两个信号混在一起了。

常见追问：

- 问：共线性是不是让模型失效？
  答：不是，它让单个系数的解释更困难，但整体预测和方差分解仍然有价值。
- 问：怎么处理？
  答：做敏感性分析、报告替代规格、避免过度解读单一系数。

### 3.8 “运动员悖论”发现与解释

固定效应结果显示，`Athlete` 相对基准组 `Actor/Actress` 出现方向反转：

$$
\beta_{\text{Athlete}}^{J}\approx -0.1287,
\qquad
\beta_{\text{Athlete}}^{F}\approx +0.0521.
$$

这就是所谓 `Athlete Paradox`：运动员更容易获得粉丝支持，但在评委评分体系下反而吃亏。

因果解释链可以这样讲：

1. 运动员通常具备知名度、故事性和既有粉丝基础；
2. 粉丝投票更容易受身份认同和群众基础影响；
3. 评委评分更强调舞蹈表现、艺术表达和节目审美；
4. 因此运动员在“人气通道”里占优，在“专业通道”里未必占优。

再结合 ICC 结果：

- 评委 ICC 为 9.5%；
- 粉丝 ICC 为 21.8%。

说明粉丝系统中舞伴和外部形象的放大更强，这进一步支持“人气机制”不同于“技术机制”。

直觉解释：观众会为“熟悉且有故事的人”投票，评委则更像在打专业分。

### 3.9 statsmodels 实现要点

本项目用 `statsmodels` 的 `MixedLM` 实现混合效应模型，关键点包括：

- 先把年龄中心化，降低截距和年龄项相关性；
- 行业做 dummy encoding，设 `Actor/Actress` 为基准组；
- `re_formula="~1"` 表示随机截距模型；
- 仅保留观测数不少于 10 的舞伴，以保证随机效应估计稳定。

模型接口可概括成

```python
MixedLM.from_formula(
    formula="judge_score ~ age_centered + week + industry_*",
    groups="pro_partner",
    re_formula="~1",
    data=panel_df,
)
```

直觉解释：statsmodels 帮我们做的是“固定效应估计 + 方差分量估计 + 随机效应预测”的一体化求解。

### 3.10 Task 3 面试常见追问速查

| 追问 | 简答 |
| --- | --- |
| 为什么不用普通回归？ | 因为样本按舞伴分组，独立性假设不成立。 |
| 为什么不用贝叶斯层次模型？ | 四天赛题里频率学派 MixedLM 更快、更稳、更易解释。 |
| Athlete Paradox 是不是在说评委歧视运动员？ | 不能直接上升到歧视，更准确说法是两套评价系统偏好不同。 |

## Task 4 · 投票系统设计

### 4.1 社会选择理论背景：Arrow 不可能定理

Arrow's Impossibility Theorem 说明：当候选者不少于 3 人时，不存在一个排序制度能同时完美满足一组看似合理的公理，例如 `unrestricted domain`、`Pareto efficiency`、`independence of irrelevant alternatives`、`non-dictatorship`。

面试里不必展开严格证明，关键说法是：

- 投票系统设计没有“绝对完美解”；
- 只能在公平性、参与度、鲁棒性之间做 trade-off。

直觉解释：任何投票制度都会牺牲某些性质，所以 Task 4 不是找唯一正确答案，而是找更符合节目目标的折中方案。

### 4.2 PTFS 系统：公式与动机

PTFS 全称 `Progressive Technical Fairness System`。综合分定义为

$$
S_{i,t}=w_J(t)\tilde J_{i,t} + \bigl(1-w_J(t)\bigr)\tilde F_{i,t},
$$

其中：

- \(\tilde J_{i,t}\)：归一化评委分；
- \(\tilde F_{i,t}\)：估计粉丝份额；
- \(w_J(t)\)：随周次递增的评委权重。

动态权重采用线性递增：

$$
w_J(t)=w_J^{\text{start}}+
\bigl(w_J^{\text{end}}-w_J^{\text{start}}\bigr)\frac{t-1}{T-1}.
$$

最优参数来自网格搜索：

$$
w_J^{\text{start}}=0.45,
\qquad
w_J^{\text{end}}=0.80.
$$

设计动机：

- 赛季早期保留粉丝参与，维持节目热度；
- 赛季后期逐步提升技术权重，避免决赛阶段被纯人气绑架。

直觉解释：前期更像全民参与，后期更像专业选拔。

### 4.3 为什么选线性递增，而不是阶梯 / 指数函数

三种候选形式：

| 形式 | 优点 | 风险 |
| --- | --- | --- |
| 线性递增 | 平滑、可解释、参数少 | 可能不够灵活 |
| 阶梯函数 | 容易表达“赛制切换” | 权重突变，边界周不稳定 |
| 指数函数 | 后期强调技术更强 | 对参数很敏感，解释成本高 |

最终选线性递增的原因：

- 更符合节目周次逐步推进的叙事节奏；
- 参数只有起点和终点，面试里 30 秒就能讲清；
- 在网格搜索结果中表现稳定，不依赖尖锐调参。

直觉解释：线性方案不是最花哨的，但最稳、最好解释，也最适合四天比赛的工程条件。

### 4.4 多维评价框架：公平性 + 参与度 + 鲁棒性

Task 4 不只看一个指标，而是构造三维评价框架：

1. 公平性 `technical fairness`
2. 参与度 `engagement`
3. 鲁棒性 `robustness`

典型指标包括：

- Kendall's \(\tau\)：最终排名和技术排序的一致性；
- Mean Rank Deviation：名次偏移；
- Tech Top3 -> Final Top3：技术前三保留率；
- Close Call Rate：悬念度；
- `tau_std` 与 `consistent seasons`：跨赛季稳定性。

直觉解释：好制度不能只看“技术更公平”，还要看“观众愿不愿意看”以及“跨赛季稳不稳”。

### 4.5 Kendall's \(\tau\) 在系统评估中的应用

Task 4 里 Kendall's \(\tau\) 衡量“最终赛果”与“技术基准排序”是否一致。定义仍是

$$
\tau = \frac{C-D}{\binom{n}{2}}.
$$

它比 Pearson 更适合这里，因为：

- 我们关心的是排序而非线性幅度；
- 节目结果天然是 rank outcome；
- 对单调但非线性关系更鲁棒。

当前结果：

- Rank-based：\(\tau=0.6739\)；
- Percentage-based：\(\tau=0.7266\)；
- PTFS：\(\tau=0.7487\)。

直觉解释：\(\tau\) 越高，说明技术更好的选手最终排名越靠前。

### 4.6 显著性论证：PTFS \(\tau=0.749\), \Delta\tau=0.022, p=0.031

从 `system_comparison.json` 可直接引用：

$$
\tau_{\text{PTFS}}=0.748745,
\qquad
\tau_{\text{Pct}}=0.726611,
$$

所以

$$
\Delta\tau = 0.748745-0.726611=0.022134.
$$

对应显著性检验 p 值约为

$$
p=0.030827<0.05.
$$

原假设可以写为

$$
H_0:\Delta\tau\le 0,
$$

备择假设为

$$
H_1:\Delta\tau>0.
$$

因为 p 值小于 0.05，所以可以拒绝原假设，认为 PTFS 相比 Percentage-based 在技术公平性上有统计显著提升。

直觉解释：0.022 看起来不大，但在跨 34 个赛季的制度比较里，这是稳定且显著的结构性改进，不是随机抖动。

### 4.7 Close Call Rate 79.1%：悬念度指标

`Close Call Rate` 用于衡量比赛是否保有悬念。一个自然定义是：若某周前两名综合分差距低于某个小阈值，则记为 close call。可写成

$$
\operatorname{CCR}=
\frac{1}{T}\sum_{t=1}^{T}
\mathbb{I}\{S_{(1),t}-S_{(2),t}<\delta\}.
$$

这里 \(S_{(1),t}\) 与 \(S_{(2),t}\) 是周内前两名综合分，\(\delta\) 为预设阈值。

结果对比：

- Rank-based：30.2%；
- Percentage-based：66.1%；
- PTFS：79.1%。

解释：PTFS 不仅提高了技术公平性，还让更多周次保持“接近局面”，节目观感更强。

直觉解释：好制度不是一边倒，而是让强者更公平地赢，同时观众觉得结果还有悬念。

### 4.8 参数调优：网格搜索怎么做

Task 4 使用 `grid search` 在参数空间中搜索最优配置。核心参数包括：

- `judge_weight_start`：\(0.35,0.4,0.45,0.5\)
- `judge_weight_end`：\(0.6,0.65,0.7,0.75,0.8\)
- `improvement_alpha`
- `protection_threshold`

对每组参数，计算综合目标函数分数。当前最优参数为：

- `judge_weight_start = 0.45`
- `judge_weight_end = 0.80`
- `improvement_alpha = 0.0`
- `protection_threshold = 0.0`

灵敏度分析显示，`judge_weight_end` 在 0.75 到 0.80 附近表现都较稳定，说明不是极端尖点最优。

直觉解释：网格搜索让我们不是“拍脑袋调权重”，而是在明确指标体系下系统比较。

### 4.9 与 baseline 的定量对比表

| 指标 | Rank-based | Percentage-based | PTFS |
| --- | --- | --- | --- |
| Kendall's \(\tau\) | 0.6739 | 0.7266 | **0.7487** |
| Spearman \(\rho\) | 0.8147 | 0.8596 | **0.8758** |
| Tech Top3 -> Final Top3 | 59.8% | 71.6% | **72.5%** |
| Mean Rank Deviation | 1.613 | 1.349 | **1.262** |
| Tech Lowest Eliminated | 41.9% | 47.2% | **52.8%** |
| Close Call Rate | 30.2% | 66.1% | **79.1%** |
| Consistent Seasons | 91.2% | 94.1% | **97.1%** |

面试中的结论句可以直接说：PTFS 相比两个 baseline 同时提升了技术公平性、悬念度和跨赛季稳定性，其中相对 Percentage 的 \(\Delta\tau=0.022\) 仍然达到统计显著。

### 4.10 Task 4 面试常见追问速查

| 追问 | 简答 |
| --- | --- |
| 为什么你们敢改赛制？ | 因为前面三个 Task 已经证明原系统存在系统性偏差，Task 4 是基于证据的制度设计。 |
| 0.022 的 \(\tau\) 改进真的有意义吗？ | 在 34 个赛季上稳定出现且 p=0.031，属于小幅但显著的制度改进。 |
| PTFS 会不会压制观众参与？ | 不会，Close Call Rate 反而从 66.1% 提到 79.1%。 |

