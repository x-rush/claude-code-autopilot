# 执行计划生成模板

> **使用说明**: 基于深度需求对齐结果，Claude自动生成详细的执行TODO清单，确保所有决策点都已明确

## 🎯 执行计划生成目标

### 核心目的
- **详细执行规划**: 将需求对齐结果转化为可执行的详细TODO
- **决策点前置**: 在执行前明确所有可能的决策点和处理方案
- **执行标准定义**: 设定每个TODO的完成标准和验收条件
- **依赖关系映射**: 明确任务之间的依赖和执行顺序

## 🤖 增强的需求对齐对话模板

### 第四阶段: 执行计划生成 (新增)
```
Claude: 基于我们的深度需求对齐，我现在需要生成详细的执行计划。

## 📋 详细执行计划生成

### 执行策略确认
基于我们的讨论，我将采用以下执行策略：
- **执行风格**: [基于需求对齐的执行风格]
- **质量标准**: [基于需求对齐的质量标准]
- **风险控制**: [基于需求对齐的风险偏好]

### 关键决策点识别
我识别出以下可能在执行中遇到的关键决策点：

#### 技术决策点
1. **[决策点1]** - 预设方案：[基于讨论的预设方案]
   - 触发条件：[什么情况下会遇到]
   - 备选方案：[如果预设方案不行的备选]
   - 决策依据：[基于什么标准选择]

2. **[决策点2]** - 预设方案：[基于讨论的预设方案]
   - 触发条件：[什么情况下会遇到]
   - 备选方案：[如果预设方案不行的备选]
   - 决策依据：[基于什么标准选择]

#### 内容决策点
1. **[决策点1]** - 处理原则：[基于讨论的处理原则]
   - 判断标准：[如何判断和选择]
   - 具体要求：[必须满足的要求]

### 详细执行TODO清单
我将按以下结构生成详细的执行计划：

```json
{
  "execution_plan": {
    "session_id": "EXEC_[YYYYMMDD_HHMMSS]",
    "based_on_requirement": "REQ_[需求对齐ID]",
    "generated_at": "2025-10-15T10:30:00Z",

    "execution_strategy": {
      "approach": "incremental", // incremental | waterfall | iterative
      "quality_gates": true,
      "self_check_intervals": "auto",
      "deviation_handling": "auto_correct"
    },

    "pre_decisions": {
      "technical_decisions": [
        {
          "decision_point": "技术选择1",
          "preset_solution": "预设方案",
          "trigger_conditions": ["触发条件1", "触发条件2"],
          "alternative_solutions": ["备选方案1", "备选方案2"],
          "decision_criteria": ["标准1", "标准2"],
          "confidence_level": "high"
        }
      ],
      "content_decisions": [
        {
          "decision_point": "内容选择1",
          "processing_principle": "处理原则",
          "judgment_criteria": ["判断标准1", "判断标准2"],
          "mandatory_requirements": ["必须满足的要求"]
        }
      ]
    },

    "execution_todos": [
      {
        "todo_id": "TODO_001",
        "title": "具体的任务标题",
        "description": "详细的任务描述",
        "type": "analysis | implementation | validation | documentation",
        "priority": "high | medium | low",
        "estimated_time": "预估时间（分钟）",

        "acceptance_criteria": [
          "验收标准1",
          "验收标准2",
          "验收标准3"
        ],

        "dependencies": ["前置TODO_ID"],
        "outputs": ["输出物1", "输出物2"],

        "self_check_points": [
          {
            "checkpoint_name": "检查点名称",
            "check_items": ["检查项1", "检查项2"],
            "validation_method": "auto | manual"
          }
        ],

        "error_handling": {
          "common_errors": ["常见错误1", "常见错误2"],
          "recovery_strategy": "恢复策略",
          "escalation_criteria": ["升级条件"]
        },

        "status": "pending",
        "started_at": null,
        "completed_at": null,
        "actual_time": null,
        "quality_score": null
      }
    ],

    "execution_gates": [
      {
        "gate_name": "里程碑名称",
        "required_todos": ["TODO_001", "TODO_002"],
        "quality_threshold": 8.0,
        "validation_criteria": ["验证标准1", "验证标准2"]
      }
    ],

    "safety_boundaries": {
      "allowed_directories": ["/当前项目目录"],
      "forbidden_operations": ["rm -rf", "pkill -9", "systemctl"],
      "max_file_size": "100MB",
      "external_calls": ["allowed_external_apis"]
    }
  }
}
```

### 执行确认
基于这个详细的执行计划：
1. **所有决策点都已预设** - 执行中无需人工决策
2. **验收标准明确定义** - 每个TODO都有清晰的完成标准
3. **依赖关系清晰** - 执行顺序明确
4. **安全边界设定** - 只在项目目录内执行

**你是否同意我基于这个计划开始全自动化执行？我将严格按照TODO清单执行，每个完成后进行自我检查，确保完全符合你的期望。**
```

## 📊 执行计划数据结构

### 自动生成的执行文件
执行完成后将生成以下文件：

1. **EXECUTION_PLAN.json** - 详细执行计划
2. **TODO_TRACKER.json** - TODO执行进度跟踪
3. **DECISION_LOG.json** - 决策记录（按预设方案自动选择）
4. **QUALITY_REPORT.json** - 每个TODO的质量评分

### 执行边界控制
```json
{
  "safety_boundaries": {
    "workspace_root": "/当前项目目录绝对路径",
    "allowed_operations": [
      "file_read", "file_write", "file_create",
      "directory_create", "claude_analysis",
      "text_processing", "code_generation"
    ],
    "forbidden_operations": [
      "system_shutdown", "user_management",
      "network_scan", "privilege_escalation",
      "file_delete_outside_workspace"
    ],
    "resource_limits": {
      "max_memory_usage": "2GB",
      "max_execution_time": "24h",
      "max_file_operations": 1000
    }
  }
}
```

## 🔄 执行计划质量保证

### Claude自检清单
```markdown
## 执行计划自检清单

### 完整性检查
- [ ] 所有需求都转化为具体的TODO？
- [ ] 每个TODO都有清晰的验收标准？
- [ ] 决策点都已预设解决方案？
- [ ] 任务依赖关系正确？
- [ ] 安全边界合理设定？

### 可执行性检查
- [ ] TODO粒度合适（不太大也不太小）？
- [ ] 时间估算合理？
- [ ] 检查点设置有效？
- [ ] 错误处理策略完备？

### 安全性检查
- [ ] 只在项目目录内操作？
- [ ] 危险操作已禁止？
- [ ] 资源限制合理？
- [ ] 异常情况有预案？
```

## 🎯 执行计划完成标志

### 生成条件
当且仅当以下条件全部满足时，执行计划才能生成：

1. **需求完全明确**: 所有需求都已转化为具体TODO
2. **决策点预设**: 所有可能的决策点都有预设方案
3. **标准已定义**: 每个TODO的完成标准都清晰
4. **边界已设定**: 安全边界和操作限制已明确
5. **用户确认**: 用户同意基于此计划执行

### 自动执行授权
一旦执行计划生成并得到用户确认，Claude将：
1. **严格按照TODO清单执行** - 不偏离计划
2. **自动处理所有决策** - 基于预设方案
3. **持续自我检查** - 每个TODO完成后验证
4. **实时进度报告** - 通过状态文件透明化进度

---

**重要说明**:
- 执行计划是一次性生成的，执行过程中不再需要人工决策
- 所有预设决策方案都基于需求对齐阶段用户的偏好
- 安全边界确保只在项目目录内执行，不会影响系统其他部分
- 每个TODO完成后都会进行质量验证，确保符合预期标准