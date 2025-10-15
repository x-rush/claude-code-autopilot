# Claude Code AutoPilot System (v2.0)

> **Claude Code CLI 的自动驾驶系统** - 基于深度需求讨论、详细TODO规划和安全边界控制的完全自动化执行系统

## 🎯 核心设计理念

### **你的工作流程，完美实现**
```
深度需求讨论 (15分钟) → 详细TODO规划 → 24小时无人值守执行
```

1. **第一阶段：深度需求讨论** - 确保Claude Code完全理解你的需求和所有决策点
2. **第二阶段：详细TODO规划** - 生成包含所有预设决策的执行计划
3. **第三阶段：真正无人值守** - Claude Code严格按照计划执行，无需人工干预

### **安全边界控制**
- ✅ **项目目录内完全权限** - Claude Code可以自由编辑项目内任何文件
- ❌ **项目目录外禁止访问** - 绝对不能触碰系统其他部分
- 🔒 **危险操作自动阻止** - rm -rf、pkill等危险命令被禁止

## 🚀 快速开始 (5分钟)

### **第一步：启动AutoPilot工作流**
```bash
# 在你的项目根目录下
./scripts/enhanced-workflow-launcher.sh --start
```

### **第二步：深度需求讨论 (15-20分钟)**
Claude将引导你完成四个阶段的深度讨论：

1. **核心目标理解** (3-5分钟)
   - 最终想要的具体成果
   - 成果的使用场景和用户
   - 完成的质量标准

2. **执行细节挖掘** (5-8分钟)
   - Claude Code CLI执行偏好
   - 风险容忍度
   - 特殊要求和约束

3. **决策点识别** (3-5分钟)
   - 可能遇到的决策点
   - 每个决策点的处理偏好
   - 备选方案优先级

4. **执行计划生成** (自动)
   - 基于讨论生成详细TODO清单
   - 预设所有决策点的解决方案
   - 设定安全边界和质量标准

### **第三步：完成讨论并标记**
```bash
# 深度讨论完成后执行
./scripts/enhanced-workflow-launcher.sh --complete-discussion
```

### **第四步：生成执行计划**
Claude自动生成详细的执行计划，包括：
- **详细TODO清单** - 每个任务的具体步骤和验收标准
- **预设决策方案** - 所有可能决策点的解决方案
- **安全边界设定** - 确保只在项目目录内操作

### **第五步：完成规划**
```bash
# 执行计划生成完成后执行
./scripts/enhanced-workflow-launcher.sh --complete-planning
```

### **第六步：开始真正无人值守执行**
```bash
# 启动24小时无人值守执行
./scripts/enhanced-workflow-launcher.sh --start-autonomous
```

## 📁 文件结构

```
claude-code-workflow-template/
├── README.md                       # 本文件 - 系统说明
├── config.json                     # 系统配置文件
├── scripts/                        # 核心脚本目录
│   ├── enhanced-workflow-launcher.sh  # 🆕 主启动器 (v2.0)
│   ├── safety-boundary.sh              # 🆕 安全边界控制器
│   ├── common-config.sh                # 通用配置函数
│   └── deviation-detector.sh           # 偏差检测器 (保留)
└── template-docs/                  # 模板文档目录
    ├── REQUIREMENT_ALIGNMENT.md       # 需求对齐模板
    └── EXECUTION_PLAN.md              # 🆕 执行计划模板
```

## 🛡️ 安全机制详解

### **1. 项目目录隔离**
```bash
# ✅ 允许的操作
./src/
./docs/
./scripts/
./config/
./data/

# ❌ 禁止的操作
../
/etc/
/home/
/usr/
/var/
```

### **2. 危险操作黑名单**
```bash
# 🚨 绝对禁止的危险操作
rm -rf /
pkill -9 node
shutdown now
systemctl restart
chmod 777 /
chown root
sudo su
```

### **3. 安全事件监控**
- 所有操作都会记录到 `SECURITY_LOG.md`
- 危险尝试会触发安全告警
- 违规操作会自动阻止并记录

## 📋 执行示例

### **深度讨论对话示例**
```
Claude: 为了确保完美执行你的项目，我需要深度理解你的需求。

## 🎯 第一阶段：核心目标确认

你最终想要得到什么具体成果？
用户: 我想要一个完整的微服务API文档系统，包含自动生成的API文档、用户手册和部署指南。

这个成果将如何被使用？谁会使用它？
用户: 开发团队会使用API文档进行接口对接，运维团队使用部署指南，产品团队使用用户手册。

怎样算"任务完成得很好"？
用户: 文档结构清晰，自动生成的API文档准确无误，部署指南可以直接用于生产环境。
```

### **生成的执行计划示例**
```json
{
  "execution_plan": {
    "session_id": "EXEC_20251015_143022",
    "execution_todos": [
      {
        "todo_id": "TODO_001",
        "title": "分析现有API结构",
        "description": "扫描项目中的API定义，提取接口信息",
        "acceptance_criteria": [
          "所有API端点都已识别",
          "请求/响应参数都已提取",
          "API分类和分组完成"
        ],
        "estimated_time": 30,
        "self_check_points": [
          {
            "checkpoint_name": "API完整性检查",
            "check_items": ["端点数量", "参数完整性", "分类正确性"]
          }
        ]
      }
    ],
    "pre_decisions": [
      {
        "decision_point": "API文档格式选择",
        "preset_solution": "使用OpenAPI 3.0规范",
        "trigger_conditions": ["发现多种API定义格式"],
        "decision_criteria": ["标准化程度", "工具支持", "可维护性"]
      }
    ]
  }
}
```

## 📈 监控和状态跟踪

### **查看工作流状态**
```bash
# 查看完整状态
./scripts/enhanced-workflow-launcher.sh --status
```

### **查看安全状态**
```bash
# 查看安全边界状态
./scripts/safety-boundary.sh --status
```

### **状态文件说明**
- `ENHANCED_WORKFLOW_STATUS.json` - 工作流总体状态
- `EXECUTION_PLAN.json` - 详细执行计划
- `TODO_TRACKER.json` - TODO执行进度
- `SECURITY_LOG.md` - 安全事件日志

## 🔧 配置说明

### **系统配置 (config.json)**
```json
{
  "version": "2.0",
  "execution": {
    "max_execution_hours": 24,
    "auto_confirm": true,
    "safety_boundary": true,
    "self_check_enabled": true
  },
  "safety": {
    "allowed_root": "项目根目录",
    "dangerous_patterns_blocked": true
  }
}
```

### **安全边界自定义**
编辑 `scripts/safety-boundary.sh` 中的配置：
```bash
# 允许的文件类型
readonly ALLOWED_EXTENSIONS=("md" "txt" "json" "js" "py" "sh")

# 允许的目录
readonly ALLOWED_DIRECTORIES=("src" "docs" "scripts" "config")
```

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

## 🚨 重要安全提醒

1. **仅在项目目录内使用** - 确保只在你的项目目录中运行此系统
2. **检查安全日志** - 定期查看 `SECURITY_LOG.md` 了解安全事件
3. **备份数据** - 在运行前备份重要数据
4. **监控执行过程** - 虽然是无人值守，但建议定期检查进度

## 🆕 v2.0 新特性

### **对比原版本**
| 特性 | v1.0 (旧版本) | v2.0 (当前版本) |
|------|---------------|-----------------|
| 人工干预 | 需要多次 | 只需一次深度讨论 |
| 决策分歧 | 执行中可能出现 | 所有决策点前置讨论 |
| 权限控制 | 无明确控制 | 项目目录内完全权限 |
| 无人值守 | ❌ 半自动化 | ✅ 真正无人值守 |
| 安全保障 | 基础 | 多层安全边界 |

### **新增核心组件**
- `scripts/enhanced-workflow-launcher.sh` - AutoPilot系统启动器
- `scripts/safety-boundary.sh` - 安全边界控制器
- `template-docs/EXECUTION_PLAN.md` - 执行计划生成模板

## 🎉 总结

这个AutoPilot版本完美实现了你的需求：
- **深度讨论前置** - 所有决策点在执行前充分讨论
- **详细TODO规划** - 执行计划清晰明确
- **项目目录安全** - 在项目内完全权限，项目外绝对禁止
- **真正无人值守** - 24小时自动执行，无需人工干预

**开始你的Claude Code AutoPilot项目：**
```bash
./scripts/enhanced-workflow-launcher.sh --start
```

---

**版本**: v2.0 | **更新时间**: 2025-10-15 | **状态**: 🟢 生产就绪