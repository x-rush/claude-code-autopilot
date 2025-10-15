#!/bin/bash
# Claude Code 偏差检测器
# 实时检测执行过程中的偏差，自动识别偏离并触发纠正机制

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
    log_message "ERROR" "偏差检测器在第 $line_number 行异常退出，退出码: $exit_code"
    cleanup_on_error
    exit $exit_code
}

# 错误处理钩子
trap 'handle_error $? $LINENO' ERR

# 错误时清理函数
cleanup_on_error() {
    log_message "INFO" "偏差检测器错误清理操作"
    cleanup_temp_files
}

# 文件路径
DEVIATION_STATUS_FILE="$PROJECT_ROOT/DEVIATION_STATUS.json"
REQUIREMENT_ALIGNMENT_FILE="$PROJECT_ROOT/REQUIREMENT_ALIGNMENT.json"
EXECUTION_CONTRACT_FILE="$PROJECT_ROOT/EXECUTION_CONTRACT.json"
NAVIGATION_STATUS_FILE="$PROJECT_ROOT/NAVIGATION_STATUS.json"
DEVIATION_LOG_FILE="$PROJECT_ROOT/DEVIATION_LOG.md"

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
log_deviation() {
    local level="$1"
    local message="$2"

    case "$level" in
        "INFO")
            echo -e "${GREEN}[DEVIATION]${NC} $(get_timestamp) - $message" | tee -a "$DEVIATION_LOG_FILE"
            ;;
        "WARN")
            echo -e "${YELLOW}[DEVIATION]${NC} $(get_timestamp) - $message" | tee -a "$DEVIATION_LOG_FILE"
            ;;
        "ERROR")
            echo -e "${RED}[DEVIATION]${NC} $(get_timestamp) - $message" | tee -a "$DEVIATION_LOG_FILE"
            ;;
        "ALERT")
            echo -e "${MAGENTA}[ALERT]${NC} $(get_timestamp) - $message" | tee -a "$DEVIATION_LOG_FILE"
            ;;
        "DETECTED")
            echo -e "${RED}[DETECTED]${NC} $(get_timestamp) - $message" | tee -a "$DEVIATION_LOG_FILE"
            ;;
        "CORRECTED")
            echo -e "${CYAN}[CORRECTED]${NC} $(get_timestamp) - $message" | tee -a "$DEVIATION_LOG_FILE"
            ;;
    esac
}

# 初始化偏差检测器
init_deviation_detector() {
    log_deviation "INFO" "初始化偏差检测系统"

    # 创建偏差日志
    echo "# Claude Code 偏差检测日志" > "$DEVIATION_LOG_FILE"
    echo "启动时间: $(get_timestamp)" >> "$DEVIATION_LOG_FILE"
    echo "" >> "$DEVIATION_LOG_FILE"

    # 初始化偏差状态
    cat > "$DEVIATION_STATUS_FILE" << EOF
{
  "detector_info": {
    "session_id": "DEV_$(generate_id)",
    "start_time": "$(get_iso_timestamp)",
    "status": "INITIALIZING",
    "detection_interval": 30
  },
  "monitoring": {
    "enabled": true,
    "last_check": null,
    "check_count": 0,
    "alert_count": 0
  },
  "deviation_types": {
    "requirement_alignment": {
      "enabled": true,
      "threshold": 20,
      "detected_count": 0,
      "last_detection": null
    },
    "execution_contract": {
      "enabled": true,
      "threshold": 15,
      "detected_count": 0,
      "last_detection": null
    },
    "navigation_route": {
      "enabled": true,
      "threshold": 25,
      "detected_count": 0,
      "last_detection": null
    },
    "quality_standards": {
      "enabled": true,
      "threshold": 30,
      "detected_count": 0,
      "last_detection": null
    }
  },
  "current_deviation": {
    "detected": false,
    "type": null,
    "severity": "low",
    "magnitude": 0,
    "confidence": 0,
    "description": "",
    "detected_at": null,
    "corrected_at": null
  },
  "deviation_history": [],
  "correction_history": [],
  "statistics": {
    "total_detections": 0,
    "auto_corrections": 0,
    "manual_interventions": 0,
    "false_positives": 0
  }
}
EOF

    log_deviation "SUCCESS" "偏差检测器初始化完成"
}

# 检测需求对齐偏差
detect_requirement_alignment_deviation() {
    log_deviation "INFO" "检测需求对齐偏差"

    if [[ ! -f "$REQUIREMENT_ALIGNMENT_FILE" ]]; then
        log_deviation "ERROR" "需求对齐文件不存在"
        return 0
    fi

    # 获取当前执行状态和需求对齐数据
    local primary_goal=$(get_json_value "$REQUIREMENT_ALIGNMENT_FILE" ".user_objective.primary_goal" "")
    local success_criteria=$(get_json_value "$REQUIREMENT_ALIGNMENT_FILE" ".user_objective.success_criteria" "[]")
    local deliverables=$(get_json_value "$REQUIREMENT_ALIGNMENT_FILE" ".deliverables" "[]")

    # 计算偏差度 (简化实现)
    local deviation_magnitude=0
    local confidence=0
    local description=""

    # 这里应该实现具体的需求对齐偏差检测逻辑
    # 暂时返回无偏差
    if [[ -n "$primary_goal" && ${#success_criteria[@]} -gt 0 ]]; then
        confidence=85
        deviation_magnitude=5
        description="需求对齐基本符合，轻微偏差"
    fi

    # 更新需求对齐偏差状态
    local threshold=$(get_json_value "$DEVIATION_STATUS_FILE" ".deviation_types.requirement_alignment.threshold" "20")
    local detected=false

    if [[ $deviation_magnitude -gt $threshold ]]; then
        detected=true
        local detection_count=$(get_json_value "$DEVIATION_STATUS_FILE" ".deviation_types.requirement_alignment.detected_count" "0")

        log_deviation "DETECTED" "需求对齐偏差检测: 偏差程度 $deviation_magnitude% (阈值: $threshold%)"

        # 更新检测状态
        jq --arg detected "$detected" --arg magnitude "$deviation_magnitude" --arg confidence "$confidence" --arg description "$description" --arg timestamp "$(get_iso_timestamp)" '
            .deviation_types.requirement_alignment.detected_count = ($detected_count + 1) |
            .deviation_types.requirement_alignment.last_detection = $timestamp |
            if $detected then
                .current_deviation.detected = true |
                .current_deviation.type = "requirement_alignment" |
                .current_deviation.severity = ($magnitude > 50 ? "high" : ($magnitude > 25 ? "medium" : "low")) |
                .current_deviation.magnitude = $magnitude |
                .current_deviation.confidence = $confidence |
                .current_deviation.description = $description |
                .current_deviation.detected_at = $timestamp
            end |
            .statistics.total_detections += 1 |
            .deviation_history += [{
                "timestamp": $timestamp,
                "type": "requirement_alignment",
                "magnitude": $magnitude,
                "confidence": $confidence,
                "threshold": $threshold,
                "description": $description
            }]
        ' "$DEVIATION_STATUS_FILE" > temp_dev.json && mv temp_dev.json "$DEVIATION_STATUS_FILE"

        # 触发自动纠正
        if [[ $deviation_magnitude -gt 40 ]]; then
            trigger_auto_correction "requirement_alignment" "$deviation_magnitude"
        fi
    fi

    return $deviation_magnitude
}

# 检测执行契约偏差
detect_execution_contract_deviation() {
    log_deviation "INFO" "检测执行契约偏差"

    if [[ ! -f "$EXECUTION_CONTRACT_FILE" ]]; then
        log_deviation "ERROR" "执行契约文件不存在"
        return 0
    fi

    # 获取契约执行状态
    local contract_status=$(get_json_value "$EXECUTION_CONTRACT_FILE" ".execution_commitments.status" "unknown")
    local quality_metrics=$(get_json_value "$EXECUTION_CONTRACT_FILE" ".quality_assurance.quality_metrics" "{}")

    # 计算契约执行偏差度
    local deviation_magnitude=0
    local confidence=0
    local description=""

    # 这里应该实现具体的契约执行偏差检测逻辑
    # 暂时返回无偏差
    if [[ "$contract_status" == "in_progress" || "$contract_status" == "running" ]]; then
        confidence=90
        deviation_magnitude=8
        description="契约执行状态正常，轻微偏离"
    fi

    # 更新执行契约偏差状态
    local threshold=$(get_json_value "$DEVIATION_STATUS_FILE" ".deviation_types.execution_contract.threshold" "15")
    local detected=false

    if [[ $deviation_magnitude -gt $threshold ]]; then
        detected=true
        local detection_count=$(get_json_value "$DEVIATION_STATUS_FILE" ".deviation_types.execution_contract.detected_count" "0")

        log_deviation "DETECTED" "执行契约偏差检测: 偏差程度 $deviation_magnitude% (阈值: $threshold%)"

        # 更新检测状态
        jq --arg detected "$detected" --arg magnitude "$deviation_magnitude" --arg confidence "$confidence" --arg description "$description" --arg timestamp "$(get_iso_timestamp)" '
            .deviation_types.execution_contract.detected_count = ($detected_count + 1) |
            .deviation_types.execution_contract.last_detection = $timestamp |
            if $detected then
                .current_deviation.detected = true |
                .current_deviation.type = "execution_contract" |
                .current_deviation.severity = ($magnitude > 50 ? "high" : ($magnitude > 25 ? "medium" : "low")) |
                .current_deviation.magnitude = $magnitude |
                .deviation.confidence = $confidence |
                .current_deviation.description = $description |
                .current_deviation.detected_at = $timestamp
            end |
            .statistics.total_detections += 1 |
            .deviation_history += [{
                "timestamp": $timestamp,
                "type": "execution_contract",
                "magnitude": $magnitude,
                "confidence": $confidence,
                "threshold": $threshold,
                "description": $description
            }]
        ' "$DEVIATION_STATUS_FILE" > temp_dev.json && mv temp_dev.json "$DEVIATION_STATUS_FILE"

        # 触发自动纠正
        if [[ $deviation_magnitude -gt 35 ]]; then
            trigger_auto_correction "execution_contract" "$deviation_magnitude"
        fi
    fi

    return $deviation_magnitude
}

# 检测导航路线偏差
detect_navigation_route_deviation() {
    log_deviation "INFO" "检测导航路线偏差"

    if [[ ! -f "$NAVIGATION_STATUS_FILE" ]]; then
        log_deviation "ERROR" "导航状态文件不存在"
        return 0
    fi

    # 获取导航状态
    local current_position=$(get_json_value "$NAVIGATION_STATUS_FILE" ".route.current_position" "")
    local target_position=$(get_json_value "$NAVIGATION_STATUS_FILE" ".route.target_position" "")
    local deviation_detected=$(get_json_value "$NAVIGATION_STATUS_FILE" ".deviation.detected" "false")

    # 计算导航偏差度
    local deviation_magnitude=0
    local confidence=0
    local description=""

    # 导航偏差计算
    if [[ "$deviation_detected" == "true" ]]; then
        local deviation_type=$(get_json_value "$NAVIGATION_STATUS_FILE" ".deviation.deviation_type" "")
        case "$deviation_type" in
            "off_course")
                deviation_magnitude=80
                confidence=95
                description="严重偏离预定路线"
                ;;
            "partial_deviation")
                deviation_magnitude=40
                confidence=85
                description="部分偏离预定路线"
                ;;
            *)
                deviation_magnitude=30
                confidence=80
                description="轻微偏离预定路线"
                ;;
        esac
    elif [[ -n "$current_position" && "$current_position" != "$target_position" && "$current_position" != "start" ]]; then
        deviation_magnitude=25
        confidence=75
        description="路线执行中轻微偏离"
    fi

    # 更新导航路线偏差状态
    local threshold=$(get_json_value "$DEVIATION_STATUS_FILE" ".deviation_types.navigation_route.threshold" "25")
    local detected=false

    if [[ $deviation_magnitude -gt $threshold ]]; then
        detected=true
        local detection_count=$(get_json_value "$DEVIATION_STATUS_FILE" ".deviation_types.navigation_route.detected_count" "0")

        log_deviation "DETECTED" "导航路线偏差检测: 偏差程度 $deviation_magnitude% (阈值: $threshold%)"

        # 更新检测状态
        jq --arg detected "$detected" --arg magnitude "$deviation_magnitude" --arg confidence "$confidence" --arg description "$description" --arg timestamp "$(get_iso_timestamp)" '
            .deviation_types.navigation_route.detected_count = ($detected_count + 1) |
            .deviation_types.navigation_route.last_detection = $timestamp |
            if $detected then
                .current_deviation.detected = true |
                .current_deviation.type = "navigation_route" |
                .current_deviation.severity = ($magnitude > 50 ? "high" : ($magnitude > 25 ? "medium" : "low")) |
                .current_deviation.magnitude = $magnitude |
                .deviation.confidence = $confidence |
                .current_deviation.description = $description |
                .current_deviation.detected_at = $timestamp
            end |
            .statistics.total_detections += 1 |
            .deviation_history += [{
                "timestamp": $timestamp,
                "type": "navigation_route",
                "magnitude": $magnitude,
                "confidence": $confidence,
                "threshold": $threshold,
                "description": $description
            }]
        ' "$DEVIATION_STATUS_FILE" > temp_dev.json && mv temp_dev.json "$DEVIATION_STATUS_FILE"

        # 触发自动纠正
        if [[ $deviation_magnitude -gt 30 ]]; then
            trigger_auto_correction "navigation_route" "$deviation_magnitude"
        fi
    fi

    return $deviation_magnitude
}

# 检测质量标准偏差
detect_quality_standards_deviation() {
    log_deviation "INFO" "检测质量标准偏差"

    if [[ ! -f "$REQUIREMENT_ALIGNMENT_FILE" ]]; then
        log_deviation "ERROR" "需求对齐文件不存在"
        return 0
    fi

    # 获取质量要求
    local quality_standard=$(get_json_value "$REQUIREMENT_ALIGNMENT_FILE" ".execution_preferences.quality_standard" "medium")
    local detail_level=$(get_json_value "$REQUIREMENT_ALIGNMENT_FILE" ".execution_preferences.detail_level" "medium")

    # 计算质量标准偏差度
    local deviation_magnitude=0
    local confidence=0
    local description=""

    # 这里应该实现具体的质量标准偏差检测逻辑
    # 基于文件质量、格式正确性等进行评估
    case "$quality_standard" in
        "production")
            if [[ "$detail_level" == "high" ]]; then
                deviation_magnitude=10
                confidence=85
                description="生产质量标准，执行质量良好"
            else
                deviation_magnitude=15
                confidence=75
                description="生产质量标准，执行质量需要提升"
            fi
            ;;
        "learning")
            deviation_magnitude=20
            confidence=80
            description="学习参考质量标准，执行质量适中"
            ;;
        "prototype")
            deviation_magnitude=30
            confidence=70
            description="原型质量标准，执行质量可接受"
            ;;
        *)
            deviation_magnitude=25
            confidence=75
            description="默认质量标准，执行质量有待提升"
            ;;
    esac

    # 更新质量标准偏差状态
    local threshold=$(get_json_value "$DEVIATION_STATUS_FILE" ".deviation_types.quality_standards.threshold" "30")
    local detected=false

    if [[ $deviation_magnitude -gt $threshold ]]; then
        detected=true
        local detection_count=$(get_json_value "$DEVIATION_STATUS_FILE" ".deviation_types.quality_standards.detected_count" "0")

        log_deviation "DETECTED" "质量标准偏差检测: 偏差程度 $deviation_magnitude% (阈值: $threshold%)"

        # 更新检测状态
        jq --arg detected "$detected" --arg magnitude "$deviation_magnitude" --arg confidence "$confidence" --arg description "$description" --arg timestamp "$(get_iso_timestamp)" '
            .deviation_types.quality_standards.detected_count = ($detected_count + 1) |
            .deviation_types.quality_standards.last_detection = $timestamp |
            if $detected then
                .current_deviation.detected = true |
                .current_deviation.type = "quality_standards" |
                .current_deviation.severity = ($magnitude > 50 ? "high" : ($magnitude > 25 ? "medium" : "low")) |
                .current_deviation.magnitude = $magnitude |
                .deviation.confidence = $confidence |
                .deviation.description = $description |
                .current_deviation.detected_at = $timestamp
            end |
            .statistics.total_detections += 1 |
            .deviation_history += [{
                "timestamp": $timestamp,
                "type": "quality_standards",
                "magnitude": $magnitude,
                "confidence": $confidence,
                "threshold": $threshold,
                "description": $description
            }]
        ' "$DEVIATION_STATUS_FILE" > temp_dev.json && mv temp_dev.json "$DEVIATION_STATUS_FILE"

        # 触发自动纠正
        if [[ $deviation_magnitude -gt 35 ]]; then
            trigger_auto_correction "quality_standards" "$deviation_magnitude"
        fi
    fi

    return $deviation_magnitude
}

