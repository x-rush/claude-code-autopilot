# AutoPilot 命令快速参考

## 四个核心命令

| 命令 | 功能 | 常用选项 | 快速说明 |
|------|------|----------|----------|
| `/autopilot-start` | 启动工作流 | `--quick` | 需求讨论→规划→初始化 |
| `/autopilot-status` | 查看状态 | `--quick`, `--progress`, `--alignment`, `--quality` | 进度、质量、需求对齐 |
| `/autopilot-continue` | 继续执行 | `--recover`, `--refresh`, `--skip <ID>` | 智能执行+自动恢复 |
| `/autopilot-help` | 显示帮助 | `--quick`, `--trouble` | 使用指南+故障排除 |

## 简化的使用流程

### 新项目启动
```bash
/autopilot-start          # 一键启动，包含需求讨论和规划
```

### 日常执行管理
```bash
/autopilot-status --quick  # 快速检查进度
/autopilot-continue        # 智能继续执行（自动处理恢复等）
```

### 异常处理
```bash
/autopilot-status          # 检查详细状态
/autopilot-continue --recover  # 智能恢复执行
```

### 需要帮助
```bash
/autopilot-help            # 查看完整使用指南
/autopilot-help --trouble  # 故障排除指南
```

## 状态检查选项

`/autopilot-status` 支持的专门检查：
- `--progress` - 仅显示任务执行进度
- `--alignment` - 仅检查需求对齐状态
- `--quality` - 仅显示质量指标
- `--quick` - 快速概览所有信息

## 核心优势

### 极简学习
- **只需记住4个命令**，大幅降低学习成本
- **智能自动化**，减少用户决策负担
- **统一入口**，避免功能重叠和混淆

### 智能执行
- **自动状态检测**，无需手动诊断
- **智能恢复机制**，自动处理常见问题
- **上下文自动管理**，无需担心对话长度

### 需求导向
- **持续需求对齐**，确保执行不偏离目标
- **质量自动控制**，维持高标准的交付质量
- **24小时无人值守**，支持长时间连续执行

**详细功能说明请运行：`/autopilot-help`**