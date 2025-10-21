---
description: 智能恢复机制 - 检测并恢复异常执行状态
---

# /autopilot-recovery
检测并恢复执行异常，支持自动修复、状态重建和连续性保证。

## 使用方法
```bash
/autopilot-recovery              # 自动恢复
/autopilot-recovery --check      # 仅检查状态
/autopilot-recovery --fix        # 自动修复
/autopilot-recovery --reinit     # 重新初始化
```

## 恢复级别
### 轻微问题
- 修复JSON格式错误
- 补充缺失字段
- 修正数据类型错误

### 中度问题
- 重建部分损坏数据
- 从备份恢复状态
- 同步文件一致性

### 严重问题
- 重新初始化状态文件
- 从可用信息恢复关键数据
- 请求用户确认

## 检测内容
- 状态文件完整性
- 数据一致性验证
- 执行连续性分析
- 需求对齐检查

## 恢复报告
- 中断原因分析
- 恢复策略说明
- 数据完整性评估
- 继续执行建议

## 使用场景
- Claude Code异常中断后
- 状态文件损坏时
- 执行停滞或异常时
- 需要状态验证时

## 相关命令
- `/autopilot-status` - 检查执行状态
- `/autopilot-context-refresh` - 刷新上下文
- `/autopilot-execute` - 继续执行

---

现在开始执行智能恢复，检测和修复异常状态。

详细说明请参考：[恢复机制文档](../docs/recovery-mechanism.md)