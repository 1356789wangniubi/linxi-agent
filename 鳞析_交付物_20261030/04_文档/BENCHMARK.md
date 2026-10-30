# 评测与性能（当前版本）

> 目的：证明“护栏 agent”不是口头承诺，而是可测的。所有数字在本机
> Windows / Python 3.14 / PyArrow 上实测。

## 1. 数据索引

| 项 | 值 |
|---|---|
| 源表 | `交付包/02_主数据表/probe_table_DMD_v2_trimmed.tsv`（1.86 GB） |
| 行数 | 20,119,200 |
| 帧数 | 49,800（dt=0.0005 s，t∈[0.1, 24.9995]） |
| 探针 | 404（上 202 + 下 202） |
| 分片 | 404 个 `probe_xxxx.parquet` + `manifest.json` |
| 索引大小 | 627.3 MB（zstd） |
| 建索引耗时 | 43.4 s（含读取、排序、写 404 个文件） |

## 2. 查询延迟

| 场景 | 延迟 |
|---|---|
| 单探针 0.1–0.2 s（201 点），冷启动 | 0.7–0.9 s |
| 同上，热查询 | **3–5 ms** |
| 取 404 探针的整帧（`frame_at`） | 0.42 s |
| 生成完整 HTML 报告（3 图 + 表 + 证据链） | **2.7 s** |

冷启动是首次读盘；演示时先跑一次 warm-up，后续都是毫秒级。

## 3. 路由评测（15 题）

`python -m fishflow.eval`：

```
OK  DMD 能不能外推到 25 秒之后？              dmd_no_extrapolation
OK  p 的 R² 都 0.99 了，为什么 RMSE 还这么大？  metric_ab
OK  u_x 为什么卡在 0.83？                     hankel_pitfalls
OK  首帧 p 幅度 2015，要不要剔除？             trim_rules
OK  探针 0 和 202 为什么特殊？                 cusp_probes
OK  要预测新工况，用物理模型还是 DMD？          method_choice
OK  只做 POD 不加 Hankel 行不行？              hankel_necessity
OK  pressure 的单位是什么？                    pressure_unit
OK  主表和旧方法表有什么区别？                  data_sources
OK  换一条鱼还能用这个 DMD 吗？                scope_limits
OK  毛刺都集中在哪里？                         spikes
OK  25 段里 p 最差是多少？                     segment_windows
OK  POD 95% 能量需要几阶？                     pod_energy
OK  u_y 的主导频率是多少？                     frequency
OK  物理模型和 DMD 差多少？                    physical_run_gap
15/15 = 100.0%
```

## 4. 权威指标（全窗口，`06_指标/两口径指标_权威.json`）

| 数据 | p A/B | u_x A/B | u_y A/B | 平均 A/B |
|---|---|---|---|---|
| dmd_v2 | 0.9715 / 0.9157 | 0.9884 / 0.9855 | 0.9928 / 0.9877 | **0.9842 / 0.9630** |
| dmd_old | 0.9936 / 0.8684 | 0.9884 / 0.9644 | 0.9964 / 0.9929 | **0.9928 / 0.9419** |

关键对照：旧方法 A 更高、B 更低——正好说明“只看一个口径会得出相反结论”。

## 4.1 物理模型（`可运行/`）

| 项 | 值 |
|---|---|
| 运行 | 1.0 s 物理时间 / 1001 步 / ≈105 s |
| 输出 | 404,404 点（1,001 帧 × 404 探针，dt=0.001） |
| 与交付包物理表 | **逐位相同**（Time/X/Y/p/u_x/u_y 最大差 0.0） |
| 与 DMD v2，全 404 | A=0.1763 / B=0.0016 / RMSE=1.764 |
| 与 DMD v2，trim 24（308） | A=0.4427 / B=0.0075 / RMSE=1.844 |
| 文档对照 | 全 404 p=0.177，trim 后 p=0.416 → 一致 |

