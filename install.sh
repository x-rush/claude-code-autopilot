#!/bin/bash
# Claude Code AutoPilot Plugin 本地安装脚本

set -euo pipefail

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# 检查依赖
check_dependencies() {
    log "检查系统依赖..."

    local missing_deps=()

    for tool in jq awk curl date stat realpath; do
        if ! which "$tool" &>/dev/null; then
            missing_deps+=("$tool")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "缺少以下依赖工具: ${missing_deps[*]}"
        echo "请安装缺少的工具后重试"
        echo ""
        echo "Ubuntu/Debian安装命令:"
        echo "  sudo apt-get install jq coreutils curl"
        echo ""
        echo "macOS安装命令:"
        echo "  brew install jq coreutils curl"
        exit 1
    fi

    # 检查Claude Code CLI
    if ! which claude &>/dev/null; then
        error "未找到Claude Code CLI"
        echo "请参考官方文档安装: https://docs.claude.com/claude-code"
        exit 1
    fi

    log "所有依赖检查通过"
}

# 创建marketplace配置
create_marketplace() {
    log "创建本地marketplace配置..."

    local marketplace_dir="../autopilot-marketplace"

    # 创建marketplace目录
    mkdir -p "$marketplace_dir"

    # 创建marketplace配置文件
    cat > "$marketplace_dir/marketplace.json" << 'EOF'
{
  "name": "autopilot-marketplace",
  "owner": {
    "name": "AutoPilot Team"
  },
  "plugins": [
    {
      "name": "claude-code-autopilot",
      "source": "../claude-code-autopilot",
      "description": "Claude Code AutoPilot - 无人值守项目执行系统"
    }
  ]
}
EOF

    log "marketplace配置创建完成: $marketplace_dir"
}

# 验证插件结构
validate_plugin() {
    log "验证插件结构..."

    local required_files=(
        ".claude-plugin/plugin.json"
        "commands/autopilot-continuous-start.md"
        "commands/autopilot-status.md"
        "commands/autopilot-context-refresh.md"
        "commands/autopilot-recovery.md"
        "templates/REQUIREMENT_ALIGNMENT.json"
        "templates/EXECUTION_PLAN.json"
        "templates/TODO_TRACKER.json"
        "templates/DECISION_LOG.json"
        "templates/EXECUTION_STATE.json"
    )

    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            error "缺少必需文件: $file"
            exit 1
        fi
    done

    # 验证JSON文件格式
    for json_file in templates/*.json .claude-plugin/plugin.json; do
        if ! jq empty "$json_file" 2>/dev/null; then
            error "JSON文件格式错误: $json_file"
            exit 1
        fi
    done

    log "插件结构验证通过"
}

# 显示安装说明
show_instructions() {
    log "安装准备完成！"
    echo ""
    echo "📋 接下来的安装步骤："
    echo ""
    echo "1. 启动Claude Code (使用权限跳过模式):"
    echo "   ${YELLOW}claude --dangerously-skip-permissions${NC}"
    echo ""
    echo "2. 在Claude Code中执行以下命令:"
    echo "   ${YELLOW}/plugin marketplace add ../autopilot-marketplace${NC}"
    echo "   ${YELLOW}/plugin install claude-code-autopilot@autopilot-marketplace${NC}"
    echo ""
    echo "3. 开始使用AutoPilot:"
    echo "   ${YELLOW}/autopilot-continuous-start${NC}"
    echo ""
    echo "📚 更多信息请查看 README.md"
    echo ""
    echo "🔗 Claude Code 官方文档: https://docs.claude.com/claude-code"
}

# 主函数
main() {
    echo "🚀 Claude Code AutoPilot Plugin 安装脚本"
    echo "============================================"
    echo ""

    # 检查当前目录
    if [ ! -f ".claude-plugin/plugin.json" ]; then
        error "请在插件根目录下运行此脚本"
        exit 1
    fi

    # 执行安装步骤
    check_dependencies
    validate_plugin
    create_marketplace
    show_instructions

    log "安装准备完成！"
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi