# 鳞析 · 鱼类侧线仿真助手

> 一个本地运行的**鱼类侧线仿真问答智能体**：问侧线是什么、怎么仿真、表浅/管道神经丘、
> 阵列怎么布置、偶极子/涡怎么感知，它用自然语言回答；也能查这条鱼的数据、画侧线信号。

这个目录是一个可以独立运行的 MVP：**聊天界面 + 侧线知识库 + 最小仿真 + 这条鱼的数据/护栏**。
直接双击 `chat.bat` 就能用。

---

## 30 秒跑起来

```powershell
# 0) 装依赖（首次）
python -m pip install -r requirements.txt

# 0.5) 聊天界面（像豆包；双击 chat.bat 也行）
python -m fishflow.chat_server

# 0.6) 智谱 GLM（先 secret_setup 录入 key；双击 chat_zhipu.bat 也行）
python -m fishflow.secret_setup
python -m fishflow.llm_check

# 1) 建索引（只需一次，约 45 秒；已建好可跳过）
python -m fishflow.build_index

# 2) 三个金牌问答 + 生成报告
python -m fishflow.demo

# 交互模式
python -m fishflow.repl

# 3) 单问
python -m fishflow.cli diagnose --question "DMD 能不能外推到 25 秒之后？"

# 4) 查数据
python -m fishflow.cli query --probe 17 --t0 0.1 --t1 0.2

# 5) 出图
python -m fishflow.cli field --t 0.2 --q p --out outputs/field.png

# 6) 出报告
python -m fishflow.cli report

# 7) 跑 15 题路由评测
python -m fishflow.eval

# 8) 物理模型（可运行包）对比
python -m fishflow.cli compare --physical --quantity p --trim 24

# 9) 跑新工况（隔离副本；1 s 物理时间：2 Hz 约 105 s、3 Hz 约 216 s）
python -m fishflow.cli run --freq 3.0 --t-end 1.0 --dt 0.001 --progress

# 10) 闭环研究：定位→对比→判定→写记录
python -m fishflow.cli research --freq 3.0
python -m fishflow.cli research-log
```

## 它回答什么

| 主题 | 例子 |
|---|---|
| 侧线基础 | 侧线是什么？能感知什么？ |
| 两类神经丘 | 表浅和管道神经丘有什么区别？ |
| 仿真流程 | 鱼类侧线怎么仿真？分几步？ |
| 传感模型 | 顶帽/管道/噪声/带宽怎么建模？ |
| 阵列设计 | 侧线阵列怎么布置？几个传感器？ |
| 偶极子/涡 | 偶极子源怎么定位？侧线能感知涡吗？ |
| 机器鱼 | 人工侧线/机器鱼怎么实现？ |
| 数据 | 我的 404 探针能当侧线用吗？ |
| 直接画图 | “给我看一个侧线信号” → `ll_dipole.png` |
| 查询解释 | “这个数据怎么来的？”“这个峰值是什么？” |
| 计算分析 | “画 t=2s 压力云图”“算涡位置”“画多模态涡量场”“画物理模型真涡量场”“拟合 Lighthill” |
| 控制仿真 | “给定来流速度 0.3 m/s，预测侧线输出” |
| 图片→仿真 | 参数卡里上传鱼图 → 轮廓 → H/L → 仿真 |
| **引导仿真** | “我给你一条鱼，帮我做侧线仿真” → 参数卡 → 四联图 |

> 如果 `run.py` 产出了新表，重建索引：
> `python -m fishflow.build_index --src <new.tsv> --out data/index`（表头需同为 7 列）。

完整功能清单见 [FEATURES.md](FEATURES.md)。

产物：

- `outputs/guard_report.html` — 证据化报告（含图、指标、问答、溯源）
- `outputs/figs/overview.png` — 表面压强 + 沿弦分布 + 两口径指标
- `outputs/figs/metrics.png` — dmd_v2 vs dmd_old 的 A/B 指标
- `data/index/` — 404 个探针的 Parquet 分片（20,119,200 行）

---

## 它拦住的三个错误
| 错误 | 它怎么拦 |
|---|---|
| 把 A 口径（形状）当成 B 口径（绝对） | 回答“准不准”必须同时给 A/B 和 RMSE；p 的 A=0.9936、B=0.8684 就是反例 |
| 拿 DMD 去预测未来/新工况 | 直接拒绝：留出测试 R²=−7.11，换任何阶数都一样；改推物理模型（R² 0.61，可外推） |
| 把启动瞬态、复位帧、鼻尖尖点混进拟合 | 强制声明时间窗；t<0.1 s、t=25.0、探针 0/202 必须剔除或标注 |

---

## 物理模型（可运行包）

`可运行/` 是自包含的二维非定常面元法包，跑 1 s 物理时间：2 Hz 约 105 s、3 Hz 约 216 s，产出
1,001 帧 × 404 探针（`probe_table.tsv`）。它和 `交付包/03_对照数据表/物理模型_老师格式.tsv`
**逐位相同**（Time/X/Y/p/u_x/u_y 最大差 0.0）。

```powershell
python -m fishflow.build_index --src "可运行\probe_table.tsv" --out data/index_physical
python -m fishflow.cli compare --physical --quantity p --trim 24
```

