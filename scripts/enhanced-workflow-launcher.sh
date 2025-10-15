#!/bin/bash
# Claude Code AutoPilot System 启动器
# Claude Code CLI的自动驾驶系统 - 支持深度讨论 + 详细TODO + 真正无人值守的工作流

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 加载通用配置
source "$SCRIPT_DIR/common-config.sh"

# 启用严格模式
set -euo pipefail

# =============================================================================
# 文件路径配置
# =============================================================================

WORKFLOW_STATUS_FILE="$PROJECT_ROOT/ENHANCED_WORKFLOW_STATUS.json"
REQUIREMENT_ALIGNMENT_FILE="$PROJECT_ROOT/REQUIREMENT_ALIGNMENT.json"
EXECUTION_PLAN_FILE="$PROJECT_ROOT/EXECUTION_PLAN.json"
TODO_TRACKER_FILE="$PROJECT_ROOT/TODO_TRACKER.json"
# 使用common-config.sh中定义的EXECUTION_LOG_FILE

# =============================================================================
# 日志函数
# =============================================================================

log_autopilot_workflow() {
    local level="$1"
    local message="$2"

    case "$level" in
        "INFO")
            echo -e "${GREEN}[AUTOPILOT]${NC} $(get_timestamp) - $message" | tee -a "$EXECUTION_LOG_FILE"
            ;;
        "WARN")
            echo -e "${YELLOW}[AUTOPILOT]${NC} $(get_timestamp) - $message" | tee -a "$EXECUTION_LOG_FILE"
            ;;
        "ERROR")
            echo -e "${RED}[AUTOPILOT]${NC} $(get_timestamp) - $message" | tee -a "$EXECUTION_LOG_FILE"
            ;;
        "SUCCESS")
            echo -e "${CYAN}[AUTOPILOT]${NC} $(get_timestamp) - $message" | tee -a "$EXECUTION_LOG_FILE"
            ;;
        "ALIGNMENT")
            echo -e "${MAGENTA}[ALIGNMENT]${NC} $(get_timestamp) - $message" | tee -a "$EXECUTION_LOG_FILE"
            ;;
        "PLANNING")
            echo -e "${BLUE}[PLANNING]${NC} $(get_timestamp) - $message" | tee -a "$EXECUTION_LOG_FILE"
            ;;
        "EXECUTION")
            echo -e "${WHITE}[EXECUTION]${NC} $(get_timestamp) - $message" | tee -a "$EXECUTION_LOG_FILE"
            ;;
        "TODO")
            echo -e "${YELLOW}[TODO]${NC} $(get_timestamp) - $message" | tee -a "$EXECUTION_LOG_FILE"
            ;;
    esac
}

# =============================================================================
# 工作流初始化
# =============================================================================

init_autopilot_workflow() {
    log_autopilot_workflow "INFO" "初始化Claude Code AutoPilot系统"

    # 创建必要目录
    ensure_directories

    # 初始化安全边界
    if [[ -f "$SCRIPT_DIR/safety-boundary.sh" ]]; then
        "$SCRIPT_DIR/safety-boundary.sh" --init
    fi

    # 初始化工作流状态
    cat > "$WORKFLOW_STATUS_FILE" << EOF
{
  "workflow_info": {
    "session_id": "ENH_WF_$(generate_id)",
    "start_time": "$(get_iso_timestamp)",
    "status": "INITIALIZING",
    "current_phase": "setup",
    "version": "enhanced_v2.0"
  },
  "phases": {
    "deep_discussion": {
      "status": "pending",
      "start_time": null,
      "end_time": null,
      "result_file": "$REQUIREMENT_ALIGNMENT_FILE"
    },
    "execution_planning": {
      "status": "pending",
      "start_time": null,
      "end_time": null,
      "result_file": "$EXECUTION_PLAN_FILE"
    },
    "auto_execution": {
      "status": "pending",
      "start_time": null,
      "end_time": null,
      "current_todo_id": null,
      "completed_todos": 0,
      "total_todos": 0
    },
    "self_validation": {
      "status": "pending",
      "start_time": null,
      "end_time": null,
      "validation_score": 0
    }
  },
  "safety": {
    "boundary_enabled": true,
    "allowed_root": "$PROJECT_ROOT",
    "security_events_count": 0,
    "last_security_check": null
  },
  "execution": {
    "auto_confirm_enabled": true,
    "self_check_enabled": true,
    "deviation_correction_enabled": true,
    "progress_percentage": 0
  }
}
EOF

    # 创建执行日志
    {
        echo "# Claude Code AutoPilot System 执行日志"
        echo "会话ID: AUTOPILOT_$(generate_id)"
        echo "开始时间: $(get_iso_timestamp)"
        echo "系统版本: autopilot_v2.0"
        echo ""
    } > "$EXECUTION_LOG_FILE"

    log_autopilot_workflow "SUCCESS" "AutoPilot系统初始化完成"
}

# =============================================================================
# 第一阶段：深度需求讨论
# =============================================================================

start_deep_discussion() {
    log_autopilot_workflow "ALIGNMENT" "开始深度需求讨论阶段"

    # 生成深度讨论启动命令 - 使用外部模板文件确保语法正确
    local discussion_command_file="$PROJECT_ROOT/START_DISCUSSION_COMMAND.txt"

    cat > "$discussion_command_file" << 'COMMAND_EOF'
claude "我将为你执行一个复杂的项目，为了确保完美执行，我需要先进行深度需求讨论。

## 🎯 深度需求讨论流程

这个讨论将分为四个阶段，确保我们完全明确所有细节：

### 第一阶段：核心目标理解 (3-5分钟)
- 最终想要的具体成果
- 成果的使用场景和用户
- 完成的质量标准

### 第二阶段：执行细节挖掘 (5-8分钟)
- 技术实现偏好
- 风险容忍度
- 特殊要求和约束

### 第三阶段：决策点识别 (3-5分钟)
- 可能遇到的决策点
- 每个决策点的处理偏好
- 备选方案优先级

### 第四阶段：执行计划生成 (自动)
- 基于讨论生成详细TODO清单
- 预设所有决策点的解决方案
- 设定安全边界和质量标准

**这个深度讨论结束后，我将生成完整的执行计划，然后开始24小时无人值守执行。**

你准备好开始深度需求讨论了吗？"
COMMAND_EOF

    log_autopilot_workflow "INFO" "深度讨论命令已准备"
    echo -e "${CYAN}=== 深度需求讨论阶段 ===${NC}"
    echo -e "${YELLOW}请在新的终端中执行以下命令开始深度讨论：${NC}"
    echo ""
    echo -e "${GREEN}$(cat "$discussion_command_file")${NC}"
    echo ""
    echo -e "${CYAN}💡 提示：${NC}"
    echo -e "  - 可以直接复制上面的命令到新终端执行"
    echo -e "  - 参考 ${YELLOW}template-docs/REQUIREMENT_ALIGNMENT.md${NC} 进行结构化讨论"
    echo -e "  - 深度讨论完成后，执行：${GREEN}$0 --complete-discussion${NC}"
    echo ""

    # 清理临时文件
    rm -f "$discussion_command_file"
}

# 完成深度讨论
complete_deep_discussion() {
    log_autopilot_workflow "ALIGNMENT" "完成深度需求讨论阶段"

    # 检查需求对齐文件是否存在
    if [[ ! -f "$REQUIREMENT_ALIGNMENT_FILE" ]]; then
        log_autopilot_workflow "ERROR" "需求对齐文件不存在，请确保深度讨论完成"
        echo -e "${RED}❌ 未找到需求对齐文件: $REQUIREMENT_ALIGNMENT_FILE${NC}"
        echo -e "${YELLOW}请先完成深度需求讨论并生成REQUIREMENT_ALIGNMENT.json文件${NC}"
        return 1
    fi

    log_autopilot_workflow "SUCCESS" "深度需求讨论完成，准备生成执行计划"
    echo -e "${GREEN}✅ 深度需求讨论阶段完成${NC}"
    return 0
}

# =============================================================================
# 第二阶段：执行计划生成
# =============================================================================

generate_execution_plan() {
    log_autopilot_workflow "PLANNING" "开始生成详细执行计划"

    # 生成执行计划生成命令
    local planning_command_file="$PROJECT_ROOT/GENERATE_PLAN_COMMAND.txt"

    cat > "$planning_command_file" << 'COMMAND_EOF'
claude "基于我们的深度需求讨论结果，我现在需要生成详细的执行计划。

请按照以下结构生成执行计划：

## 📋 执行计划生成要求

### 1. 识别所有决策点
回顾我们的讨论，识别出执行中可能遇到的任何决策点，并为每个决策点预设解决方案。

### 2. 生成详细TODO清单
将整个项目分解为具体的、可执行的TODO项目，每个TODO包括：
- 清晰的任务描述
- 具体的验收标准
- 预估执行时间
- 依赖关系
- 自我检查点

### 3. 设定安全边界
- 确认只在项目目录内操作
- 设定文件操作限制
- 定义危险操作禁止规则

### 4. 质量控制标准
- 每个TODO的质量检查方法
- 整体质量验证标准
- 自我检查频率

**请生成完整的EXECUTION_PLAN.json文件，包含所有这些信息。生成完成后，我将基于此计划开始真正的无人值守执行。"
COMMAND_EOF

    log_autopilot_workflow "INFO" "执行计划生成命令已准备"
    echo -e "${CYAN}=== 执行计划生成阶段 ===${NC}"
    echo -e "${YELLOW}请在新的终端中执行以下命令生成执行计划：${NC}"
    echo ""
    echo -e "${GREEN}$(cat "$planning_command_file")${NC}"
    echo ""
    echo -e "${CYAN}💡 提示：${NC}"
    echo -e "  - 参考 ${YELLOW}template-docs/EXECUTION_PLAN.md${NC} 了解详细结构要求"
    echo -e "  - 确保生成完整的EXECUTION_PLAN.json文件"
    echo -e "  - 执行计划生成完成后，执行：${GREEN}$0 --complete-planning${NC}"
    echo ""

    # 清理临时文件
    rm -f "$planning_command_file"
}

# 完成执行计划
complete_execution_planning() {
    log_autopilot_workflow "PLANNING" "完成执行计划生成阶段"

    # 检查执行计划文件是否存在
    if [[ ! -f "$EXECUTION_PLAN_FILE" ]]; then
        log_autopilot_workflow "ERROR" "执行计划文件不存在，请确保计划生成完成"
        echo -e "${RED}❌ 未找到执行计划文件: $EXECUTION_PLAN_FILE${NC}"
        echo -e "${YELLOW}请先生成详细的EXECUTION_PLAN.json文件${NC}"
        return 1
    fi

    # 初始化TODO跟踪器
    local total_todos=$(jq -r '.execution_todos | length' "$EXECUTION_PLAN_FILE" 2>/dev/null || echo "0")

    cat > "$TODO_TRACKER_FILE" << EOF
{
  "tracker_info": {
    "session_id": "TODO_$(generate_id)",
    "execution_plan_id": "$(jq -r '.session_id' "$EXECUTION_PLAN_FILE")",
    "start_time": "$(get_iso_timestamp)",
    "total_todos": $total_todos,
    "completed_todos": 0,
    "current_todo": null
  },
  "todo_progress": [],
  "decision_log": [],
  "quality_scores": [],
  "execution_timeline": []
}
EOF

    log_autopilot_workflow "SUCCESS" "执行计划生成完成，TODO总数: $total_todos"
    echo -e "${GREEN}✅ 执行计划生成完成，共规划 $total_todos 个TODO任务${NC}"
    return 0
}

# =============================================================================
# 第三阶段：真正无人值守执行
# =============================================================================

start_autonomous_execution() {
    log_autopilot_workflow "EXECUTION" "开始真正无人值守执行"

    # 生成无人值守执行命令
    local execution_command_file="$PROJECT_ROOT/START_EXECUTION_COMMAND.txt"

    cat > "$execution_command_file" << COMMAND_EOF
claude "执行计划已生效，我现在开始真正的无人值守执行。

## 🚀 无人值守执行启动

### 执行基础
- 执行计划ID: $(jq -r '.session_id' "$EXECUTION_PLAN_FILE")
- TODO总数: $(jq -r '.execution_todos | length' "$EXECUTION_PLAN_FILE")
- 安全边界: 已启用（仅限项目目录）
- 自动确认: 已启用
- 自我检查: 已启用

### 执行承诺
我将严格按照以下原则执行：
1. **完全按照TODO清单执行** - 不偏离预设计划
2. **所有决策基于预设方案** - 不需要人工干预
3. **持续自我检查和验证** - 确保质量符合标准
4. **严格遵守安全边界** - 只在项目目录内操作
5. **实时记录执行进度** - 完全透明的进度追踪

### 执行监控
- 每个TODO完成后自动验证
- 偏差检测和自动纠正
- 安全事件实时记录
- 进度和质量实时更新

**我现在开始24小时无人值守执行，严格按照执行计划进行，确保最终结果完全符合我们的深度讨论和执行计划要求。"
COMMAND_EOF

    log_autopilot_workflow "INFO" "无人值守执行命令已生成"
    echo -e "${CYAN}=== 真正无人值守执行阶段 ===${NC}"
    echo -e "${YELLOW}请在新的终端中执行以下命令启动无人值守执行：${NC}"
    echo ""
    echo -e "${GREEN}$(cat "$execution_command_file")${NC}"
    echo ""
    echo -e "${CYAN}🔥 重要提示：${NC}"
    echo -e "  - ${RED}此阶段将开始完全无人值守执行${NC}"
    echo -e "  - Claude将严格按照EXECUTION_PLAN.json执行"
    echo -e "  - 可以通过 ${GREEN}$0 --status${NC} 实时查看进度"
    echo -e "  - 所有操作都在安全边界内进行"
    echo ""

    # 更新配置以启用真正的自动执行
    update_config_for_autonomous_execution

    # 启动后台监控进程
    start_background_monitors

    log_autopilot_workflow "SUCCESS" "无人值守执行已启动"

    # 清理临时文件
    rm -f "$execution_command_file"
}

# 更新配置支持无人值守
update_config_for_autonomous_execution() {
    log_autopilot_workflow "INFO" "更新配置支持无人值守执行"

    # 创建临时配置文件
    local temp_config="$PROJECT_ROOT/autonomous_config.json"

    cat > "$temp_config" << EOF
{
  "execution_mode": "autonomous",
  "auto_confirm": true,
  "self_check_enabled": true,
  "safety_boundary": true,
  "max_execution_hours": 24,
  "progress_report_interval": 60,
  "quality_check_interval": 30,
  "deviation_correction": "auto"
}
EOF

    log_autopilot_workflow "INFO" "无人值守配置已更新"
}

# 启动后台监控
start_background_monitors() {
    log_autopilot_workflow "INFO" "启动后台监控进程"

    # 启动安全边界监控
    if [[ -f "$SCRIPT_DIR/safety-boundary.sh" ]]; then
        (
            while true; do
                sleep 300  # 每5分钟检查一次
                "$SCRIPT_DIR/safety-boundary.sh" --status >> "$PROJECT_ROOT/SAFETY_MONITOR_LOG.md" 2>&1
            done
        ) &
        local safety_pid=$!
        log_autopilot_workflow "INFO" "安全边界监控已启动 PID: $safety_pid"
    fi

    # 启动进度监控
    (
        while true; do
            sleep 180  # 每3分钟检查一次
            update_execution_progress
        done
    ) &
    local progress_pid=$!
    log_autopilot_workflow "INFO" "进度监控已启动 PID: $progress_pid"
}

# 更新执行进度
update_execution_progress() {
    if [[ -f "$TODO_TRACKER_FILE" && -f "$EXECUTION_PLAN_FILE" ]]; then
        local completed=$(jq -r '.completed_todos' "$TODO_TRACKER_FILE" 2>/dev/null || echo "0")
        local total=$(jq -r '.total_todos' "$TODO_TRACKER_FILE" 2>/dev/null || echo "1")
        local progress=$((completed * 100 / total))

        # 更新工作流状态
        jq --arg progress "$progress" --arg completed "$completed" --arg total "$total" '
            .execution.progress_percentage = ($progress | tonumber) |
            .phases.auto_execution.completed_todos = ($completed | tonumber) |
            .phases.auto_execution.total_todos = ($total | tonumber) |
            .workflow_info.last_update = "$(get_iso_timestamp)"
        ' "$WORKFLOW_STATUS_FILE" > temp_status.json && mv temp_status.json "$WORKFLOW_STATUS_FILE"

        log_autopilot_workflow "INFO" "执行进度更新: $completed/$total $progress%"
    fi
}

# =============================================================================
# 状态显示和帮助
# =============================================================================

show_autopilot_status() {
    echo -e "${WHITE}=== Claude Code AutoPilot System 状态 ===${NC}"
    echo ""

    if [[ -f "$WORKFLOW_STATUS_FILE" ]]; then
        echo -e "${CYAN}工作流信息:${NC}"
        echo "  会话ID: $(jq -r '.workflow_info.session_id' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "未知")"
        echo "  开始时间: $(jq -r '.workflow_info.start_time' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "未知")"
        echo "  状态: $(jq -r '.workflow_info.status' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "未知")"
        echo ""

        echo -e "${CYAN}阶段状态:${NC}"
        echo "  深度讨论: $(jq -r '.phases.deep_discussion.status' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "未知")"
        echo "  执行计划: $(jq -r '.phases.execution_planning.status' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "未知")"
        echo "  自动执行: $(jq -r '.phases.auto_execution.status' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "未知")"
        echo "  自我验证: $(jq -r '.phases.self_validation.status' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "未知")"
        echo ""

        echo -e "${CYAN}安全状态:${NC}"
        local safety_enabled=$(jq -r '.safety.boundary_enabled' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "false")
        local security_events=$(jq -r '.safety.security_events_count' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "0")
        echo -e "  安全边界: $([ "$safety_enabled" = true ] && echo "${GREEN}启用${NC}" || echo "${RED}禁用${NC}")"
        echo -e "  安全事件: $security_events 次"
        echo ""

        echo -e "${CYAN}执行状态:${NC}"
        local progress=$(jq -r '.execution.progress_percentage' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "0")
        local auto_confirm=$(jq -r '.execution.auto_confirm_enabled' "$WORKFLOW_STATUS_FILE" 2>/dev/null || echo "false")
        echo -e "  执行进度: ${progress}%"
        echo -e "  自动确认: $([ "$auto_confirm" = true ] && echo "${GREEN}启用${NC}" || echo "${RED}禁用${NC}")"

        # TODO进度详情
        if [[ -f "$TODO_TRACKER_FILE" ]]; then
            echo ""
            echo -e "${CYAN}TODO进度详情:${NC}"
            local completed=$(jq -r '.completed_todos' "$TODO_TRACKER_FILE" 2>/dev/null || echo "0")
            local total=$(jq -r '.total_todos' "$TODO_TRACKER_FILE" 2>/dev/null || echo "0")
            local current=$(jq -r '.current_todo' "$TODO_TRACKER_FILE" 2>/dev/null || echo "null")
            echo -e "  已完成: $completed/$total"
            echo -e "  当前任务: $([ "$current" != "null" ] && echo "$current" || echo "无")"
        fi

        # 文件状态
        echo ""
        echo -e "${CYAN}文件状态:${NC}"
        echo -e "  需求对齐: $([ -f "$REQUIREMENT_ALIGNMENT_FILE" ] && echo "${GREEN}存在${NC}" || echo "${RED}缺失${NC}")"
        echo -e "  执行计划: $([ -f "$EXECUTION_PLAN_FILE" ] && echo "${GREEN}存在${NC}" || echo "${RED}缺失${NC}")"
        echo -e "  TODO跟踪: $([ -f "$TODO_TRACKER_FILE" ] && echo "${GREEN}存在${NC}" || echo "${RED}缺失${NC}")"
        echo -e "  执行日志: $([ -f "$EXECUTION_LOG_FILE" ] && echo "${GREEN}存在${NC}" || echo "${RED}缺失${NC}")"

    else
        echo -e "${RED}工作流状态文件不存在${NC}"
        echo -e "${YELLOW}请先执行: $0 --start${NC}"
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
${WHITE}Claude Code AutoPilot System 启动器 v2.0${NC}

${CYAN}用法:${NC} $0 [选项]

${YELLOW}选项:${NC}
    --start                    启动AutoPilot工作流（深度讨论模式）
    --complete-discussion     完成深度讨论阶段
    --complete-planning       完成执行计划生成阶段
    --start-autonomous        开始无人值守执行
    --status                   显示工作流状态
    --help                     显示此帮助信息

${CYAN}AutoPilot工作流流程:${NC}
    1. $0 --start                # 启动深度需求讨论
    2. 执行深度讨论命令
    3. $0 --complete-discussion # 标记讨论完成
    4. 执行计划生成命令
    5. $0 --complete-planning   # 标记计划完成
    6. $0 --start-autonomous    # 开始无人值守执行

${GREEN}安全特性:${NC}
    - 项目目录内安全边界
    - 危险操作自动阻止
    - 24小时无人值守执行
    - 完全的执行透明度

${BLUE}文件说明:${NC}
    - template-docs/REQUIREMENT_ALIGNMENT.md  # 需求对齐模板
    - template-docs/EXECUTION_PLAN.md         # 执行计划模板
    - ENHANCED_WORKFLOW_STATUS.json           # 工作流状态
    - EXECUTION_PLAN.json                     # 详细执行计划
    - TODO_TRACKER.json                       # TODO进度跟踪

EOF
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    # 检查依赖
    if ! check_dependencies; then
        log_autopilot_workflow "ERROR" "依赖检查失败，请安装必要的工具"
        echo -e "${RED}❌ 依赖检查失败，请参考README.md安装必需工具${NC}"
        exit 1
    fi

    # 初始化工作流
    init_autopilot_workflow

    case "${1:-}" in
        "--start")
            log_autopilot_workflow "INFO" "启动Claude Code AutoPilot系统"
            start_deep_discussion
            ;;
        "--complete-discussion")
            complete_deep_discussion
            if [[ $? -eq 0 ]]; then
                generate_execution_plan
            fi
            ;;
        "--complete-planning")
            complete_execution_planning
            if [[ $? -eq 0 ]]; then
                start_autonomous_execution
            fi
            ;;
        "--start-autonomous")
            start_autonomous_execution
            ;;
        "--status")
            show_autopilot_status
            ;;
        "--help"|"")
            show_help
            ;;
        *)
            log_autopilot_workflow "ERROR" "未知选项: $1"
            echo -e "${RED}❌ 未知选项: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi