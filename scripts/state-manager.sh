#!/bin/bash
# Claude Code AutoPilot - 状态管理工具
# 自动更新和维护JSON状态文件

set -euo pipefail

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] STATE-MANAGER: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] STATE-MANAGER: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] STATE-MANAGER: WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] STATE-MANAGER: ERROR: $1${NC}"
}

# 检查状态文件是否存在
check_state_files() {
    local required_files=(
        "REQUIREMENT_ALIGNMENT.json"
        "EXECUTION_PLAN.json"
        "TODO_TRACKER.json"
        "DECISION_LOG.json"
        "EXECUTION_STATE.json"
    )

    local missing_files=()
    local corrupted_files=()

    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        elif [ ! -s "$file" ]; then
            warn "状态文件为空: $file"
            corrupted_files+=("$file")
        elif ! jq empty "$file" 2>/dev/null; then
            warn "状态文件JSON格式错误: $file"
            corrupted_files+=("$file")
        fi
    done

    # 报告缺失文件
    if [ ${#missing_files[@]} -gt 0 ]; then
        error "以下状态文件不存在:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        echo ""
        echo "建议解决方案:"
        echo "  1. 运行 './scripts/init-session.sh' 进行初始化"
        echo "  2. 或者从备份目录恢复状态文件"
        return 1
    fi

    # 报告损坏文件
    if [ ${#corrupted_files[@]} -gt 0 ]; then
        error "以下状态文件已损坏或格式错误:"
        for file in "${corrupted_files[@]}"; do
            echo "  - $file"
        done
        echo ""
        echo "建议解决方案:"
        echo "  1. 运行 './scripts/init-session.sh --force' 重新初始化"
        echo "  2. 检查备份目录是否有可用备份"
        return 1
    fi

    return 0
}

# 备份状态文件
backup_state_files() {
    local backup_dir="autopilot-backups/backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    local files=(
        "REQUIREMENT_ALIGNMENT.json"
        "EXECUTION_PLAN.json"
        "TODO_TRACKER.json"
        "DECISION_LOG.json"
        "EXECUTION_STATE.json"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            cp "$file" "$backup_dir/"
            log "备份文件: $file -> $backup_dir/"
        fi
    done

    echo "$backup_dir"
}

# 更新TODO进度
update_todo_progress() {
    local todo_id="$1"
    local status="$2"  # pending, in_progress, completed, failed, skipped
    local notes="${3:-""}"
    local quality_score="${4:-0}"

    # 验证参数
    if [ -z "$todo_id" ] || [ -z "$status" ]; then
        error "TODO ID和状态参数不能为空"
        return 1
    fi

    # 验证状态值
    local valid_statuses=("pending" "in_progress" "completed" "failed" "skipped")
    local status_valid=false
    for valid_status in "${valid_statuses[@]}"; do
        if [ "$status" = "$valid_status" ]; then
            status_valid=true
            break
        fi
    done

    if [ "$status_valid" = false ]; then
        error "无效的状态值: $status"
        error "有效状态值: ${valid_statuses[*]}"
        return 1
    fi

    # 验证质量分数范围
    if [[ "$quality_score" =~ ^[0-9]+$ ]] && [ "$quality_score" -ge 0 ] && [ "$quality_score" -le 10 ]; then
        : # 质量分数有效
    else
        error "质量分数必须是0-10之间的整数，当前值: $quality_score"
        return 1
    fi

    log "更新TODO进度: $todo_id -> $status"

    # 检查状态文件是否存在
    if [ ! -f "TODO_TRACKER.json" ]; then
        error "TODO_TRACKER.json文件不存在"
        return 1
    fi

    # 备份当前状态
    cp TODO_TRACKER.json TODO_TRACKER.json.backup 2>/dev/null || true

    # 更新TODO_TRACKER.json
    local timestamp=$(date -Iseconds)

    # 查找并更新对应的TODO
    local todo_found=$(jq --arg todo_id "$todo_id" \
        '.todo_tracker.todo_progress[] | select(.todo_id == $todo_id)' \
        TODO_TRACKER.json 2>/dev/null || echo "")

    if [ -n "$todo_found" ]; then
        # 更新现有TODO
        if ! jq --arg todo_id "$todo_id" \
           --arg status "$status" \
           --arg timestamp "$timestamp" \
           --arg notes "$notes" \
           --argjson quality_score "$quality_score" \
           '(.todo_tracker.todo_progress[] | select(.todo_id == $todo_id)) |= {
               todo_id: .todo_id,
               title: .title,
               status: $status,
               start_time: (if $status == "in_progress" then $timestamp else .start_time end),
               end_time: (if $status == "completed" or $status == "failed" then $timestamp else .end_time end),
               duration_minutes: (if $status == "completed" then ((($timestamp | fromdateiso8601) - (.start_time | fromdateiso8601)) / 60 | floor) else .duration_minutes end),
               quality_score: (if $status == "completed" then $quality_score else .quality_score end),
               progress_percentage: (if $status == "completed" then 100 else (if $status == "in_progress" then 50 else 0 end) end)
           } + .' \
           TODO_TRACKER.json > TODO_TRACKER.json.tmp 2>/dev/null; then
            error "更新TODO记录失败"
            if [ -f "TODO_TRACKER.json.backup" ]; then
                mv TODO_TRACKER.json.backup TODO_TRACKER.json
            fi
            return 1
        fi
    else
        # 创建新TODO记录
        local todo_title=""
        if [ -f "EXECUTION_PLAN.json" ]; then
            todo_title=$(jq --arg todo_id "$todo_id" \
                '.execution_plan.execution_todos[] | select(.todo_id == $todo_id) | .title' \
                EXECUTION_PLAN.json 2>/dev/null | tr -d '"' || echo "")
        fi

        if [ -z "$todo_title" ]; then
            warn "在EXECUTION_PLAN.json中未找到TODO ID: $todo_id"
            todo_title="未知任务 ($todo_id)"
        fi

        if ! jq --arg todo_id "$todo_id" \
           --arg title "$todo_title" \
           --arg status "$status" \
           --arg timestamp "$timestamp" \
           --arg notes "$notes" \
           --argjson quality_score "$quality_score" \
           '.todo_tracker.todo_progress += [{
               todo_id: $todo_id,
               title: $title,
               status: $status,
               start_time: (if $status == "in_progress" then $timestamp else null end),
               end_time: (if $status == "completed" or $status == "failed" then $timestamp else null end),
               duration_minutes: 0,
               estimated_minutes: 0,
               quality_score: (if $status == "completed" then $quality_score else 0),
               retry_count: 0,
               progress_percentage: (if $status == "completed" then 100 else (if $status == "in_progress" then 50 else 0 end) end),
               acceptance_criteria_results: [],
               self_check_results: [],
               error_history: [],
               outputs_generated: []
           }]' \
           TODO_TRACKER.json > TODO_TRACKER.json.tmp 2>/dev/null; then
            error "创建新TODO记录失败"
            if [ -f "TODO_TRACKER.json.backup" ]; then
                mv TODO_TRACKER.json.backup TODO_TRACKER.json
            fi
            return 1
        fi
    fi

    # 验证生成的文件
    if ! jq empty TODO_TRACKER.json.tmp 2>/dev/null; then
        error "生成的TODO_TRACKER.json.tmp文件格式错误"
        if [ -f "TODO_TRACKER.json.backup" ]; then
            mv TODO_TRACKER.json.backup TODO_TRACKER.json
        fi
        return 1
    fi

    # 替换原文件
    mv TODO_TRACKER.json.tmp TODO_TRACKER.json

    # 清理备份文件
    rm -f TODO_TRACKER.json.backup

    # 重新计算总体进度
    if ! recalculate_progress; then
        error "重新计算进度失败"
        return 1
    fi

    log "TODO进度更新完成: $todo_id"
    return 0
}

# 重新计算总体进度
recalculate_progress() {
    log "重新计算总体进度..."

    local total_todos=$(jq '.execution_plan.execution_todos | length' EXECUTION_PLAN.json)
    local completed_todos=$(jq '[.todo_tracker.todo_progress[] | select(.status == "completed")] | length' TODO_TRACKER.json)
    local in_progress_todos=$(jq '[.todo_tracker.todo_progress[] | select(.status == "in_progress")] | length' TODO_TRACKER.json)
    local failed_todos=$(jq '[.todo_tracker.todo_progress[] | select(.status == "failed")] | length' TODO_TRACKER.json)
    local skipped_todos=$(jq '[.todo_tracker.todo_progress[] | select(.status == "skipped")] | length' TODO_TRACKER.json)

    local progress_percentage=0
    if [ "$total_todos" -gt 0 ]; then
        progress_percentage=$((completed_todos * 100 / total_todos))
    fi

    # 更新进度信息
    jq --argjson total "$total_todos" \
       --argjson completed "$completed_todos" \
       --argjson in_progress "$in_progress_todos" \
       --argjson failed "$failed_todos" \
       --argjson skipped "$skipped_todos" \
       --argjson percentage "$progress_percentage" \
       '.todo_tracker.overall_progress.total_todos = $total |
        .todo_tracker.overall_progress.completed_todos = $completed |
        .todo_tracker.overall_progress.in_progress_todos = $in_progress |
        .todo_tracker.overall_progress.failed_todos = $failed |
        .todo_tracker.overall_progress.skipped_todos = $skipped |
        .todo_tracker.overall_progress.progress_percentage = $percentage |
        .todo_tracker.last_update_time = "'$(date -Iseconds)'"' \
       TODO_TRACKER.json > TODO_TRACKER.json.tmp && mv TODO_TRACKER.json.tmp TODO_TRACKER.json

    log "进度更新: $percentage% ($completed/$total 完成)"
}

# 记录决策
record_decision() {
    local todo_id="$1"
    local decision_point="$2"
    local decision_made="$3"
    local decision_type="${4:-manual}"  # preset, manual, fallback, recovery
    local reasoning="${5:-""}"
    local confidence_level="${6:-medium}"  # high, medium, low

    log "记录决策: $decision_point -> $decision_made"

    local timestamp=$(date -Iseconds)
    local decision_id="DEC_$(date +%Y%m%d_%H%M%S)_$$"

    # 添加到决策日志
    jq --arg decision_id "$decision_id" \
       --arg timestamp "$timestamp" \
       --arg todo_id "$todo_id" \
       --arg decision_point "$decision_point" \
       --arg decision_made "$decision_made" \
       --arg decision_type "$decision_type" \
       --arg reasoning "$reasoning" \
       --arg confidence_level "$confidence_level" \
       '.decision_log.decision_timeline += [{
           decision_id: $decision_id,
           timestamp: $timestamp,
           todo_id: $todo_id,
           decision_sequence: (.decision_log.decision_statistics.total_decisions_made + 1),
           decision_context: {
               trigger_event: "todo_execution",
               decision_point: $decision_point,
               context_description: "执行TODO时的决策",
               urgency_level: "medium",
               impact_scope: "task"
           },
           decision_details: {
               decision_type: $decision_type,
               decision_category: "execution",
               decision_made: $decision_made,
               decision_description: $decision_made,
               options_considered: [],
               chosen_option: $decision_made,
               decision_reasoning: $reasoning
           },
           confidence_assessment: {
               confidence_level: $confidence_level,
               confidence_justification: $reasoning,
               risk_assessment: "low",
               uncertainty_factors: []
           },
           implementation_plan: {
               implementation_steps: [],
               required_resources: [],
               estimated_implementation_time: 0,
               success_criteria: [],
               rollback_plan: ""
           },
           decision_outcome: {
               implementation_status: "planned",
               implementation_start_time: null,
               implementation_completion_time: null,
               actual_implementation_time: 0,
               success_indicators: [],
               issues_encountered: [],
               lessons_learned: ""
           },
           quality_impact: {
               impact_on_code_quality: "neutral",
               impact_on_maintainability: "neutral",
               impact_on_performance: "neutral",
               impact_on_security: "neutral",
               overall_quality_impact_score: 0
           },
           review_and_validation: {
               review_required: false,
               review_status: "pending",
               review_time: null,
               reviewer_notes: "",
               validation_method: "auto",
               validation_results: ""
           }
       }] |
       .decision_log.decision_statistics.total_decisions_made += 1 |
       .decision_log.last_update_time = $timestamp' \
       DECISION_LOG.json > DECISION_LOG.json.tmp && mv DECISION_LOG.json.tmp DECISION_LOG.json

    # 更新TODO_TRACKER中的决策统计
    jq --arg todo_id "$todo_id" \
       '(.todo_tracker.decision_tracking.decision_log[] | select(.todo_id == $todo_id)) |= . + {
           decision_id: "'$decision_id'",
           todo_id: $todo_id,
           decision_point: $decision_point,
           decision_made: $decision_made,
           decision_type: $decision_type,
           decision_time: "'$timestamp'",
           reasoning: $reasoning,
           confidence_level: $confidence_level,
           impact_assessment: "medium"
       } |
       .todo_tracker.decision_tracking.decisions_made += 1 |
       .todo_tracker.decision_tracking.last_update_time = "'$timestamp'"' \
       TODO_TRACKER.json > TODO_TRACKER.json.tmp && mv TODO_TRACKER.json.tmp TODO_TRACKER.json

    log "决策记录完成: $decision_id"
}

# 记录错误和恢复
record_error_recovery() {
    local error_type="$1"
    local error_description="$2"
    local recovery_action="$3"
    local recovery_success="${4:-true}"
    local todo_id="${5:-unknown}"

    log "记录错误恢复: $error_type -> $recovery_action"

    local timestamp=$(date -Iseconds)
    local recovery_id="REC_$(date +%Y%m%d_%H%M%S)_$$"

    # 添加到TODO_TRACKER的错误历史
    if [ -f "TODO_TRACKER.json" ]; then
        jq --arg todo_id "$todo_id" \
           --arg error_type "$error_type" \
           --arg error_description "$error_description" \
           --arg recovery_action "$recovery_action" \
           --argjson recovery_success "$recovery_success" \
           --arg timestamp "$timestamp" \
           '(.todo_tracker.todo_progress[] | select(.todo_id == $todo_id) | .error_history) += [{
               error_time: $timestamp,
               error_type: $error_type,
               error_description: $error_description,
               recovery_action: $recovery_action,
               recovery_success: $recovery_success,
               retry_number: 0
           }]' \
           TODO_TRACKER.json > TODO_TRACKER.json.tmp && mv TODO_TRACKER.json.tmp TODO_TRACKER.json
    fi

    # 更新执行状态
    if [ -f "EXECUTION_STATE.json" ]; then
        jq --arg error_type "$error_type" \
           --arg recovery_action "$recovery_action" \
           --argjson recovery_success "$recovery_success" \
           --arg timestamp "$timestamp" \
           '.error_and_recovery_state.last_error_time = $timestamp |
            .error_and_recovery_state.total_errors += 1 |
            (if $recovery_success then
                .error_and_recovery_state.resolved_errors += 1
            else
                .error_and_recovery_state.pending_errors += 1
            end) |
            .last_state_update = $timestamp' \
           EXECUTION_STATE.json > EXECUTION_STATE.json.tmp && mv EXECUTION_STATE.json.tmp EXECUTION_STATE.json
    fi

    log "错误恢复记录完成: $recovery_id"
}