# 执行综合偏差检测
perform_comprehensive_deviation_check() {
    log_deviation "INFO" "执行综合偏差检测"

    local max_deviation=0
    local dominant_type=""

    # 检测各类偏差
    local req_alignment=$(detect_requirement_alignment_deviation)
    local exec_contract=$(detect_execution_contract_deviation)
    local nav_route=$(detect_navigation_route_deviation)
    local quality_std=$(detect_quality_standards_deviation)

    # 找出最大偏差
    for deviation in $req_alignment $exec_contract $nav_route $quality_std; do
        if [[ $deviation -gt $max_deviation ]]; then
            max_deviation=$deviation
        fi
    done

    # 确定主导偏差类型
    if [[ $req_alignment -eq $max_deviation ]]; then
        dominant_type="requirement_alignment"
    elif [[ $exec_contract -eq $max_deviation ]]; then
        dominant_type="execution_contract"
    elif [[ $nav_route -eq $max_deviation ]]; then
        dominant_type="navigation_route"
    elif [[ $quality_std -eq $max_deviation ]]; then
        dominant_type="quality_standards"
    fi

    # 更新监控状态
    jq --arg count "$(jq -r '.monitoring.check_count' "$DEVIATION_STATUS_FILE")" '
        .monitoring.check_count = $count + 1 |
        .monitoring.last_check = "$(get_iso_timestamp)"
    ' "$DEVIATION_STATUS_FILE" > temp_dev.json && mv temp_dev.json "$DEVIATION_STATUS_FILE"

    log_deviation "INFO" "综合偏差检测完成: 最大偏差 $max_deviation% (类型: $dominant_type)"

    return $max_deviation
}

# 触发自动纠正
trigger_auto_correction() {
    local deviation_type="$1"
    local deviation_magnitude="$2"

    log_deviation "ALERT" "触发自动纠正: $deviation_type (偏差程度: $deviation_magnitude%)"

    # 记录纠正操作
    local correction_count=$(get_json_value "$DEVIATION_STATUS_FILE" ".statistics.auto_corrections" "0")

    local correction_entry=$(cat << EOF
{
  "timestamp": "$(get_iso_timestamp)",
  "type": "$deviation_type",
  "magnitude": $deviation_magnitude,
  "strategy": "automatic_realignment",
  "status": "initiated"
}
EOF
    )

    jq --argjson correction_entry "$correction_entry" '
        .statistics.auto_corrections += 1 |
        .correction_history += [$correction_entry] |
        .current_deviation.corrected_at = "$(get_iso_timestamp)"
    ' "$DEVIATION_STATUS_FILE" > temp_dev.json && mv temp_dev.json "$DEVIATION_STATUS_FILE"

    # 调用自动纠偏器
    if [[ -f "$SCRIPT_DIR/auto-corrector.sh" ]]; then
        log_deviation "INFO" "调用自动纠偏器"
        "$SCRIPT_DIR/auto-corrector.sh" --type "$deviation_type" --magnitude "$deviation_magnitude" &
    else
        log_deviation "WARN" "自动纠偏器不存在，请手动处理"
    fi
}

# 开始监控
start_monitoring() {
    log_deviation "INFO" "启动偏差监控"

    local interval=$(get_json_value "$DEVIATION_STATUS_FILE" ".detector_info.detection_interval" "30")

    while true; do
        perform_comprehensive_deviation_check
        sleep "$interval"
    done
}

# 显示偏差状态
show_deviation_status() {
    echo -e "${WHITE}=== Claude Code 偏差检测状态 ===${NC}"
    echo ""

    if [[ -f "$DEVIATION_STATUS_FILE" ]]; then
        echo -e "${CYAN}检测器信息:${NC}"
        jq -r '.detector_info | to_entries[] | "  \(.key): \(.value)"' "$DEVIATION_STATUS_FILE"
        echo ""

        echo -e "${CYAN}监控统计:${NC}"
        local check_count=$(jq -r '.monitoring.check_count' "$DEVIATION_STATUS_FILE")
        local alert_count=$(jq -r '.monitoring.alert_count' "$DEVIATION_STATUS_FILE")
        echo -e "  检查次数: $check_count"
        echo -e "  告警次数: $alert_count"
        echo ""

        echo -e "${CYAN}偏差类型统计:${NC}"
        jq -r '.deviation_types | to_entries[] | "  \(.key): 检测次数=\(.value.detected_count), 阈值=\(.value.threshold)"' "$DEVIATION_STATUS_FILE"
        echo ""

        echo -e "${CYAN}当前偏差状态:${NC}"
        local detected=$(jq -r '.current_deviation.detected' "$DEVIATION_STATUS_FILE")
        local dev_type=$(jq -r '.current_deviation.type' "$DEVIATION_STATUS_FILE")
        local severity=$(jq -r '.current_deviation.severity' "$DEVIATION_STATUS_FILE")
        local magnitude=$(jq -r '.current_deviation.magnitude' "$DEVIATION_STATUS_FILE")
        local confidence=$(jq -r '.current_deviation.confidence' "$DEVIATION_STATUS_FILE")

        if [[ "$detected" == "true" ]]; then
            echo -e "  状态: ${RED}检测到偏离${NC}"
            echo -e "  类型: $dev_type"
            echo -e "   严重程度: $severity"
            echo -e "  偏差程度: $magnitude%"
            echo -e "  置信度: $confidence%"
            echo -e "  检测时间: $(jq -r '.current_deviation.detected_at' "$DEVIATION_STATUS_FILE")"
        else
            echo -e "  状态: ${GREEN}正常${NC}"
        fi
        echo ""

        echo -e "${CYAN}统计信息:${NC}"
        local total_detections=$(jq -r '.statistics.total_detections' "$DEVIATION_STATUS_FILE")
        local auto_corrections=$(jq -r '.statistics.auto_corrections' "$DEVIATION_STATUS_FILE")
        local manual_interventions=$(jq -r '.statistics.manual_interventions' "$DEVIATION_STATUS_FILE")
        echo -e "  总检测次数: $total_detections"
        echo -e "  自动纠正次数: $auto_corrections"
        echo -e "   人工干预次数: $manual_interventions"
    else
        echo -e "${RED}偏差检测器未启动${NC}"
    fi
}

# 显示偏差报告
show_deviation_report() {
    echo -e "${WHITE}=== 偏差检测报告 ===${NC}"
    echo -e "${WHITE}生成时间: $(get_timestamp)${NC}"
    echo ""

    if [[ -f "$DEVIATION_STATUS_FILE" ]]; then
        echo -e "${CYAN}检测历史:${NC}"
        echo -e "${CYAN}最近5次检测:${NC}"
        jq -r '.deviation_history[-5:] | to_entries[] | "  \(.key): [\(.value.timestamp)] \(.value.type) - 偏差程度: \(.value.magnitude)%"' "$DEVIATION_STATUS_FILE"
        echo ""

        echo -e "${CYAN}纠正历史:${NC}"
        echo -e "${CYAN}最近5次纠正:${NC}"
        jq -r '.correction_history[-5:] | to_entries[] | "  \(.key): [\(.value.timestamp)] \(.value.type) - 策略: \(.value.strategy)"' "$DEVIATION_STATUS_FILE" | while read line; do
            echo "  $line"
        done
    else
        echo -e "${RED}无偏差检测记录${NC}"
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
Claude Code 偏差检测器 v1.0

用法: $0 [选项]

选项:
    --init                     初始化偏差检测器
    --check                    执行一次偏差检测
    --monitor                  启动持续监控
    --status                   显示检测状态
    --report                   生成偏差报告
    --help                     显示此帮助信息

检测类型:
    --requirement-alignment    检测需求对齐偏差
    --execution-contract      检测执行契约偏差
    --navigation-route         检测导航路线偏差
    --quality-standards        检测质量标准偏差

示例:
    $0 --init                   # 初始化检测器
    $0 --check                  # 执行一次检测
    $0 --monitor                # 启动持续监控
    $0 --report                 # 生成偏差报告

EOF
}

# 主函数
main() {
    # 检查依赖
    if ! check_dependencies; then
        log_deviation "ERROR" "依赖检查失败，请安装必要的工具"
        exit 1
    fi

    case "${1:-}" in
        "--init")
            init_deviation_detector
            ;;
        "--check")
            perform_comprehensive_deviation_check
            ;;
        "--monitor")
            start_monitoring
            ;;
        "--status")
            show_deviation_status
            ;;
        "--report")
            show_deviation_report
            ;;
        "--requirement-alignment")
            detect_requirement_alignment_deviation
            ;;
        "--execution-contract")
            detect_execution_contract_deviation
            ;;
        "--navigation-route")
            detect_navigation_route_deviation
            ;;
        "--quality-standards")
            detect_quality_standards_deviation
            ;;
        "--help"|"")
            show_help
            ;;
        *)
            log_deviation "ERROR" "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi