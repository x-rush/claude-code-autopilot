# Claude Code AutoPilot API 参考文档

**版本**: 1.0.0
**更新时间**: 2025-10-17
**API类型**: Bash脚本命令行接口

## 📋 目录

- [概述](#概述)
- [核心组件API](#核心组件api)
- [状态管理API](#状态管理api)
- [监控系统API](#监控系统api)
- [执行引擎API](#执行引擎api)
- [数据结构规范](#数据结构规范)
- [错误处理](#错误处理)
- [使用示例](#使用示例)

---

## 🎯 概述

Claude Code AutoPilot 提供了一套完整的命令行API，用于管理24小时无人值守的项目执行系统。所有API都通过Bash脚本提供，支持JSON格式的状态文件操作。

### 核心特性
- ✅ **完整的命令行接口**: 所有功能都可通过CLI访问
- ✅ **JSON状态管理**: 结构化的状态文件管理
- ✅ **错误处理机制**: 完善的错误检测和恢复
- ✅ **参数验证**: 输入参数的严格验证
- ✅ **备份恢复**: 自动备份和恢复机制

### API设计原则
- **一致性**: 所有脚本使用统一的命令格式和参数规范
- **可靠性**: 完善的错误处理和边界情况处理
- **可观测性**: 详细的日志输出和状态报告
- **安全性**: 参数验证和操作边界检查

---

## 🏗️ 核心组件API

### 初始化系统 API (`scripts/init-session.sh`)

#### 命令格式
```bash
./scripts/init-session.sh [command] [options]
```

#### 可用命令

| 命令 | 描述 | 参数 |
|------|------|------|
| `init` | 初始化AutoPilot系统状态（默认） | 无 |
| `check` | 检查初始化前置条件 | 无 |
| `status` | 显示当前初始化状态 | 无 |
| `clean` | 清理已初始化的状态文件 | 无 |
| `help` | 显示帮助信息 | 无 |

#### 选项参数

| 选项 | 长选项 | 描述 |
|------|--------|------|
| `-f` | `--force` | 强制重新初始化，不询问确认 |
| `-q` | `--quiet` | 静默模式，减少输出信息 |
| `-v` | `--verbose` | 详细模式，显示更多调试信息 |

#### 返回值
- `0`: 成功
- `1`: 失败（依赖缺失、权限问题等）

#### 使用示例
```bash
# 标准初始化
./scripts/init-session.sh init

# 强制重新初始化
./scripts/init-session.sh init --force

# 检查初始化条件
./scripts/init-session.sh check

# 静默模式初始化
./scripts/init-session.sh init --quiet
```

---

## 📊 状态管理API (`scripts/state-manager.sh`)

#### 命令格式
```bash
./scripts/state-manager.sh <command> [arguments...]
```

#### 可用命令

| 命令 | 描述 | 参数 | 示例 |
|------|------|------|------|
| `check` | 检查状态文件完整性 | 无 | `./scripts/state-manager.sh check` |
| `backup` | 备份所有状态文件 | 无 | `./scripts/state-manager.sh backup` |
| `update-todo` | 更新TODO进度 | `<todo_id> <status> [notes] [score]` | `./scripts/state-manager.sh update-todo TODO_001 completed '任务完成' 9.0` |
| `record-decision` | 记录决策 | `<todo_id> <point> <decision> [type] [reason] [confidence]` | `./scripts/state-manager.sh record-decision TODO_001 '技术选型' '使用React' preset '基于需求选择' high` |
| `record-error` | 记录错误恢复 | `<type> <desc> <action> [success] [todo_id]` | `./scripts/state-manager.sh record-error network_error '网络连接失败' '重试3次' true TODO_001` |
| `update-quality` | 更新质量指标 | `<todo_id> <score> <issues_json>` | `./scripts/state-manager.sh update-quality TODO_001 8.5 '[{"type":"performance","severity":"medium"}]'` |
| `checkpoint` | 创建检查点 | `[name] [todo_id]` | `./scripts/state-manager.sh checkpoint '重要里程碑' TODO_005` |
| `status` | 显示状态摘要 | 无 | `./scripts/state-manager.sh status` |
| `help` | 显示帮助信息 | 无 | `./scripts/state-manager.sh help` |

#### 状态值规范

**TODO状态值**:
- `pending`: 待执行
- `in_progress`: 进行中
- `completed`: 已完成
- `failed`: 执行失败
- `skipped`: 已跳过

**决策类型值**:
- `preset`: 预设决策
- `manual`: 手动决策
- `fallback`: 备选方案
- `recovery`: 恢复决策

**信心水平值**:
- `high`: 高信心
- `medium`: 中等信心
- `low`: 低信心

#### 质量评分规范
- 范围: 0-10（整数）
- 0-3: 需要重大改进
- 4-6: 基本满足要求
- 7-8: 质量良好
- 9-10: 质量优秀

#### 错误类型规范
```bash
# 网络相关错误
network_error、connection_timeout、api_failure

# 文件系统错误
file_not_found、permission_denied、disk_full

# 系统错误
memory_insufficient、process_crashed、resource_exhausted

# 执行错误
validation_failed、quality_check_failed、dependency_missing
```

---

## 🔍 监控系统API (`scripts/execution-monitor.sh`)

#### 命令格式
```bash
./scripts/execution-monitor.sh <command>
```

#### 可用命令

| 命令 | 描述 | 用途 |
|------|------|------|
| `start` | 启动监控系统 | 开始7x24小时监控 |
| `stop` | 停止监控系统 | 停止监控进程 |
| `restart` | 重启监控系统 | 重启监控进程 |
| `status` | 显示监控状态 | 查看监控运行状态 |
| `check` | 执行健康检查 | 检查系统健康状态 |
| `refresh` | 手动触发上下文刷新 | 刷新对话上下文 |
| `report` | 生成监控报告 | 生成详细监控报告 |
| `help` | 显示帮助信息 | 查看命令帮助 |

#### 监控配置
监控系统的关键配置参数（在脚本中定义）：

```bash
MONITOR_INTERVAL=30              # 监控间隔（秒）
CONTEXT_REFRESH_INTERVAL=7200     # 上下文刷新间隔（2小时）
CHECKPOINT_INTERVAL=1800          # 检查点间隔（30分钟）
MAX_INACTIVITY_TIME=300           # 最大无活动时间（5分钟）
```

#### 监控状态文件
监控系统会在`autopilot-monitor.pid`文件中保存进程ID，用于进程管理。

---

## 🚀 执行引擎API (`scripts/autopilot-engine.sh`)

#### 命令格式
```bash
./scripts/autopilot-engine.sh <command>
```

#### 可用命令

| 命令 | 描述 | 用途 |
|------|------|------|
| `start` | 启动24小时连续自主执行 | 开始自动化执行 |
| `status` | 显示执行状态 | 查看执行进度和状态 |
| `help` | 显示帮助信息 | 查看命令帮助 |

#### 执行引擎任务类型
执行引擎支持以下任务类型，每种类型都有专门的执行逻辑：

| 任务类型 | 描述 | 输出文件 |
|----------|------|----------|
| `analysis` | 分析类任务 | `analysis-result-*.md` |
| `design` | 设计类任务 | `design-document-*.md` |
| `implementation` | 实现类任务 | `implementation-*.py` |
| `testing` | 测试类任务 | `test-suite-*.py` |
| `documentation` | 文档类任务 | `documentation-*.md` |
| `deployment` | 部署类任务 | `deployment-report-*.md` |
| `generic` | 通用任务 | `task-completion-*.md` |

#### 执行配置
```bash
MAX_EXECUTION_TIME=86400         # 最大执行时间（24小时）
SESSION_LOG_FILE="autopilot-logs/session-*.log"  # 会话日志文件
```

---

## 📋 数据结构规范

### 状态文件JSON结构

所有状态文件都遵循统一的JSON结构规范：

#### 通用字段
```json
{
  "session_id": "PREFIX_YYYYMMDD_HHMMSS_PID",
  "generated_at": "2025-10-17T10:30:00+08:00",
  "last_update_time": "2025-10-17T10:30:00+08:00"
}
```

#### REQUIREMENT_ALIGNMENT.json 结构
```json
{
  "requirement_alignment": {
    "session_id": "REQ_20251017_103000_12345",
    "user_original_task": "用户原始任务描述",
    "analyzed_requirements": {
      "functional_requirements": [],
      "non_functional_requirements": [],
      "technical_constraints": [],
      "business_constraints": []
    },
    "user_objective": {
      "primary_goal": "主要目标",
      "success_criteria": [],
      "target_users": [],
      "usage_context": "使用场景",
      "expected_outcomes": []
    },
    "alignment_verification": {
      "understanding_confirmed": true,
      "requirements_complete": true,
      "user_approval": true
    }
  }
}
```

#### TODO_TRACKER.json 结构
```json
{
  "todo_tracker": {
    "session_id": "TRACK_20251017_103000_12345",
    "overall_progress": {
      "total_todos": 10,
      "completed_todos": 3,
      "in_progress_todos": 1,
      "progress_percentage": 30
    },
    "todo_progress": [
      {
        "todo_id": "TODO_001",
        "title": "任务标题",
        "status": "completed",
        "start_time": "2025-10-17T10:30:00+08:00",
        "end_time": "2025-10-17T10:45:00+08:00",
        "duration_minutes": 15,
        "quality_score": 9.0,
        "progress_percentage": 100
      }
    ]
  }
}
```

---

## ⚠️ 错误处理

### 错误级别
- **ERROR**: 严重错误，导致程序退出
- **WARNING**: 警告信息，不影响继续执行
- **INFO**: 信息性消息

### 错误码规范
所有脚本遵循统一的错误码规范：
- `0`: 成功
- `1`: 一般错误
- `2`: 参数错误
- `3`: 文件不存在或权限问题
- `4`: JSON格式错误
- `5`: 依赖工具缺失

### 错误恢复机制
1. **自动备份**: 修改状态文件前自动创建备份
2. **回滚机制**: 操作失败时自动恢复到备份状态
3. **重试策略**: 网络和临时性错误支持重试
4. **优雅降级**: 非关键功能失败时继续执行

### 错误信息格式
```bash
[YYYY-MM-DD HH:MM:SS] SCRIPT_NAME: ERROR: 错误描述
[YYYY-MM-DD HH:MM:SS] SCRIPT_NAME: WARNING: 警告描述
[YYYY-MM-DD HH:MM:SS] SCRIPT_NAME: INFO: 信息描述
```

---

## 💡 使用示例

### 完整的执行流程示例

```bash
#!/bin/bash
# Claude Code AutoPilot 完整使用示例

# 1. 系统初始化
echo "=== 1. 初始化系统 ==="
./scripts/init-session.sh init --force

# 2. 检查初始化状态
echo "=== 2. 检查初始化状态 ==="
./scripts/init-session.sh status

# 3. 验证状态文件
echo "=== 3. 验证状态文件 ==="
./scripts/state-manager.sh check

# 4. 创建检查点
echo "=== 4. 创建初始检查点 ==="
./scripts/state-manager.sh checkpoint "初始化完成"

# 5. 启动监控系统
echo "=== 5. 启动监控系统 ==="
./scripts/execution-monitor.sh start

# 6. 模拟任务执行
echo "=== 6. 模拟任务执行 ==="
./scripts/state-manager.sh update-todo "TODO_001" "in_progress" "开始执行分析任务"
sleep 5
./scripts/state-manager.sh update-todo "TODO_001" "completed" "分析任务完成" 8.5

# 7. 记录决策
echo "=== 7. 记录执行决策 ==="
./scripts/state-manager.sh record-decision "TODO_001" "分析方法" "使用文档分析" "preset" "基于需求选择" "high"

# 8. 更新质量指标
echo "=== 8. 更新质量指标 ==="
./scripts/state-manager.sh update-quality "TODO_001" 8.5 '[{"type":"completeness","severity":"low"}]'

# 9. 查看状态摘要
echo "=== 9. 查看状态摘要 ==="
./scripts/state-manager.sh status

# 10. 生成监控报告
echo "=== 10. 生成监控报告 ==="
./scripts/execution-monitor.sh report

echo "=== 示例执行完成 ==="
```

### 错误处理示例

```bash
#!/bin/bash
# 错误处理示例

# 使用函数封装错误处理
safe_update_todo() {
    local todo_id="$1"
    local status="$2"

    if ./scripts/state-manager.sh update-todo "$todo_id" "$status"; then
        echo "✅ TODO更新成功: $todo_id"
        return 0
    else
        echo "❌ TODO更新失败: $todo_id"

        # 尝试错误恢复
        echo "🔄 尝试恢复..."
        ./scripts/state-manager.sh record-error "update_failure" "TODO更新失败" "重新尝试" false "$todo_id"

        return 1
    fi
}

# 使用示例
safe_update_todo "TODO_001" "in_progress"
```

### 批量操作示例

```bash
#!/bin/bash
# 批量TODO更新示例

TODO_LIST=("TODO_001" "TODO_002" "TODO_003")

for todo in "${TODO_LIST[@]}"; do
    echo "处理TODO: $todo"

    # 开始执行
    ./scripts/state-manager.sh update-todo "$todo" "in_progress"

    # 模拟执行
    sleep 2

    # 完成执行
    ./scripts/state-manager.sh update-todo "$todo" "completed" "批量处理完成" 8.0

    echo "✅ $todo 处理完成"
done

echo "批量处理完成，生成最终报告..."
./scripts/state-manager.sh status
```

---

## 🔧 开发指南

### 添加新命令
1. 在相应脚本中添加新函数
2. 在`main()`函数的case语句中添加新命令处理
3. 更新帮助信息
4. 添加参数验证
5. 编写错误处理逻辑

### 扩展状态文件
1. 在`templates/`目录中添加新的JSON模板
2. 更新初始化脚本以处理新文件
3. 在状态管理器中添加相应的操作函数
4. 更新API文档

### 错误处理最佳实践
1. 始终验证输入参数
2. 在关键操作前创建备份
3. 提供清晰的错误信息
4. 实现适当的重试机制
5. 记录详细的操作日志

---

## 📞 技术支持

### 故障排除
1. 检查依赖工具是否安装：`jq`, `date`, `stat`, `realpath`
2. 验证文件权限：确保脚本有执行权限
3. 检查磁盘空间：确保有足够空间创建状态文件
4. 查看日志文件：`autopilot-logs/`目录中的日志

### 常见问题
- **Q: JSON文件格式错误怎么办？**
  A: 运行 `./scripts/init-session.sh --force` 重新初始化

- **Q: 监控进程异常退出怎么办？**
  A: 检查 `autopilot-monitor.pid` 文件，然后运行 `./scripts/execution-monitor.sh restart`

- **Q: 状态文件损坏怎么办？**
  A: 从 `autopilot-backups/` 目录恢复备份文件

### 联系方式
- GitHub Issues: [项目仓库Issues](https://github.com/x-rush/claude-code-autopilot/issues)
- 文档参考: [README.md](../README.md)

---

*本文档随项目更新而更新，最新版本请参考项目仓库。*