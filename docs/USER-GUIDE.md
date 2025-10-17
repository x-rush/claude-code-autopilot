# Claude Code AutoPilot 用户指南

**版本**: 1.0.0
**更新时间**: 2025-10-17
**适用用户**: 项目管理者、开发者、技术负责人

## 📋 目录

- [快速开始](#快速开始)
- [安装和配置](#安装和配置)
- [基本使用](#基本使用)
- [高级功能](#高级功能)
- [故障排除](#故障排除)
- [最佳实践](#最佳实践)
- [FAQ](#faq)

---

## 🚀 快速开始

### 什么是Claude Code AutoPilot？

Claude Code AutoPilot是一个**完全无人值守的项目执行系统**，能够：

- ✅ **深度需求讨论**: 确保完全理解用户需求
- ✅ **智能执行计划**: 自动分解任务并制定执行策略
- ✅ **24小时连续执行**: 真正的无分段自主工作
- ✅ **智能异常恢复**: 自动处理各种异常情况
- ✅ **实时进度追踪**: 持续监控执行状态和质量

### 5分钟快速体验

```bash
# 1. 克隆项目
git clone https://github.com/x-rush/claude-code-autopilot.git
cd claude-code-autopilot

# 2. 启动Claude Code
claude --dangerously-skip-permissions

# 3. 安装插件
/plugin marketplace add ../autopilot-marketplace
/plugin install claude-code-autopilot@autopilot-marketplace

# 4. 开始使用
/autopilot-continuous-start
```

---

## 🔧 安装和配置

### 系统要求

#### 必需工具
```bash
# 检查依赖工具
for tool in jq awk curl date stat realpath; do
    if which "$tool" &>/dev/null; then
        echo "✅ $tool 已安装"
    else
        echo "❌ 请先安装 $tool"
        exit 1
    fi
done
```

#### 安装命令
```bash
# Ubuntu/Debian
sudo apt-get install jq coreutils curl

# macOS
brew install jq coreutils curl
```

### 插件安装

#### 方法1：本地开发安装（推荐）
```bash
# 1. 克隆项目
git clone https://github.com/x-rush/claude-code-autopilot.git
cd claude-code-autopilot

# 2. 创建本地marketplace
mkdir ../autopilot-marketplace
cd ../autopilot-marketplace

# 3. 创建marketplace配置
cat > marketplace.json << 'EOF'
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

# 4. 安装插件
claude --dangerously-skip-permissions
/plugin marketplace add ../autopilot-marketplace
/plugin install claude-code-autopilot@autopilot-marketplace
```

#### 方法2：团队共享安装
```bash
# 在项目根目录创建配置
echo '{
  "enabledPlugins": {
    "claude-code-autopilot@autopilot-marketplace": true
  },
  "extraKnownMarketplaces": {
    "autopilot-marketplace": {
      "source": {
        "source": "github",
        "repo": "x-rush/claude-code-autopilot"
      }
    }
  }
}' > .claude/settings.json

# 团队成员使用
cd your-project
claude --dangerously-skip-permissions
/trust-folder
```

### 验证安装
```bash
# 运行测试脚本
./test-plugin.sh

# 检查插件是否安装成功
/plugin list | grep autopilot
```

---

## 🎯 基本使用

### 启动AutoPilot

#### 完整工作流程
```bash
# 1. 启动Claude Code（使用权限跳过模式）
claude --dangerously-skip-permissions

# 2. 开始AutoPilot工作流
/autopilot-continuous-start
```

### 三阶段执行流程

#### 第一阶段：深度需求讨论（约30分钟）
Claude将引导你进行结构化的需求讨论：

1. **核心目标确认**
   - 最终想要的具体成果
   - 成果的使用场景和用户群体
   - 成功的质量标准和验收条件

2. **执行细节挖掘**
   - 技术实现偏好和风格
   - 风险容忍度和特殊要求
   - 质量标准和完整性要求

3. **决策点识别**
   - 识别所有可能的决策点
   - 为每个决策点预设解决方案
   - 建立决策优先级和备选方案

4. **需求对齐验证**
   - 生成结构化需求文件
   - 验证需求的一致性和完整性
   - 获得你的最终确认

#### 第二阶段：执行计划生成（约15分钟）
基于需求对齐结果，Claude将：

1. **生成详细TODO清单**
   - 将项目分解为具体可执行的任务
   - 设定每个任务的验收标准和完成时间
   - 建立任务依赖关系和执行顺序

2. **设定质量门禁**
   - 为每个TODO设置质量检查点
   - 建立自动验证机制
   - 设定需求对齐验证频率

3. **配置异常处理**
   - 识别可能出现的错误类型
   - 设定重试策略和恢复机制
   - 建立严重错误的处理流程

#### 第三阶段：连续自主执行（24小时）
讨论完成后，Claude将立即开始连续执行：

1. **严格按照TODO清单执行**
   - 顺序执行每个任务，不偏离计划
   - 使用预设决策方案处理所有问题
   - 每完成一个TODO自动验证质量

2. **智能上下文管理**
   - 监控对话长度，避免上下文窗口限制
   - 智能总结关键信息，保持执行连续性
   - 自动刷新上下文，确保状态一致性

3. **自动异常处理**
   - 网络错误：自动重试5次，指数退避
   - 文件错误：自动重试3次，线性退避
   - 依赖错误：自动重装依赖，重新尝试
   - 质量错误：自动修复并重新验证
   - 严重错误：记录日志，跳过任务，继续执行

4. **持续需求对齐**
   - 每完成5个TODO自动验证需求对齐
   - 检测执行偏差并自动纠正
   - 确保最终结果完全符合原始需求

---

## 📊 监控和管理

### 查看执行状态

#### 实时状态检查
```bash
/autopilot-status
```

状态报告包含：
- 📈 执行进度：当前完成百分比
- 🎯 质量指标：代码质量评分、测试覆盖率
- ⚠️ 错误统计：错误发生和恢复情况
- 🏥 系统健康：资源使用和性能状态
- 📈 时间分析：执行效率和时间预估

#### 执行状态解读

**进度信息**：
- **完成率**：已完成任务占总任务的百分比
- **当前任务**：正在执行的任务详情
- **时间预估**：基于当前进度的完成时间预测

**质量指标**：
- **质量评分**：0-10分的综合质量评分
- **需求对齐度**：与原始需求的一致性评分
- **自动处理成功率**：异常自动恢复的成功率

### 智能恢复

#### 异常恢复机制
```bash
/autopilot-recovery
```

**支持的恢复场景**：
- **系统级中断**：系统重启、网络中断、电源故障
- **应用级中断**：进程崩溃、内存溢出、对话超时
- **环境级中断**：磁盘空间不足、依赖缺失、配置损坏

**恢复策略**：
1. **轻微问题**：自动重启相关进程
2. **中度问题**：从检查点恢复状态
3. **严重问题**：重新初始化并重建状态
4. **灾难性问题**：人工介入建议

### 上下文刷新

#### 解决对话窗口限制
```bash
/autopilot-context-refresh
```

**自动触发条件**：
- 对话长度接近上下文窗口限制（80%）
- 每执行2小时自动刷新
- 完成重要里程碑后自动刷新
- 检测到异常时立即刷新

---

## 🛠️ 高级功能

### 自定义执行计划

#### 手动创建TODO
虽然AutoPilot会自动生成执行计划，但你也可以通过编辑`EXECUTION_PLAN.json`来自定义任务：

```json
{
  "execution_plan": {
    "execution_todos": [
      {
        "todo_id": "CUSTOM_001",
        "title": "自定义任务标题",
        "description": "详细任务描述",
        "type": "implementation",
        "priority": "high",
        "estimated_minutes": 60,
        "acceptance_criteria": [
          "具体验收标准1",
          "具体验收标准2"
        ]
      }
    ]
  }
}
```

### 质量控制配置

#### 自定义质量标准
编辑`REQUIREMENT_ALIGNMENT.json`中的质量门禁：

```json
{
  "requirement_alignment": {
    "quality_gates": {
      "code_quality": {
        "standard": "industry_standard",
        "enforcement": "strict",
        "check_method": "automated",
        "tools": ["eslint", "pylint"]
      },
      "testing": {
        "coverage_threshold": [80, "%"],
        "test_types": ["unit", "integration", "e2e"],
        "frameworks": ["pytest", "jest"],
        "automation_level": "full"
      }
    }
  }
}
```

### 安全配置

#### 工作空间限制
默认配置允许在以下目录操作：
- `./` - 项目根目录
- `./src` - 源代码目录
- `./docs` - 文档目录
- `./tests` - 测试目录
- `./scripts` - 脚本目录

#### 危险操作阻止
系统自动阻止以下操作：
- 系统关机和重启
- 用户和权限管理
- 网络扫描和攻击工具
- 删除项目目录外的文件

---

## 🔧 故障排除

### 常见问题解决

#### 1. 插件安装失败
```bash
# 检查Claude Code版本
claude --version

# 重新安装插件
/plugin remove claude-code-autopilot@autopilot-marketplace
/plugin install claude-code-autopilot@autopilot-marketplace
```

#### 2. 权限问题
```bash
# 确保使用权限跳过模式启动
claude --dangerously-skip-permissions

# 检查文件权限
ls -la .claude/
```

#### 3. 状态文件损坏
```bash
# 使用恢复命令
/autopilot-recovery

# 或重新初始化
./scripts/init-session.sh clean
./scripts/init-session.sh init --force
```

#### 4. 执行中断
```bash
# 检查Claude进程状态
ps aux | grep claude

# 重启Claude并恢复
claude --dangerously-skip-permissions
/autopilot-recovery
```

### 调试模式

#### 启用详细日志
```bash
# 检查运行日志
tail -f autopilot-logs/*.log

# 查看错误日志
grep -r "ERROR" autopilot-logs/
```

#### 手动状态检查
```bash
# 检查初始化状态
./scripts/init-session.sh status

# 检查系统健康
./scripts/state-manager.sh check
./scripts/execution-monitor.sh status
```

### 性能优化

#### 系统资源优化
```bash
# 检查磁盘使用情况
df -h

# 检查内存使用
free -h

# 清理临时文件
rm -rf autopilot-session-temp/*
```

#### 日志管理
```bash
# 查看日志大小
du -sh autopilot-logs/

# 清理旧日志（保留最近7天）
find autopilot-logs/ -name "*.log" -mtime +7 -delete
```

---

## 💡 最佳实践

### 项目准备

#### 1. 明确项目目标
- 在开始前明确最终成果
- 定义清晰的成功标准
- 准备详细的需求文档

#### 2. 环境准备
- 确保稳定的网络连接
- 准备充足磁盘空间
- 安装必要的开发工具

#### 3. 风险评估
- 识别潜在的技术风险
- 制定备选方案
- 设置合理的质量门禁

### 执行过程管理

#### 1. 监控执行进度
- 定期查看执行状态
- 关注质量指标变化
- 及时处理异常情况

#### 2. 上下文管理
- 定期触发上下文刷新
- 检查对话窗口使用情况
- 保持关键信息不丢失

#### 3. 质量保证
- 关注质量评分趋势
- 验证需求对齐情况
- 及时调整执行策略

### 团队协作

#### 1. 权限配置
- 确保团队成员有适当权限
- 配置共享的安装方式
- 建立统一的工作标准

#### 2. 状态同步
- 定期分享执行进度
- 同步重要的决策和变更
- 保持信息透明度

#### 3. 知识分享
- 记录最佳实践和经验教训
- 建立项目知识库
- 培训团队成员

### 项目维护

#### 1. 状态文件管理
- 定期备份状态文件
- 清理过期的日志文件
- 监控磁盘空间使用

#### 2. 版本控制
- 将重要的配置文件加入版本控制
- 记录重要的决策变更
- 建立清晰的分支策略

#### 3. 性能优化
- 定期分析执行效率
- 优化资源配置
- 更新和改进工具

---

## ❓ FAQ

### Q1: AutoPilot可以执行哪些类型的任务？

**A**: AutoPilot擅长执行以下类型的项目：
- 大型文档生成项目（API文档、技术手册）
- 代码库重构和分析
- 测试套件开发
- 配置文件管理
- 数据处理和分析

不适合的任务：
- 需要系统级权限的任务
- 涉及敏感数据处理
- 需要实时性极高（毫秒级响应）的任务

### Q2: 如何确保执行质量？

**A**: AutoPilot通过多层质量控制确保质量：
- **预设质量门禁**：每个任务都有明确的质量标准
- **自动验证机制**：完成后自动验证输出质量
- **需求对齐检查**：定期验证与原始需求的一致性
- **智能重试机制**：质量不达标时自动修复和重试

### Q3: 执行过程中可以干预吗？

**A**: 可以通过以下方式干预：
- **查看状态**：使用`/autopilot-status`随时查看进度
- **手动控制**：使用脚本命令直接管理状态
- **暂停恢复**：使用`/autopilot-recovery`控制执行流程
- **调整计划**：编辑状态文件修改执行计划

### Q4: 如何处理长时间执行？

**A**: AutoPilot专为长时间执行设计：
- **连续执行**：真正的24小时无分段执行
- **智能上下文管理**：自动解决对话窗口限制
- **断点续传**：异常中断后可以从断点继续
- **自动保存**：定期保存执行状态和进度

### Q5: 系统安全性如何保障？

**A**: 多重安全保障机制：
- **目录限制**：仅在项目目录内执行操作
- **危险操作阻止**：自动识别和阻止危险命令
- **完整审计**：所有操作都有详细日志记录
- **权限控制**：严格的操作权限管理

### Q6: 支持哪些编程语言和框架？

**A**: AutoPilot语言无关，可以处理任何文本格式的任务：
- 编程语言：Python, JavaScript, Java, Go, Rust等
- 配置文件：YAML, JSON, XML, INI等
- 文档格式：Markdown, AsciiDoc, LaTeX等
- 数据格式：CSV, JSON, SQL等

### Q7: 如何扩展AutoPilot功能？

**A**: 可以通过以下方式扩展：
- **自定义脚本**：在`scripts/`目录添加新功能
- **扩展命令**：在`commands/`目录添加新的slash命令
- **修改模板**：在`templates/`目录自定义状态文件结构
- **调整配置**：修改脚本中的配置参数

### Q8: 执行失败后如何恢复？

**A**: 智能恢复机制：
- **自动检测**：系统会自动检测执行失败
- **智能分析**：分析失败原因和影响范围
- **自动恢复**：选择最佳恢复策略
- **手动介入**：提供详细的手动恢复指南

### Q9: 如何获得技术支持？

**A**: 多种支持渠道：
- **GitHub Issues**：报告问题和功能请求
- **项目文档**：查看详细的API和开发指南
- **社区讨论**：参与社区讨论和经验分享
- **邮件支持**：联系技术支持团队

---

## 📞 联系支持

### 获取帮助
- **项目仓库**：[GitHub](https://github.com/x-rush/claude-code-autopilot)
- **问题反馈**：[Issues](https://github.com/x-rush/claude-code-autopilot/issues)
- **功能建议**：[Discussions](https://github.com/x-rush/claude-code-autopilot/discussions)

### 贡献指南
欢迎为项目做出贡献：
- 报告Bug和问题
- 提出新功能建议
- 改进文档和示例
- 分享使用经验和最佳实践

---

*本文档持续更新，请关注最新版本以获取最新功能和使用指南。*