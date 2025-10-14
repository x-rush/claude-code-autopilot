#!/bin/bash
# Claude Code 工作流通用配置
# 统一管理所有脚本的配置参数和路径

# 启用严格模式
set -euo pipefail

# =============================================================================
# 脚本元信息
# =============================================================================
readonly SCRIPT_VERSION="1.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# =============================================================================
# 文件路径配置
# =============================================================================
# 状态文件
readonly STATUS_FILE="${PROJECT_ROOT}/EXECUTION_STATUS.json"
readonly ERROR_LOG_FILE="${PROJECT_ROOT}/ERROR_REPORT.md"
readonly EXECUTION_LOG_FILE="${PROJECT_ROOT}/EXECUTION_LOG.md"

# 监控相关文件
readonly MONITOR_LOG_FILE="${PROJECT_ROOT}/MONITOR_LOG.md"
readonly ALERT_HISTORY_FILE="${PROJECT_ROOT}/ALERT_HISTORY.md"
readonly DASHBOARD_FILE="${PROJECT_ROOT}/MONITOR_DASHBOARD.md"
readonly HEALTH_LOG_FILE="${PROJECT_ROOT}/HEALTH_CHECK_LOG.md"
readonly ALERT_LOG_FILE="${PROJECT_ROOT}/ALERT_LOG.md"

# 重试和恢复文件
readonly RETRY_LOG_FILE="${PROJECT_ROOT}/RETRY_LOG.md"
readonly RECOVERY_LOG_FILE="${PROJECT_ROOT}/RECOVERY_LOG.md"

# 备份和恢复目录
readonly BACKUP_DIR="${PROJECT_ROOT}/BACKUPS"
readonly RECOVERY_POINTS_DIR="${PROJECT_ROOT}/RECOVERY_POINTS"
readonly STATE_BACKUPS_DIR="${PROJECT_ROOT}/STATE_BACKUPS"
readonly ERROR_REPORTS_DIR="${PROJECT_ROOT}/ERROR_REPORTS"
readonly QUALITY_REPORTS_DIR="${PROJECT_ROOT}/QUALITY_REPORTS"

# 日志目录
readonly LOGS_DIR="${PROJECT_ROOT}/logs"

# =============================================================================
# 时间配置
# =============================================================================
readonly MONITOR_INTERVAL=60
readonly ALERT_COOLDOWN=300
readonly HEALTH_CHECK_INTERVAL=60
readonly TASK_TIMEOUT_THRESHOLD=1800
readonly LOG_ROTATION_SIZE=10485760  # 10MB
readonly MAX_LOG_FILES=5

# 重试配置
readonly MAX_TOTAL_RETRIES=10
readonly MAX_RETRY_PER_TASK=3
readonly RETRY_DELAY_BASE=30
readonly RETRY_DELAY_MAX=1800

# 阈值配置
readonly API_ERROR_THRESHOLD=5
readonly NETWORK_ERROR_THRESHOLD=3
readonly MAX_RECOVERY_POINTS=20
readonly MAX_BACKUPS=20

# =============================================================================
# 网络和系统检查配置
# =============================================================================
readonly PING_TARGET="google.com"
readonly API_CHECK_URL="https://api.openai.com"
readonly DISK_USAGE_WARNING_THRESHOLD=90
readonly MEMORY_USAGE_WARNING_THRESHOLD=90
readonly CPU_LOAD_WARNING_THRESHOLD=2.0

# =============================================================================
# 颜色输出配置
# =============================================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

# =============================================================================
# 通用函数
# =============================================================================

# 创建必要的目录
ensure_directories() {
    local dirs=(
        "$BACKUP_DIR"
        "$RECOVERY_POINTS_DIR"
        "$STATE_BACKUPS_DIR"
        "$ERROR_REPORTS_DIR"
        "$QUALITY_REPORTS_DIR"
        "$LOGS_DIR"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            echo "创建目录: $dir"
        fi
    done
}

# 检查必要的依赖
check_dependencies() {
    local mandatory_deps=("jq" "claude" "curl" "ping" "date" "stat")
    local optional_deps=("bc" "awk" "nproc")

    local missing_mandatory=()
    local missing_optional=()

    # 检查必需依赖
    for dep in "${mandatory_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_mandatory+=("$dep")
        fi
    done

    # 检查可选依赖
    for dep in "${optional_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_optional+=("$dep")
        fi
    done

    # 报告缺失的必需依赖
    if [[ ${#missing_mandatory[@]} -gt 0 ]]; then
        echo -e "${RED}错误: 缺少必需的依赖工具: ${missing_mandatory[*]}${NC}" >&2
        return 1
    fi

    # 报告缺失的可选依赖
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        echo -e "${YELLOW}警告: 缺少可选的依赖工具: ${missing_optional[*]}，某些功能可能受限${NC}"
    fi

    return 0
}

# 通用日志函数
log_message() {
    local level="$1"
    local message="$2"
    local log_file="${3:-}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local color=""
    local prefix=""

    case "$level" in
        "INFO")
            color="$GREEN"
            prefix="[INFO]"
            ;;
        "WARN")
            color="$YELLOW"
            prefix="[WARN]"
            ;;
        "ERROR")
            color="$RED"
            prefix="[ERROR]"
            ;;
        "SUCCESS")
            color="$GREEN"
            prefix="[SUCCESS]"
            ;;
        "DEBUG")
            color="$BLUE"
            prefix="[DEBUG]"
            ;;
        *)
            color="$NC"
            prefix="[LOG]"
            ;;
    esac

    # 输出到控制台
    echo -e "${color}${prefix}${NC} ${timestamp} - $message"

    # 如果指定了日志文件，也写入文件
    if [[ -n "$log_file" ]]; then
        echo "[$level] $timestamp - $message" >> "$log_file"
    fi
}