# 更新质量指标
update_quality_metrics() {
    local todo_id="$1"
    local quality_score="$2"
    local quality_issues="$3"  # JSON array string

    log "更新质量指标: $todo_id -> $quality_score"

    local timestamp=$(date -Iseconds)

    # 更新TODO_TRACKER中的质量信息
    jq --arg todo_id "$todo_id" \
       --argjson quality_score "$quality_score" \
       --argjson quality_issues "$quality_issues" \
       '(.todo_tracker.quality_metrics.overall_quality_score = ($quality_score + .todo_tracker.quality_metrics.overall_quality_score) / 2) |
        .todo_tracker.quality_metrics.last_quality_check_time = "'$timestamp'" |
        .todo_tracker.quality_metrics.quality_issues += $quality_issues |
        .todo_tracker.last_update_time = "'$timestamp'"' \
       TODO_TRACKER.json > TODO_TRACKER.json.tmp && mv TODO_TRACKER.json.tmp TODO_TRACKER.json

    # 更新执行状态中的质量控制
    jq --argjson quality_score "$quality_score" \
       --arg timestamp "$timestamp" \
       '.quality_control_state.current_quality_score = $quality_score |
        .quality_control_state.last_quality_check_time = $timestamp |
        .last_state_update = $timestamp' \
       EXECUTION_STATE.json > EXECUTION_STATE.json.tmp && mv EXECUTION_STATE.json.tmp EXECUTION_STATE.json

    log "质量指标更新完成"
}

# 创建检查点
create_checkpoint() {
    local checkpoint_name="$1"
    local todo_id="${2:-current}"

    log "创建检查点: $checkpoint_name"

    local checkpoint_id="CP_$(date +%Y%m%d_%H%M%S)_$$"
    local timestamp=$(date -Iseconds)
    local checkpoint_dir="autopilot-recovery-points/$checkpoint_id"

    mkdir -p "$checkpoint_dir"

    # 复制所有状态文件
    local files=(
        "REQUIREMENT_ALIGNMENT.json"
        "EXECUTION_PLAN.json"
        "TODO_TRACKER.json"
        "DECISION_LOG.json"
        "EXECUTION_STATE.json"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            cp "$file" "$checkpoint_dir/"
        fi
    done

    # 创建检查点元数据
    cat > "$checkpoint_dir/checkpoint-meta.json" << EOF
{
  "checkpoint_id": "$checkpoint_id",
  "checkpoint_name": "$checkpoint_name",
  "creation_time": "$timestamp",
  "todo_id": "$todo_id",
  "progress_percentage": $(jq '.todo_tracker.overall_progress.progress_percentage' TODO_TRACKER.json),
  "quality_score": $(jq '.todo_tracker.quality_metrics.overall_quality_score' TODO_TRACKER.json),
  "state_size_kb": $(du -sk . | cut -f1),
  "validity_status": "valid",
  "recovery_capability": "full"
}
EOF

    # 更新EXECUTION_STATE中的检查点信息
    jq --arg checkpoint_id "$checkpoint_id" \
       --arg checkpoint_name "$checkpoint_name" \
       --arg timestamp "$timestamp" \
       --arg todo_id "$todo_id" \
       '.checkpoint_information.latest_checkpoint = {
           checkpoint_id: $checkpoint_id,
           creation_time: $timestamp,
           todo_id: $todo_id,
           state_size_kb: 1024,
           validity_status: "valid",
           recovery_capability: "full"
       } |
        .checkpoint_information.available_checkpoints += [{
            checkpoint_id: $checkpoint_id,
            checkpoint_time: $timestamp,
            description: $checkpoint_name,
            usability: "excellent"
        }] |
        .last_state_update = $timestamp' \
       EXECUTION_STATE.json > EXECUTION_STATE.json.tmp && mv EXECUTION_STATE.json.tmp EXECUTION_STATE.json

    log "检查点创建完成: $checkpoint_dir"
    echo "$checkpoint_dir"
}

