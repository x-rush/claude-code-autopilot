---
description: 查看AutoPilot执行状态和进度报告
---

# /autopilot-status
查看实时执行状态、进度报告和系统健康状况。

## 使用方法
```bash
/autopilot-status                    # 完整状态报告
/autopilot-status --quick           # 快速概览
/autopilot-status --aspect <类型>    # 指定方面检查
```

## 检查方面
- `alignment` - 需求对齐状态
- `progress` - 任务执行进度
- `quality` - 质量指标状况
- `health` - 系统健康状态
- `decisions` - 决策记录分析

## 状态内容
### 执行概览
- 会话信息和执行时长
- 当前状态和进度百分比
- 整体健康评分

### 任务进度
- 总任务数和完成情况
- 当前任务和下一步计划
- 质量评分趋势

### 系统健康
- 状态文件完整性
- 数据一致性检查
- 上下文健康度

## 使用场景
- 定期检查执行进度
- 评估项目健康状况
- 分析执行效率
- 验证需求对齐

## 相关命令
- `/autopilot-align` - 需求对齐检查
- `/autopilot-recovery` - 异常恢复
- `/autopilot-execute` - 继续执行

---

现在开始执行状态检查，生成详细报告。

详细说明请参考：[工作流程文档](../docs/workflow.md)