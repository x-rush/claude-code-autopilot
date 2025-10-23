# 状态管理技能

## 技能描述
专业化的项目状态跟踪和管理技能，维护完整的项目执行状态和质量指标。

## 核心能力
- **任务进度跟踪**：实时更新任务执行状态和质量评分
- **决策记录管理**：完整记录所有偏离原计划的决策及其理由
- **执行状态维护**：动态维护当前执行会话和系统健康状态
- **数据一致性保障**：确保各状态文件间的数据一致性

## 使用场景
- 任务执行过程中的状态更新
- 异常情况的状态恢复和修复
- 定期的执行进度报告生成
- 项目状态的完整性检查

## 输出产物
维护三个核心状态文件：
- `TODO_TRACKER.json`：任务进度跟踪和质量指标
- `DECISION_LOG.json`：决策记录和偏离分析
- `EXECUTION_STATE.json`：当前执行状态和会话信息

## 质量标准
- 状态更新及时性 ≤ 5分钟
- 数据一致性检查通过率 100%
- 决策记录完整性 ≥ 95%
- 质量评分准确性 ≥ 90%

## 模板文件
- 任务跟踪结构：@templates/TODO_TRACKER.json
- 决策日志结构：@templates/DECISION_LOG.json
- 执行状态结构：@templates/EXECUTION_STATE.json

## 示例文件
- @examples/healthy-state-example.json
- @examples/recovery-scenario-example.json
- @examples/quality-metrics-example.json