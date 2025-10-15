#!/bin/bash
# Claude Code 安全边界控制器
# 确保Claude只在项目目录内执行安全操作

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 加载通用配置
source "$SCRIPT_DIR/common-config.sh"

# 启用严格模式
set -euo pipefail

# =============================================================================
# 安全边界配置
# =============================================================================

# 项目根目录（唯一允许操作的目录）
readonly ALLOWED_ROOT="$PROJECT_ROOT"

# 危险操作模式匹配
readonly DANGEROUS_PATTERNS=(
    "rm -rf"
    "rm -r"
    "rm -f"
    "pkill"
    "killall"
    "shutdown"
    "reboot"
    "systemctl"
    "service"
    "chmod 777"
    "chown root"
    "sudo"
    "su"
    "dd if="
    "mkfs"
    "fdisk"
    "iptables"
    "crontab"
    "passwd"
    "useradd"
    "userdel"
    "groupadd"
    "mount"
    "umount"
    "swapoff"
    "sysctl"
)

# 允许的文件扩展名
readonly ALLOWED_EXTENSIONS=(
    "md"
    "txt"
    "json"
    "js"
    "ts"
    "py"
    "sh"
    "yml"
    "yaml"
    "html"
    "css"
    "xml"
    "csv"
    "log"
    "config"
    "conf"
)

# 允许的目录名
readonly ALLOWED_DIRECTORIES=(
    "scripts"
    "template-docs"
    "logs"
    "backups"
    "recovery-points"
    "state-backups"
    "error-reports"
    "quality-reports"
    "src"
    "docs"
    "tests"
    "config"
    "data"
)

# =============================================================================
# 安全检查函数
# =============================================================================

# 检查路径是否在项目根目录内
is_path_safe() {
    local path="$1"

    # 转换为绝对路径
    local absolute_path
    if [[ "$path" == /* ]]; then
        absolute_path="$path"
    else
        absolute_path="$(pwd)/$path"
    fi

    # 规范化路径（处理 ../ 等）
    absolute_path="$(realpath -m "$absolute_path" 2>/dev/null || echo "$absolute_path")"

    # 检查是否在允许的根目录内
    if [[ "$absolute_path" == "$ALLOWED_ROOT"* ]]; then
        return 0
    else
        return 1
    fi
}

# 检查命令是否包含危险操作
is_command_safe() {
    local command="$1"

    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if [[ "$command" == *"$pattern"* ]]; then
            echo "❌ 危险操作检测: $pattern"
            return 1
        fi
    done

    return 0
}

# 检查文件扩展名是否允许
is_extension_allowed() {
    local filename="$1"

    # 获取文件扩展名
    local extension="${filename##*.}"

    # 如果没有扩展名，允许（可能是目录名）
    if [[ "$filename" == "$extension" ]]; then
        return 0
    fi

    # 检查是否在允许列表中
    for allowed in "${ALLOWED_EXTENSIONS[@]}"; do
        if [[ "$extension" == "$allowed" ]]; then
            return 0
        fi
    done

    echo "❌ 不允许的文件类型: .$extension"
    return 1
}

# 检查目录名是否允许
is_directory_allowed() {
    local dirname="$1"

    # 检查是否在允许列表中
    for allowed in "${ALLOWED_DIRECTORIES[@]}"; do
        if [[ "$dirname" == "$allowed" ]]; then
            return 0
        fi
    done

    # 如果是项目根目录下的现有目录，也允许
    if [[ -d "$ALLOWED_ROOT/$dirname" ]]; then
        return 0
    fi

    echo "❌ 不允许的目录: $dirname"
    return 1
}

# 综合安全检查
perform_safety_check() {
    local operation="$1"
    local target="$2"

    echo "🔒 执行安全检查..."
    echo "   操作: $operation"
    echo "   目标: $target"

    # 检查路径安全
    if ! is_path_safe "$target"; then
        echo "❌ 路径安全检查失败: 尝试访问项目目录外的文件"
        return 1
    fi

    # 检查命令安全
    if ! is_command_safe "$operation"; then
        echo "❌ 命令安全检查失败: 包含危险操作"
        return 1
    fi

    # 检查文件类型安全
    if [[ "$operation" == *"file"* ]] || [[ "$operation" == *"write"* ]]; then
        if ! is_extension_allowed "$target"; then
            echo "❌ 文件类型安全检查失败"
            return 1
        fi
    fi

    # 检查目录安全
    local dirname
    dirname="$(dirname "$target")"
    dirname="$(basename "$dirname")"
    if ! is_directory_allowed "$dirname"; then
        echo "❌ 目录安全检查失败"
        return 1
    fi

    echo "✅ 安全检查通过"
    return 0
}

# =============================================================================
# 安全包装函数
# =============================================================================

# 安全文件创建
safe_file_create() {
    local filepath="$1"
    local content="$2"

    if perform_safety_check "file_create" "$filepath"; then
        mkdir -p "$(dirname "$filepath")"
        echo "$content" > "$filepath"
        echo "✅ 文件创建成功: $filepath"
        return 0
    else
        echo "❌ 文件创建被安全策略阻止: $filepath"
        return 1
    fi
}

# 安全文件读取
safe_file_read() {
    local filepath="$1"

    if perform_safety_check "file_read" "$filepath"; then
        if [[ -f "$filepath" ]]; then
            cat "$filepath"
            return 0
        else
            echo "❌ 文件不存在: $filepath"
            return 1
        fi
    else
        echo "❌ 文件读取被安全策略阻止: $filepath"
        return 1
    fi
}

# 安全目录创建
safe_directory_create() {
    local dirpath="$1"

    if perform_safety_check "directory_create" "$dirpath"; then
        mkdir -p "$dirpath"
        echo "✅ 目录创建成功: $dirpath"
        return 0
    else
        echo "❌ 目录创建被安全策略阻止: $dirpath"
        return 1
    fi
}

# 安全命令执行
safe_command_execute() {
    local command="$1"

    # 提取命令中的文件路径进行检查
    local file_paths
    file_paths=$(echo "$command" | grep -oE '[^"]+\.(md|txt|json|js|ts|py|sh|yml|yaml)' || true)

    for filepath in $file_paths; do
        if ! perform_safety_check "command_execute" "$filepath"; then
            echo "❌ 命令执行被安全策略阻止"
            return 1
        fi
    done

    # 执行命令
    echo "✅ 执行命令: $command"
    eval "$command"
    return $?
}

# =============================================================================
# 安全监控和日志
# =============================================================================

# 记录安全事件
log_security_event() {
    local event_type="$1"
    local details="$2"
    local timestamp=$(get_iso_timestamp)

    # 写入安全日志
    {
        echo "[$timestamp] $event_type: $details"
        echo "  User: $(whoami)"
        echo "  PID: $$"
        echo "  PWD: $(pwd)"
        echo "---"
    } >> "$PROJECT_ROOT/SECURITY_LOG.md"

    # 如果是严重安全事件，也写入系统日志
    if [[ "$event_type" == "SECURITY_VIOLATION" ]]; then
        logger -t "claude-safety" "安全违规: $details"
    fi
}

# 安全边界初始化
init_safety_boundary() {
    echo "🔒 初始化Claude Code安全边界"
    echo "   允许的根目录: $ALLOWED_ROOT"
    echo "   危险操作模式数: ${#DANGEROUS_PATTERNS[@]}"
    echo "   允许的文件类型数: ${#ALLOWED_EXTENSIONS[@]}"
    echo "   允许的目录数: ${#ALLOWED_DIRECTORIES[@]}"

    # 创建安全日志
    {
        echo "# Claude Code 安全日志"
        echo "初始化时间: $(get_iso_timestamp)"
        echo "项目根目录: $ALLOWED_ROOT"
        echo ""
    } > "$PROJECT_ROOT/SECURITY_LOG.md"

    # 记录初始化事件
    log_security_event "SAFETY_BOUNDARY_INIT" "安全边界已初始化"

    echo "✅ 安全边界初始化完成"
}

# 显示安全状态
show_safety_status() {
    echo -e "${WHITE}=== Claude Code 安全边界状态 ===${NC}"
    echo ""

    echo -e "${CYAN}🔒 安全配置:${NC}"
    echo "  项目根目录: $ALLOWED_ROOT"
    echo "  危险操作保护: ${#DANGEROUS_PATTERNS[@]} 种模式"
    echo "  允许文件类型: ${#ALLOWED_EXTENSIONS[@]} 种"
    echo "  允许目录: ${#ALLOWED_DIRECTORIES[@]} 种"
    echo ""

    echo -e "${CYAN}📊 最近安全事件:${NC}"
    if [[ -f "$PROJECT_ROOT/SECURITY_LOG.md" ]]; then
        tail -10 "$PROJECT_ROOT/SECURITY_LOG.md" | grep -E "^\[.*\].*:" || echo "  无安全事件记录"
    else
        echo "  无安全日志文件"
    fi
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    case "${1:-}" in
        "--init")
            init_safety_boundary
            ;;
        "--check")
            if [[ -z "${2:-}" ]]; then
                echo "错误: 请提供要检查的操作和目标"
                echo "用法: $0 --check <operation> <target>"
                exit 1
            fi
            perform_safety_check "$2" "${3:-}"
            ;;
        "--status")
            show_safety_status
            ;;
        "--help"|"")
            cat << EOF
Claude Code 安全边界控制器 v1.0

用法: $0 [选项] [参数]

选项:
    --init                     初始化安全边界
    --check <operation> <target>  检查操作是否安全
    --status                   显示安全状态
    --help                     显示此帮助信息

安全功能:
    - 路径安全检查 (仅允许项目目录内)
    - 命令安全检查 (禁止危险操作)
    - 文件类型检查 (仅允许安全的文件类型)
    - 目录安全检查 (仅允许预设目录)
    - 安全事件记录和监控

示例:
    $0 --init                    # 初始化安全边界
    $0 --check file_read test.md  # 检查读取test.md是否安全
    $0 --status                  # 查看安全状态

EOF
            ;;
        *)
            echo "错误: 未知选项 $1"
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi