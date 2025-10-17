# Claude Code AutoPilot 开发指南

**版本**: 1.0.0
**更新时间**: 2025-10-17
**目标读者**: 插件开发者和系统管理员

## 📋 目录

- [开发环境设置](#开发环境设置)
- [项目结构](#项目结构)
- [开发工作流](#开发工作流)
- [代码规范](#代码规范)
- [测试指南](#测试指南)
- [发布流程](#发布流程)
- [故障排除](#故障排除)

---

## 🛠️ 开发环境设置

### 系统要求
- **操作系统**: Linux, macOS, Windows (WSL2)
- **Bash版本**: 4.0+
- **依赖工具**: jq 1.6+, awk, curl, date, stat, realpath

### 开发工具安装

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install jq coreutils curl git vim
```

#### macOS
```bash
brew install jq coreutils curl git vim
```

#### Windows (WSL2)
```bash
sudo apt-get update
sudo apt-get install jq coreutils curl git vim
```

### IDE/编辑器配置
推荐使用支持Bash语法高亮的编辑器：
- VS Code + Bash extension
- Vim + bash-support plugin
- Sublime Text + ShellScript package

### 代码质量工具
```bash
# ShellCheck - Bash脚本静态分析
sudo apt-get install shellcheck

# 安装
shellcheck scripts/*.sh
```

---

## 📁 项目结构

```
claude-code-autopilot/
├── .claude-plugin/              # Claude Code插件配置
│   └── plugin.json            # 插件清单文件
├── commands/                   # Slash命令定义
│   ├── autopilot-continuous-start.md
│   ├── autopilot-status.md
│   ├── autopilot-context-refresh.md
│   └── autopilot-recovery.md
├── scripts/                    # 核心执行脚本
│   ├── init-session.sh        # 系统初始化
│   ├── state-manager.sh       # 状态管理
│   ├── execution-monitor.sh   # 监控系统
│   └── autopilot-engine.sh    # 执行引擎
├── templates/                  # 状态文件模板
│   ├── REQUIREMENT_ALIGNMENT.json
│   ├── EXECUTION_PLAN.json
│   ├── TODO_TRACKER.json
│   ├── DECISION_LOG.json
│   └── EXECUTION_STATE.json
├── docs/                       # 文档目录
│   ├── API-REFERENCE.md
│   ├── DEVELOPMENT-GUIDE.md
│   └── USER-GUIDE.md
├── tests/                      # 测试文件
│   └── integration/
├── autopilot-logs/              # 运行时日志
├── autopilot-backups/           # 状态备份
├── autopilot-recovery-points/    # 恢复检查点
└── README.md                   # 项目说明文档
```

### 文件说明

#### `.claude-plugin/plugin.json`
Claude Code插件的核心配置文件，定义插件的基本信息和能力。

#### `commands/`
Slash命令定义文件，每个Markdown文件对应一个命令。

#### `scripts/`
核心执行脚本，实现自动化功能。

#### `templates/`
JSON状态文件模板，用于初始化系统状态。

---

## 🔄 开发工作流

### 1. 功能开发流程

#### 步骤1: 需求分析
```bash
# 创建功能开发分支
git checkout -b feature/new-feature

# 分析需求并设计API
# 设计JSON数据结构
# 规划命令行接口
```

#### 步骤2: 核心脚本开发
```bash
# 创建新的脚本文件
cp scripts/state-manager.sh scripts/new-feature.sh

# 编辑脚本，实现核心功能
vim scripts/new-feature.sh

# 测试脚本语法
bash -n scripts/new-feature.sh
```

#### 步骤3: 状态文件模板
```bash
# 创建新的JSON模板
cp templates/TODO_TRACKER.json templates/NEW_FEATURE.json

# 编辑模板结构
vim templates/NEW_FEATURE.json
```

#### 步骤4: 集成测试
```bash
# 测试新功能
./scripts/new-feature.sh test

# 验证与现有组件的集成
./scripts/state-manager.sh status
./scripts/execution-monitor.sh check
```

#### 步骤5: 文档更新
```bash
# 更新API文档
vim docs/API-REFERENCE.md

# 更新用户指南
vim docs/USER-GUIDE.md

# 更新README
vim README.md
```

### 2. 测试流程

#### 单元测试
```bash
# 测试脚本语法
for script in scripts/*.sh; do
    echo "Testing $script..."
    bash -n "$script" || echo "Syntax error in $script"
done
```

#### 功能测试
```bash
# 测试初始化
./scripts/init-session.sh clean
./scripts/init-session.sh init

# 测试状态管理
./scripts/state-manager.sh check
./scripts/state-manager.sh status

# 测试监控系统
./scripts/execution-monitor.sh status
```

#### 集成测试
```bash
# 运行完整测试套件
./test-plugin.sh

# 创建测试场景
./tests/integration/full-workflow-test.sh
```

### 3. 代码审查流程

#### 自我审查清单
- [ ] 代码遵循项目规范
- [ ] 错误处理完善
- [ ] 日志输出清晰
- [ ] 参数验证严格
- [ ] 文档更新完整

#### 提交审查
```bash
# 添加文件到Git
git add .

# 创建提交
git commit -m "feat: 添加新功能模块

- 实现新功能的核心逻辑
- 添加对应的JSON模板
- 更新API文档
- 添加完整测试用例

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude <noreply@anthropic.com>"

# 推送到远程
git push origin feature/new-feature
```

---

## 📝 代码规范

### Bash脚本规范

#### 1. 脚本头部
```bash
#!/bin/bash
# Claude Code AutoPilot - 脚本描述
# 详细的功能说明

set -euo pipefail
```

#### 2. 变量命名
```bash
# 全局常量（大写）
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"

# 局部变量（小写）
local todo_id="$1"
local status="$2"
```

#### 3. 函数定义
```bash
# 函数命名：动词_名词
function_name() {
    local param1="$1"
    local param2="${2:-default_value}"

    # 函数实现
    log "执行函数: $param1, $param2"
    return 0
}

# 简化语法
another_function() {
    echo "简化的函数定义"
}
```

#### 4. 日志输出
```bash
# 统一的日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] SCRIPT_NAME: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] SCRIPT_NAME: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] SCRIPT_NAME: WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] SCRIPT_NAME: ERROR: $1${NC}"
}
```

#### 5. 错误处理
```bash
# 参数验证
if [ -z "$param1" ]; then
    error "参数不能为空"
    return 1
fi

# 文件存在检查
if [ ! -f "$file_path" ]; then
    error "文件不存在: $file_path"
    return 1
fi

# JSON格式验证
if ! jq empty "$json_file" 2>/dev/null; then
    error "JSON格式错误: $json_file"
    return 1
fi
```

### JSON文件规范

#### 1. 基本结构
```json
{
  "component_name": {
    "session_id": "PREFIX_YYYYMMDD_HHMMSS_PID",
    "generated_at": "2025-10-17T10:30:00+08:00",
    "last_update_time": "2025-10-17T10:30:00+08:00"
  }
}
```

#### 2. 字段命名
- 使用下划线命名法
- 时间戳使用ISO 8601格式
- ID字段包含时间戳和进程ID

#### 3. 数组规范
```json
{
  "items": [
    {
      "id": "ITEM_001",
      "name": "项目名称",
      "status": "active"
    }
  ]
}
```

### Markdown文档规范

#### 1. 命令文档
```markdown
# /command-name
命令简要描述

## 功能说明
详细的功能描述...

## 用法
命令的使用方法...

## 参数
参数说明...

## 示例
使用示例...
```

#### 2. API文档
```markdown
# 功能名称 API

## 概述
API的总体介绍...

## 端点
### 端点名称
- **方法**: GET/POST/PUT/DELETE
- **路径**: `/api/endpoint`
- **描述**: 端点功能描述

## 请求格式
```json
{
  "field": "value"
}
```

## 响应格式
```json
{
  "success": true,
  "data": {}
}
```
```

---

## 🧪 测试指南

### 测试策略

#### 1. 单元测试
- 语法检查
- 函数测试
- 边界条件测试

#### 2. 集成测试
- 组件间协作测试
- 端到端流程测试
- 错误恢复测试

#### 3. 性能测试
- 大数据量处理测试
- 并发执行测试
- 资源使用测试

### 测试脚本模板

#### 功能测试模板
```bash
#!/bin/bash
# 功能测试模板

set -euo pipefail

# 测试配置
readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(realpath "$TEST_DIR/..")"

# 测试辅助函数
test_passed() {
    echo "✅ PASS: $1"
}

test_failed() {
    echo "❌ FAIL: $1"
    exit 1
}

# 测试用例
test_function() {
    local test_name="$1"

    echo "测试: $test_name"

    # 执行测试逻辑
    if command_under_test; then
        test_passed "$test_name"
    else
        test_failed "$test_name"
    fi
}

# 主测试函数
main() {
    echo "开始功能测试..."

    cd "$PROJECT_ROOT"

    # 运行测试用例
    test_function "初始化测试"
    test_function "状态管理测试"
    test_function "监控测试"

    echo "所有测试通过！"
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 自动化测试

#### CI/CD集成
```yaml
# .github/workflows/test.yml
name: 测试
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: 安装依赖
      run: |
        sudo apt-get update
        sudo apt-get install jq shellcheck

    - name: 语法检查
      run: |
        shellcheck scripts/*.sh

    - name: 功能测试
      run: |
        ./test-plugin.sh
        ./tests/integration/full-workflow-test.sh
```

---

## 🚀 发布流程

### 版本管理

#### 版本号规范
使用语义化版本号：`主版本.次版本.修订版本`

- **主版本**: 不兼容的API修改
- **次版本**: 向后兼容的功能性新增
- **修订版本**: 向后兼容的问题修正

#### 发布检查清单
- [ ] 所有测试通过
- [ ] 文档更新完整
- [ ] 版本号更新
- [ ] CHANGELOG更新
- [ ] 安全扫描通过

### 发布步骤

#### 1. 准备发布
```bash
# 更新版本号
sed -i 's/"version": ".*"/"version": "1.0.1"/' .claude-plugin/plugin.json

# 更新CHANGELOG
vim CHANGELOG.md

# 运行完整测试
./test-plugin.sh
```

#### 2. 创建发布标签
```bash
# 提交更改
git add .
git commit -m "release: v1.0.1

# 创建标签
git tag -a v1.0.1 -m "Release version 1.0.1"

# 推送标签
git push origin v1.0.1
```

#### 3. 发布验证
```bash
# 验证安装流程
./install.sh

# 验证功能完整性
./scripts/init-session.sh status
./scripts/state-manager.sh status
```

---

## 🔧 故障排除

### 常见问题

#### 1. 权限问题
```bash
# 错误: Permission denied
# 解决方案:
chmod +x scripts/*.sh
```

#### 2. 依赖缺失
```bash
# 错误: command not found: jq
# 解决方案:
sudo apt-get install jq
```

#### 3. JSON格式错误
```bash
# 错误: parse error
# 解决方案:
jq empty broken_file.json
```

#### 4. 状态文件冲突
```bash
# 错误: 状态文件已存在
# 解决方案:
./scripts/init-session.sh clean
./scripts/init-session.sh init
```

### 调试技巧

#### 1. 启用调试模式
```bash
# 在脚本中添加调试信息
set -x  # 启用命令跟踪

# 或使用调试函数
debug() {
    echo "DEBUG: $1"
}
```

#### 2. 查看详细日志
```bash
# 查看运行日志
tail -f autopilot-logs/*.log

# 查看错误日志
grep -r "ERROR" autopilot-logs/
```

#### 3. 验证JSON文件
```bash
# 验证JSON格式
for file in *.json; do
    echo "检查 $file..."
    jq empty "$file" || echo "$file 格式错误"
done
```

### 性能优化

#### 1. 脚本性能
- 避免不必要的子进程调用
- 使用内置命令替代外部工具
- 优化循环和字符串操作

#### 2. JSON处理
- 减少大文件的频繁解析
- 使用流式处理大数据
- 合理使用缓存

#### 3. 文件I/O
- 批量操作代替单个操作
- 减少不必要的文件读写
- 使用临时文件优化复杂操作

---

## 📚 扩展资源

### 相关文档
- [API参考文档](./API-REFERENCE.md)
- [用户使用指南](./USER-GUIDE.md)
- [项目README](../README.md)

### 外部资源
- [Bash脚本最佳实践](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck文档](https://www.shellcheck.net/)
- [JSON规范](https://json.org/)

### 社区资源
- [Claude Code官方文档](https://docs.claude.com/claude-code)
- [GitHub Issues](https://github.com/x-rush/claude-code-autopilot/issues)
- [讨论区](https://github.com/x-rush/claude-code-autopilot/discussions)

---

*本文档随项目更新而更新，欢迎贡献和改进建议！*