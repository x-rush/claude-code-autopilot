#!/bin/bash

# Claude Code AutoPilot 零依赖安装脚本
# 仅依赖基本shell命令，符合纯插件设计理念

set -e

# 版本信息
VERSION="1.0.0"

# 颜色定义（可选，如果不支持则自动禁用）
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

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
    echo "Claude Code AutoPilot 零依赖安装脚本 v$VERSION"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -u, --uninstall     卸载AutoPilot插件"
    echo "  -v, --version       显示版本信息"
    echo ""
    echo "特点:"
    echo "  - 零外部依赖，仅依赖基本shell命令"
    echo "  - 纯插件设计，完全基于Claude Code能力"
    echo "  - 支持项目级安装，无需全局配置"
    echo ""
    echo "安装后使用:"
    echo "  1. 启动Claude Code: claude --dangerously-skip-permissions"
    echo "  2. 开始使用: /autopilot-continuous-start"
}

# 显示版本信息
show_version() {
    echo "Claude Code AutoPilot 零依赖安装脚本 v$VERSION"
}

# 获取插件源目录
get_plugin_source_dir() {
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

    if [ -f "$script_dir/.claude-plugin/plugin.json" ]; then
        echo "$script_dir"
    else
        error "未找到插件源文件，请在 claude-code-autopilot 项目根目录下运行此脚本"
    fi
}

# 检查目录是否存在
check_directory() {
    local dir="$1"
    local description="$2"

    if [ ! -d "$dir" ]; then
        error "未找到$description目录: $dir"
    fi
}

# 检查文件是否存在
check_file() {
    local file="$1"
    local description="$2"

    if [ ! -f "$file" ]; then
        error "未找到$description文件: $file"
    fi
}

# 验证插件源文件完整性
validate_plugin_source() {
    local plugin_source_dir="$1"

    log "验证插件源文件完整性..."

    # 检查必需的目录
    check_directory "$plugin_source_dir/.claude-plugin" "插件清单"
    check_directory "$plugin_source_dir/commands" "命令文件"
    check_directory "$plugin_source_dir/templates" "模板文件"

    # 检查必需的文件
    check_file "$plugin_source_dir/.claude-plugin/plugin.json" "插件配置"
    check_file "$plugin_source_dir/commands/autopilot-continuous-start.md" "主命令"

    # 验证命令文件数量
    local command_count=$(find "$plugin_source_dir/commands" -name "*.md" | wc -l)
    if [ "$command_count" -lt 5 ]; then
        error "命令文件数量不足，发现: $command_count"
    fi

    # 验证模板文件数量
    local template_count=$(find "$plugin_source_dir/templates" -name "*.json" | wc -l)
    if [ "$template_count" -lt 5 ]; then
        error "模板文件数量不足，发现: $template_count"
    fi

    log "✅ 插件源文件验证通过"
}

# 在当前项目中安装插件
install_to_project() {
    local plugin_source_dir
    plugin_source_dir=$(get_plugin_source_dir)

    local current_dir
    current_dir=$(pwd)

    # 验证插件源文件
    validate_plugin_source "$plugin_source_dir"

    log "插件源目录: $plugin_source_dir"
    log "目标项目目录: $current_dir"

    # 创建项目插件目录
    local plugin_dir=".claude/plugins/claude-code-autopilot"
    mkdir -p "$plugin_dir"

    log "复制插件文件到项目..."

    # 复制核心插件文件
    cp -r "$plugin_source_dir/.claude-plugin" "$plugin_dir/" || error "复制 .claude-plugin 失败"
    log "✅ 复制 .claude-plugin"

    cp -r "$plugin_source_dir/commands" "$plugin_dir/" || error "复制 commands 失败"
    log "✅ 复制 commands"

    cp -r "$plugin_source_dir/templates" "$plugin_dir/" || error "复制 templates 失败"
    log "✅ 复制 templates"

    # 复制文档文件（可选）
    if [ -d "$plugin_source_dir/docs" ]; then
        cp -r "$plugin_source_dir/docs" "$plugin_dir/" || warn "复制 docs 失败（可选）"
        log "✅ 复制 docs"
    fi

    # 复制README和LICENSE
    if [ -f "$plugin_source_dir/README.md" ]; then
        cp "$plugin_source_dir/README.md" "$plugin_dir/" || warn "复制 README.md 失败（可选）"
    fi

    if [ -f "$plugin_source_dir/LICENSE" ]; then
        cp "$plugin_source_dir/LICENSE" "$plugin_dir/" || warn "复制 LICENSE 失败（可选）"
    fi

    # 创建简化版的安装脚本用于项目管理
    cat > "$plugin_dir/manage.sh" << 'EOF'
#!/bin/bash
# AutoPilot 插件管理脚本（零依赖版本）

case "$1" in
    "uninstall")
        echo "删除 AutoPilot 插件..."
        rm -rf "$(dirname "$0")"
        echo "✅ 插件已删除"
        ;;
    "status")
        if [ -f "$(dirname "$0")/.claude-plugin/plugin.json" ]; then
            echo "✅ AutoPilot 插件已安装"
        else
            echo "❌ AutoPilot 插件未完整安装"
        fi
        ;;
    *)
        echo "用法: $0 {uninstall|status}"
        echo "  uninstall - 删除插件"
        echo "  status     - 检查安装状态"
        ;;
esac
EOF
    chmod +x "$plugin_dir/manage.sh"

    log "🎉 AutoPilot 插件安装完成！"
    echo ""
    echo "安装位置: $current_dir/$plugin_dir"
    echo ""
    echo "现在可以使用AutoPilot插件："
    echo "  1. 启动Claude Code: claude --dangerously-skip-permissions"
    echo "  2. 开始使用: /autopilot-continuous-start"
    echo ""
    echo "管理插件："
    echo "  - 查看状态: $plugin_dir/manage.sh status"
    echo "  - 卸载插件: $plugin_dir/manage.sh uninstall"
    echo ""
    echo "🎯 零依赖设计特点："
    echo "  - 仅依赖Claude Code和基本shell命令"
    echo "  - 无需jq、curl等外部工具"
    echo "  - 纯插件实现，自主执行和状态管理"
}

# 显示安装状态
show_status() {
    local current_dir
    current_dir=$(pwd)
    local plugin_dir=".claude/plugins/claude-code-autopilot"

    echo "Claude Code AutoPilot 安装状态"
    echo "============================"
    echo ""

    if [ -d "$plugin_dir" ]; then
        echo "✅ AutoPilot 已安装在当前项目"
        echo "   位置: $current_dir/$plugin_dir"
        echo ""

        # 检查核心文件
        local required_files=(
            ".claude-plugin/plugin.json"
            "commands/autopilot-continuous-start.md"
            "templates/REQUIREMENT_ALIGNMENT.json"
        )

        local all_files_exist=true
        for file in "${required_files[@]}"; do
            if [ -f "$plugin_dir/$file" ]; then
                echo "   ✅ $file"
            else
                echo "   ❌ $file"
                all_files_exist=false
            fi
        done

        if [ "$all_files_exist" = true ]; then
            echo ""
            echo "🎉 插件完整性: ✅ 良好"
            echo ""
            echo "建议下一步:"
            echo "  1. 启动Claude Code: claude --dangerously-skip-permissions"
            echo "  2. 开始使用: /autopilot-continuous-start"
        else
            echo ""
            echo "⚠️  插件完整性: ❌ 有问题"
            echo "建议重新安装: bash $(dirname "$0")/install.sh"
        fi

    else
        echo "❌ AutoPilot 未在当前项目中安装"
        echo ""
        echo "安装方法："
        echo "  bash /path/to/claude-code-autopilot/install.sh"
    fi

    echo ""
    echo "系统兼容性:"
    echo "  - Shell环境: ✅ 支持 (使用基本命令)"
    echo "  - 外部依赖: ✅ 无需 (零依赖设计)"
    echo "  - Claude Code: 需要安装"
}

# 卸载插件
uninstall_from_project() {
    local plugin_dir=".claude/plugins/claude-code-autopilot"

    if [ ! -d "$plugin_dir" ]; then
        warn "AutoPilot 未在当前项目中安装"
        return 0
    fi

    warn "准备从当前项目卸载 AutoPilot..."
    echo ""

    read -p "确认要卸载吗？这将删除项目中的插件文件 (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消卸载"
        exit 0
    fi

    # 删除插件目录
    rm -rf "$plugin_dir"
    log "✅ 已删除插件目录: $plugin_dir"

    # 如果 .claude/plugins 目录为空，也删除它
    if [ -d ".claude/plugins" ] && [ -z "$(ls -A .claude/plugins 2>/dev/null)" ]; then
        rmdir ".claude/plugins" 2>/dev/null || true
        log "✅ 已清理空的插件目录"
    fi

    # 如果 .claude 目录为空，也删除它
    if [ -d ".claude" ] && [ -z "$(ls -A .claude 2>/dev/null)" ]; then
        rmdir ".claude" 2>/dev/null || true
        log "✅ 已清理空的.claude目录"
    fi

    log "🎉 卸载完成！"
}

# 主函数
main() {
    local action="install"

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
        "install")
            log "开始安装 Claude Code AutoPilot 到当前项目..."
            install_to_project
            ;;
        "status")
            show_status
            ;;
        "uninstall")
            uninstall_from_project
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi