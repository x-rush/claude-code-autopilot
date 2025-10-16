# Claude Code AutoPilot Plugin

> **完全无人值守的项目执行系统** - 基于深度需求讨论、智能执行计划、严格质量控制和连续自主执行

## 🎯 核心特性

### 🤖 深度需求讨论
- **结构化对话流程**：确保完全理解用户真实需求和期望
- **决策点智能识别**：自动识别所有可能的决策点
- **预设解决方案**：为每个决策点预设最佳解决方案
- **需求对齐验证**：确保执行结果与原始需求完全一致

### 🚀 连续自主执行
- **24小时连续工作**：真正的无分段连续执行
- **智能上下文管理**：自动处理对话长度限制
- **断点续传机制**：异常中断后自动恢复执行
- **自动重试策略**：分类处理各种异常情况

### 🛡️ 安全质量保障
- **项目目录限制**：仅在当前项目目录内执行操作
- **危险操作阻止**：自动识别并阻止危险系统命令
- **质量门禁控制**：严格执行质量标准和验证机制
- **完整操作审计**：记录所有操作，支持回滚和恢复

## 📋 系统要求

### 必要工具
```bash
# Claude Code CLI (必需)
# 参考官方文档安装: https://docs.claude.com/claude-code

# JSON处理工具
sudo apt-get install jq                    # Ubuntu/Debian
brew install jq                           # macOS

# 基础工具 (大多数系统已预装)
# awk, curl, date, stat, realpath
```

### 环境检查
```bash
# 检查依赖工具
for tool in jq awk curl date stat realpath; do
    if which "$tool" &>/dev/null; then
        echo "✅ $tool 已安装"
    else
        echo "❌ 请先安装 $tool"
    fi
done
```

## 🚀 快速开始

### 1. 安装插件

#### 方法1：本地开发安装 (推荐)
```bash
# 1. 克隆插件仓库
git clone https://github.com/x-rush/claude-code-autopilot.git
cd claude-code-autopilot

# 2. 创建本地marketplace
mkdir ../autopilot-marketplace
cd ../autopilot-marketplace

# 3. 创建marketplace配置
cat > marketplace.json << 'EOF'
{
  "name": "autopilot-marketplace",
  "owner": {
    "name": "AutoPilot Team"
  },
  "plugins": [
    {
      "name": "claude-code-autopilot",
      "source": "../claude-code-autopilot",
      "description": "Claude Code AutoPilot - 无人值守项目执行系统"
    }
  ]
}
EOF

# 4. 启动Claude Code并安装
claude
/plugin marketplace add ./autopilot-marketplace
/plugin install claude-code-autopilot@autopilot-marketplace
```

#### 方法2：团队共享安装
```bash
# 在你的项目根目录添加配置
echo '{
  "plugins": [
    {
      "name": "claude-code-autopilot",
      "source": "https://github.com/x-rush/claude-code-autopilot.git",
      "enabled": true
    }
  ]
}' > .claude/settings.json

# 团队成员使用
cd your-project
claude
/trust-folder  # 自动安装配置的插件
```

### 2. 启动AutoPilot

#### 启动Claude Code (使用权限跳过模式)
```bash
claude --dangerously-skip-permissions
```

#### 启动AutoPilot工作流
```
/autopilot-continuous-start
```

### 3. 深度需求讨论 (30分钟)
Claude将引导你进行结构化的需求讨论：

1. **核心目标确认**
   - 最终想要的具体成果
   - 成果的使用场景和用户群体
   - 成功的质量标准和验收条件

2. **执行细节挖掘**
   - 技术实现偏好和风格
   - 风险容忍度和特殊要求
   - 质量标准和完整性要求

3. **决策点识别**
   - 识别所有可能的决策点
   - 为每个决策点预设解决方案
   - 建立决策优先级和备选方案

4. **需求对齐验证**
   - 生成结构化需求文件
   - 验证需求的一致性和完整性

### 4. 连续自主执行 (24小时)
讨论完成后，Claude将立即开始连续执行：

- **严格按照TODO清单执行**：不偏离计划，使用预设决策方案
- **智能上下文管理**：避免对话长度限制，保持执行连续性
- **自动异常处理**：分类重试机制，智能处理各种异常
- **持续需求对齐**：定期验证执行结果与原始需求的一致性

## 📊 监控和管理

### 查看执行状态
```
/autopilot-status
```

显示内容包括：
- 实时进度信息
- 质量指标和评分
- 错误统计和恢复情况
- 时间分析和预估
- 故障诊断和建议

### 智能上下文刷新
```
/autopilot-context-refresh
```

当需要时手动触发上下文刷新：
- 提取关键历史信息
- 重建执行状态
- 确保执行连续性

### 异常恢复
```
/autopilot-recovery
```

当Claude Code异常中断时：
- 自动检测中断原因
- 恢复执行状态
- 从断点继续执行

## 📁 项目结构

```
claude-code-autopilot/
├── .claude-plugin/
│   └── plugin.json              # 插件清单文件
├── commands/                    # Slash命令目录
│   ├── autopilot-continuous-start.md    # 启动连续执行
│   ├── autopilot-status.md             # 查看执行状态
│   ├── autopilot-context-refresh.md     # 上下文刷新
│   └── autopilot-recovery.md           # 异常恢复
├── templates/                   # 状态文件模板
│   ├── REQUIREMENT_ALIGNMENT.json       # 需求对齐模板
│   ├── EXECUTION_PLAN.json              # 执行计划模板
│   ├── TODO_TRACKER.json                # TODO跟踪模板
│   ├── DECISION_LOG.json                # 决策日志模板
│   └── EXECUTION_STATE.json            # 执行状态模板
├── agents/                      # 专用代理配置 (未来扩展)
├── scripts/                     # 辅助脚本 (来自原项目)
│   ├── safety-boundary.sh             # 安全边界控制
│   ├── common-config.sh               # 通用配置
│   └── deviation-detector.sh          # 偏差检测
└── README.md                    # 本文档
```

## 🔄 工作流程详解

### 阶段1：深度需求讨论 (30分钟)
```
用户输入任务 → Claude结构化提问 → 深度需求挖掘 → 决策点识别 → 需求对齐验证
```

### 阶段2：执行计划生成 (15分钟)
```
需求分析 → TODO分解 → 质量门禁设定 → 异常处理配置 → 执行计划确认
```

### 阶段3：连续自主执行 (24小时)
```
按TODO执行 → 质量验证 → 进度更新 → 上下文管理 → 异常处理 → 需求对齐检查
```

### 阶段4：智能监控恢复 (持续)
```
状态监控 → 异常检测 → 自动恢复 → 断点续传 → 执行继续
```

## 📊 状态文件说明

### REQUIREMENT_ALIGNMENT.json
记录需求对齐的完整结果：
- 用户的核心目标和期望
- 详细的交付物要求
- 预设的决策解决方案
- 质量标准和约束条件

### EXECUTION_PLAN.json
详细的执行计划：
- 完整的TODO清单
- 任务依赖关系和顺序
- 质量门禁和检查点
- 安全边界和操作限制

### TODO_TRACKER.json
实时进度跟踪：
- 每个任务的执行状态
- 质量评分和验收结果
- 错误历史和重试记录
- 需求对齐验证结果

### DECISION_LOG.json
决策过程记录：
- 所做决策的详细信息
- 决策依据和考虑因素
- 与需求的对齐情况
- 决策效果评估

### EXECUTION_STATE.json
详细的执行状态：
- 当前执行位置和上下文
- 系统健康和资源状况
- 错误恢复和异常处理
- 下一阶段行动建议

## ⚠️ 安全和限制

### 安全保障
- ✅ **项目目录限制**：仅在当前项目目录内执行操作
- ✅ **危险操作阻止**：自动识别并阻止危险系统命令
- ✅ **完整操作日志**：记录所有操作，支持审计和回滚
- ✅ **权限控制**：严格的操作权限管理

### 操作限制
- **允许的操作**：文件读写、编辑、创建、目录操作
- **禁止的操作**：系统级命令、用户管理、权限提升
- **文件大小限制**：单个文件不超过100MB
- **执行时间限制**：最长24小时连续执行

### 数据安全
- **状态文件备份**：重要状态的多重备份机制
- **数据完整性校验**：状态文件的一致性验证
- **恢复机制**：异常中断后的数据恢复保证

## 🛠️ 故障排除

### 常见问题

#### 1. 插件安装失败
```bash
# 检查Claude Code版本
claude --version

# 重新安装插件
/plugin remove claude-code-autopilot@autopilot-marketplace
/plugin install claude-code-autopilot@autopilot-marketplace
```

#### 2. 权限问题
```bash
# 确保使用权限跳过模式启动
claude --dangerously-skip-permissions

# 检查文件权限
ls -la .claude/
```

#### 3. 状态文件损坏
```bash
# 使用恢复命令
/autopilot-recovery

# 检查状态文件完整性
jq . REQUIREMENT_ALIGNMENT.json
```

#### 4. 执行中断
```bash
# 检查Claude进程状态
ps aux | grep claude

# 重启Claude并恢复
claude --dangerously-skip-permissions
/autopilot-recovery
```

### 调试模式
```bash
# 启动调试模式
claude --debug --dangerously-skip-permissions

# 查看详细日志
tail -f AUTOPILOT_LOG.md
```

## 📈 性能优化

### 建议配置
- **内存**：至少2GB可用内存
- **磁盘**：至少1GB可用空间
- **网络**：稳定的网络连接

### 优化建议
- 定期清理临时文件
- 监控磁盘使用情况
- 保持系统稳定运行
- 避免频繁重启

## 🎯 适用场景

### ✅ **完美适合的场景**
- 大型文档生成项目
- 代码库重构和分析
- API文档自动生成
- 测试套件开发
- 配置文件管理
- 数据处理和分析

### ⚠️ **需要评估的场景**
- 需要系统级权限的任务
- 涉及敏感数据处理
- 需要与外部系统深度集成
- 实时性要求极高的任务

## 🤝 贡献和支持

### 报告问题
如果遇到问题，请提供：
1. 错误信息和日志
2. 系统环境信息
3. 重现步骤
4. 预期行为

### 贡献代码
欢迎提交Pull Request来改进插件：
1. Fork项目仓库
2. 创建功能分支
3. 提交代码变更
4. 创建Pull Request

### 技术支持
- 查看文档：`/help`
- 状态检查：`/autopilot-status`
- 社区讨论：GitHub Issues

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🔄 版本历史

### v1.0.0 (2025-10-15)
- 🎉 初始版本发布
- ✨ 深度需求讨论功能
- ✨ 连续自主执行能力
- ✨ 智能异常恢复机制
- ✨ 完整的状态管理系统
- 🛡️ 安全边界和质量控制

---

**开始你的24小时无人值守项目：**

```bash
# 1. 安装插件
git clone https://github.com/x-rush/claude-code-autopilot.git
cd claude-code-autopilot

# 2. 启动Claude Code
claude --dangerously-skip-permissions

# 3. 安装插件
/plugin marketplace add ../autopilot-marketplace
/plugin install claude-code-autopilot@autopilot-marketplace

# 4. 开始AutoPilot
/autopilot-continuous-start
```

让Claude Code AutoPilot为你实现真正的24小时无人值守项目执行！