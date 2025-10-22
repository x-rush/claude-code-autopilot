# Claude Code AutoPilot Plugin v1.0.0

> **轻量级24小时无人值守执行系统** - 基于纯插件实现，专注需求对齐和自主执行

**🎯 核心定位**：
- ✅ **纯插件实现**：完全依赖Claude Code原生能力，无外部依赖
- ✅ **本地Marketplace安装**：符合官方插件规范，通过本地marketplace安装
- ✅ **严格工作流程**：需求讨论→规划生成→按计划执行→状态更新→需求对齐
- ✅ **JSON状态管理**：结构化记录执行进度和决策过程
- ✅ **长时间执行支持**：结构化的状态管理和恢复机制

**🎉 v1.0.0 核心特性**：
- ✅ **纯插件实现**：完全依赖Claude Code原生能力，无外部依赖
- ✅ **结构化工作流**：需求讨论→规划生成→按计划执行→持续对齐
- ✅ **JSON状态管理**：5个核心文件跟踪完整项目生命周期
- ✅ **智能恢复机制**：异常检测和状态恢复，支持执行连续性
- ✅ **需求对齐**：持续验证执行结果与原始需求的一致性

## 🎯 核心特性

### 🤖 严格工作流程约束
- **需求讨论优先**：深度理解用户需求，确认所有细节
- **规划文档生成**：基于讨论结果生成详细执行计划
- **按计划执行**：严格按照规划执行，及时更新状态
- **需求对齐检查**：持续验证执行结果与原始需求的一致性

### 📝 JSON状态文件系统
- **5个核心状态文件**：覆盖完整的项目生命周期
- **实时状态跟踪**：记录任务执行、质量评分、决策过程
- **状态一致性验证**：确保各状态文件间的数据一致性
- **智能恢复机制**：异常中断后的状态恢复和数据修复

### 🔄 纯插件执行模式
- **slash命令驱动**：所有功能通过标准slash命令访问
- **智能上下文管理**：避免对话长度限制，保持执行连续性
- **自动状态维护**：Claude Code自动读取和更新JSON状态文件
- **需求对齐确认**：每个重要节点都验证与需求的一致性

## 📋 系统要求

### 基本要求
- **Claude Code**：已安装并正常运行
- **项目目录**：任何现有项目目录或空目录
- **纯插件实现**：无需额外依赖工具

### 验证Claude Code
```bash
# 检查Claude Code版本
claude --version

# 测试基本功能
claude --dangerously-skip-permissions
/help
```

## 🚀 快速开始

### 1. 安装插件

#### 全局安装（推荐）

**步骤1：下载插件源码**
```bash
# 克隆插件仓库（只需要执行一次）
git clone https://github.com/x-rush/claude-code-autopilot.git
```

**步骤2：在Claude Code中添加本地marketplace并安装**
```bash
# 启动Claude Code
claude --dangerously-skip-permissions

# 添加本地marketplace（使用你的实际路径）
/plugin marketplace add /path/to/claude-code-autopilot

# 安装插件
/plugin install claude-code-autopilot@claude-code-autopilot

# 验证插件安装
/help | grep autopilot
```

**安装优势**：
- ✅ **全局可用**：一次安装，所有项目都可以使用
- ✅ **符合官方规范**：通过标准marketplace机制安装
- ✅ **简单直接**：只需几个命令完成安装
- ✅ **自动管理**：Claude Code自动处理插件加载和更新

**示例**：
```bash
# 假设你把插件克隆到了 ~/dev/claude-code-autopilot
/plugin marketplace add ~/dev/claude-code-autopilot
/plugin install claude-code-autopilot@claude-code-autopilot
```

### 2. 启动AutoPilot工作流

#### 启动Claude Code
```bash
claude --dangerously-skip-permissions
```

#### 启动连续执行流程
```
/autopilot-start
```

### 3. 三阶段执行流程

#### 第一阶段：需求深度讨论
Claude将引导你进行结构化的需求讨论：

1. **核心目标确认**
   - 最终想要的具体成果
   - 成果的使用场景和用户群体
   - 成功的质量标准和验收条件

2. **执行细节挖掘**
   - 技术实现偏好和风格要求
   - 风险容忍度和特殊约束
   - 质量标准和完整性要求

3. **决策点识别**
   - 识别所有可能的决策点
   - 为每个决策点预设解决方案
   - 建立决策优先级和备选方案

#### 第二阶段：执行计划生成
基于需求讨论生成完整的执行计划：

1. **TODO任务分解**
   - 将需求分解为具体的可执行任务
   - 确定任务间的依赖关系和执行顺序
   - 为每个任务设定验收标准

2. **状态文件初始化**
   - 生成5个核心JSON状态文件
   - 建立需求对齐配置
   - 设定决策框架和质量标准

#### 第三阶段：按计划自主执行
严格按规划执行，持续更新状态：

1. **任务执行**
   - 按照TODO清单顺序执行任务
   - 每个任务完成后立即更新状态
   - 记录质量评分和执行备注

2. **状态维护**
   - 实时更新TODO_TRACKER.json
   - 记录决策过程到DECISION_LOG.json
   - 维护EXECUTION_STATE.json

3. **需求对齐检查**
   - 定期验证执行结果与原始需求
   - 确认没有偏离预期目标
   - 必要时调整执行策略

## 📊 监控和管理

### 查看执行状态
```
/autopilot-status
```

显示内容包括：
- 执行概览（会话ID、开始时间、当前状态）
- 进度统计（总任务数、完成数、进行中数）
- 当前任务详情
- 质量指标和需求对齐度
- 系统健康状态

### 需求对齐检查
```
/autopilot-align
```

检查内容包括：
- 核心目标符合度
- 场景覆盖度
- 标准达成度
- 验收条件达成情况

### 执行具体任务
```
/autopilot-execute <task_id> [选项]
```

参数说明：
- `task_id`：要执行的任务ID
- `--notes`：执行备注信息
- `--quality-score`：质量评分（0-10）
- `--confidence`：执行信心（high/medium/low）

### 智能上下文刷新
```
/autopilot-context-refresh
```

当对话较长时手动触发：
- 重新加载状态文件信息
- 重建执行上下文
- 确保执行连续性

### 异常恢复
```
/autopilot-recovery [模式]
```

恢复模式：
- `check`：仅检查状态，不修复（默认）
- `auto-fix`：自动修复可恢复的问题
- `interactive`：交互式恢复

## 📁 项目结构

```
claude-code-autopilot/
├── .claude-plugin/
│   └── plugin.json              # 插件清单文件
├── commands/                    # Slash命令目录
│   ├── autopilot-start.md    # 启动完整工作流程
│   ├── autopilot-plan.md               # 执行计划生成
│   ├── autopilot-align.md               # 需求对齐生成
│   ├── autopilot-execute.md             # 自主执行管理
│   ├── autopilot-status.md              # 状态查看报告
│   ├── autopilot-context-refresh.md     # 智能上下文刷新
│   └── autopilot-recovery.md            # 异常恢复机制
├── templates/                   # JSON结构定义文件（重要）
│   ├── REQUIREMENT_ALIGNMENT.json       # 需求对齐结构定义
│   ├── EXECUTION_PLAN.json              # 执行计划结构定义
│   ├── TODO_TRACKER.json                # 任务跟踪结构定义
│   ├── DECISION_LOG.json                # 决策日志结构定义
│   └── EXECUTION_STATE.json            # 执行状态结构定义
├── docs/                        # 完整文档体系
│   ├── API-REFERENCE.md             # API参考文档
│   ├── DEVELOPMENT-GUIDE.md         # 开发者指南
│   └── USER-GUIDE.md                # 用户使用指南
├── install.sh                   # 插件安装脚本
├── LICENSE                      # 开源许可证
└── README.md                    # 本文档
```

### 🎯 关键设计说明

**templates/ 目录的核心作用**：
- 这些是**结构定义文件**，不是预填充模板
- Claude Code读取这些文件来理解JSON数据结构和字段要求
- 包含详细的字段描述、类型定义、格式要求和示例
- **必须保留**，用户从GitHub下载后需要这些文件才能使用插件

**纯插件工作流程**：
1. 用户下载插件代码（包含templates/结构定义文件）
2. 运行 `/autopilot-start` 开始工作流程
3. Claude Code读取templates/中的结构定义文件
4. 基于用户需求讨论**动态生成**项目特定的运行时JSON文件
5. 运行时文件保存在项目根目录，被.gitignore忽略

**结构定义 vs 运行时文件**：
- **templates/\*.json**：结构定义文件，描述数据格式和字段要求（Git跟踪）
- **根目录*.json**：运行时生成的项目特定状态文件（Git忽略）

## 🔄 工作流程详解

### 核心工作流程约束
```
用户需求任务 → 深度讨论所有决策和细节 → 生成任务规划和状态跟踪文件 → 按规划执行过程中及时自主更新状态并确认需求对齐
```

### 阶段1：需求深度讨论 (30分钟)
```
用户输入任务 → Claude结构化提问 → 深度需求挖掘 → 决策点识别 → 需求对齐验证
```

### 阶段2：规划生成 (15分钟)
```
需求分析 → TODO分解 → 质量标准设定 → 决策框架建立 → 状态文件生成
```

### 阶段3：按计划执行 (24小时)
```
按TODO执行 → 状态更新 → 质量评分 → 需求对齐检查 → 下一任务
```

### 阶段4：持续监控恢复 (持续)
```
状态检查 → 异常检测 → 智能恢复 → 执行继续 → 需求对齐
```

## 📚 文档体系

### 🚀 快速开始
- **命令快速参考**：[commands/README.md](commands/README.md) - 所有命令一览表
- **核心概念**：[docs/concepts.md](docs/concepts.md) - 理解基本概念和工作原理

### 📋 详细指南
- **工作流程详解**：[docs/workflow.md](docs/workflow.md) - 三阶段执行流程说明
- **状态管理系统**：[docs/state-management.md](docs/state-management.md) - JSON状态文件详解
- **恢复机制**：[docs/recovery-mechanism.md](docs/recovery-mechanism.md) - 异常处理和状态恢复

## 📊 状态文件概览

AutoPilot使用5个JSON状态文件跟踪项目执行：

| 状态文件 | 用途 | 核心内容 |
|---------|------|----------|
| `REQUIREMENT_ALIGNMENT.json` | 需求对齐 | 用户需求、技术方案、质量标准 |
| `EXECUTION_PLAN.json` | 执行计划 | 任务清单、依赖关系、验收标准 |
| `TODO_TRACKER.json` | 进度跟踪 | 执行进度、质量评分、时间统计 |
| `DECISION_LOG.json` | 决策记录 | 重要决策、选择理由、偏离分析 |
| `EXECUTION_STATE.json` | 执行状态 | 当前任务、系统健康、下一步行动 |

详细说明请参考：[状态管理系统](docs/state-management.md)

## ⚠️ 安全和限制

### 安全保障
- ✅ **项目目录限制**：仅在当前项目目录内执行操作
- ✅ **纯插件实现**：无外部脚本执行风险
- ✅ **状态文件管理**：安全的JSON文件操作
- ✅ **操作记录**：完整的决策和执行记录

### 操作限制
- **允许的操作**：文件读写、编辑、状态管理
- **禁止的操作**：系统级命令、用户管理、权限提升
- **文件范围**：仅限当前项目目录
- **数据安全**：本地状态文件，无外部传输

## 🛠️ 故障排除

### 常见问题

#### 1. 插件加载失败
```bash
# 检查插件是否正确安装
/help | grep autopilot

# 重新安装插件
bash .claude/plugins/claude-code-autopilot/install.sh --uninstall
bash /path/to/claude-code-autopilot/install.sh
```

#### 2. 状态文件异常
```bash
# 检查状态文件
/autopilot-status

# 自动修复
/autopilot-recovery --fix
```

#### 3. 执行中断恢复
```bash
# 检查中断原因
/autopilot-recovery --check

# 恢复执行
/autopilot-recovery --interactive
```

### 调试技巧
- 使用 `--quick` 选项快速检查状态
- 使用 `--aspect` 选项检查特定方面
- 定期进行需求对齐检查
- 保持状态文件的备份

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
1. 错误信息和状态
2. 执行的环境信息
3. 重现步骤
4. 预期行为

### 贡献代码
欢迎提交Pull Request来改进插件：
1. Fork项目仓库
2. 创建功能分支
3. 提交代码变更
4. 创建Pull Request

### 技术支持
- 查看命令帮助：`/help`
- 状态检查：`/autopilot-status`
- 社区讨论：GitHub Issues

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🔄 版本历史

### v1.0.0 (2025-10-17)
- 🎉 **重大版本发布**：纯插件实现的24小时无人值守系统
- ✨ **严格工作流程**：需求讨论→规划生成→按计划执行→需求对齐
- ✨ **纯插件方案**：完全依赖Claude Code原生能力，零外部依赖
- ✨ **智能状态管理**：Claude Code自动维护JSON状态文件
- ✨ **需求对齐机制**：持续验证执行与需求的一致性
- 🛡️ **安全保障**：项目目录限制，纯插件执行，无安全风险
- 🔧 **完整命令体系**：6个slash命令覆盖完整工作流程
- 📚 **完整文档体系**：API参考文档、开发者指南、用户使用指南

---

**开始你的24小时无人值守项目：**

```bash
# 1. 安装插件
git clone https://github.com/x-rush/claude-code-autopilot.git
cd your-project
bash /path/to/claude-code-autopilot/install.sh

# 2. 启动Claude Code
claude --dangerously-skip-permissions

# 3. 开始AutoPilot
/autopilot-start
```

让Claude Code AutoPilot为你实现真正的24小时无人值守项目执行！