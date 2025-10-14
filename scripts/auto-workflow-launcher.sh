#!/bin/bash
# Claude Code 全自动化工作流启动器
# 整合需求对齐、执行契约、自我导航、偏差检测和自动纠偏功能

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
    log_message "ERROR" "工作流启动器在第 $line_number 行异常退出，退出码: $exit_code"
    cleanup_on_error
    exit $exit_code
}

# 错误处理钩子
trap 'handle_error $? $LINENO' ERR

# 错误时清理函数
cleanup_on_error() {
    log_message "INFO" "执行错误清理操作"
    cleanup_temp_files
}

# 工作流状态文件
WORKFLOW_STATUS_FILE="$PROJECT_ROOT/WORKFLOW_STATUS.json"
REQUIREMENT_ALIGNMENT_FILE="$PROJECT_ROOT/REQUIREMENT_ALIGNMENT.json"
EXECUTION_CONTRACT_FILE="$PROJECT_ROOT/EXECUTION_CONTRACT.json"

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
log_workflow() {
    local level="$1"
    local message="$2"
    local log_file="$PROJECT_ROOT/workflow.log"

    case "$level" in
        "INFO")
            echo -e "${GREEN}[WORKFLOW]${NC} $(get_timestamp) - $message" | tee -a "$log_file"
            ;;
        "WARN")
            echo -e "${YELLOW}[WORKFLOW]${NC} $(get_timestamp) - $message" | tee -a "$log_file"
            ;;
        "ERROR")
            echo -e "${RED}[WORKFLOW]${NC} $(get_timestamp) - $message" | tee -a "$log_file"
            ;;
        "SUCCESS")
            echo -e "${CYAN}[WORKFLOW]${NC} $(get_timestamp) - $message" | tee -a "$log_file"
            ;;
        "ALIGNMENT")
            echo -e "${MAGENTA}[ALIGNMENT]${NC} $(get_timestamp) - $message" | tee -a "$log_file"
            ;;
        "CONTRACT")
            echo -e "${BLUE}[CONTRACT]${NC} $(get_timestamp) - $message" | tee -a "$log_file"
            ;;
    esac
}

# 初始化工作流环境
init_workflow() {
    log_workflow "INFO" "初始化全自动化工作流环境"

    # 创建必要目录
    ensure_directories

    # 初始化工作流状态
    cat > "$WORKFLOW_STATUS_FILE" << EOF
{
  "workflow_info": {
    "session_id": "WF_$(generate_id)",
    "start_time": "$(get_iso_timestamp)",
    "status": "INITIALIZING",
    "current_phase": "setup"
  },
  "phases": {
    "requirement_alignment": {
      "status": "pending",
      "start_time": null,
      "end_time": null,
      "result_file": "$REQUIREMENT_ALIGNMENT_FILE"
    },
    "execution_contract": {
      "status": "pending",
      "start_time": null,
      "end_time": null,
      "result_file": "$EXECUTION_CONTRACT_FILE"
    },
    "auto_execution": {
      "status": "pending",
      "start_time": null,
      "end_time": null
    },
    "navigation_monitoring": {
      "status": "pending",
      "start_time": null,
      "end_time": null
    }
  },
  "navigation": {
    "current_position": "start",
    "target_position": "completion",
    "deviation_detected": false,
    "correction_count": 0
  },
  "quality": {
    "current_score": 0,
    "target_score": 10,
    "validation_checks": []
  }
}
EOF

    log_workflow "SUCCESS" "工作流环境初始化完成"
}

# 更新工作流状态
update_workflow_status() {
    local phase="$1"
    local status="$2"
    local message="${3:-}"

    if [[ -f "$WORKFLOW_STATUS_FILE" ]]; then
        jq --arg phase "$phase" --arg status "$status" --arg message "$message" --arg timestamp "$(get_iso_timestamp)" '
            .phases[$phase].status = $status |
            if $message != "" then
                .phases[$phase].last_message = $message |
                .phases[$phase].last_update = $timestamp
            else
                .
            end |
            if $status == "in_progress" then
                .phases[$phase].start_time = $timestamp
            elif $status == "completed" then
                .phases[$phase].end_time = $timestamp
            end |
            .workflow_info.current_phase = $phase |
            .workflow_info.last_update = $timestamp
        ' "$WORKFLOW_STATUS_FILE" > temp_status.json && mv temp_status.json "$WORKFLOW_STATUS_FILE"
    fi
}

