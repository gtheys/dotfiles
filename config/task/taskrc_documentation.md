# Taskwarrior Configuration Documentation

## Overview

This document describes the Taskwarrior configuration at `/home/geert/.config/task/taskrc`, including custom User Defined Attributes (UDAs), reports, and usage patterns for specification workflow management.

## Configuration Structure

### Basic Configuration
```
data.location=/home/geert/.task
news.version=3.4.2
```

- **data.location**: Directory where Taskwarrior stores task data
- **news.version**: Tracks which version news has been shown

### Color Themes (Available but Disabled)
Multiple color themes are available but currently commented out:
- `light-16.theme`, `light-256.theme`
- `dark-16.theme`, `dark-256.theme`
- `bubblegum-256.theme`
- `dark-red-256.theme`, `dark-green-256.theme`, `dark-blue-256.theme`
- `dark-violets-256.theme`, `dark-yellow-green.theme`
- `dark-gray-256.theme`, `dark-gray-blue-256.theme`
- `solarized-dark-256.theme`, `solarized-light-256.theme`
- `no-color.theme`

## Custom User Defined Attributes (UDAs)

### Priority UDA
```
uda.priority.type=string
uda.priority.label=Priority
uda.priority.values=H,M,L,
```

**Purpose**: Track task priority levels
**Values**: 
- `H` (High) - Green color
- `M` (Medium) - White color  
- `L` (Low) - Gray color
- Empty (no priority)

### Spec State UDA
```
uda.spec_state.type=string
uda.spec_state.label=SpecState
uda.spec_state.values=approved,review,draft,stale,
uda.spec_state.default=draft
```

**Purpose**: Track specification workflow states
**Values** (in priority order):
- `approved` - Green color (spec is approved and ready)
- `review` - Yellow color (spec is under review)
- `draft` - Blue color (spec is in draft state)
- `stale` - Red color (spec is outdated/stale)
- Empty (no state assigned)

## Color Configuration

### Priority Colors
```
color.uda.priority.H=color255
color.uda.priority.L=color245
color.uda.priority.M=color250
```

### Spec State Colors
```
color.uda.spec_state.approved=green
color.uda.spec_state.review=yellow
color.uda.spec_state.draft=blue
color.uda.spec_state.stale=red
```

## Custom Reports

### Specs Report
```
report.specs.description=Specification tasks with state
report.specs.columns=id,spec_state,priority,project,tags,due,description
report.specs.filter=+spec
report.specs.labels=ID,State,Pri,Project,Tags,Due,Description
report.specs.sort=spec_state-,priority+,due+
```

**Purpose**: Display all specification tasks with their workflow states
**Filter**: Shows tasks with `+spec` tag
**Sort Order**: By spec state (descending), then priority, then due date

## Usage Guide

### Specification Workflow Management

#### Adding New Specifications
```bash
# Add new spec (defaults to draft state)
task add "New API spec" project:account-api +spec

# Add spec with specific state
task add "Database migration spec" project:backend +spec spec_state:review

# Add spec with due date
task add "Frontend component spec" project:frontend +spec due:2025-12-20
```

#### Managing Spec States
```bash
# Update spec state
task 38 modify spec_state:review

# Move to approved state
task 38 modify spec_state:approved

# Mark as stale
task 38 modify spec_state:stale
```

#### Viewing Specifications
```bash
# View all specs with states
task specs

# View all spec tasks (standard view)
task +spec

# View specs by state
task spec_state:draft
task spec_state:review
task spec_state:approved
task spec_state:stale

# View specs needing attention
task +spec spec_state:review or spec_state:draft

# View specs by project
task +spec project:account-api
task +spec project:backend
```

#### Advanced Filtering
```bash
# High priority specs needing review
task +spec priority:H spec_state:review

# Overdue specs
task +spec +OVERDUE

# Specs due this week
task +spec due:today+7d

# Complex filter: draft specs from account-api project
task +spec project:account-api spec_state:draft
```

### Priority Management
```bash
# Set high priority
task 38 modify priority:H

# Set medium priority
task 38 modify priority:M

# Set low priority
task 38 modify priority:L

# Remove priority
task 38 modify priority:

# View high priority tasks
task priority:H
```

