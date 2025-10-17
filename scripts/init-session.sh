#!/bin/bash

# Claude Code AutoPilot - 轻量级初始化脚本
# 专注于MD规划文档+JSON状态记录的核心功能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 版本信息
VERSION="1.0.0"

# 日志函数
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 显示帮助信息
show_help() {
    echo "Claude Code AutoPilot 轻量级初始化脚本 v$VERSION"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -u, --uninstall     卸载AutoPilot状态文件"
    echo "  -v, --version       显示版本信息"
    echo "  -s, --status        显示初始化状态"
    echo ""
    echo "功能:"
    echo "  - 初始化JSON状态文件（5个核心文件）"
    echo "  - 支持Claude Code自动发现和加载"
    echo "  - 轻量级设计，专注于MD+JSON记录"
    echo ""
    echo "状态文件:"
    echo "  - REQUIREMENT_ALIGNMENT.json  需求对齐配置"
    echo "  - EXECUTION_PLAN.json         执行计划配置"
    echo "  - TODO_TRACKER.json          TODO进度跟踪"
    echo "  - DECISION_LOG.json          决策日志记录"
    echo "  - EXECUTION_STATE.json       执行状态管理"
}

# 显示版本信息
show_version() {
    echo "Claude Code AutoPilot 初始化脚本 v$VERSION"
    echo "更新时间: 2025-10-17"
}

# 检查依赖
check_dependencies() {
    log "检查系统依赖..."

    local missing_deps=()

    # 检查基本工具
    for tool in jq date stat realpath; do
        if ! command -v "$tool" &> /dev/null; then
            missing_deps+=("$tool")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "缺少以下依赖工具: ${missing_deps[*]}"
        echo ""
        echo "Ubuntu/Debian 安装命令:"
        echo "  sudo apt-get install ${missing_deps[*]}"
        echo ""
        echo "macOS 安装命令:"
        echo "  brew install ${missing_deps[*]}"
        exit 1
    fi

    log "✅ 所有依赖检查通过"
}

# 生成唯一ID
generate_session_id() {
    local prefix="$1"
    echo "${prefix}_$(date +%Y%m%d_%H%M%S)_$$"
}

# 获取时间戳
get_timestamp() {
    date -Iseconds
}

# 初始化需求对齐文件
init_requirement_alignment() {
    log "初始化需求对齐文件..."

    local session_id=$(generate_session_id "REQ")
    local timestamp=$(get_timestamp)

    # 从模板复制并初始化
    jq --arg session_id "$session_id" \
       --arg timestamp "$timestamp" \
       '.requirement_alignment.session_id = $session_id |
        .requirement_alignment.alignment_time = $timestamp |
        .requirement_alignment.user_original_task = "" |
        .requirement_alignment.analyzed_requirements.functional_requirements = [] |
        .requirement_alignment.analyzed_requirements.non_functional_requirements = [] |
        .requirement_alignment.analyzed_requirements.technical_constraints = [] |
        .requirement_alignment.analyzed_requirements.business_constraints = [] |
        .requirement_alignment.user_objective.primary_goal = "" |
        .requirement_alignment.user_objective.success_criteria = [] |
        .requirement_alignment.user_objective.target_users = [] |
        .requirement_alignment.user_objective.usage_context = "" |
        .requirement_alignment.user_objective.expected_outcomes = [] |
        .requirement_alignment.deliverables = [] |
        .requirement_alignment.preset_decisions = [] |
        .requirement_alignment.alignment_verification.understanding_confirmed = false |
        .requirement_alignment.alignment_verification.requirements_complete = false |
        .requirement_alignment.alignment_verification.decisions_preset = false |
        .requirement_alignment.alignment_verification.quality_standards_set = false |
        .requirement_alignment.alignment_verification.user_approval = false' \
       templates/REQUIREMENT_ALIGNMENT.json > REQUIREMENT_ALIGNMENT.json

    log "✅ 需求对齐文件已初始化: $session_id"
}

