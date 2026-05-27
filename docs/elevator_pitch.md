# 美赛项目 Elevator Pitch

## 30 秒版（中文）

如果把这个项目压缩成一句话，就是：我们在没有真实观众投票数据的情况下，用贝叶斯推断和 MCMC 从淘汰结果反推隐藏投票份额，再用混合效应模型解释评委与粉丝偏好的差异，最后设计了一个更公平的投票系统。最终模型的淘汰重构准确率达到 93.49%，决赛排名 Kendall's \(\tau\) 达到 0.994，新系统 PTFS 把技术公平性提升到 \(\tau=0.749\)，而且改进显著。

开头 hook：这个题最难的地方不是建模，而是我们根本看不到最关键的观众投票数据。

结尾 takeaway：这是一个从隐藏投票推断走到机制优化的完整项目。

## 1 分钟版（中文）

这个项目来自 2026 MCM/ICM Problem C，研究 `Dancing with the Stars` 的投票机制。最难的地方在于节目公开了评委分数和淘汰结果，却没有公开真实观众投票，所以我们面对的是一个隐藏变量推断问题。

我们的工作分四个 Task。Task 1 把问题建模成 constrained Bayesian inverse problem，用自适应 Metropolis-Hastings 反推每周粉丝份额，重构准确率做到 93.49%，冠军识别率 100%，决赛 Kendall's \(\tau\) 达到 0.994。Task 2 评估规则效果，发现 Judges' Save 在 90.5% 的情况下救的是粉丝份额更高的人，而且 Rank 和 Percentage 两种聚合规则有 10.2% 的周次会导出不同淘汰者。Task 3 用双轨混合效应模型把技术评价和人气评价分开，发现了 Athlete Paradox，舞伴对粉丝投票的 ICC 是 21.8%，高于评委的 9.5%。Task 4 基于这些发现设计了 PTFS 动态权重系统，把技术公平性的 Kendall's \(\tau\) 从 0.7266 提升到 0.7487，\(\Delta\tau=0.022\)，并且 \(p=0.031\)。

我觉得这个项目最有价值的地方，不是某一个高精度数字，而是我们把隐藏偏好推断、机制解释和制度设计做成了完整链条。

开头 hook：我们不是在预测谁会红，而是在没有真实投票标签的情况下反推一整套隐藏机制。

结尾 takeaway：这个项目说明我不仅能做模型，还能把模型结果转成可解释、可落地的系统设计。

## 3 分钟版（中文）

这个项目研究的是《Dancing with the Stars》的投票机制，但它本质上不是娱乐节目题，而是一个典型的数据科学问题：关键标签缺失、规则复杂、结果必须可解释。

题目最棘手的地方是，节目公开了评委打分和淘汰结果，却没有公开真实观众投票。也就是说，我们真正想知道的变量是隐藏的。于是我们没有把它当成普通监督学习，而是把它重写成一个 constrained Bayesian inverse problem。核心思想是：如果某组粉丝投票份额和真实评委分数组合后，能够导出真实发生的淘汰结果，那么这组隐藏变量就是合理的；否则就不合理。基于这个思路，我们在 Task 1 里设计了带 simplex constraint、indicator likelihood、时间平滑先验和自适应步长的 Metropolis-Hastings 采样器。最后模型在 261 个有淘汰记录的周次里正确重构了 244 个，重构准确率是 93.49%，决赛排名 Kendall's \(\tau\) 是 0.994，冠军识别率是 100%。

有了隐藏投票份额之后，我们继续追问：评委评分和观众投票是不是同一套偏好机制？Task 2 先做规则评估，发现 Judges' Save 的制度目标是纠偏，但数据上它 90.5% 的时候救下的是粉丝份额更高的人，所以它并没有真正实现专业纠偏；同时 Rank 和 Percentage 两种规则有 10.2% 的周次会淘汰不同的人，说明规则选择会真实改变赛果。接着在 Task 3，我们用双轨混合效应模型把技术评价系统和人气评价系统拆开，结果发现 Athlete Paradox：运动员在评委模型里的系数是负的，但在粉丝模型里是正的。再结合 ICC 结果，舞伴对评委打分的解释比例是 9.5%，对粉丝投票的解释比例是 21.8%，也就是舞伴对粉丝系统的影响大约是评委系统的 2.3 倍。这说明节目并不是单一评价系统，而是技术和人气两套通道叠加后的混合机制。

最后我们把分析结果落到机制设计上。既然原有规则存在系统性偏差，我们就在 Task 4 设计了一个 Progressive Technical Fairness System，也就是 PTFS。它的核心公式是让评委权重随周次线性递增，前期更保留观众参与感，后期更强调技术公平性。通过网格搜索，我们得到最优参数是评委权重从 0.45 递增到 0.80。结果显示，PTFS 的技术公平性 Kendall's \(\tau\) 达到 0.7487，相比 Percentage-based 方法提升了 0.022，而且显著性检验给出 \(p=0.031\)。同时，它的 Close Call Rate 还有 79.1%，说明没有通过牺牲悬念来换公平。

如果总结这个项目，我最想强调三点。第一，这是一个完整的链条：从隐藏变量推断到机制解释，再到制度优化。第二，它体现的是跨层能力，不只是写一个模型，而是要把统计假设、工程实现和结果表达接起来。第三，这个项目让我很确定，好的数据科学工作不应该停留在“跑出一个分数”，而应该能回答“机制是什么、限制是什么、如果要改系统该怎么改”。

开头 hook：我们面对的不是“数据太少”，而是“最关键的数据根本看不到”。

结尾 takeaway：这不是一个单点模型项目，而是一个从概率推断走到机制设计的完整数据科学案例。

## 30 Seconds Pitch (English)

Our MCM project studied the voting mechanism of *Dancing with the Stars*. The key challenge was that the true fan votes were never published, so we formulated the problem as a constrained Bayesian inverse problem and used adaptive MCMC to infer hidden fan vote shares from judges' scores and elimination outcomes. The model achieved 93.49% reconstruction accuracy and a finale Kendall's \(\tau\) of 0.994. Based on those findings, we built a mixed-effects explanation layer and then designed a new voting system, PTFS, which improved technical fairness to \(\tau=0.749\) with statistically significant gain.

Hook: The hardest part was not prediction, but inference without ever seeing the true labels.

Takeaway: It was a full pipeline from hidden-variable inference to mechanism redesign.
