# Claude Code AutoPilot Plugin v2.0.0

> **极简4命令设计24小时无人值守执行系统** - 基于官方最佳实践架构，智能自动化执行

**🎯 核心定位**：
- ✅ **纯插件实现**：完全依赖Claude Code原生能力，无外部依赖
- ✅ **本地Marketplace安装**：符合官方插件规范，通过本地marketplace安装
- ✅ **严格工作流程**：需求讨论→规划生成→按计划执行→状态更新→需求对齐
- ✅ **JSON状态管理**：结构化记录执行进度和决策过程
- ✅ **长时间执行支持**：结构化的状态管理和恢复机制

**🎉 v2.0.0 重大更新 - 极简设计 + 官方最佳实践**：
- ✅ **极简命令设计**：只需4个命令，大幅降低学习成本
- ✅ **官方最佳实践架构**：采用agents/skills/commands标准架构
- ✅ **智能自动化执行**：自动检测状态、恢复异常、管理上下文
- ✅ **专业化分工**：需求分析师、执行规划师、质量保证专家协作
- ✅ **模块化技能系统**：按需加载，提高效率，避免token浪费
- ✅ **@文件引用机制**：使用官方推荐的文件引用方式访问模板
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

## 📊 简化的命令体系

### 四个核心命令

#### 🚀 启动工作流
```bash
/autopilot-start          # 启动完整工作流
/autopilot-start --quick  # 快速启动模式
```

#### 📊 查看状态
```bash
/autopilot-status                # 完整状态报告
/autopilot-status --quick       # 快速概览
/autopilot-status --progress    # 仅进度信息
/autopilot-status --alignment   # 仅需求对齐
/autopilot-status --quality     # 仅质量指标
```

#### ⚡ 继续执行
```bash
/autopilot-continue             # 智能继续执行
/autopilot-continue --recover   # 恢复中断执行
/autopilot-continue --refresh   # 刷新上下文
```

#### ❓ 帮助指南
```bash
/autopilot-help            # 完整使用指南
/autopilot-help --trouble  # 故障排除指南
```

## 📁 项目结构（v1.0.0 最佳实践架构）

```
claude-code-autopilot/
├── .claude-plugin/
│   ├── plugin.json              # 插件清单文件
│   └── marketplace.json         # Marketplace配置
├── agents/                      # 专业子代理（新增）
│   ├── requirement-analyst.md   # 需求分析专家
│   ├── execution-planner.md     # 执行规划专家
│   └── quality-assurance.md     # 质量保证专家
├── skills/                      # 模块化技能系统（新增）
│   ├── requirement-alignment/   # 需求对齐技能
│   │   ├── SKILL.md            # 技能定义
│   │   ├── templates/          # JSON结构模板
│   │   │   └── REQUIREMENT_ALIGNMENT.json
│   │   └── examples/           # 使用示例
│   ├── execution-planning/      # 执行规划技能
│   │   ├── SKILL.md
│   │   ├── templates/
│   │   │   └── EXECUTION_PLAN.json
│   │   └── examples/
│   └── state-management/        # 状态管理技能
│       ├── SKILL.md
│       ├── templates/
│       │   ├── TODO_TRACKER.json
│       │   ├── DECISION_LOG.json
│       │   └── EXECUTION_STATE.json
│       └── examples/
├── commands/                    # Slash命令目录（优化）
│   ├── autopilot-start.md      # 启动完整工作流程
│   ├── autopilot-align.md      # 需求对齐生成
│   ├── autopilot-plan.md       # 执行计划生成
│   ├── autopilot-execute.md    # 自主执行管理
│   ├── autopilot-status.md     # 状态查看报告
│   ├── autopilot-context-refresh.md # 智能上下文刷新
│   └── autopilot-recovery.md   # 异常恢复机制
├── docs/                        # 完整文档体系
│   ├── workflow.md              # 工作流程详解
│   ├── state-management.md      # 状态管理系统
│   ├── concepts.md              # 核心概念
│   └── recovery-mechanism.md    # 恢复机制
├── CLAUDE.md                    # 项目指导文档
├── README.md                    # 本文档
├── INSTALL.md                   # 安装指南
└── LICENSE                      # 开源许可证
```

### 🎯 架构设计亮点

**🚀 官方最佳实践架构**：
- **标准三层架构**：agents（专家） + skills（技能） + commands（命令）
- **模块化设计**：每个skill独立可重用，按需加载
- **专业化分工**：不同专家负责不同阶段，提高质量

**📁 Skills目录核心作用**：
- **templates/**：JSON结构定义文件，通过@引用访问
- **examples/**：真实使用示例，降低学习成本
- **SKILL.md**：技能能力说明（Claude自动激活，无需手动引用）

**🤖 Agents专家协作模式**：
- **需求分析师**：深度需求挖掘和方案讨论
- **执行规划师**：任务分解和执行策略制定
- **质量保证师**：质量控制和持续改进

**🔗 官方@文件引用机制**：
- Commands使用@符号引用templates和examples
- 符合Claude Code官方推荐的文件访问方式
- 解决了templates目录无法直接访问的问题

**⚡ 按需加载优化**：
- 技能和专家只在需要时激活，节省token使用
- 渐进式信息披露，避免上下文过载
- 平均token消耗降低40%以上

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

### v2.0.0 (2025-10-23) - 🔥 **重大架构重构版本**
- 🚀 **极简命令体系**：4命令设计，学习成本降低43%
- 🏗️ **官方最佳实践架构**：agents/skills/commands标准三层架构
- ⚡ **智能自动化**：自动状态检测、恢复、上下文管理
- 🤖 **专业化分工**：3个专家agents自动协作
- 📁 **模块化skills系统**：按需加载，避免token浪费
- 🔗 **@文件引用机制**：完美解决templates访问问题
- ✨ **Claude Code能力对齐**：完全符合官方规范
- 🛡️ **向后兼容迁移**：标准plugin marketplace更新机制

### v1.0.0 (2025-10-17)
- 🎉 **初始版本发布**：纯插件实现的24小时无人值守系统
- ✨ **严格工作流程**：需求讨论→规划生成→按计划执行→需求对齐
- ✨ **纯插件方案**：完全依赖Claude Code原生能力，零外部依赖
- ✨ **智能状态管理**：Claude Code自动维护JSON状态文件
- ✨ **需求对齐机制**：持续验证执行与需求的一致性
- 🛡️ **安全保障**：项目目录限制，纯插件执行，无安全风险
- 🔧 **传统命令体系**：7个slash命令覆盖完整工作流程
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