# 初始化执行计划文件
init_execution_plan() {
    log "初始化执行计划文件..."

    local session_id=$(generate_session_id "EXEC")
    local timestamp=$(get_timestamp)
    local req_id=$(jq -r '.requirement_alignment.session_id' REQUIREMENT_ALIGNMENT.json)

    # 从模板复制并初始化
    jq --arg session_id "$session_id" \
       --arg timestamp "$timestamp" \
       --arg req_id "$req_id" \
       --arg working_dir "$(realpath .)" \
       '.execution_plan.session_id = $session_id |
        .execution_plan.based_on_requirement = $req_id |
        .execution_plan.generated_at = $timestamp |
        .execution_plan.estimated_duration_hours = 0 |
        .execution_plan.total_todos = 0 |
        .execution_plan.execution_todos = [] |
        .execution_plan.execution_phases = [] |
        .execution_plan.execution_gates = [] |
        .execution_plan.safety_boundaries.workspace_root = $working_dir |
        .execution_plan.safety_boundaries.allowed_directories = ["./", "./src", "./docs", "./tests", "./scripts"] |
        .execution_plan.context_management.key_information_retention = [] |
        .execution_plan.recovery_and_resilience.auto_recovery_enabled = true |
        .execution_plan.completion_criteria.all_todos_completed = false |
        .execution_plan.completion_criteria.all_quality_gates_passed = false |
        .execution_plan.completion_criteria.requirement_alignment_valid = false' \
       templates/EXECUTION_PLAN.json > EXECUTION_PLAN.json

    log "✅ 执行计划文件已初始化: $session_id"
}

# 初始化TODO跟踪文件
init_todo_tracker() {
    log "初始化TODO跟踪文件..."

    local session_id=$(generate_session_id "TRACK")
    local timestamp=$(get_timestamp)
    local exec_id=$(jq -r '.execution_plan.session_id' EXECUTION_PLAN.json)
    local req_id=$(jq -r '.requirement_alignment.session_id' REQUIREMENT_ALIGNMENT.json)

    # 从模板复制并初始化
    jq --arg session_id "$session_id" \
       --arg timestamp "$timestamp" \
       --arg exec_id "$exec_id" \
       --arg req_id "$req_id" \
       '.todo_tracker.session_id = $session_id |
        .todo_tracker.execution_plan_id = $exec_id |
        .todo_tracker.requirement_alignment_id = $req_id |
        .todo_tracker.tracking_start_time = $timestamp |
        .todo_tracker.last_update_time = $timestamp |
        .todo_tracker.overall_progress.total_todos = 0 |
        .todo_tracker.overall_progress.completed_todos = 0 |
        .todo_tracker.overall_progress.in_progress_todos = 0 |
        .todo_tracker.overall_progress.failed_todos = 0 |
        .todo_tracker.overall_progress.skipped_todos = 0 |
        .todo_tracker.overall_progress.progress_percentage = 0 |
        .todo_tracker.todo_progress = [] |
        .todo_tracker.phase_progress = [] |
        .todo_tracker.quality_metrics.overall_quality_score = 0 |
        .todo_tracker.requirement_alignment_tracking.alignment_checks_performed = 0 |
        .todo_tracker.decision_tracking.decisions_made = 0 |
        .todo_tracker.error_and_recovery_tracking.total_errors = 0 |
        .todo_tracker.context_management.context_health_score = 10.0 |
        .todo_tracker.checkpoint_data.available_checkpoints = []' \
       templates/TODO_TRACKER.json > TODO_TRACKER.json

    log "✅ TODO跟踪文件已初始化: $session_id"
}

