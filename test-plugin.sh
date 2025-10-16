#!/bin/bash
# Claude Code AutoPilot Plugin 测试脚本

set -euo pipefail

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[TEST] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# 测试插件结构
test_plugin_structure() {
    log "测试插件结构..."

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

    local missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done

    if [ ${#missing_files[@]} -gt 0 ]; then
        error "缺少必需文件:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi

    log "插件结构检查通过"
    return 0
}

# 测试JSON文件格式
test_json_format() {
    log "测试JSON文件格式..."

    local json_files=(
        ".claude-plugin/plugin.json"
        "templates/REQUIREMENT_ALIGNMENT.json"
        "templates/EXECUTION_PLAN.json"
        "templates/TODO_TRACKER.json"
        "templates/DECISION_LOG.json"
        "templates/EXECUTION_STATE.json"
    )

    local invalid_files=()
    for file in "${json_files[@]}"; do
        if ! jq empty "$file" 2>/dev/null; then
            invalid_files+=("$file")
        fi
    done

    if [ ${#invalid_files[@]} -gt 0 ]; then
        error "JSON文件格式错误:"
        for file in "${invalid_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi

    log "JSON格式检查通过"
    return 0
}

# 测试命令文件完整性
test_command_files() {
    log "测试命令文件完整性..."

    local command_files=(
        "commands/autopilot-continuous-start.md"
        "commands/autopilot-status.md"
        "commands/autopilot-context-refresh.md"
        "commands/autopilot-recovery.md"
    )

    for file in "${command_files[@]}"; do
        if [ ! -s "$file" ]; then
            error "命令文件为空: $file"
            return 1
        fi

        # 检查是否包含必要的markdown格式
        if ! grep -q "^# /" "$file"; then
            warn "命令文件可能缺少slash命令定义: $file"
        fi
    done

    log "命令文件完整性检查通过"
    return 0
}

# 测试插件配置
test_plugin_config() {
    log "测试插件配置..."

    # 检查插件名称
    local plugin_name=$(jq -r '.name' .claude-plugin/plugin.json 2>/dev/null)
    if [ "$plugin_name" != "claude-code-autopilot" ]; then
        error "插件名称不正确: $plugin_name"
        return 1
    fi

    # 检查版本
    local version=$(jq -r '.version' .claude-plugin/plugin.json 2>/dev/null)
    if [ -z "$version" ] || [ "$version" == "null" ]; then
        error "插件版本未定义"
        return 1
    fi

    # 检查描述
    local description=$(jq -r '.description' .claude-plugin/plugin.json 2>/dev/null)
    if [ -z "$description" ] || [ "$description" == "null" ]; then
        error "插件描述未定义"
        return 1
    fi

    log "插件配置检查通过 (名称: $plugin_name, 版本: $version)"
    return 0
}

# 检查Claude Code CLI
test_claude_cli() {
    log "检查Claude Code CLI..."

    if ! which claude &>/dev/null; then
        warn "Claude Code CLI 未安装或不在PATH中"
        info "请参考官方文档安装: https://docs.claude.com/claude-code"
        return 1
    fi

    local version=$(claude --version 2>/dev/null || echo "unknown")
    log "Claude Code CLI 已安装 (版本: $version)"
    return 0
}

# 生成测试报告
generate_report() {
    log "生成测试报告..."

    local report_file="plugin-test-report-$(date +%Y%m%d_%H%M%S).md"

    cat > "$report_file" << EOF
# Claude Code AutoPilot Plugin 测试报告

**测试时间**: $(date)
**插件版本**: $(jq -r '.version // "unknown"' .claude-plugin/plugin.json)

## 测试项目

- [x] 插件结构检查
- [x] JSON文件格式验证
- [x] 命令文件完整性检查
- [x] 插件配置验证
EOF

    if which claude &>/dev/null; then
        echo "- [x] Claude Code CLI 检查" >> "$report_file"
    else
        echo "- [ ] Claude Code CLI 检查 (未安装)" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## 测试结果

**总体状态**: ${GREEN}✅ PASSED${NC}

所有必需的文件都已就位，JSON格式正确，插件配置完整。

## 下一步

1. 运行安装脚本: \`./install.sh\`
2. 启动Claude Code: \`claude --dangerously-skip-permissions\`
3. 安装插件: \`/plugin marketplace add ../autopilot-marketplace\`
4. 安装插件: \`/plugin install claude-code-autopilot@autopilot-marketplace\`
5. 开始使用: \`/autopilot-continuous-start\`

---

**测试完成时间**: $(date)
EOF

    log "测试报告已生成: $report_file"
}

# 主测试函数
main() {
    echo "🧪 Claude Code AutoPilot Plugin 测试"
    echo "===================================="
    echo ""

    local failed_tests=()

    # 执行测试
    if ! test_plugin_structure; then
        failed_tests+=("plugin_structure")
    fi

    if ! test_json_format; then
        failed_tests+=("json_format")
    fi

    if ! test_command_files; then
        failed_tests+=("command_files")
    fi

    if ! test_plugin_config; then
        failed_tests+=("plugin_config")
    fi

    if ! test_claude_cli; then
        failed_tests+=("claude_cli")
    fi

    # 显示结果
    echo ""
    echo "===================================="
    if [ ${#failed_tests[@]} -eq 0 ]; then
        log "🎉 所有测试通过！插件已准备就绪"
        generate_report
        echo ""
        echo "下一步运行: ./install.sh"
    else
        error "❌ 测试失败: ${failed_tests[*]}"
        echo ""
        echo "请修复上述问题后重新运行测试"
        exit 1
    fi
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi