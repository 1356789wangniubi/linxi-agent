# 现在能实现的功能（v0.1）

> 每一条都能在本地跑；命令都在 workspace 根目录执行。

## A0. 鱼类侧线问答（主入口）

| 功能 | 怎么用 | 状态 |
|---|---|---|
| 侧线是什么 / 两类神经丘 | 聊天问“侧线是什么？” | ✅ |
| 仿真流程 / 传感模型 / 阵列 | 聊天问“侧线怎么仿真？” | ✅ |
| 偶极子 / 涡 / 源定位 | 聊天问“偶极子源怎么定位？” | ✅ |
| 直接画侧线信号 | 聊天说“给我看一个侧线信号” | ✅ `ll_dipole.png` |
| 404 探针当侧线 | 聊天问“我的 404 探针能当侧线用吗？” | ✅ `ll_from_probes.png` |
| **引导式仿真** | 聊天说“我给你一条鱼，帮我做侧线仿真” | ✅ 参数卡 → 四联图 + SNR/定位误差 |
| **图片→轮廓→仿真** | 参数卡里上传鱼图 | ✅ `fish_contour.png` + 仿真图 |
| **多模态涡量场** | “画多模态涡量场” | ✅ 压力/速度/涡量代理三合一 |
| **真涡量场** | “画物理模型的真涡量场” | ✅ 面元速度 → 170×120 网格 → ω_z |
| **十篇论文** | “十篇论文是哪十篇？” / “Tu 2014 的 DMD 局限？” | ✅ `PAPERS.md` + 论文问答 |
| **引导思考** | “带我走一遍” / “我该怎么开始？” | ✅ 5 步思考框架 |
| **检验我的仿真** | 说“检验我的仿真” → 上传 CSV | ✅ A/B/RMSE + 四联图 |
| **口述/粘贴数据** | 直接贴 `t=..., probe=..., p=...` | ✅ 生成 CSV + 直接检验 |
| **示例数据** | “帮我生成一份示例数据” | ✅ 带 synthetic 标记，不冒充实测 |
| **错因自查** | 问“我的数据哪里错了”/校验结果异常 | ✅ 多条假设 + 证据 + 自查 + 修法 |
| **坐标查压强/速度** | `/point` 输入 x/y/t | ✅ 鱼体 404 探针 + 点选 + 时间曲线 |
| **查询解释** | “这个数据怎么来的？”“这个峰值是什么？” | ✅ meta / origin / peak |
| **计算分析** | “画 t=2s 压力云图”“算侧线感知的涡位置”“拟合 Lighthill” | ✅ 云图 / 涡代理 / 行波拟合 |
| **控制仿真** | “给定来流速度 0.3 m/s，预测侧线输出” | ✅ 正向模型 |
| 知识边界 | 概念性知识 + 最小解析模型，不冒充 CFD | ✅ |

## A. 数据查询与可视化

| 功能 | 命令 | 状态 |
|---|---|---|
| 环境自检 | `python -m fishflow.cli doctor` | ✅ |
| 索引信息 | `python -m fishflow.cli manifest` | ✅ |
| 单探针时序（DMD） | `query --probe 17 --t0 0.1 --t1 0.2 --q p` | ✅ 3–5 ms（热） |
| 单探针时序（物理） | `query --dataset physical_run --probe 100 --t0 0.1 --t1 0.2` | ✅ |
| 表面场图 | `field --t 0.2 --q p --out outputs/field.png` | ✅ |
| 时序图 | `series --probe 100 --q p --t0 0.1 --t1 0.5 --out outputs/series.png` | ✅ |
| 压强动画 | `python -m fishflow.animate` | ✅ GIF |

## B. 方法学护栏（核心）

| 功能 | 命令 | 状态 |
|---|---|---|
| 问题路由到护栏 | `diagnose --question "..."` | ✅ 15 条 |
| A/B 口径 | 问“p 的 R² 0.99 为什么还不准？” | ✅ |
| DMD 外推拒绝 | 问“DMD 能不能外推到 25 秒后？” | ✅ |
| u_x 卡 0.83 排查 | 问“u_x 为什么卡在 0.83？” | ✅ |
| 瞬态/复位帧 | 问“首帧要不要剔除？” | ✅ |
| 尖点探针 | 问“探针 0 和 202 为什么特殊？” | ✅ |
| 物理 vs DMD | 问“物理模型和 DMD 差多少？” | ✅ |
| 单位/数据源/边界 | 对应问题 | ✅ |

## C. 对比与评测

| 功能 | 命令 | 状态 |
|---|---|---|
| 权威 A/B/RMSE | `compare` | ✅ dmd_v2 / dmd_old |
| 物理 vs DMD | `compare --physical --quantity p --trim 24` | ✅ A=0.176(404) / 0.443(308) |
| 15 题路由评测 | `python -m fishflow.eval` | ✅ 15/15 |
| 侧线问答评测 | `python validation/lateral_eval.py` | ✅ 17/17 |
| 冒烟测试 | `python tests/test_guard.py` | ✅ 全过 |
| 开发者自测日志 | `python validation/selftest.py` | ✅ 6/6 |

## D. 跑物理模型（新工况）

| 功能 | 命令 | 状态 |
|---|---|---|
| 隔离副本运行（带进度） | `run --freq 3.0 --t-end 1.0 --dt 0.001 --progress` | ✅ 1 s/216 s |
| 后台运行（普通终端） | `run ... --background` | ⚠️ DSH 沙箱可能杀脱离进程 |
| 查运行状态 | `run-status [run_id]` | ✅ |
| 历史运行 | `runs` | ✅ |
| 自动建索引 + 对比 | `run` 内置 | ✅ |

## E. 报告与证据

| 功能 | 命令 | 状态 |
|---|---|---|
| 单文件 HTML（图/动画内嵌） | `python -m fishflow.cli report` | ✅ 526 KB |
| Markdown 报告 | 同上 | ✅ |
| 证据日志 | `data/provenance.jsonl` | ✅ `ev-*` |
| 28 秒 demo reel | `python video/make_reel.py` | ✅ GIF |
| AVI / MP4（MJPEG） | `python video/make_video.py` | ✅ 8 MB |

## F. 智能体接入

| 功能 | 方式 | 状态 |
|---|---|---|
| DSH 技能 | `.dsh/skills/fishflow-guard/SKILL.md` | ✅ 已被目录发现 |
| CLI 工具 | `python -m fishflow.cli ...` | ✅ JSON 输出 |
| MCP 工具 | `python -m fishflow.mcp_server` | ✅ 10 个 |
| 本地模型 | DSH + Ollama | ✅ 配置示例 |
| 校内 API | 同一 provider 路由 | ✅ 配置示例 |
| 自然语言端到端 | 子 agent 实测 | ✅ 调用 CLI + 引用证据 |

## G. 验证与试用

| 功能 | 命令 | 状态 |
|---|---|---|
| 真实自测 | `validation/SELFTEST.md` | ✅ 6/6 |
| 试用工具包 | `validation/TRIAL_KIT.md` | ✅ 模板/问卷/分析脚本 |
| 试用分析 | `python validation/analyze_trial.py` | ✅（等真实数据） |
| 答辩一页纸 | `DEFENSE.md` | ✅ |

## H. 闭环研究（agent 核心）

| 功能 | 命令 | 状态 |
|---|---|---|
| 定位→对比→判定→写记录 | `python -m fishflow.cli research --freq 3.0` | ✅ 3 步自动 |
| 判定 | 返回 `BLOCK / WARN / PASS` | ✅ |
| 研究记录 | `outputs/research_<id>.md` + `data/experiments.jsonl` | ✅ |
| 历史记录 | `python -m fishflow.cli research-log` | ✅ |
| 新工况闭环 | `research --freq 3.0 --execute` | ✅（慢，走 run） |

实测：

- 3 Hz → **BLOCK**（频率不匹配；全 404 A=0.233、trim A=0.375、B=−0.023）；
- 2 Hz → **WARN**（trim A=0.443、B=0.008；尖点+无黏，不能称精度）。

## I. 交互性

| 方式 | 怎么用 | 状态 |
|---|---|---|
| **聊天界面**（鱼类侧线助手） | `python -m fishflow.chat_server` 或双击 `chat.bat` | ✅ |
| **对话**（DSH） | `dsh web`，自然语言多轮，工具调用可见 | ✅ |
| **REPL** | `python -m fishflow.repl`，`/q /compare /research /report` | ✅ |
| **CLI** | 一次性命令，JSON 输出 | ✅ |
| **交互式看板** | `outputs/flow_dashboard.html`（3D 旋转 / 探针 / 动画） | ✅ |
| **坐标→流场计算器** | `outputs/flow_calculator.html` | ✅ |
| **报告** | 单文件，顶部有“可交互”链接 | ✅ |

REPL 示例：

```text
鳞析> /q 17 0.1 0.2
鳞析> DMD 能不能外推到 25 秒之后？
鳞析> /research 3
鳞析> /report
```

## J. 现在**不能**做的

| 不能做 | 原因 |
|---|---|
| 重跑 DMD 拟合 | 交付包没有当时的拟合脚本 |
| 窗外预测 | DMD 本质不支持；物理模型也要新工况参考 |
| 通用科研 agent | 有意收窄到这条鱼/这套方法 |
| 真实用户试用数据 | 需要 5–10 位真人；**不编** |
| 高保真侧线 CFD | 当前只有解析偶极子 + 404 探针降采样，没有 3D 黏性 CFD |
| 真实侧线标定 | 没有实验/机器鱼标定数据，不能声称真实精度 |
| H.264 MP4 | 本机 ffmpeg 无 x264；只有 MJPEG |
| DSH 内 `--background` | job object 会杀脱离进程；用 `--progress` + 后台 job |

## 一句话

> **能查、能画、能对比、能跑物理模型、能出报告、能拒绝、能追溯。**
> 不能替你编用户日志，也不能把 DMD 变成预测模型。
