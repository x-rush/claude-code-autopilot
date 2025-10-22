# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Claude Code AutoPilot** is a sophisticated plugin that enables 24-hour fully autonomous project execution through pure slash command implementation. It's a zero-dependency, lightweight system focused on requirement alignment and autonomous execution.

## Core Architecture

### Pure Plugin Design
- **Zero External Dependencies**: Only relies on Claude Code and basic shell commands
- **Global Marketplace Installation**: Installation through local marketplace following official standards
- **Slash Command Driven**: All functionality through standard slash commands
- **JSON State Management**: Five core state files track the entire project lifecycle

### Three-Phase Execution Workflow
1. **Deep Requirement Discussion**: Structured analysis of user needs and decision points
2. **Execution Plan Generation**: Dynamic task decomposition and state file creation
3. **Autonomous Execution**: Continuous task execution with real-time status updates

## Key Commands

### Primary Workflow Commands
- `/autopilot-start` - Initiates the complete workflow from requirements to autonomous execution
- `/autopilot-status` - Shows current execution progress and system health
- `/autopilot-align` - Validates execution against original requirements
- `/autopilot-execute` - Executes specific tasks with quality scoring
- `/autopilot-context-refresh` - Handles context limitations automatically
- `/autopilot-recovery` - Handles abnormal execution states
- `/autopilot-plan` - Generates execution plans

## Installation and Setup

### Global Installation
```bash
# Clone the repository (one time)
git clone https://github.com/x-rush/claude-code-autopilot.git

# Start Claude Code
claude --dangerously-skip-permissions

# Add the plugin directory as a marketplace
/plugin marketplace add /path/to/claude-code-autopilot

# Install the plugin
/plugin install claude-code-autopilot@claude-code-autopilot
```

### Example Installation
```bash
# Example with absolute path
/plugin marketplace add ~/dev/claude-code-autopilot
/plugin install claude-code-autopilot@claude-code-autopilot
```

### Verification
```bash
# Check plugin installation
/help | grep autopilot

# Start the workflow
/autopilot-start
```

## State File System

### Core JSON State Files
The plugin uses five state files that are generated dynamically based on templates:

1. **REQUIREMENT_ALIGNMENT.json** - Requirements validation and alignment
2. **EXECUTION_PLAN.json** - Task breakdown and execution strategy
3. **TODO_TRACKER.json** - Task progress tracking and quality metrics
4. **DECISION_LOG.json** - Decision-making process documentation
5. **EXECUTION_STATE.json** - Current execution status and session information

### Template vs Runtime Files
- `templates/*.json` - Structure definitions that Claude Code reads to understand data formats
- Project root `*.json` - Runtime-generated project-specific state files (git-ignored)

## Development Workflow

### Understanding the Plugin Structure
```
.claude/plugins/claude-code-autopilot/
├── .claude-plugin/plugin.json      # Plugin metadata
├── commands/                       # Slash command implementations
├── templates/                      # JSON structure definitions
├── docs/                          # Documentation
└── manage.sh                     # Plugin management script
```

### Working with State Files
When modifying or debugging the plugin:

1. **Template Files**: These define the structure that Claude Code uses to generate runtime files
2. **Runtime Files**: Generated dynamically based on user requirements discussions
3. **State Consistency**: All five state files must maintain data consistency

### Quality Assurance
- Tasks are scored 0-10 for quality tracking
- Multi-stage validation: Requirements → Planning → Execution → Quality
- Continuous alignment checking with original requirements

## Best Practices

### For Plugin Development
- Follow the zero-dependency philosophy strictly
- Maintain the three-phase workflow constraint
- Ensure template files are well-documented with clear field descriptions
- Test command implementations thoroughly

### For User Projects
- Always start with `/autopilot-start` for new projects
- Monitor progress with `/autopilot-status` regularly
- Use `/autopilot-align` to verify requirement alignment
- Leverage `/autopilot-recovery` for error recovery

### Safety and Security
- Operations are restricted to the current project directory
- No system-level commands or privileged operations
- All state management through safe JSON file operations
- Complete audit trail of all decisions and actions

## Troubleshooting

### Common Issues
- **Plugin Loading**: Verify installation with `/help | grep autopilot`
- **State File Issues**: Use `/autopilot-recovery --auto-fix` for automatic repairs
- **Context Limits**: Use `/autopilot-context-refresh` manually when needed
- **Execution Interruption**: Check status with `/autopilot-status` and recover as needed

### Debug Commands
```bash
# Quick status check
/autopilot-status --quick

# Check specific aspects
/autopilot-status --aspect=requirements
/autopilot-status --aspect=execution

# Recovery modes
/autopilot-recovery --check
/autopilot-recovery --auto-fix
/autopilot-recovery --interactive
```

## File Management

### Git Integration
- Template files in `templates/` are versioned
- Runtime state files in project root are git-ignored
- Local marketplace files in `local-marketplace/` can be versioned with project

### File Operations
- All file operations are limited to the project directory
- State files are automatically managed by Claude Code
- Manual editing of state files should be done carefully

## Advanced Usage

### Custom Command Development
When extending the plugin:
1. Follow existing command patterns in `commands/`
2. Update relevant JSON templates if adding new state tracking
3. Maintain compatibility with the three-phase workflow
4. Ensure proper error handling and recovery mechanisms

### Integration with Other Tools
- The plugin is designed to work standalone
- External integrations should be handled through the decision framework
- All external tool usage must be explicitly planned and tracked

## Version Information

- **Current Version**: v1.0.0 (released 2025-10-17)
- **Claude Code Requirement**: >=1.0.0
- **License**: MIT

## Key Design Principles

1. **Zero Dependency**: Pure Claude Code capability utilization
2. **Official Standards Compliance**: Installation through local marketplace mechanism
3. **Project Autonomy**: Each project manages its own instance and marketplace
4. **Workflow Constraint**: Strict three-phase execution model
5. **State Persistence**: Complete execution tracking through JSON files
6. **Continuous Alignment**: Ongoing verification with original requirements
7. **Autonomous Recovery**: Intelligent error detection and recovery

This plugin represents a sophisticated approach to autonomous project execution that maintains strict alignment with user requirements while providing complete transparency and control through its comprehensive state management system.