### Integration with Jira Tasks

Many tasks in the system are synchronized with Jira and contain:
- `jiraid`: Jira issue ID
- `jirastatus`: Jira status
- `jiraurl`: Link to Jira issue
- `jiradescription`: Full Jira description

#### Working with Jira Specs
```bash
# View all Jira tasks
task export | jq '.[] | select(.jiraid)'

# View Jira specs
task +spec export | jq '.[] | select(.jiraid)'

# Add spec state to Jira task
task 4 modify +spec spec_state:draft
```

## Configuration File Structure

### File Location
- **Primary**: `/home/geert/.config/task/taskrc`
- **Backup**: `/home/geert/.config/task/taskrc.backup`
- **Data**: `/home/geert/.task/`

### Adding New UDAs
To add new UDAs, follow this pattern:
```
uda.<name>.type=string|numeric|uuid|date|duration
uda.<name>.label=<Column Heading>
uda.<name>.values=A,B,C,  # For string type only
uda.<name>.default=<default_value>
```

### Adding New Reports
```
report.<name>.description=<Report Description>
report.<name>.columns=<comma-separated column list>
report.<name>.filter=<filter expression>
report.<name>.labels=<comma-separated label list>
report.<name>.sort=<sort expression>
```

## Best Practices

### Specification Management
1. **Always tag specs** with `+spec` for proper filtering
2. **Set appropriate states** to track workflow progress
3. **Use projects** to organize specs by component/team
4. **Set due dates** for time-sensitive specifications
5. **Use priorities** to highlight critical specs

### Task Management
1. **Use descriptive titles** that clearly indicate the spec content
2. **Add annotations** for additional context and links
3. **Set dependencies** when specs depend on other tasks
4. **Regular reviews** of `spec_state:review` and `spec_state:draft` tasks

### Configuration Management
1. **Backup before changes** to taskrc configuration
2. **Test new UDAs** with sample tasks before production use
3. **Document custom configurations** for team reference
4. **Use version control** for taskrc if collaborating

## Troubleshooting

### Common Issues

#### UDA Not Recognized
```bash
# Check if UDA is configured
task show | grep uda.<name>

# Reload configuration
task diagnostics
```

#### Colors Not Showing
```bash
# Check color support
task color

# Force color output
task specs --color
```

#### Report Not Working
```bash
# Check report configuration
task show | grep report.<name>

# Test with simple filter
task +spec
```

### Recovery
If configuration becomes corrupted:
```bash
# Restore from backup
cp /home/geert/.config/task/taskrc.backup /home/geert/.config/task/taskrc

# Verify data integrity
task export > tasks_backup.json
```

## Migration Notes

### Recent Changes
- **Added spec_state UDA** for specification workflow tracking
- **Migrated Task 38** from description-based state to proper UDA field
- **Added specs report** for dedicated specification viewing
- **Implemented color coding** for visual state distinction

### Data Migration
Task 38 was migrated from:
```
Description: "SPEC: IMP-7070 account-api UserRepository spec_state:draft"
```
To:
```
Description: "SPEC: IMP-7070 account-api UserRepository"
SpecState: "draft"
```

This migration enables proper filtering, sorting, and color coding for specification states.

## Future Enhancements

### Potential Improvements
1. **Automated state transitions** based on task status changes
2. **Integration with Git** for spec document versioning
3. **Custom urgency coefficients** for spec states
4. **Automated reporting** for spec workflow metrics
5. **Integration hooks** with external specification tools

### Suggested UDAs
```
# Spec complexity tracking
uda.spec_complexity.type=string
uda.spec_complexity.label=Complexity
uda.spec_complexity.values=high,medium,low,

# Spec review assignment
uda.spec_reviewer.type=string
uda.spec_reviewer.label=Reviewer

# Spec approval date
uda.spec_approved.type=date
uda.spec_approved.label=Approved
```

---

**Last Updated**: 2025-12-13  
**Taskwarrior Version**: 3.4.2  
**Configuration File**: `/home/geert/.config/task/taskrc`