# 启动需求对齐阶段
start_requirement_alignment() {
    log_workflow "ALIGNMENT" "开始需求对齐阶段"
    update_workflow_status "requirement_alignment" "in_progress" "启动需求对齐对话"

    # 生成需求对齐启动命令
    local alignment_command="claude \"我需要为这个项目进行全自动化执行。首先，我需要与你进行需求对齐，以确保执行结果完全符合你的期望。

请按照以下模板与我对话：

## 🔍 核心目标确认
- 你最终想要得到什么具体成果？
- 这个成果将如何被使用？谁会使用它？
- 怎样算'任务完成得很好'？

## 📋 交付物清单
- 需要生成哪些具体文件或内容？
- 每个交付物的基本要求是什么？
- 有什么必须包含或绝对不能包含的内容？

## 🎯 质量标准要求
- 技术准确性：最高专业标准 / 实用够用 / 快速原型？
- 完整性：面面俱到 / 核心完整 / 最小可行？
- 可用性：生产就绪 / 学习参考 / 概念验证？

## ⚠️ 特殊要求
- 有什么技术栈、格式或风格的特殊要求？
- 有什么特别要避免的问题或坑？
- 有什么必须遵循的最佳实践？

请详细告诉我这些信息，我会基于你的回答进行深度需求挖掘和CC自检确认。\""

    log_workflow "INFO" "需求对齐命令已准备，请在新终端执行"
    echo -e "${CYAN}=== 需求对齐阶段 ===${NC}"
    echo -e "${YELLOW}请在新的终端中执行以下命令：${NC}"
    echo ""
    echo -e "${GREEN}$alignment_command${NC}"
    echo ""
    echo -e "${CYAN}需求对齐完成后，请执行：${NC}"
    echo -e "${GREEN}$0 --complete-alignment${NC}"
}

# 完成需求对齐
complete_requirement_alignment() {
    log_workflow "ALIGNMENT" "完成需求对齐阶段"
    update_workflow_status "requirement_alignment" "completed" "需求对齐已完成"

    # 检查需求对齐文件是否存在
    if [[ ! -f "$REQUIREMENT_ALIGNMENT_FILE" ]]; then
        log_workflow "ERROR" "需求对齐文件不存在，请确保对齐完成"
        return 1
    fi

    log_workflow "SUCCESS" "需求对齐完成，准备生成执行契约"
    return 0
}

# 生成执行契约
generate_execution_contract() {
    log_workflow "CONTRACT" "开始生成执行契约"
    update_workflow_status "execution_contract" "in_progress" "基于需求对齐生成执行契约"

    # 生成契约生成命令
    local contract_command="claude \"基于我们的需求对齐结果，我现在需要生成执行契约。

请按照以下模板生成执行契约：

## 🔧 执行契约生成

### 契约基础
- 需求对齐ID: $(jq -r '.requirement_alignment.session_id' "$REQUIREMENT_ALIGNMENT_FILE")
- 核心目标: $(jq -r '.user_objective.primary_goal' "$REQUIREMENT_ALIGNMENT_FILE")

### 执行承诺
- 主要目标承诺: [明确承诺的主要目标]
- 交付物承诺: [基于需求对齐的交付物承诺]
- 质量标准承诺: [明确的质量承诺标准]

### 导航协议
- 执行方向: [基于需求的导航策略]
- 检查点设置: [关键检查和控制点]
- 偏差控制: [偏差容忍和自动纠偏机制]

### 质量保证
- 质量标准: [基于需求的质量标准]
- 验证协议: [自动验证机制]
- 成功指标: [可量化的成功指标]

### 自我约束
- 执行范围: [明确的执行范围和边界]
- 决策权限: [自主决策的范围和限制]
- 质量承诺: [具体的质量承诺和保证]

请生成详细的执行契约JSON文件，并承诺严格按照契约执行。\""

    log_workflow "INFO" "执行契约生成命令已准备"
    echo -e "${CYAN}=== 执行契约生成阶段 ===${NC}"
    echo -e "${YELLOW}请在新的终端中执行以下命令：${NC}"
    echo ""
    echo -e "${GREEN}$contract_command${NC}"
    echo ""
    echo -e "${CYAN}契约生成完成后，请执行：${NC}"
    echo -e "${GREEN}$0 --complete-contract${NC}"
}

