#!/bin/bash
# Claude Code 需求验证器
# 基于需求对齐结果，自动验证最终执行成果的需求匹配度和质量达标情况

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
    log_message "ERROR" "需求验证器在第 $line_number 行异常退出，退出码: $exit_code"
    cleanup_on_error
    exit $exit_code
}

# 错误处理钩子
trap 'handle_error $? $LINENO' ERR

# 错误时清理函数
cleanup_on_error() {
    log_message "INFO" "需求验证器错误清理操作"
    cleanup_temp_files
}

# 文件路径
REQUIREMENT_ALIGNMENT_FILE="$PROJECT_ROOT/REQUIREMENT_ALIGNMENT.json"
EXECUTION_CONTRACT_FILE="$PROJECT_ROOT/EXECUTION_CONTRACT.json"
NAVIGATION_STATUS_FILE="$PROJECT_ROOT/NAVIGATION_STATUS.json"
VALIDATION_REPORT_FILE="$PROJECT_ROOT/VALIDATION_REPORT.json"
VALIDATION_LOG_FILE="$PROJECT_ROOT/VALIDATION_LOG.md"

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
log_validation() {
    local level="$1"
    local message="$2"

    case "$level" in
        "INFO")
            echo -e "${GREEN}[VALIDATION]${NC} $(get_timestamp) - $message" | tee -a "$VALIDATION_LOG_FILE"
            ;;
        "WARN")
            echo -e "${YELLOW}[VALIDATION]${NC} $(get_timestamp) - $message" | tee -a "$VALIDATION_LOG_FILE"
            ;;
        "ERROR")
            echo -e "${RED}[VALIDATION]${NC} $(get_timestamp) - $message" | tee -a "$VALIDATION_LOG_FILE"
            ;;
        "SUCCESS")
            echo -e "${CYAN}[VALIDATION]${NC} $(get_timestamp) - $message" | tee -a "$VALIDATION_LOG_FILE"
            ;;
        "REQUIREMENT")
            echo -e "${MAGENTA}[REQUIREMENT]${NC} $(get_timestamp) - $message" | tee -a "$VALIDATION_LOG_FILE"
            ;;
        "QUALITY")
            echo -e "${BLUE}[QUALITY]${NC} $(get_timestamp) - $message" | tee -a "$VALIDATION_LOG_FILE"
            ;;
    esac
}

# 初始化验证器
init_validator() {
    log_validation "INFO" "初始化需求验证器"

    # 创建验证日志
    echo "# Claude Code 需求验证日志" > "$VALIDATION_LOG_FILE"
    echo "验证时间: $(get_timestamp)" >> "$VALIDATION_LOG_FILE"
    echo "" >> "$VALIDATION_LOG_FILE"

    # 初始化验证报告
    cat > "$VALIDATION_REPORT_FILE" << EOF
{
  "validation_info": {
    "session_id": "VAL_$(generate_id)",
    "validation_time": "$(get_iso_timestamp)",
    "status": "INITIALIZING",
    "validator_version": "1.0"
  },
  "requirement_alignment": {
    "file_exists": false,
    "alignment_score": 0,
    "key_requirements": [],
    "validation_result": "pending"
  },
  "execution_contract": {
    "file_exists": false,
    "contract_compliance": 0,
    "commitments_met": [],
    "validation_result": "pending"
  },
  "deliverable_validation": {
    "expected_deliverables": [],
    "actual_deliverables": [],
    "completeness_score": 0,
    "quality_score": 0,
    "validation_result": "pending"
  },
  "final_assessment": {
    "overall_score": 0,
    "requirement_match": 0,
    "quality_standard_met": false,
    "user_satisfaction_prediction": 0,
    "validation_result": "pending"
  },
  "recommendations": [],
  "validation_history": []
}
EOF

    log_validation "SUCCESS" "需求验证器初始化完成"
}

# 验证前置条件
validate_prerequisites() {
    log_validation "INFO" "验证前置条件"

    local all_prerequisites_met=true

    # 检查需求对齐文件
    if [[ -f "$REQUIREMENT_ALIGNMENT_FILE" ]]; then
        jq --arg exists true '.requirement_alignment.file_exists = $exists' "$VALIDATION_REPORT_FILE" > temp_val.json && mv temp_val.json "$VALIDATION_REPORT_FILE"
        log_validation "SUCCESS" "需求对齐文件存在"
    else
        log_validation "ERROR" "需求对齐文件不存在: $REQUIREMENT_ALIGNMENT_FILE"
        all_prerequisites_met=false
    fi

    # 检查执行契约文件
    if [[ -f "$EXECUTION_CONTRACT_FILE" ]]; then
        jq --arg exists true '.execution_contract.file_exists = $exists' "$VALIDATION_REPORT_FILE" > temp_val.json && mv temp_val.json "$VALIDATION_REPORT_FILE"
        log_validation "SUCCESS" "执行契约文件存在"
    else
        log_validation "ERROR" "执行契约文件不存在: $EXECUTION_CONTRACT_FILE"
        all_prerequisites_met=false
    fi

    # 检查导航状态文件
    if [[ -f "$NAVIGATION_STATUS_FILE" ]]; then
        log_validation "SUCCESS" "导航状态文件存在"
    else
        log_validation "WARN" "导航状态文件不存在，跳过导航验证"
    fi

    if [[ "$all_prerequisites_met" = false ]]; then
        log_validation "ERROR" "前置条件验证失败"
        return 1
    fi

    log_validation "SUCCESS" "前置条件验证通过"
    return 0
}

# 验证需求对齐质量
validate_requirement_alignment() {
    log_validation "REQUIREMENT" "验证需求对齐质量"

    # 提取需求对齐关键信息
    local primary_goal=$(get_json_value "$REQUIREMENT_ALIGNMENT_FILE" ".user_objective.primary_goal" "")
    local success_criteria=$(get_json_value "$REQUIREMENT_ALIGNMENT_FILE" ".user_objective.success_criteria | length" "0")
    local deliverables_count=$(get_json_value "$REQUIREMENT_ALIGNMENT_FILE" ".deliverables | length" "0")
    local quality_standard=$(get_json_value "$REQUIREMENT_ALIGNMENT_FILE" ".execution_preferences.quality_standard" "")

    log_validation "INFO" "主要目标: $primary_goal"
    log_validation "INFO" "成功标准数量: $success_criteria"
    log_validation "INFO" "交付物数量: $deliverables_count"
    log_validation "INFO" "质量标准: $quality_standard"

    # 计算需求对齐质量分数
    local alignment_score=0

    # 主要目标明确性 (30分)
    if [[ -n "$primary_goal" && "$primary_goal" != "null" ]]; then
        alignment_score=$((alignment_score + 30))
    fi

    # 成功标准完整性 (30分)
    if [[ $success_criteria -ge 2 ]]; then
        alignment_score=$((alignment_score + 30))
    elif [[ $success_criteria -ge 1 ]]; then
        alignment_score=$((alignment_score + 15))
    fi

    # 交付物明确性 (20分)
    if [[ $deliverables_count -ge 1 ]]; then
        alignment_score=$((alignment_score + 20))
    fi

    # 质量标准明确性 (20分)
    if [[ -n "$quality_standard" && "$quality_standard" != "null" ]]; then
        alignment_score=$((alignment_score + 20))
    fi

    # 提取关键需求
    local key_requirements=$(jq -c '.user_objective.success_criteria[]' "$REQUIREMENT_ALIGNMENT_FILE" 2>/dev/null || echo '[]')

    # 更新验证报告
    jq --arg score "$alignment_score" --argjson requirements "$key_requirements" '
        .requirement_alignment.alignment_score = ($score | tonumber) |
        .requirement_alignment.key_requirements = $requirements |
        if $score >= 80 then
            .requirement_alignment.validation_result = "excellent"
        elif $score >= 60 then
            .requirement_alignment.validation_result = "good"
        elif $score >= 40 then
            .requirement_alignment.validation_result = "acceptable"
        else
            .requirement_alignment.validation_result = "inadequate"
        end
    ' "$VALIDATION_REPORT_FILE" > temp_val.json && mv temp_val.json "$VALIDATION_REPORT_FILE"

    log_validation "SUCCESS" "需求对齐质量评分: $alignment_score/100"

    # 记录验证历史
    local validation_entry=$(cat << EOF
{
  "timestamp": "$(get_iso_timestamp)",
  "validation_type": "requirement_alignment",
  "score": $alignment_score,
  "result": "$(get_json_value "$VALIDATION_REPORT_FILE" ".requirement_alignment.validation_result" "")",
  "details": {
    "primary_goal": "$primary_goal",
    "success_criteria_count": $success_criteria,
    "deliverables_count": $deliverables_count,
    "quality_standard": "$quality_standard"
  }
}
EOF
    )

    jq --argjson validation_entry "$validation_entry" '.validation_history += [$validation_entry]' "$VALIDATION_REPORT_FILE" > temp_val.json && mv temp_val.json "$VALIDATION_REPORT_FILE"

    return $alignment_score
}

# 验证执行契约合规性
validate_execution_contract() {
    log_validation "REQUIREMENT" "验证执行契约合规性"

    # 提取执行契约关键信息
    local primary_objective=$(get_json_value "$EXECUTION_CONTRACT_FILE" ".execution_commitments.primary_objective" "")
    local deliverable_commitments=$(get_json_value "$EXECUTION_CONTRACT_FILE" ".execution_commitments.deliverable_commitments | length" "0")
    local quality_standards=$(get_json_value "$EXECUTION_CONTRACT_FILE" ".quality_assurance.quality_standards" "{}")
    local navigation_protocol=$(get_json_value "$EXECUTION_CONTRACT_FILE" ".navigation_protocol" "{}")

    log_validation "INFO" "执行主要目标: $primary_objective"
    log_validation "INFO" "交付物承诺数量: $deliverable_commitments"

    # 计算契约合规分数
    local contract_compliance=0

    # 主要目标明确性 (25分)
    if [[ -n "$primary_objective" && "$primary_objective" != "null" ]]; then
        contract_compliance=$((contract_compliance + 25))
    fi

    # 交付物承诺完整性 (30分)
    if [[ $deliverable_commitments -ge 1 ]]; then
        contract_compliance=$((contract_compliance + 30))
    fi

    # 质量标准完整性 (25分)
    if [[ "$quality_standards" != "{}" && "$quality_standards" != "null" ]]; then
        contract_compliance=$((contract_compliance + 25))
    fi

    # 导航协议完整性 (20分)
    if [[ "$navigation_protocol" != "{}" && "$navigation_protocol" != "null" ]]; then
        contract_compliance=$((contract_compliance + 20))
    fi

    # 提取承诺履约情况
    local commitments_met=$(jq -c '.execution_commitments.deliverable_commitments[].description' "$EXECUTION_CONTRACT_FILE" 2>/dev/null || echo '[]')

    # 更新验证报告
    jq --arg compliance "$contract_compliance" --argjson commitments "$commitments_met" '
        .execution_contract.contract_compliance = ($compliance | tonumber) |
        .execution_contract.commitments_met = $commitments |
        if $compliance >= 80 then
            .execution_contract.validation_result = "excellent"
        elif $compliance >= 60 then
            .execution_contract.validation_result = "good"
        elif $compliance >= 40 then
            .execution_contract.validation_result = "acceptable"
        else
            .execution_contract.validation_result = "inadequate"
        end
    ' "$VALIDATION_REPORT_FILE" > temp_val.json && mv temp_val.json "$VALIDATION_REPORT_FILE"

    log_validation "SUCCESS" "执行契约合规评分: $contract_compliance/100"

    # 记录验证历史
    local validation_entry=$(cat << EOF
{
  "timestamp": "$(get_iso_timestamp)",
  "validation_type": "execution_contract",
  "score": $contract_compliance,
  "result": "$(get_json_value "$VALIDATION_REPORT_FILE" ".execution_contract.validation_result" "")",
  "details": {
    "primary_objective": "$primary_objective",
    "deliverable_commitments_count": $deliverable_commitments,
    "quality_standards_exists": $([ "$quality_standards" != "{}" ] && echo true || echo false),
    "navigation_protocol_exists": $([ "$navigation_protocol" != "{}" ] && echo true || echo false)
  }
}
EOF
    )

    jq --argjson validation_entry "$validation_entry" '.validation_history += [$validation_entry]' "$VALIDATION_REPORT_FILE" > temp_val.json && mv temp_val.json "$VALIDATION_REPORT_FILE"

    return $contract_compliance
}

# 验证交付物完整性
validate_deliverables() {
    log_validation "QUALITY" "验证交付物完整性和质量"

    # 提取预期交付物
    local expected_deliverables=$(jq -c '.deliverables[]' "$REQUIREMENT_ALIGNMENT_FILE" 2>/dev/null || echo '[]')

    # 扫描实际交付物
    local actual_deliverables=()
    local deliverable_files=()

    # 扫描项目根目录下的交付物文件
    while IFS= read -r -d '' file; do
        local filename=$(basename "$file")
        local filesize=$(stat -c%s "$file" 2>/dev/null || echo 0)

        deliverable_files+=("{\"filename\": \"$filename\", \"path\": \"$file\", \"size\": $filesize}")
    done < <(find "$PROJECT_ROOT" -maxdepth 1 -type f \( -name "*.md" -o -name "*.txt" -o -name "*.json" -o -name "*.js" -o -name "*.py" -o -name "*.sh" \) -print0 2>/dev/null)

    # 转换为JSON数组
    local actual_deliverables_json=$(printf '%s\n' "${deliverable_files[@]}" | jq -s '.')

    # 计算完整性分数
    local expected_count=$(echo "$expected_deliverables" | jq '. | length' 2>/dev/null || echo 0)
    local actual_count=${#deliverable_files[@]}
    local completeness_score=0

    if [[ $expected_count -gt 0 ]]; then
        completeness_score=$((actual_count * 100 / expected_count))
        if [[ $completeness_score -gt 100 ]]; then
            completeness_score=100
        fi
    else
        completeness_score=0
    fi

    # 计算质量分数（基于文件大小和内容完整性）
    local quality_score=0
    if [[ $actual_count -gt 0 ]]; then
        local total_size=0
        for file in "${deliverable_files[@]}"; do
            local size=$(echo "$file" | jq -r '.size')
            total_size=$((total_size + size))
        done

        # 基于总文件大小和质量评估
        if [[ $total_size -gt 1000 ]]; then
            quality_score=80
        elif [[ $total_size -gt 500 ]]; then
            quality_score=60
        elif [[ $total_size -gt 100 ]]; then
            quality_score=40
        else
            quality_score=20
        fi
    fi

    # 更新验证报告
    jq --arg completeness "$completeness_score" --arg quality "$quality_score" --argjson expected "$expected_deliverables" --argjson actual "$actual_deliverables_json" '
        .deliverable_validation.expected_deliverables = $expected |
        .deliverable_validation.actual_deliverables = $actual |
        .deliverable_validation.completeness_score = ($completeness | tonumber) |
        .deliverable_validation.quality_score = ($quality | tonumber) |
        if ($completeness | tonumber) >= 80 and ($quality | tonumber) >= 60 then
            .deliverable_validation.validation_result = "excellent"
        elif ($completeness | tonumber) >= 60 and ($quality | tonumber) >= 40 then
            .deliverable_validation.validation_result = "good"
        elif ($completeness | tonumber) >= 40 and ($quality | tonumber) >= 20 then
            .deliverable_validation.validation_result = "acceptable"
        else
            .deliverable_validation.validation_result = "inadequate"
        end
    ' "$VALIDATION_REPORT_FILE" > temp_val.json && mv temp_val.json "$VALIDATION_REPORT_FILE"

    log_validation "SUCCESS" "交付物完整性评分: $completeness_score/100"
    log_validation "SUCCESS" "交付物质量评分: $quality_score/100"

    # 记录验证历史
    local validation_entry=$(cat << EOF
{
  "timestamp": "$(get_iso_timestamp)",
  "validation_type": "deliverable_validation",
  "completeness_score": $completeness_score,
  "quality_score": $quality_score,
  "result": "$(get_json_value "$VALIDATION_REPORT_FILE" ".deliverable_validation.validation_result" "")",
  "details": {
    "expected_count": $expected_count,
    "actual_count": $actual_count,
    "deliverable_files": $actual_deliverables_json
  }
}
EOF
    )

    jq --argjson validation_entry "$validation_entry" '.validation_history += [$validation_entry]' "$VALIDATION_REPORT_FILE" > temp_val.json && mv temp_val.json "$VALIDATION_REPORT_FILE"

    return $(( (completeness_score + quality_score) / 2 ))
}

# 执行最终评估
perform_final_assessment() {
    log_validation "INFO" "执行最终评估"

    # 获取各验证分数
    local requirement_score=$(get_json_value "$VALIDATION_REPORT_FILE" ".requirement_alignment.alignment_score" "0")
    local contract_score=$(get_json_value "$VALIDATION_REPORT_FILE" ".execution_contract.contract_compliance" "0")
    local deliverable_score=$(get_json_value "$VALIDATION_REPORT_FILE" ".deliverable_validation.completeness_score" "0")
    local quality_score=$(get_json_value "$VALIDATION_REPORT_FILE" ".deliverable_validation.quality_score" "0")

    # 计算总分
    local overall_score=0
    overall_score=$(( (requirement_score + contract_score + deliverable_score + quality_score) / 4 ))

    # 计算需求匹配度
    local requirement_match=$(( (requirement_score + contract_score) / 2 ))

    # 判断质量标准是否达标
    local quality_standard_met=false
    if [[ $quality_score -ge 60 ]]; then
        quality_standard_met=true
    fi

    # 预测用户满意度
    local user_satisfaction_prediction=$overall_score

    # 生成建议
    local recommendations=()

    if [[ $requirement_score -lt 60 ]]; then
        recommendations+=("建议重新进行需求对齐，明确主要目标和成功标准")
    fi

    if [[ $contract_score -lt 60 ]]; then
        recommendations+=("建议完善执行契约，明确交付承诺和质量标准")
    fi

    if [[ $deliverable_score -lt 60 ]]; then
        recommendations+=("建议补充缺失的交付物，确保完整性")
    fi

    if [[ $quality_score -lt 60 ]]; then
        recommendations+=("建议提升交付物质量，增加详细内容和实用价值")
    fi

    if [[ ${#recommendations[@]} -eq 0 ]]; then
        recommendations+=("执行质量优秀，建议按当前标准继续执行")
    fi

    # 转换建议为JSON
    local recommendations_json=$(printf '%s\n' "${recommendations[@]}" | jq -R . | jq -s .)

    # 确定最终验证结果
    local final_result="pending"
    if [[ $overall_score -ge 80 ]]; then
        final_result="excellent"
    elif [[ $overall_score -ge 60 ]]; then
        final_result="good"
    elif [[ $overall_score -ge 40 ]]; then
        final_result="acceptable"
    else
        final_result="needs_improvement"
    fi

    # 更新最终评估
    jq --arg overall "$overall_score" --arg requirement "$requirement_match" --argjson quality "$quality_standard_met" --arg satisfaction "$user_satisfaction_prediction" --argjson recommendations "$recommendations_json" --arg result "$final_result" '
        .final_assessment.overall_score = ($overall | tonumber) |
        .final_assessment.requirement_match = ($requirement | tonumber) |
        .final_assessment.quality_standard_met = $quality |
        .final_assessment.user_satisfaction_prediction = ($satisfaction | tonumber) |
        .final_assessment.validation_result = $result |
        .recommendations = $recommendations |
        .validation_info.status = "completed"
    ' "$VALIDATION_REPORT_FILE" > temp_val.json && mv temp_val.json "$VALIDATION_REPORT_FILE"

    log_validation "SUCCESS" "最终评估完成"
    log_validation "INFO" "总体评分: $overall_score/100"
    log_validation "INFO" "需求匹配度: $requirement_match/100"
    log_validation "INFO" "质量标准达标: $quality_standard_met"
    log_validation "INFO" "用户满意度预测: $user_satisfaction_prediction/100"
    log_validation "SUCCESS" "验证结果: $final_result"

    # 显示建议
    log_validation "INFO" "改进建议："
    echo "$recommendations_json" | jq -r '.[]' | while read -r recommendation; do
        log_validation "INFO" "  - $recommendation"
    done
}

# 显示验证报告
show_validation_report() {
    echo -e "${WHITE}=== Claude Code 需求验证报告 ===${NC}"
    echo ""

    if [[ -f "$VALIDATION_REPORT_FILE" ]]; then
        local overall_score=$(get_json_value "$VALIDATION_REPORT_FILE" ".final_assessment.overall_score" "0")
        local requirement_match=$(get_json_value "$VALIDATION_REPORT_FILE" ".final_assessment.requirement_match" "0")
        local quality_met=$(get_json_value "$VALIDATION_REPORT_FILE" ".final_assessment.quality_standard_met" "false")
        local satisfaction=$(get_json_value "$VALIDATION_REPORT_FILE" ".final_assessment.user_satisfaction_prediction" "0")
        local result=$(get_json_value "$VALIDATION_REPORT_FILE" ".final_assessment.validation_result" "pending")

        # 总体评估
        echo -e "${CYAN}📊 总体评估:${NC}"
        echo -e "  总体评分: $overall_score/100"
        echo -e "  需求匹配度: $requirement_match/100"
        echo -e "  质量标准达标: $([ "$quality_met" = true ] && echo "${GREEN}是${NC}" || echo "${RED}否${NC}")"
        echo -e "  用户满意度预测: $satisfaction/100"

        # 结果状态
        case "$result" in
            "excellent")
                echo -e "  验证结果: ${GREEN}优秀${NC}"
                ;;
            "good")
                echo -e "  验证结果: ${CYAN}良好${NC}"
                ;;
            "acceptable")
                echo -e "  验证结果: ${YELLOW}可接受${NC}"
                ;;
            "needs_improvement")
                echo -e "  验证结果: ${RED}需要改进${NC}"
                ;;
            *)
                echo -e "  验证结果: ${WHITE}$result${NC}"
                ;;
        esac
        echo ""

        # 详细验证结果
        echo -e "${CYAN}📋 详细验证结果:${NC}"

        local req_alignment_result=$(get_json_value "$VALIDATION_REPORT_FILE" ".requirement_alignment.validation_result" "")
        local req_alignment_score=$(get_json_value "$VALIDATION_REPORT_FILE" ".requirement_alignment.alignment_score" "0")
        echo -e "  需求对齐质量: $req_alignment_score/100 ($req_alignment_result)"

        local contract_result=$(get_json_value "$VALIDATION_REPORT_FILE" ".execution_contract.validation_result" "")
        local contract_score=$(get_json_value "$VALIDATION_REPORT_FILE" ".execution_contract.contract_compliance" "0")
        echo -e "  执行契约合规: $contract_score/100 ($contract_result)"

        local deliverable_result=$(get_json_value "$VALIDATION_REPORT_FILE" ".deliverable_validation.validation_result" "")
        local completeness_score=$(get_json_value "$VALIDATION_REPORT_FILE" ".deliverable_validation.completeness_score" "0")
        local quality_score=$(get_json_value "$VALIDATION_REPORT_FILE" ".deliverable_validation.quality_score" "0")
        echo -e "  交付物完整性: $completeness_score/100"
        echo -e "  交付物质量: $quality_score/100 ($deliverable_result)"
        echo ""

        # 改进建议
        echo -e "${CYAN}💡 改进建议:${NC}"
        jq -r '.recommendations[]' "$VALIDATION_REPORT_FILE" 2>/dev/null | while read -r recommendation; do
            echo -e "  • $recommendation"
        done
    else
        echo -e "${RED}验证报告文件不存在${NC}"
    fi
}

# 启动验证
start_validation() {
    log_validation "INFO" "启动需求验证流程"

    # 验证前置条件
    if ! validate_prerequisites; then
        log_validation "ERROR" "前置条件验证失败，终止验证流程"
        return 1
    fi

    # 执行各项验证
    validate_requirement_alignment
    validate_execution_contract
    validate_deliverables

    # 执行最终评估
    perform_final_assessment

    log_validation "SUCCESS" "需求验证流程完成"
}

# 显示帮助信息
show_help() {
    cat << EOF
Claude Code 需求验证器 v1.0

用法: $0 [选项]

选项:
    --start                    启动需求验证流程
    --report                   显示验证报告
    --requirement-only         仅验证需求对齐质量
    --contract-only            仅验证执行契约合规性
    --deliverable-only         仅验证交付物完整性
    --help                     显示此帮助信息

示例:
    $0 --start                 # 启动完整验证流程
    $0 --report                # 显示验证报告
    $0 --requirement-only      # 仅验证需求对齐

验证结果说明:
    - excellent (80-100分): 验证通过，质量优秀
    - good (60-79分): 验证通过，质量良好
    - acceptable (40-59分): 基本通过，需要改进
    - needs_improvement (0-39分): 验证失败，需要重新执行

EOF
}

# 主函数
main() {
    # 检查依赖
    if ! check_dependencies; then
        log_validation "ERROR" "依赖检查失败，请安装必要的工具"
        exit 1
    fi

    # 初始化验证器
    init_validator

    case "${1:-}" in
        "--start")
            start_validation
            show_validation_report
            ;;
        "--report")
            show_validation_report
            ;;
        "--requirement-only")
            validate_requirement_alignment
            ;;
        "--contract-only")
            validate_execution_contract
            ;;
        "--deliverable-only")
            validate_deliverables
            ;;
        "--help"|"")
            show_help
            ;;
        *)
            log_validation "ERROR" "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi