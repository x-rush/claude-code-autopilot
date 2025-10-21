---
description: 基于需求对齐结果执行任务，自主管理状态更新
---

# /autopilot-execute
按照执行计划继续执行任务，Claude Code自主管理状态更新和需求对齐。

## 使用方法
```bash
/autopilot-execute                  # 继续执行下一个任务
/autopilot-execute --recover       # 恢复中断执行
/autopilot-execute --skip <ID>     # 跳过指定任务
/autopilot-execute --status        # 显示当前状态
```

## 执行流程
### 任务确认
- 读取执行计划和当前状态
- 确定下一个待执行任务
- 验证前置依赖条件

### 执行管理
- 严格按照需求对齐结果执行
- 遵循质量标准和验收条件
- 处理异常和偏离情况

### 状态更新
- 自动更新TODO_TRACKER.json
- 更新EXECUTION_STATE.json
- 记录决策到DECISION_LOG.json

### 需求对齐
- 验证执行结果与需求一致性
- 检查质量标准达成情况
- 确认用户偏好符合性

## 执行特点
- **完全自主**：Claude Code自动管理所有状态
- **需求导向**：严格遵循原始需求对齐
- **质量保证**：持续验证和质量控制
- **决策记录**：完整记录执行过程

## 使用场景
- 按计划继续执行任务
- 恢复中断的执行流程
- 跳过问题继续后续任务
- 检查当前执行状态

## 相关命令
- `/autopilot-status` - 查看执行状态
- `/autopilot-align` - 验证需求对齐
- `/autopilot-recovery` - 处理异常情况

---

现在开始执行任务，自主管理状态更新。

详细说明请参考：[工作流程文档](../docs/workflow.md)