- 全 404 探针：A=0.176、B=0.002、RMSE=1.76；
- 剔除鼻尖/尾缘各 24（308 探针）：A=0.443、B=0.008、RMSE=1.84；
- 这与文档的 0.177/0.416 一致——低 R² 是**无黏 + 尖点奇异**的已知边界，不是 bug。

**跑新工况**：`runner.py` 把源码复制到 `data/runs/<id>/pkg` 再跑，
不会覆盖 `可运行/`；跑完自动建索引并对比。

```powershell
python -m fishflow.cli run --freq 3.0 --t-end 1.0 --dt 0.001 --progress
python -m fishflow.cli run-status
python -m fishflow.cli runs
```

1 s 物理时间：2 Hz 约 105 s、3 Hz 约 216 s；`freq≠2.0` 时与 DMD 的对比只说明“DMD 不能外推”，
不是物理模型的精度。

- **在 DSH 里**：用后台 job + `--progress`（进度行会进 job 输出）；不要用 `--background`，
  沙箱的 job object 可能杀掉脱离进程。
- **普通终端**：`--background` 可用，返回 `run_id`，再用 `run-status` / `runs` 查进度。

细节见 [RUN_INTEGRATION.md](RUN_INTEGRATION.md)。

## 架构

```
交付包/02_主数据表 (1.86 GB TSV)
        │  build_index.py（92 秒）
        ▼
data/index/probe_0000..0403.parquet   ← 单探针查询 3–5 ms（热）
        │
        ▼
fishflow.store  →  query / frame_at
        │
        ├── fishflow.metrics      A/B/RMSE 权威指标
        ├── fishflow.compare      DMD vs 可运行物理模型
        ├── fishflow.knowledge    15 条护栏（10 个坑 + 4 条须知 + 数据源）
        ├── fishflow.diagnose     关键词路由 + 证据引用
        ├── fishflow.plots        表面场/时序/指标图
        └── fishflow.report       HTML + Markdown 报告
        │
        ▼
fishflow.cli（JSON 输出）  ←  DSH skill 通过 shell 调用
```

**为什么是 Parquet 分片**：原始表 1.86 GB、2,000 万行，按探针拆成 404 个文件后，
单探针查询只读一个小文件；热查询 3–5 ms，冷启动约 0.5–0.9 s（首次读盘）。

---

## 在 DSH 里用它

把本目录作为 DSH 的 workspace，启动 `dsh web` 后，`fishflow-guard` skill
会出现在技能目录里。然后直接问：

> “用 fishflow-guard 回答：p 的 R² 都 0.99 了，为什么还说压强不准？”

skill 会让 agent 调用：

```powershell
python -m fishflow.cli diagnose --question "..."
```

并把 JSON 里的 `answer / evidence / guardrail` 原样引用，禁止自己编数字。

配置示例见 [`dsh/SETUP.md`](dsh/SETUP.md)。

---

## 目录

| 路径 | 作用 |
|---|---|
| `fishflow/build_index.py` | TSV → 404 个 Parquet 探针分片 + manifest |
| `fishflow/store.py` | 查询、取帧、几何 |
| `fishflow/metrics.py` | A/B/RMSE、权威指标 |
| `fishflow/compare.py` | DMD vs 物理模型（可运行包）对比 |
| `fishflow/runner.py` | 隔离副本跑新工况 → 建索引 → 对比 |
| `fishflow/research.py` | 闭环研究：定位→对比→护栏判定→写记录 |
| `fishflow/repl.py` | 交互模式（`/q /compare /research /report`） |
| `fishflow/knowledge.py` | 15 条护栏知识（全部带出处） |
| `fishflow/diagnose.py` | 问题 → 护栏路由 |
| `fishflow/plots.py` | 图 |
| `fishflow/report.py` | HTML/Markdown 报告 |
| `fishflow/provenance.py` | 追加式证据日志 `data/provenance.jsonl` |
| `fishflow/cli.py` | JSON CLI |
| `fishflow/mcp_server.py` | 无依赖 stdio MCP server（6 个工具） |
| `fishflow/eval.py` | 15 题路由评测（当前 15/15） |
| `fishflow/demo.py` | 三问演示 |
| `.dsh/skills/fishflow-guard/SKILL.md` | DSH 技能 |
| `dsh/SETUP.md` | DSH 本地模型/校内 API 配置 |
| `RUN_INTEGRATION.md` | 可运行包的一致性验证与对比结果 |
| `FEATURES.md` | 当前能实现的功能清单 |
| `PAPERS.md` | 十篇论文阅读包（问题/方法/结论/边界/对本项目） |
| `SECURITY.md` | 智谱 key 的 DPAPI 存储与轮换 |

---

## 边界（有意不做）

1. **不重跑 DMD**：交付包没有当时的拟合脚本；本 MVP 只分析已交付的 DMD 表。
2. **不读老师原始仿真数据**：只用 `02_主数据表` 与 `06_指标`；原始数据 1.81 GB 不外传。
3. **不承诺“一键启动”**：`交付包/07_代码/run.py` 依赖缺失模块（`verify_package.py`、`fish_model.py`），
   本目录不碰它，避免和你的修改冲突。
4. **不做通用科研 agent**：只服务这条鱼、这份数据、这套方法。

---

## 比赛口径（一句话）

> **别的队伍让 AI 回答问题；我们让 AI 把一次研究做对，并且每一步都能查。**
