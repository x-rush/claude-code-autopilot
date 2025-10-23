---
description: 启动AutoPilot工作流程 - 统一入口命令，包含需求讨论和规划生成
allowed-tools: Read, Write, Bash
---

# /autopilot-start
启动AutoPilot完整工作流程：需求讨论 → 规划生成 → 状态文件初始化。

## 使用方法
```bash
/autopilot-start           # 启动完整工作流
/autopilot-start --quick   # 快速启动模式（跳过详细讨论）
```

## 工作流程阶段

### 阶段1：需求深度讨论
我将进行专业化的需求分析，涵盖：
- 理解原始需求和核心目标
- 讨论技术方案和实现细节
- 设定质量标准和验收条件
- 确认用户偏好和约束

将基于以下结构模板生成需求对齐文件：
@skills/requirement-alignment/templates/REQUIREMENT_ALIGNMENT.json

参考示例：
@skills/requirement-alignment/examples/typical-alignment.json

### 阶段2：执行计划生成
我将进行详细的任务分解和规划，包括：
- 基于需求对齐生成执行计划
- 分解任务并确定依赖关系
- 初始化状态管理系统
- 配置质量门禁和安全边界

将基于以下结构模板生成执行计划文件：
@skills/execution-planning/templates/EXECUTION_PLAN.json

参考示例：
@skills/execution-planning/examples/software-development-plan.json

### 阶段3：状态文件初始化
我将初始化完整的状态管理系统：
- 任务跟踪系统
- 决策日志系统
- 执行状态监控

将基于以下结构模板初始化状态文件：
- @skills/state-management/templates/TODO_TRACKER.json
- @skills/state-management/templates/DECISION_LOG.json
- @skills/state-management/templates/EXECUTION_STATE.json

## 核心特点
- **需求导向**：一切从用户需求出发
- **充分讨论**：确保所有决策经过讨论
- **动态生成**：基于讨论生成项目规划
- **自主执行**：Claude Code完全自主管理
- **持续对齐**：保持与需求的一致性

## 支持的专业能力

本插件配备了专业化的agents和skills：
- **需求分析专家**：深度需求挖掘和技术方案讨论
- **执行规划专家**：任务分解和执行策略制定
- **质量保证专家**：质量控制和持续改进

Claude会根据任务需求自动选择最合适的专业能力。

## 产出文件
- `REQUIREMENT_ALIGNMENT.json` - 需求对齐文件
- `EXECUTION_PLAN.json` - 执行计划文件
- `TODO_TRACKER.json` - 任务跟踪文件
- `DECISION_LOG.json` - 决策记录文件
- `EXECUTION_STATE.json` - 执行状态文件

## 使用场景
- 新项目首次启动
- 需要重新规划执行时
- 执行流程完全中断时
- 项目重大调整重启时

## 后续命令
启动后使用以下命令管理执行：
- `/autopilot-status` - 查看执行状态和进度
- `/autopilot-continue` - 继续执行任务
- `/autopilot-help` - 显示帮助信息

---

现在开始启动AutoPilot工作流程。

**第一步：让我检查当前环境**
!`pwd && ls -la`

**第二步：请告诉我你的项目需求**

我将基于专业的需求分析方法和以下模板来讨论需求：
@skills/requirement-alignment/templates/REQUIREMENT_ALIGNMENT.json

参考实际案例：
@skills/requirement-alignment/examples/typical-alignment.json