低 R² 是**无黏 + 鼻尖/尾缘尖点奇异**的已知边界，不是相位/单位 bug。

## 5. 三条不可越过的边界

1. DMD 留出测试平均 R² = **−7.11**，任何阶数都一样；
2. 物理模型平均 R² = **0.61**，可外推，但需要剔除 96 个尖点探针；
3. 首帧 p 幅度 2015（正常 1.3）、末帧坐标全 0；不剔除会把稳定段 R² 拉到负数。

## 6. MCP 自测

`python -m fishflow.mcp_server` 暴露 10 个工具：

```
diagnose  query  compare  manifest  field  report  run_physical  run_status  research  research_log
```

已用 stdio JSON-RPC 客户端验证：`initialize` → `tools/list` → `tools/call`
全链路通过；`run_physical` 用 0.01 s 短工况验证（7.8 s），DSH 配置见 `dsh/SETUP.md`。

## 6.1 跑新工况（隔离副本）
```powershell
python -m fishflow.cli run --freq 3.0 --t-end 1.0 --dt 0.001 --progress
python -m fishflow.cli run-status
python -m fishflow.cli runs
```

- 源码复制到 `data/runs/<id>/pkg`，不覆盖 `可运行/`；
- 1 s 物理时间：2 Hz 约 105 s，3 Hz 约 216 s；0.02 s 短工况约 9 s；
- `--progress` 每 1.5 s 输出 `percent / step / elapsed`；DSH 里用后台 job 跑它；
- `--background` 适合普通终端；DSH 的 job object 可能杀掉脱离进程；
- 跑完自动建索引 + 与 DMD 对比；`freq≠2` 时对比只作“外推失败”演示
  （3 Hz 实测 A=0.375、B=−0.023、RMSE=5.06）。

## 6.2 闭环研究（research）

```powershell
python -m fishflow.cli research --freq 3.0
```

| 工况 | verdict | 关键数 |
|---|---|---|
| 3 Hz（已有 run） | **BLOCK** | 全 404 A=0.233 / trim24 A=0.375 / B=−0.023 |
| 2 Hz（物理索引） | **WARN** | trim24 A=0.443 / B=0.008；尖点+无黏 |

每次写 `outputs/research_<id>.md` 与 `data/experiments.jsonl`（hypothesis/steps/critic/conclusion）。

## 7. 侧线问答评测

```powershell
python validation/lateral_eval.py
```

17 个侧线问题（是什么/两类神经丘/仿真流程/传感模型/阵列/偶极子/涡/自运动/ML/软件/404/评估/坑/机器鱼/视觉/集群），
当前 **17/17 = 100%**。

## 7.1 三类工具自测

| 问题 | 分支 | 工具 | 结果 |
|---|---|---|---|
| 这个数据怎么来的？ | query | origin | ✅ 文字 |
| 这个峰值是什么？ | query | peak | ✅ 探针 + 位置 |
| 画 t=2s 压力云图 | compute | pressure_cloud | ✅ `cloud_p_2p0.png` |
| 计算侧线感知的涡位置 | compute | vortex | ✅ `vortex_0p2.png` |
| 画多模态涡量场 | compute | vorticity | ✅ `vorticity_0p2.png` |
| 画物理模型真涡量场 | compute | physical_vorticity | ✅ `physical_vorticity_0p2.png`（外场 ω≈0） |
| 上传鱼图 + 体长 | simulate | image | ✅ `fish_contour.png` + 仿真图 |
| 拟合 Lighthill 模型 | compute | lighthill | ✅ `lighthill_fit.png`（相位一致性 0.999；波形 R²≈0.54，k 接近长波） |
| 给定来流速度 0.3 m/s，预测侧线输出 | simulate | forward | ✅ `sim-*.png` |

## 8. 复现命令

```powershell
python -m fishflow.build_index
python -m fishflow.eval
python -m fishflow.demo
python -m fishflow.cli report
```
