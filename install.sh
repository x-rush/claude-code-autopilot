#!/bin/bash

# Claude Code AutoPilot 简化安装脚本
# 支持在任意项目中安装和使用AutoPilot插件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 版本信息
VERSION="1.0.0"

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
    echo "Claude Code AutoPilot 安装脚本 v$VERSION"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -u, --uninstall     卸载AutoPilot插件"
    echo "  -v, --version       显示版本信息"
    echo "  -s, --status        显示安装状态"
    echo ""
    echo "安装步骤："
    echo "  1. 在插件项目目录下运行: $0"
    echo "  2. 在任意项目目录下运行: $0"
    echo ""
    echo "说明："
    echo "  - 此脚本会将插件文件复制到当前项目的 .claude/plugins/ 目录"
    echo "  - 支持 Claude Code 自动发现和加载项目级插件"
    echo "  - 无需全局安装或配置"
}

# 显示版本信息
show_version() {
    echo "Claude Code AutoPilot 安装脚本 v$VERSION"
    echo "更新时间: 2025-10-17"
}

# 检查依赖
check_dependencies() {
    log "检查系统依赖..."

    local missing_deps=()

    # 检查基本工具
    for tool in jq curl date stat realpath; do
        if ! command -v "$tool" &> /dev/null; then
            missing_deps+=("$tool")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "缺少以下依赖工具: ${missing_deps[*]}"
        echo ""
        echo "Ubuntu/Debian 安装命令:"
        echo "  sudo apt-get install ${missing_deps[*]}"
        echo ""
        echo "macOS 安装命令:"
        echo "  brew install ${missing_deps[*]}"
        exit 1
    fi

    # 检查Claude Code CLI
    if ! command -v claude &> /dev/null; then
        warn "Claude Code CLI 未安装"
        echo "请参考官方文档安装: https://docs.claude.com/claude-code"
        echo ""
        read -p "是否继续安装？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log "✅ Claude Code CLI 已安装"
    fi

    log "✅ 所有依赖检查通过"
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

# 在当前项目中安装插件
install_to_project() {
    local plugin_source_dir
    plugin_source_dir=$(get_plugin_source_dir)

    local current_dir
    current_dir=$(pwd)

    log "插件源目录: $plugin_source_dir"
    log "目标项目目录: $current_dir"

    # 创建项目插件目录
    local plugin_dir=".claude/plugins/claude-code-autopilot"
    mkdir -p "$plugin_dir"

    log "复制插件文件到项目..."

    # 复制核心插件文件
    if [ -d "$plugin_source_dir/.claude-plugin" ]; then
        cp -r "$plugin_source_dir/.claude-plugin" "$plugin_dir/"
        log "✅ 复制 .claude-plugin"
    else
        error "未找到 .claude-plugin 目录"
    fi

    if [ -d "$plugin_source_dir/commands" ]; then
        cp -r "$plugin_source_dir/commands" "$plugin_dir/"
        log "✅ 复制 commands"
    else
        error "未找到 commands 目录"
    fi

    # 复制脚本文件
    if [ -d "$plugin_source_dir/scripts" ]; then
        cp -r "$plugin_source_dir/scripts" "$plugin_dir/"
        log "✅ 复制 scripts"
    fi

    # 复制模板文件
    if [ -d "$plugin_source_dir/templates" ]; then
        cp -r "$plugin_source_dir/templates" "$plugin_dir/"
        log "✅ 复制 templates"
    fi

    # 复制文档文件（可选）
    if [ -d "$plugin_source_dir/docs" ]; then
        cp -r "$plugin_source_dir/docs" "$plugin_dir/"
        log "✅ 复制 docs"
    fi

    # 复制安装脚本（用于后续管理）
    cp "$plugin_source_dir/install.sh" "$plugin_dir/"

    log "🎉 插件安装完成！"
    echo ""
    echo "安装位置: $current_dir/$plugin_dir"
    echo ""
    echo "现在可以使用AutoPilot插件："
    echo "  1. 启动Claude Code: claude --dangerously-skip-permissions"
    echo "  2. 开始使用: /autopilot-continuous-start"
    echo ""
    echo "管理插件："
    echo "  - 查看状态: $0 --status"
    echo "  - 卸载插件: $0 --uninstall"
    echo "  - 查看帮助: $0 --help"
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

        if [ -f "$plugin_dir/.claude-plugin/plugin.json" ]; then
            local plugin_name
            plugin_name=$(jq -r '.name' "$plugin_dir/.claude-plugin/plugin.json" 2>/dev/null || echo "未知")
            echo "   插件: $plugin_name"
        fi

        if [ -f "$plugin_dir/install.sh" ]; then
            echo "   管理脚本: ✅ 可用"
        else
            echo "   管理脚本: ❌ 缺失"
        fi
    else
        echo "❌ AutoPilot 未在当前项目中安装"
        echo ""
        echo "安装方法："
        echo "  在当前项目中运行: bash /path/to/claude-code-autopilot/install.sh"
        echo "  或者在插件源目录中运行: ./install.sh"
    fi

    echo ""
    echo "系统状态："

    # 检查Claude Code
    if command -v claude &> /dev/null; then
        echo "  Claude Code CLI: ✅ 已安装"
    else
        echo "  Claude Code CLI: ❌ 未安装"
    fi

    # 检查依赖工具
    local missing_tools=()
    for tool in jq curl date stat realpath; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -eq 0 ]; then
        echo "  系统依赖: ✅ 完整"
    else
        echo "  系统依赖: ❌ 缺少 ${missing_tools[*]}"
    fi
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
    if [ -d ".claude/plugins" ] && [ -z "$(ls -A .claude/plugins)" ]; then
        rmdir ".claude/plugins" 2>/dev/null || true
        log "✅ 已清理空的插件目录"
    fi

    # 如果 .claude 目录为空，也删除它
    if [ -d ".claude" ] && [ -z "$(ls -A .claude)" ]; then
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
            check_dependencies
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