# 初始化决策日志文件
init_decision_log() {
    log "初始化决策日志文件..."

    local session_id=$(generate_session_id "DEC")
    local timestamp=$(get_timestamp)
    local exec_id=$(jq -r '.execution_plan.session_id' EXECUTION_PLAN.json)
    local req_id=$(jq -r '.requirement_alignment.session_id' REQUIREMENT_ALIGNMENT.json)

    # 从模板复制并初始化
    jq --arg session_id "$session_id" \
       --arg timestamp "$timestamp" \
       --arg exec_id "$exec_id" \
       --arg req_id "$req_id" \
       '.decision_log.session_id = $session_id |
        .decision_log.execution_plan_id = $exec_id |
        .decision_log.requirement_alignment_id = $req_id |
        .decision_log.logging_start_time = $timestamp |
        .decision_log.last_update_time = $timestamp |
        .decision_log.decision_statistics.total_decisions_made = 0 |
        .decision_log.decision_statistics.preset_decisions_used = 0 |
        .decision_log.decision_statistics.manual_decisions_required = 0 |
        .decision_log.decision_timeline = [] |
        .decision_log.preset_decision_usage.preset_decision_analysis = [] |
        .decision_log.manual_decision_tracking.manual_decisions_required = 0 |
        .decision_log.learning_and_improvement.improvement_recommendations = [] |
        .decision_log.decision_audit_trail.audit_entries = []' \
       templates/DECISION_LOG.json > DECISION_LOG.json

    log "✅ 决策日志文件已初始化: $session_id"
}

# 初始化执行状态文件
init_execution_state() {
    log "初始化执行状态文件..."

    local session_id=$(generate_session_id "STATE")
    local timestamp=$(get_timestamp)
    local exec_id=$(jq -r '.execution_plan.session_id' EXECUTION_PLAN.json)
    local req_id=$(jq -r '.requirement_alignment.session_id' REQUIREMENT_ALIGNMENT.json)

    # 从模板复制并初始化
    jq --arg session_id "$session_id" \
       --arg timestamp "$timestamp" \
       --arg exec_id "$exec_id" \
       --arg req_id "$req_id" \
       --arg working_dir "$(realpath .)" \
       '.execution_state.session_id = $session_id |
        .execution_state.execution_plan_id = $exec_id |
        .execution_state.requirement_alignment_id = $req_id |
        .execution_state.state_creation_time = $timestamp |
        .execution_state.last_state_update = $timestamp |
        .execution_state.session_metadata.claude_session_start_time = $timestamp |
        .execution_state.session_metadata.total_execution_duration_minutes = 0 |
        .execution_state.session_metadata.session_type = "interactive" |
        .execution_state.session_metadata.recovery_count = 0 |
        .execution_state.session_metadata.context_refresh_count = 0 |
        .execution_state.current_execution_position.execution_progress_percentage = 0 |
        .execution_state.execution_environment.working_directory = $working_dir |
        .execution_state.execution_environment.project_root_directory = $working_dir |
        .execution_state.context_management.current_context_size_estimate = 0 |
        .execution_state.context_management.context_window_utilization_percent = 0 |
        .execution_state.context_management.context_health_score = 10.0 |
        .execution_state.error_and_recovery_state.current_error_status = "no_error" |
        .execution_state.error_and_recovery_state.active_error_count = 0 |
        .execution_state.quality_control_state.current_quality_score = 0 |
        .execution_state.system_health.overall_health_score = 10.0 |
        .execution_state.system_health.health_status = "excellent" |
        .execution_state.next_steps_and_projections.immediate_next_action.estimated_start_time = $timestamp' \
       templates/EXECUTION_STATE.json > EXECUTION_STATE.json

    log "✅ 执行状态文件已初始化: $session_id"
}

# 初始化所有状态文件
init_all_states() {
    log "开始初始化AutoPilot状态文件..."

    check_dependencies
    init_requirement_alignment
    init_execution_plan
    init_todo_tracker
    init_decision_log
    init_execution_state

    log "🎉 所有状态文件初始化完成！"
    echo ""
    echo "📁 已创建的文件："
    echo "  - REQUIREMENT_ALIGNMENT.json  需求对齐配置"
    echo "  - EXECUTION_PLAN.json         执行计划配置"
    echo "  - TODO_TRACKER.json          TODO进度跟踪"
    echo "  - DECISION_LOG.json          决策日志记录"
    echo "  - EXECUTION_STATE.json       执行状态管理"
    echo ""
    echo "🚀 现在可以使用AutoPilot命令："
    echo "  /autopilot-continuous-start  # 开始需求讨论和规划"
    echo "  /autopilot-status           # 查看当前状态"
    echo ""
    echo "💡 轻量级设计：专注于MD规划文档+JSON状态记录"
}

# 显示初始化状态
show_status() {
    echo "Claude Code AutoPilot 状态检查"
    echo "============================"
    echo ""

    local required_files=(
        "REQUIREMENT_ALIGNMENT.json"
        "EXECUTION_PLAN.json"
        "TODO_TRACKER.json"
        "DECISION_LOG.json"
        "EXECUTION_STATE.json"
    )

    local all_exists=true
    local total_size=0

    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            local session_id=$(jq -r '.session_id // "未知"' "$file" 2>/dev/null || echo "解析失败")
            local file_size=$(stat -c%s "$file" 2>/dev/null || echo "0")
            total_size=$((total_size + file_size))
            echo "✅ $file (会话ID: $session_id, 大小: ${file_size}字节)"
        else
            echo "❌ $file (文件不存在)"
            all_exists=false
        fi
    done

    echo ""
    if [ "$all_exists" = true ]; then
        echo "🎉 系统状态: 已完全初始化"
        echo "📊 总文件大小: ${total_size}字节"
        echo "💡 建议下一步: 运行 /autopilot-continuous-start"
    else
        echo "⚠️  系统状态: 部分或完全未初始化"
        echo "💡 建议操作: 运行 '$0' 进行初始化"
    fi

    echo ""
    echo "🔧 系统状态："

    # 检查Claude Code
    if command -v claude &> /dev/null; then
        echo "  Claude Code CLI: ✅ 已安装"
    else
        echo "  Claude Code CLI: ❌ 未安装"
    fi

    # 检查依赖工具
    local missing_tools=()
    for tool in jq date stat realpath; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -eq 0 ]; then
        echo "  系统依赖: ✅ 完整"
    else
        echo "  系统依赖: ❌ 缺少 ${missing_tools[*]}"
    fi
}

# 卸载状态文件
uninstall_states() {
    local files_to_remove=(
        "REQUIREMENT_ALIGNMENT.json"
        "EXECUTION_PLAN.json"
        "TODO_TRACKER.json"
        "DECISION_LOG.json"
        "EXECUTION_STATE.json"
    )

    local files_exist=()
    for file in "${files_to_remove[@]}"; do
        if [ -f "$file" ]; then
            files_exist+=("$file")
        fi
    done

    if [ ${#files_exist[@]} -eq 0 ]; then
        warn "未发现任何状态文件"
        return 0
    fi

    warn "准备删除以下状态文件："
    for file in "${files_exist[@]}"; do
        echo "  - $file"
    done
    echo ""

    read -p "确认要删除这些文件吗？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消删除"
        exit 0
    fi

    for file in "${files_exist[@]}"; do
        rm -f "$file"
        log "✅ 已删除: $file"
    done

    log "🎉 所有状态文件已删除！"
}

# 主函数
main() {
    local action="init"

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -u|--uninstall)
                action="uninstall"
                shift
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -s|--status)
                action="status"
                shift
                ;;
            *)
                error "未知参数: $1，使用 --help 查看帮助"
                ;;
        esac
    done

    case "$action" in
        "init")
            # 检查是否已经初始化
            if [ -f "REQUIREMENT_ALIGNMENT.json" ] && [ -f "EXECUTION_PLAN.json" ]; then
                warn "检测到状态文件已存在"
                read -p "是否要重新初始化？这将覆盖现有状态 (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log "保持现有状态，初始化取消"
                    exit 0
                fi
            fi

            # 检查模板文件是否存在
            if [ ! -d "templates" ]; then
                error "templates目录不存在，请确保在正确的项目目录中执行"
            fi

            local required_templates=(
                "templates/REQUIREMENT_ALIGNMENT.json"
                "templates/EXECUTION_PLAN.json"
                "templates/TODO_TRACKER.json"
                "templates/DECISION_LOG.json"
                "templates/EXECUTION_STATE.json"
            )

            for template in "${required_templates[@]}"; do
                if [ ! -f "$template" ]; then
                    error "缺少模板文件: $template"
                fi
            done

            init_all_states
            ;;
        "status")
            show_status
            ;;
        "uninstall")
            uninstall_states
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi