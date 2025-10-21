# AutoPilot 命令快速参考

## 核心命令

| 命令 | 功能 | 常用选项 | 快速说明 |
|------|------|----------|----------|
| `/autopilot-start` | 启动完整工作流 | `--quick` | 需求讨论→规划→执行 |
| `/autopilot-status` | 查看执行状态 | `--quick`, `--aspect <type>` | 进度、质量、健康状态 |
| `/autopilot-execute` | 继续执行任务 | `--recover`, `--skip <ID>` | 按计划执行下一任务 |
| `/autopilot-align` | 需求对齐检查 | `--update`, `--verify` | 验证与需求的一致性 |
| `/autopilot-recovery` | 异常状态恢复 | `--check`, `--fix`, `--reinit` | 检测和修复执行异常 |
| `/autopilot-context-refresh` | 刷新对话上下文 | `--quick`, `--summary-only` | 重建执行环境连续性 |
| `/autopilot-plan` | 生成执行计划 | `--update`, `--validate` | 基于需求制定任务计划 |

## 典型使用流程

### 新项目启动
```bash
/autopilot-start          # 启动完整工作流
```

### 日常执行管理
```bash
/autopilot-status --quick           # 快速检查状态
/autopilot-execute                  # 继续执行任务
/autopilot-context-refresh          # 定期刷新上下文
```

### 异常处理
```bash
/autopilot-recovery --check         # 检查异常状态
/autopilot-recovery --fix           # 自动修复问题
/autopilot-status                   # 验证修复效果
```

### 需求变更
```bash
/autopilot-align --update           # 更新需求对齐
/autopilot-plan --update            # 重新制定计划
/autopilot-execute                  # 按新计划执行
```

## 检查方面类型

`/autopilot-status --aspect` 支持的类型：
- `alignment` - 需求对齐状态
- `progress` - 任务执行进度
- `quality` - 质量指标状况
- `health` - 系统健康状态
- `decisions` - 决策记录分析

## 使用技巧

### 高效执行
- 使用 `--quick` 选项进行快速操作
- 定期运行 `/autopilot-context-refresh` 避免上下文丢失
- 在重要节点后检查 `/autopilot-status`

### 问题排查
- 先用 `/autopilot-recovery --check` 诊断问题
- 根据诊断结果选择合适的恢复选项
- 验证修复效果后再继续执行

### 质量保证
- 定期检查 `/autopilot-align` 确保需求对齐
- 关注质量评分趋势
- 在偏离时及时调整执行策略

详细文档请参考：
- [核心概念](../docs/concepts.md)
- [工作流程详解](../docs/workflow.md)
- [状态管理系统](../docs/state-management.md)