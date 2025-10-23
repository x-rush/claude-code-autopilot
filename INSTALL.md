# 🚀 快速安装指南

## 方法一：在 Claude Code 中直接添加本地 Marketplace

这是最简单推荐的方法：

### 1. 克隆插件
```bash
git clone https://github.com/x-rush/claude-code-autopilot.git
```

### 2. 启动 Claude Code 并安装
```bash
claude --dangerously-skip-permissions
```

在 Claude Code 中执行：
```bash
# 添加本地 marketplace（使用你的实际路径）
/plugin marketplace add ~/dev/claude-code-autopilot

# 安装插件
/plugin install claude-code-autopilot@claude-code-autopilot

# 验证安装
/help | grep autopilot

# 开始使用
/autopilot-start
```

## 方法二：使用相对路径

如果你在插件目录中启动 Claude Code：

```bash
cd claude-code-autopilot
claude --dangerously-skip-permissions
```

然后执行：
```bash
/plugin marketplace add ./
/plugin install claude-code-autopilot@claude-code-autopilot
```

## 🎯 安装完成后的使用

安装成功后，你可以在任何项目中使用这4个简化命令：

### 核心命令
- `/autopilot-start` - 启动完整的自主执行工作流
- `/autopilot-status` - 查看执行进度和状态
- `/autopilot-continue` - 智能继续执行任务
- `/autopilot-help` - 显示使用指南和帮助

### 快速开始
```bash
# 1. 启动项目
/autopilot-start

# 2. 查看状态
/autopilot-status --quick

# 3. 继续执行
/autopilot-continue

# 4. 需要帮助
/autopilot-help
```

**特点**：极简设计，只需记住4个命令，大幅降低学习成本！

## 🔧 卸载插件

如需卸载插件，在 Claude Code 中执行：
```bash
/plugin uninstall claude-code-autopilot
```

---

**注意**：此插件通过本地 marketplace 安装，一次安装，全局可用！