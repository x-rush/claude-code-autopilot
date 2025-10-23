---
description: 继续执行AutoPilot任务 - 智能执行命令，自动处理恢复、刷新等需求
allowed-tools: Read, Write, Bash
---

# /autopilot-continue
继续执行AutoPilot任务，自动检测状态并智能处理恢复、上下文刷新等需求。

## 使用方法
```bash
/autopilot-continue           # 继续执行下一个任务
/autopilot-continue --recover # 恢复中断执行
/autopilot-continue --refresh # 刷新上下文后继续
/autopilot-continue --skip <ID> # 跳过指定任务
```

## 智能执行流程

### 状态检测和自动处理
- **状态文件检查**：自动检测JSON文件完整性
- **异常恢复**：发现问题自动修复或提示用户
- **上下文刷新**：检测到上下文过长时自动刷新
- **需求对齐验证**：执行前验证与需求的一致性

### 执行管理
- **任务确认**：确定下一个待执行任务
- **依赖验证**：检查前置条件是否满足
- **质量控制**：按质量标准执行任务
- **状态更新**：自动更新所有相关状态文件

### 需求对齐
- **执行验证**：确保执行结果符合需求
- **质量评分**：自动评估任务完成质量
- **偏离检测**：发现偏离时自动调整

## 核心特点
- **完全智能**：自动检测和处理各种状态
- **自动恢复**：无需用户干预的状态恢复
- **上下文管理**：智能处理对话长度限制
- **需求导向**：始终与原始需求保持一致

## 使用场景
- 按计划继续执行任务
- 恢复中断的执行流程
- 处理各种异常状态
- 智能上下文管理

## 相关命令
- `/autopilot-status` - 检查执行状态
- `/autopilot-start` - 重新启动工作流
- `/autopilot-help` - 显示帮助信息

---

现在开始智能执行，自动处理所有状态管理。

**执行前全面检查**
!`echo "=== 状态文件检查 ===" && ls -la *.json 2>/dev/null || echo "需要先运行 /autopilot-start"`

**智能状态分析**
将基于以下状态管理模板进行全面分析：
- @skills/state-management/templates/TODO_TRACKER.json
- @skills/state-management/templates/DECISION_LOG.json
- @skills/state-management/templates/EXECUTION_STATE.json

**智能恢复机制**
参考健康状态和恢复场景：
- @skills/state-management/examples/healthy-state-example.json
- @skills/state-management/examples/recovery-scenario-example.json
- @skills/state-management/examples/quality-metrics-example.json

**开始执行**
将自动：
1. 检测和修复状态问题
2. 刷新上下文（如需要）
3. 确定下一个任务
4. 执行并更新状态
5. 验证需求对齐