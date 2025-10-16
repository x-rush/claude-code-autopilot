#!/bin/bash
# Claude Code AutoPilot - 执行监控和自动更新机制
# 实时跟踪执行进度，自动触发状态更新和恢复

set -euo pipefail

# 配置参数
MONITOR_INTERVAL=30  # 监控间隔（秒）
CONTEXT_REFRESH_INTERVAL=7200  # 上下文刷新间隔（2小时）
CHECKPOINT_INTERVAL=1800  # 检查点间隔（30分钟）
MAX_INACTIVITY_TIME=300  # 最大无活动时间（5分钟）

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] MONITOR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] MONITOR: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] MONITOR: WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] MONITOR: ERROR: $1${NC}"
}

debug() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] MONITOR: DEBUG: $1${NC}"
}

# 检查Claude Code进程是否运行
check_claude_process() {
    local claude_processes=$(pgrep -f "claude.*autopilot" || true)

    if [ -z "$claude_processes" ]; then
        warn "未检测到Claude Code AutoPilot进程"
        return 1
    fi

    debug "检测到Claude进程: $claude_processes"
    return 0
}

# 检查状态文件活动
check_state_activity() {
    local current_time=$(date +%s)
    local last_update=$(jq -r '.todo_tracker.last_update_time' TODO_TRACKER.json 2>/dev/null || echo "1970-01-01T00:00:00+00:00")

    if command -v date >/dev/null 2>&1; then
        local last_update_timestamp=$(date -d "$last_update" +%s 2>/dev/null || echo 0)
        local inactivity_duration=$((current_time - last_update_timestamp))

        if [ "$inactivity_duration" -gt "$MAX_INACTIVITY_TIME" ]; then
            warn "状态文件长时间未更新: ${inactivity_duration}秒"
            return 1
        fi
    fi

    return 0
}

# 检查执行进度停滞
check_progress_stagnation() {
    if [ ! -f "TODO_TRACKER.json" ]; then
        error "TODO_TRACKER.json文件不存在"
        return 1
    fi

    local current_progress=$(jq -r '.todo_tracker.overall_progress.progress_percentage' TODO_TRACKER.json)
    local last_progress_time=$(jq -r '.todo_tracker.last_update_time' TODO_TRACKER.json)

    # 计算停滞时间
    local current_time=$(date +%s)
    local progress_timestamp=$(date -d "$last_progress_time" +%s 2>/dev/null || echo 0)
    local stagnation_duration=$((current_time - progress_timestamp))

    # 如果停滞超过15分钟且进度不为100%，发出警告
    if [ "$stagnation_duration" -gt 900 ] && [ "$current_progress" != "100" ]; then
        warn "执行进度停滞: $current_progress% 已停滞${stagnation_duration}秒"
        return 1
    fi

    return 0
}

# 检查上下文窗口使用情况
check_context_usage() {
    if [ ! -f "EXECUTION_STATE.json" ]; then
        return 0
    fi

    local context_utilization=$(jq -r '.execution_state.context_management.context_window_utilization_percent' EXECUTION_STATE.json 2>/dev/null || echo "0")
    local context_health=$(jq -r '.execution_state.context_management.context_health_score' EXECUTION_STATE.json 2>/dev/null || echo "10")

    # 估算上下文使用率（简化版本）
    local estimated_usage=$((context_utilization + (RANDOM % 20) - 10))  # 添加一些随机性

    if [ "$estimated_usage" -gt 80 ]; then
        warn "上下文窗口使用率过高: ${estimated_usage}%"
        return 1
    fi

    if [ "$context_health" -lt 7 ]; then
        warn "上下文健康度较低: $context_health/10"
        return 1
    fi

    return 0
}

# 检查系统健康状态
check_system_health() {
    if [ ! -f "EXECUTION_STATE.json" ]; then
        return 0
    fi

    local health_score=$(jq -r '.execution_state.system_health.overall_health_score' EXECUTION_STATE.json 2>/dev/null || echo "10")
    local health_status=$(jq -r '.execution_state.system_health.health_status' EXECUTION_STATE.json 2>/dev/null || echo "excellent")

    if [ "$health_score" -lt 5 ]; then
        error "系统健康状态严重: $health_score/10 ($health_status)"
        return 1
    fi

    if [ "$health_score" -lt 7 ]; then
        warn "系统健康状态需要关注: $health_score/10 ($health_status)"
        return 1
    fi

    return 0
}

# 检查错误状态
check_error_status() {
    if [ ! -f "EXECUTION_STATE.json" ]; then
        return 0
    fi

    local active_errors=$(jq -r '.execution_state.error_and_recovery_state.active_error_count' EXECUTION_STATE.json 2>/dev/null || echo "0")
    local total_errors=$(jq -r '.execution_state.error_and_recovery_state.total_errors' EXECUTION_STATE.json 2>/dev/null || echo "0")

    if [ "$active_errors" -gt 0 ]; then
        error "存在活跃错误: $active_errors 个"
        return 1
    fi

    if [ "$total_errors" -gt 10 ]; then
        warn "错误总数过多: $total_errors 个"
        return 1
    fi

    return 0
}

# 自动创建检查点
auto_create_checkpoint() {
    log "自动创建检查点..."

    local checkpoint_name="auto-checkpoint-$(date +%H%M%S)"
    local current_todo=$(jq -r '.todo_tracker.current_execution_state.current_todo_id' TODO_TRACKER.json 2>/dev/null || echo "unknown")

    if ./scripts/state-manager.sh checkpoint "$checkpoint_name" "$current_todo"; then
        log "自动检查点创建成功: $checkpoint_name"
    else
        error "自动检查点创建失败"
    fi
}

# 自动上下文刷新
auto_context_refresh() {
    log "触发自动上下文刷新..."

    local refresh_report="autopilot-logs/context-refresh-$(date +%Y%m%d_%H%M%S).md"

    cat > "$refresh_report" << EOF
# 自动上下文刷新报告

**刷新时间**: $(date)
**触发原因**: 定时自动刷新

## 当前状态摘要

$(./scripts/state-manager.sh status)

## 关键信息提取

### 原始需求
$(jq -r '.requirement_alignment.user_objective.primary_goal' REQUIREMENT_ALIGNMENT.json 2>/dev/null || echo "未设置")

### 当前进度
$(jq -r '.todo_tracker.overall_progress.progress_percentage' TODO_TRACKER.json 2>/dev/null || echo "0")% 完成

### 当前任务
$(jq -r '.todo_tracker.current_execution_state.current_todo_title' TODO_TRACKER.json 2>/dev/null || echo "未知")

### 最近决策
$(jq -r '.decision_log.decision_timeline[-1].decision_details.decision_made' DECISION_LOG.json 2>/dev/null || echo "无")

## 下一步行动

基于当前状态，建议继续执行当前任务，保持与原始需求的对齐。

---

*此报告由自动监控系统生成*
EOF

    # 更新上下文刷新计数
    jq '.execution_state.session_metadata.context_refresh_count += 1 |
         .execution_state.context_management.last_context_refresh_time = "'$(date -Iseconds)'" |
         .execution_state.context_management.context_health_score = 10 |
         .last_state_update = "'$(date -Iseconds)'"' \
         EXECUTION_STATE.json > EXECUTION_STATE.json.tmp && mv EXECUTION_STATE.json.tmp EXECUTION_STATE.json

    log "上下文刷新完成: $refresh_report"
}

# 发送警报
send_alert() {
    local alert_type="$1"
    local message="$2"
    local severity="${3:-warning}"  # info, warning, error, critical

    local alert_file="autopilot-logs/alert-$(date +%Y%m%d_%H%M%S).md"

    cat > "$alert_file" << EOF
# AutoPilot 警报

**时间**: $(date)
**类型**: $alert_type
**严重级别**: $severity

## 警报信息

$message

## 当前状态

$(./scripts/state-manager.sh status)

## 建议行动

根据警报类型，可能需要：
1. 检查执行状态
2. 手动干预
3. 触发恢复流程
4. 联系技术支持

---

*此警报由自动监控系统生成*
EOF

    case "$severity" in
        "critical")
            error "🚨 严重警报: $message"
            error "警报文件: $alert_file"
            ;;
        "error")
            error "❌ 错误警报: $message"
            warn "警报文件: $alert_file"
            ;;
        "warning")
            warn "⚠️  警告警报: $message"
            info "警报文件: $alert_file"
            ;;
        *)
            info "ℹ️  信息警报: $message"
            info "警报文件: $alert_file"
            ;;
    esac
}

# 执行健康检查
run_health_check() {
    log "执行系统健康检查..."

    local issues=()

    # 检查各项指标
    if ! check_claude_process; then
        issues+=("claude_process_not_running")
    fi

    if ! check_state_activity; then
        issues+=("state_file_inactive")
    fi

    if ! check_progress_stagnation; then
        issues+=("progress_stagnated")
    fi

    if ! check_context_usage; then
        issues+=("context_overload")
    fi

    if ! check_system_health; then
        issues+=("system_health_low")
    fi

    if ! check_error_status; then
        issues+=("active_errors")
    fi

    # 根据问题严重程度发送警报
    if [ ${#issues[@]} -gt 0 ]; then
        local message="检测到 ${#issues[@]} 个问题: ${issues[*]}"

        if [[ " ${issues[*]} " =~ "claude_process_not_running" ]]; then
            send_alert "process_failure" "Claude Code进程未运行" "critical"
        elif [[ " ${issues[*]} " =~ "system_health_low" ]] || [[ " ${issues[*]} " =~ "active_errors" ]]; then
            send_alert "health_issue" "$message" "error"
        else
            send_alert "monitoring_warning" "$message" "warning"
        fi
    else
        log "✅ 系统健康检查通过"
    fi
}

# 生成监控报告
generate_monitoring_report() {
    local report_file="autopilot-logs/monitoring-report-$(date +%Y%m%d_%H%M%S).md"

    cat > "$report_file" << EOF
# AutoPilot 监控报告

**报告时间**: $(date)
**监控周期**: 持续监控

## 系统状态

### 执行进度
$(jq -r '.todo_tracker.overall_progress | "完成率: \(.progress_percentage)% (\(.completed_todos)/\(.total_todos))"' TODO_TRACKER.json 2>/dev/null || echo "数据不可用")

### 健康状态
$(jq -r '.execution_state.system_health | "健康评分: \(.overall_health_score)/10 (\(.health_status))"' EXECUTION_STATE.json 2>/dev/null || echo "数据不可用")

### 错误统计
$(jq -r '.execution_state.error_and_recovery_state | "总错误: \(.total_errors), 已解决: \(.resolved_errors), 活跃: \(.active_error_count)"' EXECUTION_STATE.json 2>/dev/null || echo "数据不可用")

### 决策统计
$(jq -r '.decision_log.decision_statistics | "总决策: \(.total_decisions_made), 预设决策: \(.preset_decisions_used)"' DECISION_LOG.json 2>/dev/null || echo "数据不可用")

## 监控指标

- ✅ Claude Code进程监控
- ✅ 状态文件活动检查
- ✅ 执行进度停滞检测
- ✅ 上下文窗口使用监控
- ✅ 系统健康状态评估
- ✅ 错误状态监控

## 自动化操作

- ✅ 定期检查点创建
- ✅ 自动上下文刷新
- ✅ 健康状态检查
- ✅ 警报系统

---

*此报告由自动监控系统生成*
EOF

    log "监控报告已生成: $report_file"
}

# 监控主循环
monitoring_loop() {
    local last_checkpoint_time=0
    local last_context_refresh_time=0
    local last_health_check_time=0

    log "启动监控循环，间隔 ${MONITOR_INTERVAL}s"

    while true; do
        local current_time=$(date +%s)

        # 健康检查
        if [ $((current_time - last_health_check_time)) -gt 60 ]; then
            run_health_check
            last_health_check_time=$current_time
        fi

        # 自动检查点
        if [ $((current_time - last_checkpoint_time)) -gt "$CHECKPOINT_INTERVAL" ]; then
            auto_create_checkpoint
            last_checkpoint_time=$current_time
        fi

        # 自动上下文刷新
        if [ $((current_time - last_context_refresh_time)) -gt "$CONTEXT_REFRESH_INTERVAL" ]; then
            auto_context_refresh
            last_context_refresh_time=$current_time
        fi

        # 生成监控报告（每小时）
        if [ $((current_time % 3600)) -lt "$MONITOR_INTERVAL" ]; then
            generate_monitoring_report
        fi

        sleep "$MONITOR_INTERVAL"
    done
}

# 启动监控
start_monitoring() {
    log "启动AutoPilot监控系统..."

    # 检查状态文件
    if [ ! -f "TODO_TRACKER.json" ]; then
        error "未找到状态文件，请先运行初始化"
        exit 1
    fi

    # 创建监控日志目录
    mkdir -p autopilot-logs

    # 记录监控启动
    local monitor_start_time=$(date -Iseconds)

    jq --arg start_time "$monitor_start_time" \
       '.execution_state.session_metadata.total_execution_duration_minutes = 0 |
        .execution_state.session_metadata.claude_session_start_time = $start_time |
        .last_state_update = $start_time' \
       EXECUTION_STATE.json > EXECUTION_STATE.json.tmp && mv EXECUTION_STATE.json.tmp EXECUTION_STATE.json

    log "监控已启动，开始监控循环"

    # 保存监控进程ID
    echo $$ > autopilot-monitor.pid

    # 开始监控循环
    monitoring_loop
}

# 停止监控
stop_monitoring() {
    log "停止AutoPilot监控系统..."

    if [ -f "autopilot-monitor.pid" ]; then
        local monitor_pid=$(cat autopilot-monitor.pid)
        if kill -0 "$monitor_pid" 2>/dev/null; then
            kill "$monitor_pid"
            rm -f autopilot-monitor.pid
            log "监控进程已停止: $monitor_pid"
        else
            warn "监控进程不存在或已停止: $monitor_pid"
            rm -f autopilot-monitor.pid
        fi
    fi

    log "监控系统已停止"
}

# 显示监控状态
show_monitoring_status() {
    echo ""
    echo "🔍 AutoPilot 监控状态"
    echo "===================="
    echo ""

    if [ -f "autopilot-monitor.pid" ]; then
        local monitor_pid=$(cat autopilot-monitor.pid)
        if kill -0 "$monitor_pid" 2>/dev/null; then
            echo "🟢 监控进程运行中: PID $monitor_pid"
        else
            echo "🔴 监控进程已停止: PID $monitor_pid"
            rm -f autopilot-monitor.pid
        fi
    else
        echo "🔴 监控进程未运行"
    fi

    echo ""
    echo "📊 配置参数:"
    echo "  监控间隔: ${MONITOR_INTERVAL}秒"
    echo "  上下文刷新间隔: ${CONTEXT_REFRESH_INTERVAL}秒"
    echo "  检查点间隔: ${CHECKPOINT_INTERVAL}秒"
    echo "  最大无活动时间: ${MAX_INACTIVITY_TIME}秒"
    echo ""

    # 显示最近的检查点
    if [ -d "autopilot-recovery-points" ]; then
        local latest_checkpoint=$(ls -t autopilot-recovery-points/*/checkpoint-meta.json 2>/dev/null | head -1)
        if [ -n "$latest_checkpoint" ]; then
            local checkpoint_info=$(jq -r '"\(.checkpoint_name) - \(.creation_time)"' "$latest_checkpoint")
            echo "💾 最新检查点: $checkpoint_info"
        fi
    fi

    echo ""
}

# 主函数
main() {
    local command="${1:-help}"

    case "$command" in
        "start")
            stop_monitoring  # 先停止现有监控
            start_monitoring
            ;;
        "stop")
            stop_monitoring
            ;;
        "restart")
            stop_monitoring
            sleep 2
            start_monitoring
            ;;
        "status")
            show_monitoring_status
            ;;
        "check")
            run_health_check
            ;;
        "checkpoint")
            auto_create_checkpoint
            ;;
        "refresh")
            auto_context_refresh
            ;;
        "report")
            generate_monitoring_report
            ;;
        "help"|"--help"|"-h")
            echo "Claude Code AutoPilot 执行监控系统"
            echo ""
            echo "用法: $0 <command>"
            echo ""
            echo "命令:"
            echo "  start       启动监控"
            echo "  stop        停止监控"
            echo "  restart     重启监控"
            echo "  status      显示监控状态"
            echo "  check       执行健康检查"
            echo "  checkpoint  手动创建检查点"
            echo "  refresh     手动触发上下文刷新"
            echo "  report      生成监控报告"
            echo "  help        显示帮助信息"
            echo ""
            echo "监控功能:"
            echo "  - Claude Code进程监控"
            echo "  - 状态文件活动检查"
            echo "  - 执行进度停滞检测"
            echo "  - 上下文窗口使用监控"
            echo "  - 系统健康状态评估"
            echo "  - 自动检查点创建"
            echo "  - 自动上下文刷新"
            echo "  - 警报系统"
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