# 显示状态摘要
show_status_summary() {
    echo ""
    echo "📊 AutoPilot 状态摘要"
    echo "==================="
    echo ""

    if [ -f "TODO_TRACKER.json" ]; then
        local total=$(jq -r '.todo_tracker.overall_progress.total_todos' TODO_TRACKER.json)
        local completed=$(jq -r '.todo_tracker.overall_progress.completed_todos' TODO_TRACKER.json)
        local in_progress=$(jq -r '.todo_tracker.overall_progress.in_progress_todos' TODO_TRACKER.json)
        local percentage=$(jq -r '.todo_tracker.overall_progress.progress_percentage' TODO_TRACKER.json)
        local quality=$(jq -r '.todo_tracker.quality_metrics.overall_quality_score' TODO_TRACKER.json)

        echo "📈 执行进度: $percentage% ($completed/$total 完成)"
        echo "🔄 进行中: $in_progress 个任务"
        echo "⭐ 质量评分: $quality"
        echo ""
    fi

    if [ -f "EXECUTION_STATE.json" ]; then
        local health=$(jq -r '.execution_state.system_health.overall_health_score' EXECUTION_STATE.json)
        local status=$(jq -r '.execution_state.system_health.health_status' EXECUTION_STATE.json)
        local errors=$(jq -r '.execution_state.error_and_recovery_state.total_errors' EXECUTION_STATE.json)

        echo "🏥 系统健康: $health/10 ($status)"
        echo "⚠️  总错误数: $errors"
        echo ""
    fi

    if [ -f "DECISION_LOG.json" ]; then
        local decisions=$(jq -r '.decision_log.decision_statistics.total_decisions_made' DECISION_LOG.json)
        local preset_used=$(jq -r '.decision_log.decision_statistics.preset_decisions_used' DECISION_LOG.json)

        echo "🤔 总决策数: $decisions"
        echo "🎯 预设决策使用: $preset_used"
        echo ""
    fi
}

# 主函数
main() {
    local command="${1:-help}"

    case "$command" in
        "check")
            check_state_files
            ;;
        "backup")
            backup_state_files
            ;;
        "update-todo")
            if [ $# -lt 3 ]; then
                error "用法: $0 update-todo <todo_id> <status> [notes] [quality_score]"
                exit 1
            fi
            update_todo_progress "$2" "$3" "$4" "${5:-0}"
            ;;
        "record-decision")
            if [ $# -lt 4 ]; then
                error "用法: $0 record-decision <todo_id> <decision_point> <decision_made> [decision_type] [reasoning] [confidence]"
                exit 1
            fi
            record_decision "$2" "$3" "$4" "${5:-manual}" "${6:-}" "${7:-medium}"
            ;;
        "record-error")
            if [ $# -lt 4 ]; then
                error "用法: $0 record-error <error_type> <error_description> <recovery_action> [recovery_success] [todo_id]"
                exit 1
            fi
            record_error_recovery "$2" "$3" "$4" "${5:-true}" "${6:-unknown}"
            ;;
        "update-quality")
            if [ $# -lt 3 ]; then
                error "用法: $0 update-quality <todo_id> <quality_score> <quality_issues_json>"
                exit 1
            fi
            update_quality_metrics "$2" "$3" "$4"
            ;;
        "checkpoint")
            local checkpoint_name="${2:-auto-checkpoint-$(date +%H%M%S)}"
            create_checkpoint "$checkpoint_name" "$3"
            ;;
        "status")
            show_status_summary
            ;;
        "help"|"--help"|"-h")
            echo "Claude Code AutoPilot 状态管理工具"
            echo ""
            echo "用法: $0 <command> [arguments...]"
            echo ""
            echo "命令:"
            echo "  check                    检查状态文件完整性"
            echo "  backup                   备份所有状态文件"
            echo "  update-todo <id> <status> [notes] [score]  更新TODO进度"
            echo "  record-decision <id> <point> <decision> [type] [reason] [confidence]  记录决策"
            echo "  record-error <type> <desc> <action> [success] [todo_id]  记录错误恢复"
            echo "  update-quality <id> <score> <issues_json>  更新质量指标"
            echo "  checkpoint [name] [todo_id]  创建检查点"
            echo "  status                   显示状态摘要"
            echo "  help                     显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  $0 update-todo TODO_001 completed '任务完成' 9.0"
            echo "  $0 record-decision TODO_001 '技术选型' '使用React' preset '基于需求选择' high"
            echo "  $0 checkpoint '重要里程碑' TODO_005"
            ;;
        *)
            error "未知命令: $command"
            echo "使用 '$0 help' 查看帮助信息"
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi