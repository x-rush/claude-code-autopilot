# Claude Code AutoPilot 最佳实践指南

## 🎯 设计理念

Claude Code AutoPilot 是一个**真正零依赖的纯插件实现**，专为24小时无人值守的项目执行而设计。

### 核心原则

1. **零外部依赖**：仅依赖Claude Code和基本shell命令
2. **纯插件实现**：所有功能通过slash命令实现，无外部脚本
3. **用户需求驱动**：从用户需求讨论到自主执行的完整工作流程
4. **永久状态存储**：所有状态文件随项目提交到远程仓库
5. **断点重续支持**：API异常或上下文超出时可恢复执行

## 📋 完整工作流程

### 1. 用户需求发布
用户发布具体的需求任务：
```
我需要开发一个用户管理系统，包含用户注册、登录、权限管理等功能
```

### 2. 深度需求讨论
AutoPilot引导结构化讨论：
- **核心目标确认**：明确最终目标和成功标准
- **技术方案讨论**：架构设计、技术栈选择、实现细节
- **质量标准设定**：代码风格、测试策略、文档要求
- **用户偏好确认**：工作方式、风险管理偏好

### 3. 生成执行规划
基于讨论结果动态生成：
- **REQUIREMENT_ALIGNMENT.json**：需求对齐文件
- **EXECUTION_PLAN.json**：详细执行计划
- **TODO_TRACKER.json**：任务进度跟踪
- **DECISION_LOG.json**：决策记录
- **EXECUTION_STATE.json**：执行状态管理

### 4. 用户确认执行
用户确认规划后开始执行：
```
请确认以上规划是否符合您的期望，我将开始按照规划自主执行。
```

### 5. 自主执行和状态更新
Claude Code完全自主管理：
- 按照EXECUTION_PLAN.json执行任务
- 实时更新TODO_TRACKER.json进度
- 记录重要决策到DECISION_LOG.json
- 维护EXECUTION_STATE.json执行状态

### 6. 持续需求对齐
定期验证执行与需求的一致性：
- 每完成部分任务后检查需求对齐
- 发现偏差及时修正和重新对齐
- 确保最终成果符合用户期望

## 🔧 技术架构特点

### 零依赖设计
```bash
# 仅依赖基本shell命令
cp, mv, rm, mkdir, find, ls, echo, read
# 无需外部工具
# ❌ jq, curl, git, python, node
```

### 纯插件实现
```bash
# 所有功能通过slash命令实现
/autopilot-continuous-start  # 启动工作流程
/autopilot-execute            # 自主执行管理
/autopilot-status             # 状态查看报告
/autopilot-align              # 需求对齐验证
/autopilot-context-refresh   # 上下文刷新
/autopilot-recovery           # 异常恢复
```

### 永久状态存储
```bash
# 所有状态文件提交到Git仓库
git add REQUIREMENT_ALIGNMENT.json
git add EXECUTION_PLAN.json
git add TODO_TRACKER.json
git add DECISION_LOG.json
git add EXECUTION_STATE.json
git commit -m "AutoPilot: 更新执行状态"
git push
```

## 🚀 断点重续机制

### 上下文超出范围恢复
```bash
/autopilot-context-refresh
```
- 读取所有状态文件
- 生成精简的上下文重构
- 继续执行不丢失状态

### API异常恢复
```bash
/autopilot-recovery
```
- 检测状态文件完整性
- 智能恢复损坏数据
- 从中断点继续执行

### 手动状态检查
```bash
/autopilot-status
```
- 显示当前执行状态
- 识别潜在问题
- 提供恢复建议

## 📊 项目结构最佳实践

### 标准目录结构
```
your-project/
├── .claude/plugins/claude-code-autopilot/  # 插件安装位置
│   ├── .claude-plugin/plugin.json          # 插件配置
│   ├── commands/                          # slash命令
│   ├── templates/                         # 结构定义文件
│   └── manage.sh                          # 插件管理脚本
├── REQUIREMENT_ALIGNMENT.json              # 运行时需求对齐
├── EXECUTION_PLAN.json                     # 运行时执行计划
├── TODO_TRACKER.json                       # 运行时任务进度
├── DECISION_LOG.json                       # 运行时决策记录
├── EXECUTION_STATE.json                   # 运行时执行状态
└── .gitignore                            # 忽略运行时文件
```

### Git配置最佳实践
```gitignore
# Claude Code AutoPilot 运行时文件
/REQUIREMENT_ALIGNMENT.json
/EXECUTION_PLAN.json
/TODO_TRACKER.json
/DECISION_LOG.json
/EXECUTION_STATE.json

# templates/ 目录被保留（结构定义文件）
# !templates/
```

## 🎯 用户使用指南

### 安装插件
```bash
# 下载AutoPilot
git clone https://github.com/x-rush/claude-code-autopilot.git

# 在项目中安装
cd your-project
bash /path/to/claude-code-autopilot/install.sh
```

### 启动工作流程
```bash
# 启动Claude Code
claude --dangerously-skip-permissions

# 开始AutoPilot工作流程
/autopilot-continuous-start
```

### 管理执行过程
```bash
# 查看当前状态
/autopilot-status

# 继续执行任务
/autopilot-execute

# 检查需求对齐
/autopilot-align

# 刷新上下文（长时间执行）
/autopilot-context-refresh
```

## 🔍 故障排除

### 常见问题

**Q: 插件无法加载**
A: 检查插件安装完整性
```bash
.claude/plugins/claude-code-autopilot/manage.sh status
```

**Q: 状态文件损坏**
A: 使用恢复机制
```bash
/autopilot-recovery
```

**Q: 长时间执行上下文丢失**
A: 刷新上下文
```bash
/autopilot-context-refresh
```

**Q: 需要重新对齐需求**
A: 执行需求对齐检查
```bash
/autopilot-align
```

## 🎉 最佳实践总结

1. **纯插件理念**：完全依赖Claude Code能力，无外部依赖
2. **用户需求驱动**：从需求讨论到执行规划的完整闭环
3. **永久状态存储**：所有状态随项目版本管理，支持长期追踪
4. **智能恢复机制**：支持各种异常情况的自动恢复
5. **断点重续能力**：确保长时间任务的连续执行
6. **持续需求对齐**：定期验证执行结果与需求的一致性

这种设计确保了AutoPilot能够真正实现24小时无人值守的项目执行，同时保持高度的可靠性和用户需求的一致性。