# 安全地获取JSON值
get_json_value() {
    local file="$1"
    local key="$2"
    local default="${3:-null}"

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return 1
    fi

    if ! jq -r "$key // \"$default\"" "$file" 2>/dev/null; then
        echo "$default"
        return 1
    fi
}

# 生成时间戳
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# 生成ISO时间戳
get_iso_timestamp() {
    date -Iseconds
}

# 生成唯一ID
generate_id() {
    local prefix="${1:-id}"
    echo "${prefix}_$(date +%Y%m%d_%H%M%S)_$$"
}

# 检查磁盘空间
check_disk_space() {
    local path="${1:-$PROJECT_ROOT}"
    local threshold="${2:-$DISK_USAGE_WARNING_THRESHOLD}"

    if [[ ! -d "$path" ]]; then
        echo "0"
        return 1
    fi

    local usage
    usage=$(df "$path" | awk 'NR==2 {print $5}' | sed 's/%//' || echo "0")
    echo "$usage"

    if [[ $usage -gt $threshold ]]; then
        return 1  # 磁盘空间不足
    fi
    return 0  # 磁盘空间充足
}

# 检查网络连接
check_network() {
    local ping_target="${1:-$PING_TARGET}"
    local api_url="${2:-$API_CHECK_URL}"

    local ping_ok=false
    local api_ok=false

    if ping -c 1 "$ping_target" &>/dev/null; then
        ping_ok=true
    fi

    if curl -s --max-time 5 -I "$api_url" &>/dev/null; then
        api_ok=true
    fi

    if [[ "$ping_ok" == true && "$api_ok" == true ]]; then
        return 0  # 网络正常
    else
        return 1  # 网络异常
    fi
}

# 清理临时文件
cleanup_temp_files() {
    local temp_patterns=("temp_*.json" "temp_*.md" "*.tmp")

    for pattern in "${temp_patterns[@]}"; do
        if compgen -G "$pattern" > /dev/null 2>&1; then
            rm -f $pattern
            echo "清理临时文件: $pattern"
        fi
    done
}

# 显示配置信息
show_config() {
    cat << EOF
Claude Code 工作流配置信息
========================

版本: $SCRIPT_VERSION
项目根目录: $PROJECT_ROOT
脚本目录: $SCRIPT_DIR

文件路径:
- 状态文件: $STATUS_FILE
- 错误日志: $ERROR_LOG_FILE
- 执行日志: $EXECUTION_LOG_FILE

监控配置:
- 监控间隔: ${MONITOR_INTERVAL}秒
- 告警冷却: ${ALERT_COOLDOWN}秒
- 任务超时: ${TASK_TIMEOUT_THRESHOLD}秒

重试配置:
- 最大重试次数: $MAX_TOTAL_RETRIES
- 单任务重试: $MAX_RETRY_PER_TASK
- 重试延迟: ${RETRY_DELAY_BASE}-${RETRY_DELAY_MAX}秒

系统阈值:
- 磁盘空间警告: ${DISK_USAGE_WARNING_THRESHOLD}%
- 内存使用警告: ${MEMORY_USAGE_WARNING_THRESHOLD}%
- CPU负载警告: ${CPU_LOAD_WARNING_THRESHOLD}

EOF
}

# 导出所有配置和函数
export -f ensure_directories
export -f check_dependencies
export -f log_message
export -f get_json_value
export -f get_timestamp
export -f get_iso_timestamp
export -f generate_id
export -f check_disk_space
export -f check_network
export -f cleanup_temp_files
export -f show_config

# 如果直接执行此脚本，显示配置信息
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_config
fi