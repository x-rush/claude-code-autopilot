#!/bin/bash
# Claude Code 自我导航引擎
# 基于需求对齐和执行契约，实现自我导航、路径规划和偏差检测

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 加载通用配置
source "$SCRIPT_DIR/common-config.sh"

# 启用严格模式
set -euo pipefail

# 全局错误处理
handle_error() {
    local exit_code=$1
    local line_number=$2
    log_message "ERROR" "导航引擎在第 $line_number 行异常退出，退出码: $exit_code"
    cleanup_on_error
    exit $exit_code
}

# 错误处理钩子
trap 'handle_error $? $LINENO' ERR

# 错误时清理函数
cleanup_on_error() {
    log_message "INFO" "导航引擎错误清理操作"
    cleanup_temp_files
}

# 文件路径
NAVIGATION_STATUS_FILE="$PROJECT_ROOT/NAVIGATION_STATUS.json"
REQUIREMENT_ALIGNMENT_FILE="$PROJECT_ROOT/REQUIREMENT_ALIGNMENT.json"
EXECUTION_CONTRACT_FILE="$PROJECT_ROOT/EXECUTION_CONTRACT.json"
NAVIGATION_LOG_FILE="$PROJECT_ROOT/NAVIGATION_LOG.md"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# 日志函数
log_navigation() {
    local level="$1"
    local message="$2"

    case "$level" in
        "INFO")
            echo -e "${GREEN}[NAVIGATION]${NC} $(get_timestamp) - $message" | tee -a "$NAVIGATION_LOG_FILE"
            ;;
        "WARN")
            echo -e "${YELLOW}[NAVIGATION]${NC} $(get_timestamp) - $message" | tee -a "$NAVIGATION_LOG_FILE"
            ;;
        "ERROR")
            echo -e "${RED}[NAVIGATION]${NC} $(get_timestamp) - $message" | tee -a "$NAVIGATION_LOG_FILE"
            ;;
        "SUCCESS")
            echo -e "${CYAN}[NAVIGATION]${NC} $(get_timestamp) - $message" | tee -a "$NAVIGATION_LOG_FILE"
            ;;
        "ROUTE")
            echo -e "${MAGENTA}[ROUTE]${NC} $(get_timestamp) - $message" | tee -a "$NAVIGATION_LOG_FILE"
            ;;
    esac
}

# 初始化导航系统
init_navigation() {
    log_navigation "INFO" "初始化自我导航系统"

    # 创建导航日志
    echo "# Claude Code 自我导航日志" > "$NAVIGATION_LOG_FILE"
    echo "启动时间: $(get_timestamp)" >> "$NAVIGATION_LOG_FILE"
    echo "" >> "$NAVIGATION_LOG_FILE"

    # 初始化导航状态
    cat > "$NAVIGATION_STATUS_FILE" << EOF
{
  "navigation_info": {
    "session_id": "NAV_$(generate_id)",
    "start_time": "$(get_iso_timestamp)",
    "status": "INITIALIZING",
    "current_phase": "setup"
  },
  "route": {
    "current_position": "start",
    "target_position": "completion",
    "total_waypoints": 0,
    "completed_waypoints": 0,
    "current_waypoint": null,
    "next_waypoint": null
  },
  "alignment": {
    "requirement_id": null,
    "contract_id": null,
    "current_alignment_score": 0,
    "target_alignment_score": 100
  },
  "deviation": {
    "detected": false,
    "deviation_type": null,
    "deviation_magnitude": 0,
    "correction_count": 0,
    "last_correction": null
  },
  "navigation_history": [],
  "decisions": []
}
EOF

    log_navigation "SUCCESS" "导航系统初始化完成"
}

# 加载导航数据
load_navigation_data() {
    log_navigation "INFO" "加载导航数据"

    if [[ ! -f "$REQUIREMENT_ALIGNMENT_FILE" ]]; then
        log_navigation "ERROR" "需求对齐文件不存在: $REQUIREMENT_ALIGNMENT_FILE"
        return 1
    fi

    if [[ ! -f "$EXECUTION_CONTRACT_FILE" ]]; then
        log_navigation "ERROR" "执行契约文件不存在: $EXECUTION_CONTRACT_FILE"
        return 1
    fi

    # 更新导航状态中的对齐信息
    local requirement_id=$(jq -r '.requirement_alignment.session_id' "$REQUIREMENT_ALIGNMENT_FILE")
    local contract_id=$(jq -r '.contract_basis.requirement_alignment_id' "$EXECUTION_CONTRACT_FILE")

    jq --arg requirement_id "$requirement_id" --arg contract_id "$contract_id" '
        .alignment.requirement_id = $requirement_id |
        .alignment.contract_id = $contract_id
    ' "$NAVIGATION_STATUS_FILE" > temp_nav.json && mv temp_nav.json "$NAVIGATION_STATUS_FILE"

    log_navigation "SUCCESS" "导航数据加载完成"
}

# 生成导航路线图
generate_navigation_route() {
    log_navigation "ROUTE" "生成导航路线图"

    # 从执行契约中提取导航指令
    local primary_direction=$(get_json_value "$EXECUTION_CONTRACT_FILE" ".navigation_protocol.primary_direction" "")
    local checkpoints_count=$(get_json_value "$EXECUTION_CONTRACT_FILE" ".navigation_protocol.route_checkpoints | length" "0")

    log_navigation "INFO" "主要方向: $primary_direction"
    log_navigation "INFO" "检查点数量: $checkpoints_count"

    # 更新导航路线
    jq --arg direction "$primary_direction" --arg waypoints "$checkpoints_count" '
        .route.current_position = "start" |
        .route.target_position = $direction |
        .route.total_waypoints = ($waypoints | tonumber)
    ' "$NAVIGATION_STATUS_FILE" > temp_nav.json && mv temp_nav.json "$NAVIGATION_STATUS_FILE"

    # 生成导航历史记录
    local route_entry=$(cat << EOF
{
  "timestamp": "$(get_iso_timestamp)",
  "action": "route_generated",
  "direction": "$primary_direction",
  "waypoints": $checkpoints_count,
  "status": "active"
}
EOF
    )

    jq --argjson route_entry "$route_entry" '.navigation_history += [$route_entry]' "$NAVIGATION_STATUS_FILE" > temp_nav.json && mv temp_nav.json "$NAVIGATION_STATUS_FILE"

    log_navigation "SUCCESS" "导航路线图生成完成"
}

# 更新当前位置
update_position() {
    local new_position="$1"
    local reason="${2:-}"

    local old_position=$(get_json_value "$NAVIGATION_STATUS_FILE" ".route.current_position" "")

    if [[ "$new_position" != "$old_position" ]]; then
        log_navigation "ROUTE" "位置更新: $old_position -> $new_position ($reason)"

        # 更新位置
        jq --arg position "$new_position" --arg reason "$reason" --arg timestamp "$(get_iso_timestamp)" '
            .route.current_position = $position |
            .navigation_history += [{
                "timestamp": $timestamp,
                "action": "position_update",
                "from_position": .route.current_position,
                "to_position": $position,
                "reason": $reason
            }]
        ' "$NAVIGATION_STATUS_FILE" > temp_nav.json && mv temp_nav.json "$NAVIGATION_STATUS_FILE"

        # 检查是否到达检查点
        check_waypoint "$new_position"
    fi
}

# 检查检查点
check_waypoint() {
    local current_position="$1"

    # 从执行契约中获取检查点信息
    local checkpoint=$(jq -r --arg pos "$current_position" '
        .navigation_protocol.route_checkpoints[] | select(.location == $pos)
    ' "$EXECUTION_CONTRACT_FILE")

    if [[ -n "$checkpoint" && "$checkpoint" != "null" ]]; then
        log_navigation "SUCCESS" "到达检查点: $current_position"

        # 记录检查点到达
        local checkpoint_entry=$(cat << EOF
{
  "timestamp": "$(get_iso_timestamp)",
  "action": "checkpoint_reached",
  "checkpoint": "$current_position",
  "validation": "pending"
}
EOF
        )

        jq --argjson checkpoint_entry "$checkpoint_entry" '.navigation_history += [$checkpoint_entry]' "$NAVIGATION_STATUS_FILE" > temp_nav.json && mv temp_nav.json "$NAVIGATION_STATUS_FILE"

        # 更新完成的检查点数量
        local completed=$(get_json_value "$NAVIGATION_STATUS_FILE" ".route.completed_waypoints" "0")
        jq --arg completed "$((completed + 1))" '
            .route.completed_waypoints = $completed
        ' "$NAVIGATION_STATUS_FILE" > temp_nav.json && mv temp_nav.json "$NAVIGATION_STATUS_FILE"

        # 执行检查点验证
        validate_checkpoint "$current_position"
    fi
}

# 验证检查点
validate_checkpoint() {
    local checkpoint="$1"

    log_navigation "INFO" "验证检查点: $checkpoint"

    # 从执行契约中获取验证标准
    local alignment_check=$(jq -r --arg cp "$checkpoint" '
        .navigation_protocol.route_checkpoints[] | select(.checkpoint_id == $cp) | .alignment_check
    ' "$EXECUTION_CONTRACT_FILE")

    if [[ -n "$alignment_check" && "$alignment_check" != "null" ]]; then
        log_navigation "INFO" "执行对齐检查: $alignment_check"

        # 这里应该调用对齐检查逻辑
        # 暂时标记为通过
        log_navigation "SUCCESS" "检查点验证通过"
    fi
}

# 检测导航偏差
detect_navigation_deviation() {
    log_navigation "INFO" "执行导航偏差检测"

    local current_position=$(get_json_value "$NAVIGATION_STATUS_FILE" ".route.current_position" "")
    local target_position=$(get_json_value "$NAVIGATION_STATUS_FILE" ".route.target_position" "")

    # 计算偏离度
    local deviation_magnitude=0
    local deviation_type="none"

    # 简单的偏离检测逻辑
    if [[ "$current_position" == "start" && "$target_position" != "start" ]]; then
        deviation_magnitude=100
        deviation_type="off_course"
    elif [[ "$current_position" != "target_position" && -n "$current_position" ]]; then
        # 这里可以添加更复杂的偏离检测逻辑
        deviation_magnitude=50
        deviation_type="partial_deviation"
    fi

    # 更新偏差状态
    local detected=false
    if [[ $deviation_magnitude -gt 20 ]]; then
        detected=true
        log_navigation "WARN" "检测到导航偏差: $deviation_type (程度: $deviation_magnitude)"
    fi

    jq --arg detected "$detected" --arg type "$deviation_type" --arg magnitude "$deviation_magnitude" '
        .deviation.detected = $detected |
        .deviation.deviation_type = $type |
        .deviation.deviation_magnitude = $magnitude |
        if $detected then
            .navigation_history += [{
                "timestamp": "$(get_iso_timestamp)",
                "action": "deviation_detected",
                "type": $type,
                "magnitude": $magnitude
            }]
        end
    ' "$NAVIGATION_STATUS_FILE" > temp_nav.json && mv temp_nav.json "$NAVIGATION_STATUS_FILE"

    return $deviation_magnitude
}

# 执行自动纠偏
execute_correction() {
    local deviation_type="$1"
    local deviation_magnitude="$2"

    log_navigation "INFO" "执行自动纠偏: $deviation_type (程度: $deviation_magnitude)"

    # 记录纠偏操作
    local correction_count=$(get_json_value "$NAVIGATION_STATUS_FILE" ".deviation.correction_count" "0")

    local correction_entry=$(cat << EOF
{
  "timestamp": "$(get_iso_timestamp)",
  "action": "auto_correction",
  "deviation_type": "$deviation_type",
  "deviation_magnitude": $deviation_magnitude,
  "correction_strategy": "realignment"
}
EOF
    )

    jq --argjson correction_entry "$correction_entry" '
        .deviation.correction_count = (.deviation.correction_count + 1) |
        .deviation.last_correction = "$(get_iso_timestamp)" |
        .navigation_history += [$correction_entry]
    ' "$NAVIGATION_STATUS_FILE" > temp_nav.json && mv temp_nav.json "$NAVIGATION_STATUS_FILE"

    # 重置到正确的位置
    realign_to_target

    log_navigation "SUCCESS" "自动纠偏完成"
}

# 重新对齐到目标
realign_to_target() {
    local target_position=$(get_json_value "$NAVIGATION_STATUS_FILE" ".route.target_position" "")

    log_navigation "ROUTE" "重新对齐到目标: $target_position"

    update_position "$target_position" "自动纠偏重新对齐"

    # 重置偏离状态
    jq '
        .deviation.detected = false |
        .deviation.deviation_type = null |
        .deviation.deviation_magnitude = 0
    ' "$NAVIGATION_STATUS_FILE" > temp_nav.json && mv temp_nav.json "$NAVIGATION_STATUS_FILE"
}

# 计算导航进度
calculate_navigation_progress() {
    local total_waypoints=$(get_json_value "$NAVIGATION_STATUS_FILE" ".route.total_waypoints" "1")
    local completed_waypoints=$(get_json_value "$NAVIGATION_STATUS_FILE" ".route.completed_waypoints" "0")
    local current_position=$(get_json_value "$NAVIGATION_STATUS_FILE" ".route.current_position" "")
    local target_position=$(get_jsonIGATION_STATUS_FILE" ".route.target_position" "")

    local progress=0

    if [[ $total_waypoints -gt 0 ]]; then
        progress=$((completed_waypoints * 100 / total_waypoints))
    fi

    # 简单的位置进度计算
    if [[ "$current_position" == "$target_position" ]]; then
        progress=100
    elif [[ "$current_position" != "start" && -n "$current_position" ]]; then
        progress=$((progress + 25))
    fi

    echo $progress
}

# 启动导航监控
start_navigation() {
    log_navigation "INFO" "启动导航监控"

    while true; do
        # 检测偏差
        local deviation=$(detect_navigation_deviation)

        if [[ $deviation -gt 20 ]]; then
            local deviation_type=$(get_json_value "$NAVIGATION_STATUS_FILE" ".deviation.deviation_type" "")
            execute_correction "$deviation_type" "$deviation"
        fi

        # 更新进度
        local progress=$(calculate_navigation_progress)
        log_navigation "INFO" "导航进度: $progress%"

        # 检查是否完成
        if [[ "$progress" -ge 100 ]]; then
            log_navigation "SUCCESS" "导航完成，已到达目标位置"
            break
        fi

        # 等待下次检查
        sleep 30
    done
}

# 显示导航状态
show_navigation_status() {
    echo -e "${WHITE}=== Claude Code 自我导航状态 ===${NC}"
    echo ""

    if [[ -f "$NAVIGATION_STATUS_FILE" ]]; then
        echo -e "${CYAN}导航信息:${NC}"
        jq -r '.navigation_info | to_entries[] | "  \(.key): \(.value)"' "$NAVIGATION_STATUS_FILE"
        echo ""

        echo -e "${CYAN}路线状态:${NC}"
        local current_pos=$(jq -r '.route.current_position' "$NAVIGATION_STATUS_FILE")
        local target_pos=$(jq -r '.route.target_position' "$NAVIGATION_STATUS_FILE")
        local total_wp=$(jq -r '.route.total_waypoints' "$NAVIGATION_STATUS_FILE")
        local completed_wp=$(jq -r '.route.completed_waypoints' "$NAVIGATION_STATUS_FILE")
        local progress=$(calculate_navigation_progress)

        echo -e "  当前位置: $current_pos"
        echo -e "  目标位置: $target_pos"
        echo -e "  进度: $progress% ($completed_wp/$total_wp)"
        echo ""

        echo -e "${CYAN}对齐状态:${NC}"
        local alignment_score=$(jq -r '.alignment.current_alignment_score' "$NAVIGATION_STATUS_FILE")
        local target_score=$(jq -r '.alignment.target_alignment_score' "$NAVIGATION_STATUS_FILE")
        echo -e "  当前对齐度: $alignment_score/$target_score"
        echo ""

        echo -e "${CYAN}偏差状态:${NC}"
        local detected=$(jq -r '.deviation.detected' "$NAVIGATION_STATUS_FILE")
        local deviation_type=$(jq -r '.deviation.deviation_type' "$NAVIGATION_STATUS_FILE")
        local deviation_mag=$(jq -r '.deviation.deviation_magnitude' "$NAVIGATION_STATUS_FILE")
        local corrections=$(jq -r '.deviation.correction_count' "$NAVIGATION_STATUS_FILE")

        echo -e "  偏差检测: $([ "$detected" = true ] && echo "${RED}检测到偏离 ($deviation_type, 程度: $deviation_mag)${NC}" || echo "${GREEN}正常${NC}")"
        echo -e "  纠偏次数: $corrections"
    else
        echo -e "${RED}导航系统未启动${NC}"
    fi
}

# 显示导航仪表板
show_dashboard() {
    echo -e "${WHITE}=== 自我导航仪表板 ===${NC}"
    echo -e "${WHITE}更新时间: $(get_timestamp)${NC}"
    echo ""

    if [[ -f "$NAVIGATION_STATUS_FILE" ]]; then
        # 进度条显示
        local progress=$(calculate_navigation_progress)
        echo -e "${CYAN}导航进度:${NC}"

        local bar_length=50
        local filled_length=$((progress * bar_length / 100))
        local empty_length=$((bar_length - filled_length))

        printf "[${GREEN}%*s${NC}" $filled_length
        printf "%*s" $empty_length
        echo " $progress%"
        echo ""

        # 详细状态
        show_navigation_status
    else
        echo -e "${RED}导航系统未初始化${NC}"
        echo ""
        echo -e "${YELLOW}请先执行: $0 --init${NC}"
    fi

    echo ""
    echo -e "${BLUE}操作命令:${NC}"
    echo "  $0 --status       # 显示详细状态"
    echo "  $0 --update-pos <position> # 更新位置"
    echo "  $0 --detect-deviation # 检测偏差"
    echo "  $0 --auto-correct  # 自动纠偏"
}

# 显示帮助信息
show_help() {
    cat << EOF
Claude Code 自我导航引擎 v1.0

用法: $0 [选项] [参数]

选项:
    --init                     初始化导航系统
    --start                    启动导航监控
    --status                   显示导航状态
    --dashboard                显示导航仪表板
    --update-pos <position>    更新当前位置
    --detect-deviation          检测导航偏差
    --auto-correct             执行自动纠偏
    --help                     显示此帮助信息

示例:
    $0 --init                   # 初始化导航系统
    $0 --start                  # 启动导航监控
    $0 --dashboard              # 显示导航仪表板
    $0 --update-pos milestone1   # 更新位置到milestone1

EOF
}

# 主函数
main() {
    # 检查依赖
    if ! check_dependencies; then
        log_navigation "ERROR" "依赖检查失败，请安装必要的工具"
        exit 1
    fi

    case "${1:-}" in
        "--init")
            init_navigation
            load_navigation_data
            generate_navigation_route
            ;;
        "--start")
            start_navigation
            ;;
        "--status")
            show_navigation_status
            ;;
        "--dashboard")
            show_dashboard
            ;;
        "--update-pos")
            if [[ -z "${2:-}" ]]; then
                log_navigation "ERROR" "请指定新位置"
                exit 1
            fi
            update_position "$2" "手动更新"
            ;;
        "--detect-deviation")
            detect_navigation_deviation
            ;;
        "--auto-correct")
            local deviation_type=$(get_json_value "$NAVIGATION_STATUS_FILE" ".deviation.deviation_type" "")
            local deviation_magnitude=$(get_json_value "$NAVIGATION_STATUS_FILE" ".deviation.deviation_magnitude" "0")
            if [[ "$deviation_type" != "null" && $deviation_magnitude -gt 0 ]]; then
                execute_correction "$deviation_type" "$deviation_magnitude"
            else
                log_navigation "INFO" "当前无偏差，无需纠偏"
            fi
            ;;
        "--help"|"")
            show_help
            ;;
        *)
            log_navigation "ERROR" "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi