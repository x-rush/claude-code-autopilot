# 核心概念

Claude Code AutoPilot 基于以下核心概念实现24小时无人值守执行：

## 纯插件实现
- **零外部依赖**：仅依赖Claude Code原生能力
- **项目级安装**：每个项目独立管理插件实例
- **slash命令驱动**：所有功能通过标准slash命令实现

## 三阶段工作流程
1. **需求深度讨论**：结构化分析用户需求
2. **执行计划生成**：动态任务分解和状态文件创建
3. **自主执行管理**：连续任务执行和实时状态更新

## JSON状态管理系统
5个核心状态文件跟踪完整项目生命周期：
- `REQUIREMENT_ALIGNMENT.json` - 需求对齐和验证
- `EXECUTION_PLAN.json` - 任务分解和执行策略
- `TODO_TRACKER.json` - 任务进度和质量跟踪
- `DECISION_LOG.json` - 决策过程记录
- `EXECUTION_STATE.json` - 当前执行状态

## 结构定义驱动
- `templates/` 目录包含JSON结构定义文件
- Claude Code读取结构定义生成运行时文件
- 确保数据一致性和完整性

## 需求对齐机制
- 持续验证执行结果与原始需求的一致性
- 自动检测和修正执行偏差
- 保持项目目标不偏离

详细概念说明请参考：
- [工作流程详解](workflow.md)
- [状态管理系统](state-management.md)
- [恢复机制](recovery-mechanism.md)