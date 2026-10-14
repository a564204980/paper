---
name: paper-dev-guidelines
description: Paper 鸿蒙端项目专属架构与工程研发规范。强制遵循两项铁律：(1) 功能高度解耦与职责细化拆分（拒绝臃肿大文件，将数据、视图、动效、手势层独立化）；(2) 问题修复与微调必须严格执行「最小化修改原则」（禁止无关格式化、代码重排或过度重构，严禁破坏已调优的微调参数与视觉坐标）。
---

# Paper 鸿蒙端工程架构与最小修改专精规范 (Paper Dev Guidelines)

本规范作为 Paper (HarmonyOS / ArkTS) 项目的核心开发铁律，在所有后续功能演进、组件拆解、Bug 修复及性能调优时强制生效。

---

## 视觉风格隔离基线：严禁遵循 focus-flight-ui-style
- **绝对隔离 Focus Flight 体系**：本项目是纯正的手绘手账应用，**严禁引入或遵循 `focus-flight-ui-style`**（坚决不使用 HUD 仪表盘、机舱仪表、暗黑深空与科幻毛玻璃）。
- **纯粹 Paper 拟物纸质手账美学**：视觉基线完全锚定经典 Moleskine 拟物素描本（真实叠纸切面、书脊包边压痕、柔和大地色系、自然接地漫射光影、极简纸面留白）。

---

## 核心法则一：功能解耦与职责尽量拆分 (Decoupling & Single Responsibility)

1. **拒绝臃肿单体文件 (No Monolithic Files)**
   - 单个 UI 文件或组件代码行数尽量控制在合理范围内（建议不超过 200~250 行）。
   - 一旦组件涉及多个视觉层或复杂逻辑，**必须坚决拆分**：
     - **数据层**：放入 `model/`（如 `NotebookModel.ets`, `PageModel.ets`），统一管理状态接口与初始常量；
     - **视觉原子组件**：放入 `components/`，按物理部件独立细化拆分（如书脊 `BookSpine.ets`、纸芯层 `PaperEdge.ets`、封面插画 `CoverIllustration.ets`、新建卡片 `AddNotebookCard.ets`）；
     - **动效/数学逻辑**：复杂的 2.5D 透视计算、贝塞尔平滑算法、手势阻尼逻辑拆分为独立的工具函数或纯控制器模块；
     - **容器页面**：`pages/` 仅负责组装子组件、分发事件与协调宏观状态，不承担具体细节绘制。

2. **单向数据流与低耦合接口 (Clean Interfaces)**
   - 子组件只通过明确的 `@Prop` / 回调闭包（如 `onCardClick`, `onPageChange`）与父级通信。
   - 禁止在子组件内部直接反向侵入或耦合全局上下文，确保每个子组件都具备独立预览和测试能力。

---

## 核心法则二：问题修复与迭代的最小化修改原则 (Minimal Modification)

1. **最小必要 Diff 范围 (Minimal Necessary Diff)**
   - 修复 Bug 或优化视觉时，**只允许改动与当前问题直接相关的代码及最小必要的上下文**。
   - 严禁借“顺手优化”之名进行大规模重构、重命名、函数重排或无意义的变量移动。

2. **严禁无关格式化 (Strictly No Collateral Formatting)**
   - 绝对不要对未改动的既有代码运行全文件格式化（Prettier/Linter 批量格式化）。
   - 保留原有的缩进风格、空行组织与代码注释，杜绝在 Git 中引入令人困惑的庞大无关 Diff。

3. **保护用户微调参数 (Protect Tuned Parameters)**
   - 拟物效果中大量的视觉参数（如 3D 旋转角度 `rotateY`、阴影模糊半径 `shadow.radius`、偏移量 `offsetY`、微调坐标 `translate/position`、颜色透明度等）均经过反复调试。
   - 在修复其他逻辑或增改功能时，**严禁无端覆盖或重置这些已调优的物理/视觉参数**。

---

## 核心法则三：第一性原理推演与零打扰验证 (Fact-Based & Zero-Nuisance)

1. **自主闭环验证 (Autonomous Verification)**
   - 代码修改完成后，必须通过终端 `hvigorw` 编译或静态检查进行自主验证，确认编译无错后方可交付。
   - 严禁每次小改动就催促用户“你去手机上点一下看好不好”，绝不把用户当成测试工具人。

2. **事实为本 (Fact-Based)**
   - 遇到 ArkUI API 变动或编译告警时，查阅官方规范与第一性原理解决，严禁主观凭空猜测。
