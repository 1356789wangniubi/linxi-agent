# 鳞析 Agent 架构

## 总链路

```
用户文字
  ↓
意图解析（LLM，可选；无 LLM 时规则回退）
  ↓
┌───────────────┬───────────────────┬────────────────────┐
│ 查询/解释      │ 计算/分析          │ 控制/仿真           │
│ query         │ compute            │ simulate            │
├───────────────┼───────────────────┼────────────────────┤
│ meta          │ pressure_cloud     │ forward             │
│ origin        │ vortex             │ （来流速度→传感器）  │
│ peak          │ vorticity          │ 图片→轮廓→仿真      │
│               │ physical_vorticity │                    │
│               │ lighthill          │                    │
└───────────────┴───────────────────┴────────────────────┘
  ↓
工具返回：图 / 数值 / 误差 / 元数据
  ↓
LLM 整理（可选）+ 模板兜底
  ↓
自然语言回答：结论 + 依据 + 误差提醒 + 追问
```

## 三类分支

### 1. 查询/解释

| 用户问 | 工具 | 输出 |
|---|---|---|
| 这个数据怎么来的？ | `origin` | 数据来源、索引、指标口径 |
| 这个峰值是什么？ | `peak` | 峰值探针/位置/时间 + 尖点提醒 |
| 多少探针/多少行？ | `meta` | 规模、dt、权威指标 |

### 2. 计算/分析

| 用户问 | 工具 | 输出 |
|---|---|---|
| 画 t=2s 压力云图 | `pressure_cloud` | 表面压力场 PNG + min/max |
| 计算侧线感知的涡位置 | `vortex` | 低压核心（涡代理）位置 + PNG |
| 画多模态涡量场 | `vorticity` | 压力/速度/近壁涡量代理 + PNG |
| 画物理模型真涡量场 | `physical_vorticity` | 170×120 网格 + ω_z + 势流边界提醒 |
| 查论文/阅读顺序 | `papers` | 十篇论文的问题/方法/结论/边界 |
| 检验我的仿真 | `validate_user` | A/B/RMSE + 四联图 + 表格 |
| 坐标查压强/速度 | `/point` | 鱼体 404 探针 + 点选 + 时间曲线 |
| 拟合 Lighthill 模型 | `lighthill` | 主频/波数/相速度/R² + 拟合图 |

### 3. 控制/仿真

| 用户问 | 工具 | 输出 |
|---|---|---|
| 给定来流速度 0.3 m/s，预测侧线输出 | `forward` | 四联图 + SNR + 定位误差 |
| 我给你一条鱼，帮我做仿真 | `sim_form` | 参数卡 → `forward` |
| 上传鱼图 + 体长 | `simulate_image` | 轮廓 → H/L → `forward` |

## LLM 在哪里

- **规划**：`plan_llm()` 让 LLM 只输出 JSON：`{branch, tool, args}`；
- **总结**：`summarize_llm()` 把工具结果整理成中文，要求保留误差/边界；
- **回退**：没有 `FISHFLOW_LLM_URL` 时用 `plan_rules()` + 模板总结；
- **边界**：LLM 不碰原始数据，数字/图只来自 Python 工具。

## 关键文件

| 文件 | 作用 |
|---|---|
| `fishflow/chat.py` | 聊天入口、人设、侧线知识、表单 |
| `fishflow/agent.py` | LLM/规则路由 + 9 个工具 |
| `fishflow/lateral_line.py` | 侧线知识库 + 偶极子/404 探针图 |
| `fishflow/sim_agent.py` | 引导式正向仿真 |
| `fishflow/image_tool.py` | 鱼图分割 → H/L 比例 → 仿真 |
| `fishflow/physical_field.py` | 面元速度 → 2D 网格 → 真涡量 |
| `fishflow/papers.py` | 十篇论文阅读包 + 问答 |
| `fishflow/validate_user.py` | 用户 CSV → 参考对比 → 图/表 |
| `fishflow/diagnose_user.py` | 量纲/符号/交换/时移/探针错位 → 多条假设 |
| `fishflow/user_csv.py` | 粘贴/口述数据 → CSV；示例数据 |
| `fishflow/point_lookup.py` | 坐标 → 最近探针 → p/ux/uy |
| `fishflow/probe_view.py` | 整帧 404 探针 + 单探针时间序列 |
| `fishflow/chat_server.py` | HTTP API |
| `fishflow/chat.html` | 豆包风格聊天 UI |

## API

```
POST /api/chat       {"message":"...","history":[...]}
POST /api/simulate   {"params":{...}}
POST /api/simulate_image {"image":"data:image/png;base64,...","length":0.15}
POST /api/validate    {"csv":"..."} 或 {"pasted":"t=0.2, probe=17, p=..."}
GET  /api/point?x=&y=&t=
GET  /api/frame?t=0.2
GET  /api/probe?probe=17&t=0.2
GET  /point           鱼体 404 探针查询页
GET  /outputs/<path> 图 / JSON
GET  /api/health
```

## 设计原则

1. **数字不经过 LLM**：工具算，LLM 只解释；
2. **每个结论带边界**：R² 口径、尖点、二维无黏、代理量；
3. **缺参数就追问**：`forward` 没给速度时返回 `need_params`；
4. **可回退**：没有 LLM 也能跑规则路由，答辩现场不怕断网。
