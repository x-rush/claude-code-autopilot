---
description: 查看AutoPilot状态 - 多功能状态命令，包含进度、质量、需求对齐等所有检查
allowed-tools: Read, Bash
---

# /autopilot-status
查看实时执行状态、进度报告、需求对齐状况和系统健康状况。

## 使用方法
```bash
/autopilot-status                    # 完整状态报告
/autopilot-status --quick           # 快速概览
/autopilot-status --progress        # 仅显示任务进度
/autopilot-status --alignment       # 仅检查需求对齐状态
/autopilot-status --quality         # 仅显示质量指标
```

## 使用场景
- 定期检查执行进度
- 评估项目健康状况
- 验证需求对齐状况
- 诊断执行异常问题

## 相关命令
- `/autopilot-continue` - 继续执行任务
- `/autopilot-start` - 重新启动工作流
- `/autopilot-help` - 显示帮助信息

---

现在开始执行状态检查，生成详细报告。

**状态文件检查**
!`ls -la *.json 2>/dev/null || echo "No JSON state files found"`

**执行状态分析**
我将基于以下状态文件结构进行分析：
- @skills/state-management/templates/TODO_TRACKER.json
- @skills/state-management/templates/DECISION_LOG.json
- @skills/state-management/templates/EXECUTION_STATE.json

**健康状态参考**
@skills/state-management/examples/healthy-state-example.json

**状态报告生成完成**