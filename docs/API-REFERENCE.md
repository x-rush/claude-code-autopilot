# Claude Code AutoPilot API 参考文档

**版本**: 1.0.0
**更新时间**: 2025-10-17
**API类型**: Claude Code 插件命令接口

## 📋 目录

- [概述](#概述)
- [插件命令API](#插件命令api)
- [状态文件数据结构](#状态文件数据结构)
- [JSON操作规范](#json操作规范)
- [错误处理](#错误处理)
- [使用示例](#使用示例)

---

## 🎯 概述

Claude Code AutoPilot 是一个纯插件实现的24小时无人值守执行系统。所有功能通过Claude Code的slash命令提供，支持JSON格式的状态文件管理。

### 核心特性
- ✅ **纯插件实现**: 完全依赖Claude Code的原生能力
- ✅ **JSON状态管理**: 结构化的状态文件作为"永久记忆"
- ✅ **slash命令接口**: 所有功能通过标准slash命令访问
- ✅ **自动状态维护**: Claude Code自动更新和检查状态
- ✅ **需求对齐机制**: 持续验证执行与需求的一致性

### 设计原则
- **简洁性**: 无外部依赖，不使用shell脚本
- **可靠性**: 基于Claude Code的稳定功能
- **可观测性**: 详细的状态跟踪和进度报告
- **一致性**: 统一的命令格式和数据结构

---

## 🚀 插件命令API

### 1. 连续执行启动命令 (`/autopilot-continuous-start`)

启动24小时连续自主执行流程，包含需求讨论、规划生成和执行三个阶段。

#### 命令格式
```
/autopilot-continuous-start
```

#### 功能流程
1. **需求讨论阶段**: 深入理解用户需求，确认所有细节
2. **规划生成阶段**: 基于需求生成详细的执行计划和状态跟踪文件
3. **执行阶段**: 按照规划自主执行，及时更新状态并确认需求对齐

#### 输出文件
- `REQUIREMENT_ALIGNMENT.json` - 需求对齐配置
- `EXECUTION_PLAN.json` - 执行计划配置
- `TODO_TRACKER.json` - TODO进度跟踪
- `DECISION_LOG.json` - 决策日志记录
- `EXECUTION_STATE.json` - 执行状态管理

#### 使用示例
```
用户: /autopilot-continuous-start
系统: 开始AutoPilot连续执行流程...

🎯 第一阶段：需求深度讨论
请详细描述您的任务需求...
[进入需求讨论]

📋 第二阶段：规划生成
基于需求讨论生成执行计划...
[生成规划文档]

🚀 第三阶段：自主执行
开始按照规划执行任务...
[进入执行循环]
```

---

### 2. 任务执行命令 (`/autopilot-execute`)

按照生成的规划执行具体任务，并立即更新状态文件。

#### 命令格式
```
/autopilot-execute <task_id> [options]
```

#### 参数说明
- `task_id`: 要执行的任务ID（来自EXECUTION_PLAN.json）
- `--notes`: 执行备注信息
- `--quality-score`: 质量评分（0-10）
- `--confidence`: 执行信心（high/medium/low）

#### 功能流程
1. **任务验证**: 检查任务ID的有效性和前置依赖
2. **状态更新**: 将任务状态更新为"in_progress"
3. **任务执行**: 执行具体的任务内容
4. **结果记录**: 记录执行结果、质量评分和备注
5. **状态完成**: 将任务状态更新为"completed"
6. **需求对齐检查**: 验证执行结果与需求的一致性

#### 使用示例
```
用户: /autopilot-execute task_003 --notes="实现用户登录功能" --quality-score=8.5
系统: 开始执行任务: task_003

✅ 任务状态已更新: in_progress
🎯 正在执行: 实现用户登录功能
...
✅ 任务执行完成: task_003
📊 质量评分: 8.5/10
🔍 需求对齐检查: 通过
```

---

### 3. 需求对齐检查命令 (`/autopilot-align`)

检查当前执行状态与原始需求的对齐情况，确认是否偏离预期。

#### 命令格式
```
/autopilot-align [options]
```

#### 参数说明
- `--detailed`: 显示详细的对齐分析
- `--auto-fix`: 自动发现偏差并提出修复建议

#### 检查内容
1. **核心目标符合度**: 验证执行结果是否符合核心目标
2. **场景覆盖度**: 检查是否覆盖了所有必要的使用场景
3. **标准达成度**: 验证是否达到约定的质量标准
4. **验收条件达成**: 检查验收条件的完成情况

#### 输出格式
```
🎯 需求对齐检查报告
====================

✅ 核心目标符合度: 95%
  - 用户认证功能: ✅ 完成
  - 数据持久化: ✅ 完成
  - 界面交互: ⚠️ 部分完成

📊 场景覆盖度: 88%
  - 正常登录流程: ✅ 覆盖
  - 异常处理: ⚠️ 需要补充
  - 权限管理: ✅ 覆盖

📋 改进建议:
  1. 补充异常处理场景
  2. 完善界面交互细节
  3. 增加权限验证测试
```

---

### 4. 状态查看命令 (`/autopilot-status`)

查看当前的执行状态、进度报告和系统健康状况。

#### 命令格式
```
/autopilot-status [options]
```

#### 参数说明
- `--quick`: 快速概览，只显示核心信息
- `--aspect <aspect>`: 指定检查方面（progress/quality/health/decisions）

#### 显示内容
1. **执行概览**: 会话信息、执行时长、当前状态
2. **进度统计**: 总任务数、完成数、进行中数、完成百分比
3. **质量指标**: 需求对齐度、代码质量评分、测试覆盖率
4. **当前任务**: 正在执行的任务详情
5. **系统健康**: 状态文件完整性、数据一致性检查

#### 输出示例
```
🎯 AutoPilot 执行状态报告
============================

📊 执行概览:
  会话ID: session_20250117_001
  开始时间: 2025-01-17 10:30:00
  执行时长: 2小时15分钟
  当前状态: running

📈 进度统计:
  总任务数: 25
  已完成: 15 (60%)
  进行中: 1
  待开始: 9

🎯 当前任务:
  任务ID: task_016
  标题: 实现用户认证模块
  执行时长: 45分钟

✅ 系统状态: 健康
📋 建议: 继续执行当前任务
```

---

### 5. 上下文刷新命令 (`/autopilot-context-refresh`)

刷新对话上下文，重新加载状态文件信息，确保Claude Code有最新的执行状态。

#### 命令格式
```
/autopilot-context-refresh
```

#### 功能流程
1. **状态文件重载**: 重新读取所有JSON状态文件
2. **上下文同步**: 更新Claude Code的上下文理解
3. **连续性验证**: 确认执行连续性和状态一致性
4. **下一步建议**: 基于最新状态提供执行建议

---

### 6. 恢复命令 (`/autopilot-recovery`)

从异常中断中恢复，检查状态文件完整性并修复不一致。

#### 命令格式
```
/autopilot-recovery [mode]
```

#### 恢复模式
- `check`: 仅检查状态，不修复（默认）
- `auto-fix`: 自动修复可恢复的问题
- `interactive`: 交互式恢复，询问每个修复操作

#### 恢复内容
1. **状态文件修复**: 修复损坏或缺失的JSON文件
2. **数据一致性**: 解决文件间的数据矛盾
3. **进度恢复**: 重新确定执行进度和当前任务
4. **备份恢复**: 从备份文件恢复必要数据

---

## 📋 状态文件数据结构

### 通用字段规范

所有状态文件都包含以下通用字段：

```json
{
  "session_id": "PREFIX_YYYYMMDD_HHMMSS_PID",
  "generated_at": "2025-10-17T10:30:00+08:00",
  "last_update_time": "2025-10-17T10:30:00+08:00"
}
```

### 1. REQUIREMENT_ALIGNMENT.json

存储需求对齐配置和验证结果。

```json
{
  "requirement_alignment": {
    "session_id": "REQ_20250117_103000_12345",
    "user_original_task": "用户原始任务描述",
    "analyzed_requirements": {
      "functional_requirements": [
        "功能需求1",
        "功能需求2"
      ],
      "non_functional_requirements": [
        "性能要求",
        "安全要求"
      ],
      "technical_constraints": [
        "技术栈限制",
        "环境约束"
      ],
      "business_constraints": [
        "时间限制",
        "资源限制"
      ]
    },
    "user_objective": {
      "primary_goal": "主要目标",
      "success_criteria": [
        "成功标准1",
        "成功标准2"
      ],
      "target_users": [
        "目标用户群体1",
        "目标用户群体2"
      ],
      "usage_context": "使用场景描述",
      "expected_outcomes": [
        "预期结果1",
        "预期结果2"
      ]
    },
    "alignment_verification": {
      "understanding_confirmed": true,
      "requirements_complete": true,
      "user_approval": true,
      "confirmation_time": "2025-10-17T10:45:00+08:00"
    },
    "current_results": {
      "core_goals_alignment": 95,
      "scenario_coverage": 88,
      "standards_achievement": 92,
      "acceptance_criteria_status": [
        {
          "criteria": "验收条件1",
          "status": "completed",
          "verification_time": "2025-10-17T11:00:00+08:00"
        }
      ]
    }
  }
}
```

### 2. EXECUTION_PLAN.json

存储详细的执行计划和任务分解。

```json
{
  "execution_plan": {
    "session_id": "PLAN_20250117_103000_12345",
    "plan_overview": {
      "total_tasks": 25,
      "estimated_duration_hours": 8,
      "complexity_level": "medium",
      "risk_level": "low"
    },
    "execution_phases": [
      {
        "phase_id": "phase_001",
        "name": "需求分析阶段",
        "description": "深入分析用户需求",
        "start_task": "task_001",
        "end_task": "task_005",
        "estimated_duration": "1小时"
      }
    ],
    "todo_list": [
      {
        "todo_id": "task_001",
        "title": "任务标题",
        "description": "详细任务描述",
        "type": "analysis/design/implementation/testing/documentation",
        "priority": "high/medium/low",
        "estimated_duration_minutes": 30,
        "dependencies": ["task_000"],
        "acceptance_criteria": [
          "验收标准1",
          "验收标准2"
        ],
        "deliverables": [
          "交付物1",
          "交付物2"
        ],
        "quality_requirements": {
          "min_quality_score": 8.0,
          "must_pass_tests": true,
          "code_review_required": true
        }
      }
    ],
    "decision_framework": {
      "technical_preferences": {
        "programming_languages": ["Python", "JavaScript"],
        "frameworks": ["React", "FastAPI"],
        "databases": ["PostgreSQL", "Redis"]
      },
      "quality_standards": {
        "code_coverage_min": 80,
        "documentation_required": true,
        "testing_levels": ["unit", "integration"]
      },
      "risk_tolerance": {
        "technical_debt_allowed": "low",
        "shortcut_allowed": false,
        "experimental_features": "with_approval"
      }
    },
    "execution_strategy": {
      "checkpoint_frequency_minutes": 30,
      "alignment_check_frequency": "every_task",
      "auto_recovery_enabled": true,
      "parallel_execution_allowed": false
    }
  }
}
```

### 3. TODO_TRACKER.json

跟踪任务执行进度和质量指标。

```json
{
  "todo_tracker": {
    "session_id": "TRACK_20250117_103000_12345",
    "overall_progress": {
      "total_todos": 25,
      "completed_todos": 15,
      "in_progress_todos": 1,
      "pending_todos": 9,
      "failed_todos": 0,
      "progress_percentage": 60,
      "estimated_completion_time": "2025-10-17T18:30:00+08:00"
    },
    "todo_progress": [
      {
        "todo_id": "task_001",
        "title": "任务标题",
        "status": "pending/in_progress/completed/failed/skipped",
        "start_time": "2025-10-17T10:30:00+08:00",
        "end_time": "2025-10-17T10:45:00+08:00",
        "duration_minutes": 15,
        "quality_score": 9.0,
        "progress_percentage": 100,
        "execution_notes": "执行备注",
        "deliverables_produced": [
          "交付物1",
          "交付物2"
        ],
        "issues_encountered": [],
        "acceptance_criteria_met": [
          "已满足的验收标准"
        ]
      }
    ],
    "quality_metrics": {
      "average_quality_score": 8.7,
      "quality_trend": "improving/stable/degrading",
      "tasks_below_threshold": 0,
      "critical_issues_found": 0
    },
    "timeline_tracking": {
      "original_plan_duration": "8小时",
      "actual_elapsed_time": "5小时",
      "time_variance_percentage": -37.5,
      "on_track_probability": 95
    }
  }
}
```

### 4. DECISION_LOG.json

记录执行过程中的所有决策和偏离。

```json
{
  "decision_log": {
    "session_id": "DECISION_20250117_103000_12345",
    "decision_summary": {
      "total_decisions": 12,
      "preset_decisions": 8,
      "manual_decisions": 3,
      "automatic_adjustments": 1,
      "major_deviations": 0
    },
    "decisions": [
      {
        "decision_id": "decision_001",
        "todo_id": "task_003",
        "decision_point": "技术选型决策点",
        "decision_made": "使用PostgreSQL作为主数据库",
        "decision_type": "preset/manual/fallback/recovery/automatic_adjustment",
        "decision_reason": "基于ACID事务需求和数据一致性要求",
        "confidence_level": "high/medium/low",
        "alternatives_considered": [
          "MySQL",
          "MongoDB"
        ],
        "impact_assessment": {
          "affected_todos": ["task_004", "task_005"],
          "time_impact": "+30分钟",
          "quality_impact": "positive",
          "risk_impact": "reduced"
        },
        "decision_time": "2025-10-17T11:15:00+08:00",
        "validation_needed": false,
        "validation_result": null
      }
    ],
    "major_deviation_decisions": [],
    "automatic_adjustment_decisions": [
      {
        "adjustment_id": "adjustment_001",
        "trigger": "网络连接异常",
        "automatic_action": "切换到备用API端点",
        "success": true,
        "time": "2025-10-17T12:30:00+08:00"
      }
    ],
    "decision_pattern_analysis": {
      "most_common_decision_type": "preset",
      "decision_consistency_score": 92,
      "quality_impact_score": 8.5,
      "time_efficiency_score": 9.0
    }
  }
}
```

### 5. EXECUTION_STATE.json

管理当前执行状态和会话信息。

```json
{
  "execution_state": {
    "session_id": "EXEC_20250117_103000_12345",
    "current_session_info": {
      "session_start_time": "2025-10-17T10:30:00+08:00",
      "current_status": "running/paused/completed/interrupted/error",
      "last_activity_time": "2025-10-17T13:45:00+08:00",
      "total_execution_time_minutes": 195,
      "current_phase": "implementation"
    },
    "current_task_context": {
      "current_todo_id": "task_016",
      "current_task_start_time": "2025-10-17T13:15:00+08:00",
      "current_task_duration_minutes": 30,
      "last_checkpoint_time": "2025-10-17T13:30:00+08:00",
      "next_checkpoint_due": "2025-10-17T14:00:00+08:00"
    },
    "execution_metrics": {
      "tasks_completed_today": 8,
      "average_task_duration": 25,
      "quality_score_average": 8.7,
      "error_recovery_count": 1,
      "user_intervention_count": 0
    },
    "system_health": {
      "last_status_check": "2025-10-17T13:45:00+08:00",
      "all_status_files_healthy": true,
      "data_consistency_verified": true,
      "backup_status": "current",
      "error_count_last_hour": 0
    },
    "execution_controls": {
      "auto_recovery_enabled": true,
      "pause_on_next_checkpoint": false,
      "require_user_approval_for_major_changes": true,
      "execution_speed": "normal",
      "verbose_logging": false
    },
    "next_actions": {
      "immediate_next_task": "task_017",
      "upcoming_checkpoints": [
        {
          "checkpoint_time": "2025-10-17T14:00:00+08:00",
          "purpose": "进度验证"
        }
      ],
      "pending_alignments": [
        {
          "alignment_type": "需求对齐检查",
          "due_time": "2025-10-17T14:30:00+08:00"
        }
      ]
    }
  }
}
```

---

## 🔧 JSON操作规范

### 文件操作原则

1. **原子性操作**: 修改文件时先写入临时文件，成功后替换原文件
2. **备份机制**: 重要修改前自动创建备份
3. **一致性检查**: 修改后验证JSON格式和数据一致性
4. **错误处理**: 操作失败时提供明确的错误信息和恢复建议

### 标准操作流程

#### 读取操作
```bash
# 1. 检查文件存在性
if [ ! -f "STATUS_FILE.json" ]; then
    echo "错误: 状态文件不存在"
    exit 1
fi

# 2. 验证JSON格式
if ! jq empty STATUS_FILE.json 2>/dev/null; then
    echo "错误: JSON格式无效"
    exit 1
fi

# 3. 读取数据
data=$(jq '.' STATUS_FILE.json)
```

#### 写入操作
```bash
# 1. 创建备份
cp STATUS_FILE.json STATUS_FILE.json.backup

# 2. 准备新数据
new_data=$(jq '.field = "new_value"' STATUS_FILE.json)

# 3. 写入临时文件
echo "$new_data" > STATUS_FILE.json.tmp

# 4. 验证新数据
if jq empty STATUS_FILE.json.tmp; then
    # 5. 替换原文件
    mv STATUS_FILE.json.tmp STATUS_FILE.json
else
    echo "错误: 新数据格式无效"
    # 6. 恢复备份
    mv STATUS_FILE.json.backup STATUS_FILE.json
    exit 1
fi
```

### 更新操作示例

#### 更新任务状态
```json
// 原始数据
{
  "todo_progress": [
    {
      "todo_id": "task_001",
      "status": "in_progress",
      "start_time": "2025-10-17T10:30:00+08:00"
    }
  ]
}

// 更新为completed状态
{
  "todo_progress": [
    {
      "todo_id": "task_001",
      "status": "completed",
      "start_time": "2025-10-17T10:30:00+08:00",
      "end_time": "2025-10-17T10:45:00+08:00",
      "duration_minutes": 15,
      "quality_score": 9.0,
      "progress_percentage": 100
    }
  ]
}
```

#### 记录新决策
```json
// 添加新决策到decisions数组
{
  "decisions": [
    // ... 现有决策 ...
    {
      "decision_id": "decision_013",
      "todo_id": "task_020",
      "decision_point": "实现方式选择",
      "decision_made": "使用异步处理方式",
      "decision_type": "manual",
      "decision_reason": "提高系统响应性能",
      "confidence_level": "high",
      "decision_time": "2025-10-17T14:20:00+08:00"
    }
  ]
}
```

---

## ⚠️ 错误处理

### 错误类型

#### 文件系统错误
- **文件不存在**: 状态文件缺失
- **权限错误**: 无法读写文件
- **磁盘空间不足**: 无法写入备份或新数据

#### JSON格式错误
- **语法错误**: JSON格式不正确
- **数据类型错误**: 字段类型不匹配
- **结构错误**: 缺少必要字段

#### 数据一致性错误
- **会话ID不匹配**: 不同文件的会话ID不一致
- **时间戳异常**: 时间逻辑不合理
- **引用错误**: 任务ID或决策ID不存在

### 错误处理策略

#### 自动恢复
1. **备份恢复**: 从最近的备份文件恢复
2. **模板重建**: 使用模板文件重新生成
3. **数据推断**: 基于其他文件推断缺失数据

#### 人工干预
1. **错误报告**: 提供详细的错误信息
2. **修复建议**: 给出具体的修复步骤
3. **回滚机制**: 支持回滚到之前的状态

### 错误信息格式

```
❌ AutoPilot 错误报告
==================

错误类型: JSON格式错误
影响文件: TODO_TRACKER.json
错误详情: 第15行缺少逗号
发生时间: 2025-10-17T14:25:00+08:00

🔧 自动修复尝试:
✅ 备份文件已创建: TODO_TRACKER.json.backup.20251017_142500
❌ 自动修复失败: 语法错误无法自动修正

📋 修复建议:
1. 手动编辑文件，在第15行添加逗号
2. 或使用以下命令恢复备份:
   cp TODO_TRACKER.json.backup.20251017_142500 TODO_TRACKER.json
3. 重新初始化: /autopilot-recovery --interactive
```

---

## 💡 使用示例

### 完整执行流程

```bash
# 1. 启动连续执行
用户: /autopilot-continuous-start

系统: 开始AutoPilot连续执行流程...
🎯 需求讨论阶段: [详细讨论用户需求]
📋 规划生成阶段: [生成执行计划和状态文件]
🚀 执行阶段: [开始按计划执行]

# 2. 执行具体任务
用户: /autopilot-execute task_003 --notes="实现用户认证" --quality-score=8.5

系统: ✅ 任务 task_003 执行完成
📊 质量评分: 8.5/10
🔍 需求对齐检查: 通过

# 3. 检查执行状态
用户: /autopilot-status

系统: 📊 执行状态报告
  进度: 60% (15/25 任务完成)
  当前任务: task_016 - 实现权限管理
  系统状态: 健康

# 4. 需求对齐检查
用户: /autopilot-align --detailed

系统: 🎯 需求对齐检查报告
  核心目标符合度: 95%
  场景覆盖度: 88%
  标准达成度: 92%

# 5. 异常恢复
用户: /autopilot-recovery --auto-fix

系统: 🔍 检查状态文件...
✅ 发现1个问题: DECISION_LOG.json 时间戳异常
🔧 自动修复: 已修正时间戳一致性
✅ 恢复完成，系统状态正常
```

### 高级使用场景

#### 批量任务执行
```bash
# 使用循环执行多个任务
for task in task_005 task_006 task_007; do
    /autopilot-execute $task --confidence=high
    /autopilot-status --quick
done
```

#### 定期对齐检查
```bash
# 每完成5个任务进行一次需求对齐检查
/autopilot-execute task_008
/autopilot-align
/autopilot-execute task_009
/autopilot-execute task_010
/autopilot-align
```

#### 错误恢复流程
```bash
# 检测到异常时的恢复流程
/autopilot-status
# 发现异常后进行恢复
/autopilot-recovery --interactive
# 验证恢复结果
/autopilot-status --aspect health
```

---

## 🔧 开发指南

### 添加新命令

1. **创建命令文件**: 在`commands/`目录创建新的`.md`文件
2. **配置YAML前置**: 设置正确的description和metadata
3. **实现命令逻辑**: 在Markdown内容中实现具体功能
4. **更新文档**: 在API文档中添加新命令的说明
5. **测试验证**: 确保命令与现有系统兼容

### 扩展状态文件

1. **设计JSON结构**: 定义新的数据结构和字段
2. **更新模板**: 在`templates/`目录添加新的JSON模板
3. **修改相关命令**: 更新所有操作该文件的命令
4. **更新API文档**: 记录新的数据结构和操作方法

### 质量保证

1. **JSON验证**: 所有JSON操作都要验证格式正确性
2. **备份策略**: 重要修改前必须创建备份
3. **一致性检查**: 定期验证文件间的数据一致性
4. **错误处理**: 提供完整的错误检测和恢复机制

---

## 📞 技术支持

### 故障排除

1. **状态文件问题**: 使用`/autopilot-recovery`命令检查和修复
2. **JSON格式错误**: 检查文件语法，使用备份恢复
3. **数据不一致**: 运行对齐检查，重新同步状态
4. **命令执行失败**: 检查命令参数，查看错误信息

### 常见问题

**Q: 如何重新开始执行？**
A: 使用`/autopilot-recovery --auto-fix`重置状态，然后重新启动。

**Q: 状态文件损坏怎么办？**
A: 系统会自动从备份恢复，或使用模板文件重建。

**Q: 如何验证执行结果？**
A: 使用`/autopilot-align --detailed`进行详细的需求对齐检查。

**Q: 执行进度停滞怎么办？**
A: 检查`/autopilot-status`输出，确认当前任务状态，必要时进行恢复。

---

*本文档随项目更新而更新，最新版本请参考项目仓库。*