# 完成执行契约
complete_execution_contract() {
    log_workflow "CONTRACT" "完成执行契约生成"
    update_workflow_status "execution_contract" "completed" "执行契约已生成"

    # 检查执行契约文件是否存在
    if [[ ! -f "$EXECUTION_CONTRACT_FILE" ]]; then
        log_workflow "ERROR" "执行契约文件不存在，请确保契约生成完成"
        return 1
    fi

    log_workflow "SUCCESS" "执行契约完成，准备启动全自动化执行"
    return 0
}

# 启动全自动化执行
start_auto_execution() {
    log_workflow "INFO" "启动全自动化执行"
    update_workflow_status "auto_execution" "in_progress" "启动自我导航执行"

    # 生成自动执行命令
    local execution_command="claude \"执行契约已生效，我现在开始全自动化执行：

## 🚀 全自动化执行启动

### 契约基础
- 执行契约: $(jq -r '.contract_basis.requirement_alignment_id' "$EXECUTION_CONTRACT_FILE")
- 生效时间: $(get_iso_timestamp)

### 执行承诺
- 主要目标: $(jq -r '.execution_commitments.primary_objective' "$EXECUTION_CONTRACT_FILE")
- 交付物: $(jq -r '.execution_commitments.deliverable_commitments | length' "$EXECUTION_CONTRACT_FILE")个

### 执行导航
我将严格按照执行契约进行：
1. **自我导航执行** - 基于导航协议执行任务
2. **实时偏差检测** - 持续监控执行与契约的一致性
3. **自动纠偏调整** - 发现偏离时自动调整策略
4. **质量自动验证** - 基于质量标准持续验证

### 执行监控
- 导航引擎将实时监控执行路径
- 偏差检测器将自动识别偏离
- 需求验证器将持续验证需求匹配度

我现在开始严格按照执行契约执行，确保最终结果完全符合需求对齐要求。\""

    log_workflow "INFO" "全自动化执行命令已生成"
    echo -e "${CYAN}=== 全自动化执行阶段 ===${NC}"
    echo -e "${YELLOW}请在新的终端中执行以下命令：${NC}"
    echo ""
    echo -e "${GREEN}$execution_command${NC}"
    echo ""
    echo -e "${CYAN}同时启动导航监控系统：${NC}"
    echo -e "${GREEN}$SCRIPT_DIR/navigation-engine.sh --start${NC}"

    # 启动导航监控
    if [[ -f "$SCRIPT_DIR/navigation-engine.sh" ]]; then
        "$SCRIPT_DIR/navigation-engine.sh" --start &
        log_workflow "INFO" "导航监控已启动"
    fi

    # 启动偏差检测
    if [[ -f "$SCRIPT_DIR/deviation-detector.sh" ]]; then
        "$SCRIPT_DIR/deviation-detector.sh" --monitor &
        log_workflow "INFO" "偏差检测已启动"
    fi

    update_workflow_status "auto_execution" "running" "全自动化执行已启动"
}

# 显示工作流状态
show_workflow_status() {
    echo -e "${WHITE}=== Claude Code 全自动化工作流状态 ===${NC}"
    echo ""

    if [[ -f "$WORKFLOW_STATUS_FILE" ]]; then
        echo -e "${CYAN}工作流信息:${NC}"
        jq -r '.workflow_info | to_entries[] | "  \(.key): \(.value)"' "$WORKFLOW_STATUS_FILE"
        echo ""

        echo -e "${CYAN}阶段状态:${NC}"
        jq -r '.phases | to_entries[] | "  \(.key): \(.value.status) (\(.value.start_time // "未开始") - \(.value.end_time // "进行中"))"' "$WORKFLOW_STATUS_FILE"
        echo ""

        echo -e "${CYAN}导航状态:${NC}"
        jq -r '.navigation | to_entries[] | "  \(.key): \(.value)"' "$WORKFLOW_STATUS_FILE"
        echo ""

        echo -e "${CYAN}质量状态:${NC}"
        jq -r '.quality | to_entries[] | "  \(.key): \(.value)"' "$WORKFLOW_STATUS_FILE"
    else
        echo -e "${RED}工作流状态文件不存在${NC}"
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
Claude Code 全自动化工作流启动器 v2.0

用法: $0 [选项]

选项:
    --start                    启动全自动化工作流
    --complete-alignment       完成需求对齐阶段
    --complete-contract        完成执行契约生成
    --status                   显示工作流状态
    --dashboard                显示工作流仪表板
    --help                     显示此帮助信息

执行流程:
    1. $0 --start               # 启动工作流
    2. 执行需求对齐命令
    3. $0 --complete-alignment  # 标记对齐完成
    4. 执行契约生成命令
    5. $0 --complete-contract   # 标记契约完成
    6. 自动开始全自动化执行

监控命令:
    ./navigation-engine.sh --status     # 查看导航状态
    ./deviation-detector.sh --check      # 检查偏差状态
    ./requirement-validator.sh --validate # 验证需求匹配度

EOF
}

# 显示工作流仪表板
show_dashboard() {
    echo -e "${WHITE}=== Claude Code 全自动化工作流仪表板 ===${NC}"
    echo -e "${WHITE}更新时间: $(get_timestamp)${NC}"
    echo ""

    if [[ -f "$WORKFLOW_STATUS_FILE" ]]; then
        local status=$(jq -r '.workflow_info.status' "$WORKFLOW_STATUS_FILE")
        local current_phase=$(jq -r '.workflow_info.current_phase' "$WORKFLOW_STATUS_FILE")

        # 阶段状态
        echo -e "${CYAN}📊 当前阶段:${NC}"
        echo -e "  状态: $status"
        echo -e "  当前阶段: $current_phase"
        echo ""

        # 各阶段进度
        echo -e "${CYAN}📈 阶段进度:${NC}"
        jq -r '.phases | to_entries[] | "  \(.key): \(.value.status)"' "$WORKFLOW_STATUS_FILE" | while read line; do
            local phase_status=$(echo "$line" | awk '{print $2}')
            local phase_name=$(echo "$line" | awk '{print $1}')

            case "$phase_status" in
                "completed")
                    echo -e "  ${GREEN}$phase_name${NC}: ✅ 完成"
                    ;;
                "in_progress"|"running")
                    echo -e "  ${YELLOW}$phase_name${NC}: 🔄 进行中"
                    ;;
                "pending")
                    echo -e "  ${WHITE}$phase_name${NC}: ⏳ 待开始"
                    ;;
                *)
                    echo -e "  ${RED}$phase_name${NC}: ❌ $phase_status"
                    ;;
            esac
        done
        echo ""

        # 导航状态
        echo -e "${CYAN}🧭 导航状态:${NC}"
        local nav_position=$(jq -r '.navigation.current_position' "$WORKFLOW_STATUS_FILE")
        local deviation=$(jq -r '.navigation.deviation_detected' "$WORKFLOW_STATUS_FILE")
        local corrections=$(jq -r '.navigation.correction_count' "$WORKFLOW_STATUS_FILE")

        echo -e "  当前位置: $nav_position"
        echo -e "  偏差检测: $([ "$deviation" = true ] && echo "${RED}检测到偏离${NC}" || echo "${GREEN}正常${NC}")"
        echo -e "  纠偏次数: $corrections"
        echo ""

        # 质量状态
        echo -e "${CYAN}✅ 质量状态:${NC}"
        local current_score=$(jq -r '.quality.current_score' "$WORKFLOW_STATUS_FILE")
        local target_score=$(jq -r '.quality.target_score' "$WORKFLOW_STATUS_FILE")

        if [[ "$current_score" != "null" && "$target_score" != "null" ]]; then
            local percentage=$((current_score * 100 / target_score))
            echo -e "  当前评分: $current_score/$target_score ($percentage%)"
        else
            echo -e "  评分: 尚未开始"
        fi
    else
        echo -e "${RED}工作流未启动${NC}"
    fi

    echo ""
    echo -e "${BLUE}快捷命令:${NC}"
    echo "  $0 --status        # 查看详细状态"
    echo "  ./navigation-engine.sh --dashboard    # 导航仪表板"
    echo "  ./deviation-detector.sh --report       # 偏差报告"
}

# 主函数
main() {
    # 检查依赖
    if ! check_dependencies; then
        log_workflow "ERROR" "依赖检查失败，请安装必要的工具"
        exit 1
    fi

    # 初始化工作流
    init_workflow

    case "${1:-}" in
        "--start")
            log_workflow "INFO" "启动Claude Code全自动化工作流"
            start_requirement_alignment
            ;;
        "--complete-alignment")
            complete_requirement_alignment
            if [[ $? -eq 0 ]]; then
                generate_execution_contract
            fi
            ;;
        "--complete-contract")
            complete_execution_contract
            if [[ $? -eq 0 ]]; then
                start_auto_execution
            fi
            ;;
        "--status")
            show_workflow_status
            ;;
        "--dashboard")
            show_dashboard
            ;;
        "--help"|"")
            show_help
            ;;
        *)
            log_workflow "ERROR" "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi