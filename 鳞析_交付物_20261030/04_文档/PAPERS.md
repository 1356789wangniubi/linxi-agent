# 十篇论文阅读包

> 引用为最佳努力；正式提交前请核对 DOI/页码。

## 阅读顺序

1. **Fish Lateral Line Inspired Flow Sensors and Flow-aided Control: A Review** — 先看综述：建立侧线/传感器/控制的地图
2. **Lateral Line System of Fish** — 再看生物：表浅 vs 管道、行为功能
3. **The Flow Fields Involved in Hydrodynamic Imaging by Fish** — 再看水动力成像：障碍物流场怎么被感知
4. **Note on the Swimming of Slender Fish** — 再看游动理论：细长体/行波/推力
5. **Wake Mechanics for Thrust Generation in Oscillating Foils** — 再看尾流与 Strouhal：高效推进的涡结构
6. **Passive and Active Flow Control by Swimming Fishes and Mammals** — 再看被动/主动流控：三维鳍与涡
7. **On Dynamic Mode Decomposition: Theory and Applications** — 再看 DMD 理论：模态/重建/预测边界
8. **Dynamic Mode Decomposition of Numerical and Experimental Data** — 再看实验 DMD：噪声/采样/物理解释
9. **Dynamic Mode Decomposition with Control** — 再看 DMDc：有控制输入时怎么做
10. **A computational framework for Kármán gaiting in robotic fish: spatio-temporal perception and CPG-based reinforcement learning** — 最后看闭环：感知+CPG+RL 的 Kármán gaiting

## 每篇的问题—方法—结论—边界

### Fish Lateral Line Inspired Flow Sensors and Flow-aided Control: A Review

- 作者/年份：Zhai, Zheng, Xie (2021)
- 期刊：Journal of Bionic Engineering
- DOI：10.1007/s42235-021-0034-y

**问题**：鱼侧线为什么能感知流场？人工侧线做到什么程度？从传感走到控制还缺什么？

**方法**：综述生物侧线形态（表浅/管道神经丘）、人工流量传感器、阵列信号处理、趋流/避障控制。

**结论**：侧线的关键不是单点传感器，而是阵列 + 带通/降噪 + 解码；人工系统在实验室能做源定位/趋流，但标定、噪声、自身运动、sim-to-real 仍是瓶颈。

**边界**：综述不是某个具体鱼/具体工况的精度证明；不同论文的传感器、鱼体、流场不可直接比。

**对本项目**：我们的 404 表面压力阵列只是“密集压力代理”，不是已验证的表浅神经丘；回答时必须区分“压力点”与“神经丘信号”。

- **我为什么要先读这篇？** 它给你一张地图：侧线是什么、传感器怎么分类、控制链条有哪些环节。先有地图，再读单篇才不会迷路。
- **这篇能证明我的阵列有效吗？** 不能。它只能说明“阵列+解码”是合理路线；你的阵列是否有效，要做传感层对照和任务层验证。

### A computational framework for Kármán gaiting in robotic fish: spatio-temporal perception and CPG-based reinforcement learning

- 作者/年份：Wang et al. (2026)
- 期刊：Bioinspiration & Biomimetics
- DOI：10.1088/1748-3190/ae8e13

**问题**：机器鱼如何在卡门涡街里“借力”游动？感知、CPG 节律和强化学习怎么耦合？

**方法**：用时空侧线感知（STP）+ CPG 生成节律 + TD3 强化学习，在涡街里学步态/站位。

**结论**：感知与控制的联合设计能让机器鱼在尾流中稳定获益；但训练依赖仿真，sim-to-real 与感知噪声仍是关键风险。

**边界**：这是特定机器鱼/特定涡街的框架，不是所有鱼、所有来流都成立；RL 策略不能直接外推到新几何。

**对本项目**：我们的 forward/阵列是简化感知模型，没有 CPG/RL 闭环；可以借它的“感知-节律-控制”分层讲路线，但不能声称已实现。

- **这篇和我的侧线仿真什么关系？** 它把“侧线阵列→状态估计→CPG/RL→游动”串成闭环；你现在只做到“阵列→信号→定位”这一段。
- **我能直接复现吗？** 不能直接复现：需要机器鱼模型、CPG、RL 训练环境和涡街流场；可以先用它的分层做架构图。

### On Dynamic Mode Decomposition: Theory and Applications

- 作者/年份：Tu, Rowley, Luchtenburg, Brunton, Kutz (2014)
- 期刊：Journal of Computational Dynamics
- DOI：10.3934/jcd.2014.1.391

**问题**：如何从高维时序数据里提取相干的时空模态，并用于重建/预测？

**方法**：把数据矩阵写成线性算子 A 的作用，用 SVD + 最小二乘求 A 的低阶近似；给出 DMD 与 Koopman/Arnoldi 的关系。

**结论**：DMD 能提取频率/增长率和空间模态；但它本质是线性近似，非线性、瞬态、控制输入都需要扩展。

**边界**：DMD 不是“任意未来都能预测”的模型；预测能力取决于数据、模态数、噪声和工况。

**对本项目**：我们用它做 2 Hz 窗内重建；窗外预测失败是具体配置的结果，不能推广成“所有 DMD/DMDc 都不能预测”。

- **DMD 的模态是什么？** 可以理解为一组具有固定频率/增长率的空间结构；它们叠加起来逼近原始数据。
- **为什么 DMD 会失败？** 线性假设、模态截断、噪声、非定常/瞬态、控制输入、工况变化都会让它在窗外失效。

### Dynamic Mode Decomposition of Numerical and Experimental Data

- 作者/年份：Schmid (2010)
- 期刊：Journal of Fluid Mechanics
- DOI：10.1017/S0022112009992611

**问题**：DMD 能不能从实验/数值流场里提取有物理意义的相干结构？

**方法**：从快照序列构造伴随/线性算子，求特征值与模态；用于剪切流、尾流等。

**结论**：DMD 能给出频率排序的模态，但实验噪声、采样、边界和处理选择会显著影响结果。

**边界**：模态的物理意义需要额外验证；不要把数学模态直接当“涡”。

**对本项目**：我们报告的模态/频率需要和数据预处理、探针布置一起说明；不能只看一个 R²。

- **DMD 模态等于涡吗？** 不等同。模态是数据里的相干结构，可能是涡、剪切层、噪声或混合；需要物理判据。
- **实验数据要注意什么？** 采样率、噪声、缺失、边界、窗口长度都会改变模态；先做预处理敏感性分析。

### Dynamic Mode Decomposition with Control

- 作者/年份：Proctor, Brunton, Kutz (2016)
- 期刊：SIAM Journal on Applied Dynamical Systems
- DOI：10.1137/15M1013857

**问题**：有控制输入时，DMD 怎么把“系统自身演化”和“输入驱动”分开？

**方法**：把快照写成 x_{k+1}=A x_k + B u_k，联合辨识 A/B；讨论可辨识性与输入设计。

**结论**：DMDc 能分离 A/B，但输入必须被测量/设计得足够丰富；否则 A/B 不可辨识。

**边界**：没有输入记录、输入不独立、非线性强时，DMDc 也会失败。

**对本项目**：如果以后把“鱼体摆动/来流”当控制输入，应走 DMDc，而不是普通 DMD；我们现在没有输入矩阵。

- **DMDc 比 DMD 强在哪？** 它显式建模控制输入，能做“如果施加这个输入会怎样”的反事实分析。
- **我需要什么数据？** 每个时刻的状态 + 对应输入；输入要足够变化，不能一直恒定。

### Note on the Swimming of Slender Fish

- 作者/年份：Lighthill (1960)
- 期刊：Journal of Fluid Mechanics
- DOI：10.1017/S0022112060000496

**问题**：细长鱼体做行波摆动时，推力/功率怎么估算？

**方法**：细长体理论：把鱼体视为细长梁，用体波运动学和反作用力/阻力分解估算推力。

**结论**：体波波长、频率、振幅和来流决定推力/效率；细长、无黏、小振幅是前提。

**边界**：不适用于短粗体、大振幅、强涡/分离、复杂鳍面；不能替代 CFD/实验。

**对本项目**：我们的 Lighthill 型拟合只是压力行波拟合，不是完整推力模型；不能用它宣称推进效率。

- **Lighthill 模型需要什么输入？** 体波运动学（波长、频率、振幅）+ 来流 + 细长体假设；不是只给压力场。
- **为什么我的拟合 R² 低？** 可能不是稳定行波、包含瞬态/多模态、体波未测、或压力与体波相位不一致。

### Wake Mechanics for Thrust Generation in Oscillating Foils

- 作者/年份：Triantafyllou, Triantafyllou, Gopalkrishnan (1991)
- 期刊：Physics of Fluids A
- DOI：—

**问题**：摆动翼/鱼尾的推力与尾流涡结构有什么关系？最佳频率在哪？

**方法**：实验/理论分析摆动翼的尾流涡街、推力系数与 Strouhal 数。

**结论**：高效推进常对应 Strouhal 数约 0.25–0.35 的反卡门涡街；频率/振幅偏离会改变涡模式。

**边界**：最佳区间依赖翼型/振幅/来流/雷诺数；不能把 0.3 当万能常数。

**对本项目**：如果分析鱼尾/摆动翼，应同时报 Strouhal 数、振幅和来流；只看压力 R² 不够。

- **Strouhal 数怎么算？** St = f·A/U，f 是摆动频率，A 是尾缘峰峰振幅，U 是来流。
- **St=0.3 一定最好吗？** 不是。它是一个常见高效区间，具体最优值取决于翼型、振幅、雷诺数和推进模式。

### Passive and Active Flow Control by Swimming Fishes and Mammals

- 作者/年份：Fish, Lauder (2006)
- 期刊：Annual Review of Fluid Mechanics
- DOI：10.1146/annurev.fluid.38.050304.092201

**问题**：鱼和海洋哺乳动物如何用身体/鳍被动或主动控制流场？

**方法**：综述实验流体力学：体波、鳍、尾流、涡控制、能量节省。

**结论**：鱼用多尺度结构（体、鳍、鳞）主动/被动控制涡；推进与感知是耦合的。

**边界**：物种/形态差异大；不能把一种鱼的结论直接套到另一种鱼。

**对本项目**：我们的二维单鱼模型只覆盖中截面；鳍/三维效应/鳞片都没建，回答要说明边界。

- **为什么我的二维模型和实验差很多？** 二维忽略了三维鳍、展向流动、鳞片和黏性；实验还有被动变形。
- **这条鱼算什么游动模式？** 需要看体波波长/振幅、鳍使用和尾迹；仅凭外形不能判定。

### Lateral Line System of Fish

- 作者/年份：Bleckmann, Zelick (2009)
- 期刊：Integrative Zoology
- DOI：10.1111/j.1749-4877.2008.00136.x

**问题**：鱼类侧线的解剖、生理和行为功能是什么？

**方法**：综述神经丘结构、表浅/管道两类、毛细胞/顶帽、行为实验。

**结论**：表浅神经丘偏局部流速/高频，管道神经丘偏压力梯度/低频；侧线用于趋流、避障、捕食、集群。

**边界**：不同鱼种、不同发育阶段差异大；不能把某一物种的参数当通用值。

**对本项目**：我们的表面压力点既不是表浅流速，也不是管道压差；要做传感模型才能称为“侧线”。

- **表浅和管道神经丘怎么选？** 看你要测什么：局部流速/高频用表浅模型；压力梯度/低频/降噪用管道模型。
- **侧线能测多远？** 近场为主，随流场衰减；不是远程声呐。具体距离取决于源强度、背景噪声和鱼体。

### The Flow Fields Involved in Hydrodynamic Imaging by Fish

- 作者/年份：Windsor, Norris, Cameron, Mallinson, Montgomery (2010)
- 期刊：Journal of Experimental Biology
- DOI：10.1242/jeb.038075

**问题**：鱼如何从自己游动产生的流场变化中“成像”障碍物？

**方法**：用粒子图像测速/数值模拟分析鱼靠近障碍物时的流场畸变与侧线响应。

**结论**：障碍物会在鱼体附近产生可测的流场畸变；侧线阵列可以从中提取距离/位置线索。

**边界**：成像依赖自身运动、障碍物形状/距离、背景流；不是无源、全天候的“视觉替代”。

**对本项目**：我们的 obstacle 基线是特征分类，不是水动力成像；没有真实障碍数据不能报准确率。

- **侧线能“看见”障碍物吗？** 能感知流场畸变并推断障碍物，但不是光学成像；分辨率和距离都受流场限制。
- **为什么需要主动游动？** 鱼自身运动产生照明流场；静止时障碍物不一定产生足够信号。
