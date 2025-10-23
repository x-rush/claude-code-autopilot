---
description: 显示AutoPilot帮助信息和使用指南
---

# /autopilot-help
显示AutoPilot插件的帮助信息、快速使用指南和常见问题解答。

## 使用方法
```bash
/autopilot-help             # 显示完整帮助
/autopilot-help --quick     # 显示快速指南
/autopilot-help --trouble   # 显示故障排除指南
```

## 四个核心命令

### 🚀 /autopilot-start
**功能**：启动完整工作流程
- 深度需求讨论和技术方案确定
- 自动生成执行计划和状态文件
- 初始化整个项目执行环境

```bash
/autopilot-start          # 完整启动流程
/autopilot-start --quick  # 快速启动模式
```

### 📊 /autopilot-status
**功能**：查看项目状态和进度
- 任务进度和完成情况
- 质量评分和健康状态
- 需求对齐状况检查

```bash
/autopilot-status          # 完整状态报告
/autopilot-status --quick  # 快速概览
/autopilot-status --progress  # 仅进度信息
```

### ⚡ /autopilot-continue
**功能**：继续执行任务
- 智能检测和处理异常状态
- 自动恢复中断的执行
- 管理上下文和需求对齐

```bash
/autopilot-continue          # 继续下一个任务
/autopilot-continue --recover  # 恢复中断执行
```

### ❓ /autopilot-help
**功能**：显示帮助信息
- 完整使用指南
- 故障排除建议
- 最佳实践提示

## 典型使用流程

### 新项目启动
```bash
/autopilot-start          # 启动项目，讨论需求
```

### 日常使用
```bash
/autopilot-status --quick  # 快速检查状态
/autopilot-continue        # 继续执行任务
```

### 遇到问题
```bash
/autopilot-status          # 检查详细状态
/autopilot-continue --recover  # 尝试自动恢复
/autopilot-help --trouble   # 查看故障排除指南
```

## 常见问题

**Q: 如何查看项目进度？**
A: 使用 `/autopilot-status --quick`

**Q: 执行中断了怎么办？**
A: 使用 `/autopilot-continue --recover`

**Q: 如何重新开始项目？**
A: 使用 `/autopilot-start`

**Q: 状态文件有问题怎么办？**
A: `/autopilot-continue` 会自动检测和修复

## 核心特点
- **简单易用**：只需记住4个命令
- **智能自动化**：自动处理复杂状态管理
- **需求导向**：始终确保与需求一致
- **无人值守**：支持24小时连续执行

---

需要更多帮助？插件会根据你的执行情况提供智能建议！