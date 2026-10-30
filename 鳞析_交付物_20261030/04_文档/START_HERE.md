# 3 分钟跑起来（Windows）

## 0. 进入目录

```powershell
cd /d C:\Users\29144\Desktop\智能体
```

> 所有命令都要在这个目录下执行；换目录会找不到 `fishflow`。
> 依赖：`numpy pandas pyarrow matplotlib pillow scipy`（缺了就 `py -3 -m pip install ...`）。

## 最简：像豆包一样聊侧线

双击 **`chat.bat`**。

浏览器会自动打开 `http://127.0.0.1:8765/`，出现一个聊天框：

- 左边是侧线示例问题；
- 下面输入框，回车发送；
- 问“侧线怎么仿真”“表浅和管道神经丘的区别”“给我看一个侧线信号”都行；
- 也可以直接说“这个数据怎么来的”“画 t=2s 压力云图”“画多模态涡量场”“画物理模型真涡量场”“拟合 Lighthill 模型”；
- 问“十篇论文是哪十篇” / “Tu 2014 的 DMD 局限” → 十篇论文阅读包；
- 说“检验我的仿真” → 上传 CSV，出指标 + 四联图；
- **没有 CSV**：直接把数据贴进聊天或检验表单，例如 `t=0.2, probe=17, p=-0.03, ux=0.45, uy=0.18`，智能体会先生成 CSV 再检验；
- 如果结果不对，问“我的数据哪里错了”，它会按可能性列出多条原因（量纲、符号、ux/uy 接反、时间/探针错位等），每条都给自查和修法；
- 坐标查压强：打开 `http://127.0.0.1:8765/point`，鱼体上有 404 个探针，点哪个看哪个；
- 说“**我给你一条鱼，帮我做侧线仿真**”会弹参数卡；参数卡里可以**上传鱼图**，按轮廓比例估体高；
- 回答带“参考”，不确定会说“不确定”。

不用命令行，也不用先跑 demo。详细说明见 [CHAT.md](CHAT.md)。

要接智谱 GLM：先运行 `python -m fishflow.secret_setup` 录入 key，再双击 `chat_zhipu.bat`。
key 用 Windows DPAPI 加密，源码/批处理里不出现明文；见 [SECURITY.md](SECURITY.md)。

### 给同网用户用

双击 **`chat_lan.bat`**：

- 黑窗口会打印 `http://10.x.x.x:8765/`；
- 同一 Wi-Fi / 校园网的手机、电脑可直接打开；
- 首次可能需要在防火墙里允许 Python；
- 没有登录认证，只建议在可信网络使用。

## 1. 先自检（5 秒）

```powershell
python -m fishflow.cli doctor
```

期望：一排 `OK`（索引、指标、报告、skill、8 个 MCP 工具、ffmpeg、runs）。

如果 `python` 不是命令，用：

```powershell
py -3 -m fishflow.cli doctor
```

## 2. 一键跑三个问答（约 20 秒）

**最简单**：双击 `run_demo.bat`。

它会：自检 → 跑三个问答 → 跑 3 Hz 闭环 → 生成报告 → 自动打开浏览器。

或者命令行：

```powershell
python -m fishflow.demo
```

你会看到：

1. DMD 不能外推（−7.11）
2. p 的 R² 0.99 为什么还不准（A/B 口径）
3. u_x 为什么卡 0.83（Hankel / rr_cap）

并自动生成 `outputs/guard_report.html`。

## 3. 看报告（双击也行）

**只想看结果、不运行**：双击 `view.bat`，会打开报告 + 28 秒视频。

或者命令行：

```powershell
start outputs\guard_report.html
```

单文件、526 KB，图/动画都内嵌，不需要联网。

## 4. 看视频

```powershell
start outputs\demo_reel.gif
```

28 秒；也可以用 `outputs\demo_reel.avi`（VLC/PotPlayer 更稳）。

## 5. 试几个命令

```powershell
# 单探针查询
python -m fishflow.cli query --probe 17 --t0 0.1 --t1 0.2

# 物理模型 vs DMD
python -m fishflow.cli compare --physical --quantity p --trim 24

# 单问护栏
python -m fishflow.cli diagnose --question "DMD 能不能外推到 25 秒之后？"

# 闭环检查 3 Hz 能不能用 DMD（定位→对比→判定）
python -m fishflow.cli research --freq 3.0

# 看历史运行
python -m fishflow.cli runs
```

## 5.5 交互模式（REPL）

```powershell
python -m fishflow.repl
```

然后：

```text
鳞析> /q 17 0.1 0.2
鳞析> DMD 能不能外推到 25 秒之后？
鳞析> /research 3
鳞析> /report
鳞析> /quit
```

输入 `/help` 看全部命令。

## 6. 跑一个新工况（可选，较慢）

```powershell
python -m fishflow.cli run --freq 3.0 --t-end 1.0 --dt 0.001 --progress
```

- 1 s 物理时间：2 Hz 约 105 s，3 Hz 约 216 s；
- 会实时打印 `percent / step / elapsed`；
- 跑完自动建索引 + 与 DMD 对比。

## 7. 在 DSH 里用自然语言（可选）

```powershell
dsh web
```

然后在对话框里：

> 用 fishflow-guard 回答：p 的 R² 都 0.99 了，为什么还说压强不准？

skill 会调用 `python -m fishflow.cli diagnose ...`，并原样引用 evidence。
配置本地模型/校内 API 见 `dsh/SETUP.md`。

## 常见问题

| 现象 | 处理 |
|---|---|
| `python` 不是命令 | 用 `py -3` |
| `IndexNotReady` | `python -m fishflow.build_index`（约 45 s） |
| 中文乱码 | `chcp 65001` |
| 报告图不显示 | 用 `outputs/guard_report.html` 单文件；图已内嵌 |
| `run` 太慢 | 正常；用 `--progress` 看进度，或先跑 `--t-end 0.02` 试通 |
| `--background` 没反应 | DSH 沙箱会杀脱离进程；用 `--progress` + 后台 job |

## 最短路径

```powershell
cd /d C:\Users\29144\Desktop\智能体
python -m fishflow.demo
start outputs\guard_report.html
```
