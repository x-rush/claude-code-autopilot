#!/bin/bash
# Claude Code AutoPilot - 启动初始化脚本
# 在开始执行前初始化所有必要的状态文件

set -euo pipefail

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] AUTOPILOT-INIT: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] AUTOPILOT-INIT: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] AUTOPILOT-INIT: WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] AUTOPILOT-INIT: ERROR: $1${NC}"
}

# 生成唯一ID
generate_session_id() {
    local prefix="$1"
    echo "${prefix}_$(date +%Y%m%d_%H%M%S)_$$"
}

# 检查依赖
check_dependencies() {
    log "检查系统依赖..."

    local missing_deps=()

    for tool in jq date stat realpath; do
        if ! which "$tool" &>/dev/null; then
            missing_deps+=("$tool")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "缺少依赖工具: ${missing_deps[*]}"
        return 1
    fi

    log "依赖检查通过"
}

# 验证环境
validate_environment() {
    log "验证执行环境..."

    # 检查当前目录
    if [ ! -f ".claude-plugin/plugin.json" ]; then
        error "请在AutoPilot插件根目录下执行"
        return 1
    fi

    # 检查templates目录
    if [ ! -d "templates" ]; then
        error "templates目录不存在"
        return 1
    fi

    # 检查模板文件
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
            return 1
        fi
    done

    log "环境验证通过"
}

# 初始化需求对齐文件
init_requirement_alignment() {
    log "初始化需求对齐文件..."

    local session_id=$(generate_session_id "REQ")
    local timestamp=$(date -Iseconds)

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

    log "需求对齐文件已初始化: $session_id"
}

# 初始化执行计划文件
init_execution_plan() {
    log "初始化执行计划文件..."

    local session_id=$(generate_session_id "EXEC")
    local timestamp=$(date -Iseconds)
    local req_id=$(jq -r '.requirement_alignment.session_id' REQUIREMENT_ALIGNMENT.json)

    # 从模板复制并初始化
    jq --arg session_id "$session_id" \
       --arg timestamp "$timestamp" \
       --arg req_id "$req_id" \
       '.execution_plan.session_id = $session_id |
        .execution_plan.based_on_requirement = $req_id |
        .execution_plan.generated_at = $timestamp |
        .execution_plan.estimated_duration_hours = 0 |
        .execution_plan.total_todos = 0 |
        .execution_plan.execution_todos = [] |
        .execution_plan.execution_phases = [] |
        .execution_plan.execution_gates = [] |
        .execution_plan.safety_boundaries.workspace_root = "'$(realpath .)'" |
        .execution_plan.safety_boundaries.allowed_directories = ["./", "./src", "./docs", "./tests", "./scripts"] |
        .execution_plan.context_management.key_information_retention = [] |
        .execution_plan.recovery_and_resilience.auto_recovery_enabled = true |
        .execution_plan.completion_criteria.all_todos_completed = false |
        .execution_plan.completion_criteria.all_quality_gates_passed = false |
        .execution_plan.completion_criteria.requirement_alignment_valid = false' \
       templates/EXECUTION_PLAN.json > EXECUTION_PLAN.json

    log "执行计划文件已初始化: $session_id"
}

# 初始化TODO跟踪文件
init_todo_tracker() {
    log "初始化TODO跟踪文件..."

    local session_id=$(generate_session_id "TRACK")
    local timestamp=$(date -Iseconds)
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

    log "TODO跟踪文件已初始化: $session_id"
}

# 初始化决策日志文件
init_decision_log() {
    log "初始化决策日志文件..."

    local session_id=$(generate_session_id "DEC")
    local timestamp=$(date -Iseconds)
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

    log "决策日志文件已初始化: $session_id"
}

# 初始化执行状态文件
init_execution_state() {
    log "初始化执行状态文件..."

    local session_id=$(generate_session_id "STATE")
    local timestamp=$(date -Iseconds)
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
        .execution_state.session_metadata.session_type = "continuous" |
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

    log "执行状态文件已初始化: $session_id"
}

# 创建必要的目录
create_directories() {
    log "创建必要的目录..."

    local dirs=(
        "autopilot-logs"
        "autopilot-backups"
        "autopilot-recovery-points"
        "autopilot-session-temp"
    )

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            log "创建目录: $dir"
        fi
    done
}

# 生成初始化报告
generate_init_report() {
    log "生成初始化报告..."

    local report_file="autopilot-logs/init-report-$(date +%Y%m%d_%H%M%S).md"
    local timestamp=$(date)

    cat > "$report_file" << EOF
# Claude Code AutoPilot 初始化报告

**初始化时间**: $timestamp
**工作目录**: $(realpath .)

## 初始化的会话ID

- **需求对齐ID**: $(jq -r '.requirement_alignment.session_id' REQUIREMENT_ALIGNMENT.json)
- **执行计划ID**: $(jq -r '.execution_plan.session_id' EXECUTION_PLAN.json)
- **TODO跟踪ID**: $(jq -r '.todo_tracker.session_id' TODO_TRACKER.json)
- **决策日志ID**: $(jq -r '.decision_log.session_id' DECISION_LOG.json)
- **执行状态ID**: $(jq -r '.execution_state.session_id' EXECUTION_STATE.json)

## 创建的文件

- ✅ \`REQUIREMENT_ALIGNMENT.json\` - 需求对齐配置
- ✅ \`EXECUTION_PLAN.json\` - 执行计划配置
- ✅ \`TODO_TRACKER.json\` - TODO进度跟踪
- ✅ \`DECISION_LOG.json\` - 决策日志记录
- ✅ \`EXECUTION_STATE.json\` - 执行状态管理

## 创建的目录

- ✅ \`autopilot-logs/\` - 执行日志目录
- ✅ \`autopilot-backups/\` - 备份目录
- ✅ \`autopilot-recovery-points/\` - 恢复点目录
- ✅ \`autopilot-session-temp/\` - 临时文件目录

## 下一步操作

1. 开始需求讨论阶段
2. 生成详细的执行计划
3. 开始连续自主执行

---

**系统状态**: 🟢 初始化完成，准备开始执行
**建议命令**: \`/autopilot-continuous-start\`
EOF

    log "初始化报告已生成: $report_file"
    echo ""
    echo "🚀 AutoPilot系统初始化完成！"
    echo "📄 详细报告: $report_file"
    echo ""
    echo "现在可以运行: /autopilot-continuous-start"
}

# 显示使用帮助
show_help() {
    echo "Claude Code AutoPilot 系统初始化工具"
    echo ""
    echo "用法: $0 [command] [options]"
    echo ""
    echo "命令:"
    echo "  init               初始化AutoPilot系统状态（默认命令）"
    echo "  check              检查初始化前置条件"
    echo "  clean              清理已初始化的状态文件"
    echo "  status             显示当前初始化状态"
    echo "  help               显示此帮助信息"
    echo ""
    echo "选项:"
    echo "  -f, --force        强制重新初始化，不询问确认"
    echo "  -q, --quiet        静默模式，减少输出信息"
    echo "  -v, --verbose      详细模式，显示更多调试信息"
    echo ""
    echo "功能特性:"
    echo "  ✅ 自动生成所有状态文件（JSON格式）"
    echo "  ✅ 创建唯一会话ID和时间戳"
    echo "  ✅ 验证系统依赖和环境要求"
    echo "  ✅ 创建必要的目录结构"
    echo "  ✅ 生成详细的初始化报告"
    echo ""
    echo "初始化的文件:"
    echo "  - REQUIREMENT_ALIGNMENT.json  需求对齐配置"
    echo "  - EXECUTION_PLAN.json         执行计划配置"
    echo "  - TODO_TRACKER.json          TODO进度跟踪"
    echo "  - DECISION_LOG.json          决策日志记录"
    echo "  - EXECUTION_STATE.json       执行状态管理"
    echo ""
    echo "示例:"
    echo "  $0 init                      # 标准初始化"
    echo "  $0 init --force              # 强制重新初始化"
    echo "  $0 check                     # 检查初始化条件"
    echo "  $0 clean                     # 清理状态文件"
    echo ""
    echo "注意事项:"
    echo "  - 请在AutoPilot插件根目录下执行"
    echo "  - 确保所有依赖工具已安装（jq, date, stat, realpath）"
    echo "  - 初始化将覆盖现有的状态文件"
}

# 检查初始化状态
check_init_status() {
    echo "🔍 AutoPilot 系统初始化状态检查"
    echo "==============================="
    echo ""

    local required_files=(
        "REQUIREMENT_ALIGNMENT.json"
        "EXECUTION_PLAN.json"
        "TODO_TRACKER.json"
        "DECISION_LOG.json"
        "EXECUTION_STATE.json"
    )

    local all_exists=true
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            local session_id=$(jq -r '.session_id // "未知"' "$file" 2>/dev/null || echo "解析失败")
            echo "✅ $file (会话ID: $session_id)"
        else
            echo "❌ $file (文件不存在)"
            all_exists=false
        fi
    done

    echo ""
    if [ "$all_exists" = true ]; then
        echo "🎉 系统状态: 已完全初始化"
        echo "💡 建议下一步: 运行 /autopilot-continuous-start"
    else
        echo "⚠️  系统状态: 部分或完全未初始化"
        echo "💡 建议操作: 运行 '$0 init' 进行初始化"
    fi

    echo ""
    echo "📁 目录状态:"
    local dirs=("autopilot-logs" "autopilot-backups" "autopilot-recovery-points" "autopilot-session-temp")
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            local file_count=$(find "$dir" -type f | wc -l)
            echo "✅ $dir/ ($file_count 个文件)"
        else
            echo "❌ $dir/ (目录不存在)"
        fi
    done
}

# 清理初始化状态
clean_init_state() {
    echo "🧹 清理AutoPilot系统初始化状态"
    echo "==============================="
    echo ""

    local files_to_remove=(
        "REQUIREMENT_ALIGNMENT.json"
        "EXECUTION_PLAN.json"
        "TODO_TRACKER.json"
        "DECISION_LOG.json"
        "EXECUTION_STATE.json"
    )

    local dirs_to_remove=(
        "autopilot-logs"
        "autopilot-backups"
        "autopilot-recovery-points"
        "autopilot-session-temp"
    )

    echo "将要删除的文件:"
    for file in "${files_to_remove[@]}"; do
        if [ -f "$file" ]; then
            echo "  - $file"
        fi
    done

    echo ""
    echo "将要删除的目录:"
    for dir in "${dirs_to_remove[@]}"; do
        if [ -d "$dir" ]; then
            echo "  - $dir/"
        fi
    done

    echo ""
    read -p "确认要删除这些文件和目录吗？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 删除文件
        for file in "${files_to_remove[@]}"; do
            if [ -f "$file" ]; then
                rm -f "$file"
                echo "✅ 已删除: $file"
            fi
        done

        # 删除目录
        for dir in "${dirs_to_remove[@]}"; do
            if [ -d "$dir" ]; then
                rm -rf "$dir"
                echo "✅ 已删除: $dir/"
            fi
        done

        echo ""
        echo "🎉 清理完成！系统已恢复到未初始化状态"
    else
        echo "❌ 取消清理操作"
    fi
}

# 主初始化流程
main() {
    local command="${1:-init}"
    local force_mode=false
    local quiet_mode=false
    local verbose_mode=false

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                force_mode=true
                shift
                ;;
            -q|--quiet)
                quiet_mode=true
                shift
                ;;
            -v|--verbose)
                verbose_mode=true
                shift
                ;;
            init|check|clean|status|help)
                command="$1"
                shift
                ;;
            *)
                error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done

    case "$command" in
        "help"|"--help"|"-h")
            show_help
            ;;
        "check")
            check_dependencies || exit 1
            validate_environment || exit 1
            echo "✅ 所有检查通过，系统可以正常初始化"
            ;;
        "status")
            check_init_status
            ;;
        "clean")
            clean_init_state
            ;;
        "init")
            if [ "$quiet_mode" != true ]; then
                echo "🚀 Claude Code AutoPilot 系统初始化"
                echo "=================================="
                echo ""
            fi

            # 检查是否已经初始化
            if [ -f "REQUIREMENT_ALIGNMENT.json" ] && [ -f "EXECUTION_PLAN.json" ]; then
                if [ "$force_mode" != true ]; then
                    warn "检测到状态文件已存在"
                    read -p "是否要重新初始化？这将覆盖现有状态 (y/N): " -n 1 -r
                    echo
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        log "保持现有状态，初始化取消"
                        exit 0
                    fi
                else
                    if [ "$quiet_mode" != true ]; then
                        warn "强制模式：覆盖现有状态文件"
                    fi
                fi
            fi

            # 执行初始化流程
            check_dependencies || exit 1
            validate_environment || exit 1
            create_directories
            init_requirement_alignment || exit 1
            init_execution_plan || exit 1
            init_todo_tracker || exit 1
            init_decision_log || exit 1
            init_execution_state || exit 1
            generate_init_report

            if [ "$quiet_mode" != true ]; then
                log "🎉 系统初始化成功完成！"
            fi
            ;;
        *)
            error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi