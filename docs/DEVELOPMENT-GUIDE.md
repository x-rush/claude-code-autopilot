# Claude Code AutoPilot 开发指南

**版本**: 1.0.0
**更新时间**: 2025-10-17
**目标读者**: 插件开发者和系统管理员

## 📋 目录

- [开发环境设置](#开发环境设置)
- [项目结构](#项目结构)
- [开发工作流](#开发工作流)
- [slash命令开发](#slash命令开发)
- [JSON状态文件设计](#json状态文件设计)
- [测试指南](#测试指南)
- [发布流程](#发布流程)
- [故障排除](#故障排除)

---

## 🛠️ 开发环境设置

### 系统要求
- **操作系统**: Linux, macOS, Windows (WSL2)
- **Claude Code**: 已安装并正常运行
- **文本编辑器**: 任何支持Markdown和JSON的编辑器

### 开发工具推荐

#### 文本编辑器/IDE
- **VS Code**: 支持Markdown和JSON语法高亮
- **Vim/Neovim**: 轻量级，支持多种文件类型
- **Sublime Text**: 优秀的Markdown和JSON支持

#### 有用插件
- **Markdown Preview**: 实时预览Markdown文档
- **JSON Lint**: JSON格式验证
- **Git Integration**: 版本控制集成

### 验证开发环境
```bash
# 检查Claude Code
claude --version

# 测试基本功能
claude --dangerously-skip-permissions
/help

# 验证插件加载
/help | grep autopilot
```

---

## 📁 项目结构

```
claude-code-autopilot/
├── .claude-plugin/              # Claude Code插件配置
│   └── plugin.json            # 插件清单文件
├── commands/                   # Slash命令定义
│   ├── autopilot-continuous-start.md
│   ├── autopilot-execute.md
│   ├── autopilot-align.md
│   ├── autopilot-status.md
│   ├── autopilot-context-refresh.md
│   └── autopilot-recovery.md
├── templates/                  # JSON状态文件模板
│   ├── REQUIREMENT_ALIGNMENT.json
│   ├── EXECUTION_PLAN.json
│   ├── TODO_TRACKER.json
│   ├── DECISION_LOG.json
│   └── EXECUTION_STATE.json
├── scripts/                    # 辅助脚本（可选）
│   └── init-session.sh        # 系统初始化脚本
├── docs/                       # 文档目录
│   ├── API-REFERENCE.md
│   ├── DEVELOPMENT-GUIDE.md
│   └── USER-GUIDE.md
└── README.md                   # 项目说明文档
```

### 文件说明

#### `.claude-plugin/plugin.json`
Claude Code插件的核心配置文件，定义插件的基本信息和能力。

#### `commands/`
**核心目录**：包含所有slash命令的Markdown文件。每个文件对应一个功能命令，包含YAML前置元数据和Markdown内容。

#### `templates/`
JSON状态文件模板，用于初始化和验证系统状态。这些文件定义了系统的数据结构。

#### `scripts/`（可选）
辅助脚本目录，仅包含必要的初始化脚本。主要功能通过slash命令实现。

---

## 🔄 开发工作流

### 1. 功能开发流程

#### 步骤1: 需求分析和设计
```bash
# 创建功能开发分支
git checkout -b feature/new-feature

# 分析需求并设计
# - 确定命令名称和功能
# - 设计JSON数据结构
# - 规划用户交互流程
```

#### 步骤2: 创建slash命令
```bash
# 创建新的命令文件
touch commands/autopilot-new-feature.md

# 编辑命令，实现功能逻辑
vim commands/autopilot-new-feature.md
```

#### 步骤3: 设计JSON模板（如需要）
```bash
# 创建新的JSON模板
touch templates/NEW_FEATURE.json

# 编辑模板结构
vim templates/NEW_FEATURE.json
```

#### 步骤4: 集成测试
```bash
# 测试新命令
claude --dangerously-skip-permissions
/autopilot-new-feature --help

# 验证与现有组件的集成
/autopilot-status
/autopilot-align
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

### 2. 开发原则

#### 纯插件实现
- **无外部依赖**: 不依赖shell脚本或外部工具
- **原生能力**: 充分利用Claude Code的原生功能
- **状态驱动**: 通过JSON文件管理状态和进度
- **用户交互**: 通过对话界面进行交互

#### 设计模式
- **命令单一职责**: 每个slash命令专注一个功能
- **状态一致性**: 确保所有状态文件的数据一致性
- **错误恢复**: 提供完整的错误检测和恢复机制
- **用户体验**: 优先考虑用户体验和易用性

---

## 📝 slash命令开发

### 基本结构

每个slash命令都是一个Markdown文件，包含以下结构：

```markdown
---
description: 命令简要描述
---

# /command-name
命令的详细描述

## 功能说明
详细解释命令的作用和使用场景...

## 使用方法
命令的具体使用方法...

## 参数说明
如果命令支持参数，说明各参数的作用...

## 示例
提供具体的使用示例...
```

### 开发指南

#### 1. 命令命名规范
- 使用清晰的描述性名称
- 采用`autopilot-功能名`的命名格式
- 避免过于简短或模糊的名称

#### 2. 功能设计原则
- **明确目标**: 每个命令有明确的功能目标
- **用户友好**: 提供清晰的说明和反馈
- **错误处理**: 处理各种异常情况并提供有用的错误信息
- **状态管理**: 正确读取和更新相关JSON文件

#### 3. 交互设计
- **引导式交互**: 通过问题引导用户完成操作
- **进度反馈**: 实时显示操作进度和状态
- **确认机制**: 重要操作前请求用户确认
- **结果展示**: 清晰展示操作结果

### 命令模板

#### 基础命令模板
```markdown
---
description: 新功能命令的简要描述
---

# /autopilot-new-feature
新功能命令的详细描述。

## 功能说明
这个命令用于实现特定的功能...

## 使用方法
```bash
/autopilot-new-feature [参数]
```

## 参数说明
- `参数1`: 参数描述
- `--option`: 选项描述

## 功能流程
1. **第一步**: 描述第一个步骤
2. **第二步**: 描述第二个步骤
3. **第三步**: 描述第三个步骤

## 示例
```
用户: /autopilot-new-feature
系统: 开始执行新功能...

✅ 第一步完成
📋 处理结果: ...
✅ 功能执行完成
```

现在我将开始执行新功能的具体操作...
```

#### 状态检查命令模板
```markdown
---
description: 检查系统状态和进度
---

# /autopilot-status-check
检查特定的系统状态。

## 检查内容
1. **状态文件检查**: 验证JSON文件的完整性
2. **数据一致性**: 检查文件间的数据一致性
3. **进度验证**: 确认执行进度的合理性

## 检查结果
- ✅ 正常: 系统状态良好
- ⚠️ 警告: 发现轻微问题
- ❌ 错误: 发现严重问题

## 修复建议
根据检查结果提供具体的修复建议...
```

#### 恢复命令模板
```markdown
---
description: 系统恢复和修复
---

# /autopilot-recovery-advanced
高级系统恢复功能。

## 恢复模式
- `check`: 仅检查状态，不修复
- `auto-fix`: 自动修复可恢复的问题
- `interactive`: 交互式恢复

## 恢复流程
1. **问题检测**: 扫描状态文件和系统状态
2. **问题分析**: 分析问题的类型和严重程度
3. **恢复策略**: 选择合适的恢复方法
4. **执行恢复**: 实施恢复操作
5. **验证结果**: 确认恢复是否成功

开始执行系统恢复检查...
```

---

## 📋 JSON状态文件设计

### 设计原则

#### 1. 数据结构规范
```json
{
  "component_name": {
    "session_id": "PREFIX_YYYYMMDD_HHMMSS_PID",
    "generated_at": "2025-10-17T10:30:00+08:00",
    "last_update_time": "2025-10-17T10:30:00+08:00",
    "其他字段": "..."
  }
}
```

#### 2. 字段命名规范
- 使用下划线命名法 (`snake_case`)
- 时间戳使用ISO 8601格式
- ID字段包含时间戳和进程信息
- 布尔值使用 `true/false`

#### 3. 数组设计规范
```json
{
  "items": [
    {
      "id": "ITEM_001",
      "name": "项目名称",
      "status": "active/inactive/completed",
      "created_at": "2025-10-17T10:30:00+08:00",
      "updated_at": "2025-10-17T10:30:00+08:00"
    }
  ]
}
```

### 状态文件类型

#### 1. 配置类文件
存储系统配置和用户偏好：
- `REQUIREMENT_ALIGNMENT.json`: 需求对齐配置
- `EXECUTION_PLAN.json`: 执行计划配置

#### 2. 状态类文件
存储动态状态和进度信息：
- `TODO_TRACKER.json`: 任务进度跟踪
- `DECISION_LOG.json`: 决策日志记录
- `EXECUTION_STATE.json`: 执行状态管理

### 文件操作最佳实践

#### 读取操作
1. **文件存在检查**: 确认文件存在
2. **格式验证**: 验证JSON格式正确性
3. **数据完整性**: 检查必要字段
4. **一致性验证**: 与其他文件数据一致性

#### 写入操作
1. **备份创建**: 修改前创建备份
2. **数据验证**: 验证新数据的正确性
3. **原子写入**: 使用临时文件确保原子性
4. **一致性更新**: 同时更新相关文件

---

## 🧪 测试指南

### 测试策略

#### 1. 功能测试
- **命令功能**: 验证每个命令的基本功能
- **参数处理**: 测试各种参数组合
- **错误处理**: 验证异常情况的处理
- **用户交互**: 测试用户界面和交互流程

#### 2. 集成测试
- **命令协作**: 测试命令间的协作
- **状态一致性**: 验证状态文件的一致性
- **工作流程**: 测试完整的执行流程
- **异常恢复**: 测试异常情况下的恢复

#### 3. 用户体验测试
- **易用性**: 验证命令的易用性
- **文档准确性**: 确保文档与实际功能一致
- **错误信息**: 验证错误信息的清晰度
- **响应时间**: 测试响应时间的合理性

### 测试方法

#### 手动测试
```bash
# 基本功能测试
claude --dangerously-skip-permissions
/autopilot-status
/autopilot-align
/autopilot-recovery --check

# 错误场景测试
# 删除部分状态文件，测试恢复功能
# 修改JSON格式，测试错误处理
```

#### 自动化测试
```bash
# 创建测试脚本
tests/test_commands.sh

# 测试JSON文件格式
tests/test_json_format.sh

# 测试命令集成
tests/test_integration.sh
```

### 测试检查清单

#### 功能测试清单
- [ ] 所有基本命令正常工作
- [ ] 参数处理正确
- [ ] 错误处理完善
- [ ] 状态文件操作正确
- [ ] 用户交互友好

#### 集成测试清单
- [ ] 命令间协作正常
- [ ] 状态文件一致性
- [ ] 完整工作流程可用
- [ ] 异常恢复机制有效

#### 文档测试清单
- [ ] 命令文档准确
- [ ] 示例可重现
- [ ] API文档完整
- [ ] 用户指南清晰

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
- [ ] 示例验证通过

### 发布步骤

#### 1. 准备发布
```bash
# 更新版本号
sed -i 's/"version": ".*"/"version": "1.0.1"/' .claude-plugin/plugin.json

# 更新CHANGELOG
vim CHANGELOG.md

# 运行完整测试
# 手动测试所有命令功能
```

#### 2. 功能验证
```bash
# 验证安装流程
bash install.sh

# 验证命令功能
claude --dangerously-skip-permissions
/autopilot-status
/autopilot-align
```

#### 3. 创建发布
```bash
# 提交更改
git add .
git commit -m "release: v1.0.1

- 更新命令功能
- 完善文档内容
- 修复已知问题

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude <noreply@anthropic.com>"

# 创建标签
git tag -a v1.0.1 -m "Release version 1.0.1"

# 推送更改
git push origin main
git push origin v1.0.1
```

---

## 🔧 故障排除

### 常见问题

#### 1. 插件加载失败
```bash
# 问题: 命令不可用
# 解决方案:
1. 检查 .claude-plugin/plugin.json 格式
2. 确认 commands/ 目录存在
3. 验证命令文件格式正确
```

#### 2. JSON文件格式错误
```bash
# 问题: JSON解析失败
# 解决方案:
1. 使用JSON验证工具检查格式
2. 检查括号、引号、逗号
3. 验证字段名称正确性
```

#### 3. 状态文件不一致
```bash
# 问题: 状态文件数据冲突
# 解决方案:
1. 使用 /autopilot-recovery 检查
2. 从备份恢复数据
3. 重新初始化状态文件
```

#### 4. 命令执行异常
```bash
# 问题: 命令执行失败
# 解决方案:
1. 检查命令文件格式
2. 验证YAML前置元数据
3. 确认Markdown内容正确
```

### 调试技巧

#### 1. 命令调试
```bash
# 检查命令是否正确加载
/help | grep autopilot

# 测试命令基本功能
/autopilot-status --quick
```

#### 2. 状态文件调试
```bash
# 检查JSON文件格式
for file in *.json; do
    echo "检查 $file..."
    python3 -m json.tool "$file" > /dev/null || echo "$file 格式错误"
done
```

#### 3. 日志查看
```bash
# 查看Claude Code日志
# 检查命令执行过程中的输出信息
```

### 性能优化

#### 1. 命令响应优化
- 简化命令逻辑，减少不必要的处理
- 优化JSON文件读取操作
- 提供快速模式选项

#### 2. 状态文件优化
- 定期清理过期的状态数据
- 优化JSON结构，减少嵌套层级
- 合理使用索引和引用

#### 3. 用户体验优化
- 提供进度指示
- 优化错误信息的可读性
- 增加操作确认机制

---

## 📚 扩展资源

### 相关文档
- [API参考文档](./API-REFERENCE.md)
- [用户使用指南](./USER-GUIDE.md)
- [项目README](../README.md)
- [Claude Code官方文档](https://docs.claude.com/claude-code)

### 开发资源
- [Markdown语法指南](https://www.markdownguide.org/)
- [JSON规范](https://json.org/)
- [YAML前置元数据](https://jekyllrb.com/docs/front-matter/)

### 社区资源
- [GitHub Issues](https://github.com/x-rush/claude-code-autopilot/issues)
- [讨论区](https://github.com/x-rush/claude-code-autopilot/discussions)
- [Claude Code社区](https://community.anthropic.com)

---

## 🤝 贡献指南

### 贡献类型
- **功能增强**: 添加新的slash命令
- **文档改进**: 完善文档和示例
- **Bug修复**: 修复已知问题
- **用户体验**: 改进交互和反馈

### 贡献流程
1. **Fork项目**: 创建项目分支
2. **开发功能**: 按照开发指南实现
3. **测试验证**: 确保功能正常
4. **提交PR**: 创建Pull Request
5. **代码审查**: 等待维护者审查
6. **合并发布**: 合并到主分支

---

*本文档随项目更新而更新，欢迎贡献和改进建议！*