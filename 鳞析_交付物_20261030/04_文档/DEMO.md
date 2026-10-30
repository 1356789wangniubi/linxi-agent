# 鳞析 Demo（已跑出来的东西）

## 先看这三个

| 文件 | 是什么 |
|---|---|
| `chat.bat` / `python -m fishflow.chat_server` | **豆包风格聊天界面**（先看这个） |
| [outputs/guard_report.html](outputs/guard_report.html) | 证据化报告：15/15 评测、三个护栏问答、A/B 指标、图、动画、证据链 |
| [outputs/field_animation.gif](outputs/field_animation.gif) | 表面压强动画（0.1–0.46 s，12 fps） |
| [outputs/demo_reel.gif](outputs/demo_reel.gif) | 28 秒 demo reel（8 页，可直接播放/发微信） |
| [outputs/demo_reel.avi](outputs/demo_reel.avi) | 28 秒 MJPEG 视频（Windows 上 VLC/PotPlayer 最稳） |
| [outputs/demo_reel.mp4](outputs/demo_reel.mp4) | 同内容 MJPEG-in-MP4（不是 H.264） |
| [outputs/demo_transcript.txt](outputs/demo_transcript.txt) | `python -m fishflow.demo` 的完整终端记录 |
| [validation/SELFTEST.md](validation/SELFTEST.md) | 开发者自测：6/6 任务、真实耗时 |
| [validation/VALIDATION.md](validation/VALIDATION.md) | 哪些是真数据、哪些还没做 |

## 三个金牌问答（报告/transcript 里都有）

1. **DMD 能不能外推到 25 秒之后？**
   → 不能；留出测试 R²=−7.11，换任何阶数都一样；要预测用物理模型。

2. **p 的 R² 都 0.99 了，为什么还说压强不准？**
   → 0.99 是 A 口径（形状），B 只有 0.868；RMSE 1.81。形状对、幅值不对。

3. **u_x 为什么卡在 0.83？**
   → 标准 DMD 模态 ≤404；Hankel 抬到 1790；查 nmodes≤0.6K、rr_cap=nmodes、ridge=1e-9、联合最小二乘。

## 物理模型 Demo

- 2 Hz：`data/index_physical`（1,001 帧，与交付包物理表逐位相同）
- 3 Hz：`data/runs/20261027_223010_f3/`（1,001 帧，216 s）
- 3 Hz 表面场：[outputs/field_3hz.png](outputs/field_3hz.png)
- 3 Hz vs DMD：A=0.3748、B=−0.0229、RMSE=5.06（频率不同，只作“DMD 不能外推”演示）

## 复现

```powershell
# 报告 + 图 + 动画
python -m fishflow.demo

# 15/15 题路由评测
python -m fishflow.eval

# 物理模型对比
python -m fishflow.cli compare --physical --quantity p --trim 24

# 跑新工况（带进度；DSH 里请用后台 job）
python -m fishflow.cli run --freq 3.0 --t-end 1.0 --dt 0.001 --progress

# 闭环研究：定位→对比→判定→写记录
python -m fishflow.cli research --freq 3.0
python -m fishflow.cli research-log
```

## 还没做的

- **H.264 录屏**：已生成 [demo_reel.avi](outputs/demo_reel.avi)（MJPEG）和
  [demo_reel.mp4](outputs/demo_reel.mp4)（MJPEG-in-MP4），但不是 H.264；
  当前 ffmpeg 没有 x264，PowerPoint `CreateVideo` 也失败。
  要 H.264，用 OBS 录屏或换一台有 libx264 的机器转码。
- **DSH 实况对话**：skill 已加载、子 agent 已跑通；还没录屏。
- **真实用户试用**：工具包已备好（[validation/TRIAL_KIT.md](validation/TRIAL_KIT.md)），
  还没有真人数据；**不要用 AI 编日志**。
