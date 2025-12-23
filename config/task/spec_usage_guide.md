# Taskwarrior Spec State Usage Guide

## Quick Start

### View All Specifications
```bash
task specs
```

### Add New Specification
```bash
task add "New API spec" project:account-api +spec
```

### Update Spec State
```bash
task 38 modify spec_state:review
```

## Complete Usage Guide

## 1. Specification Workflow States

### State Definitions
- **`draft`** (Blue) - Initial specification, work in progress
- **`review`** (Yellow) - Ready for team review and feedback
- **`approved`** (Green) - Approved and ready for implementation
- **`stale`** (Red) - Outdated, needs revision or archiving

### State Transitions
```
draft → review → approved
  ↓         ↓
 stale ←─────┘
```

## 2. Daily Operations

### Morning Review
```bash
# Check specs needing attention
task +spec spec_state:review or spec_state:draft

# View all specs by priority
task specs
```

### Adding New Specs
```bash
# Basic spec (defaults to draft)
task add "User authentication spec" project:auth +spec

# Spec with due date
task add "Payment processing spec" project:payments +spec due:2025-12-20

# Spec with high priority
task add "Security audit spec" project:security +spec priority:H
```

### Updating Spec Progress
```bash
# Move to review
task 38 modify spec_state:review

# Approve spec
task 38 modify spec_state:approved

# Mark as stale (needs revision)
task 38 modify spec_state:stale

# Return to draft for revision
task 38 modify spec_state:draft
```

## 3. Reporting and Filtering

### View All Specifications
```bash
# Custom specs report with color coding
task specs

# Standard view with all details
task +spec

# Compact view
task +spec ls
```

### Filter by State
```bash
# Draft specs (work in progress)
task spec_state:draft

# Specs under review
task spec_state:review

# Approved specs (ready for implementation)
task spec_state:approved

# Stale specs (need attention)
task spec_state:stale
```

### Filter by Project
```bash
# Account API specs
task +spec project:account-api

# Backend specs
task +spec project:backend

# Frontend specs
task +spec project:frontend
```

### Combined Filters
```bash
# High priority specs needing review
task +spec priority:H spec_state:review

# Draft specs due this week
task +spec spec_state:draft due:today+7d

# Overdue specs
task +spec +OVERDUE

# Specs by specific reviewer (if using reviewer UDA)
task +spec reviewer:john.doe
```

## 4. Advanced Workflows

### Specification Review Process
```bash
# 1. Create spec
task add "New feature spec" project:feature +spec

# 2. Move to review when ready
task <id> modify spec_state:review

# 3. Assign reviewer (optional)
task <id> modify reviewer:team.lead

# 4. Approve after review
task <id> modify spec_state:approved

# 5. Link to implementation tasks
task <implementation_id> modify depends:<spec_id>
```

### Batch Operations
```bash
# Mark multiple specs as approved
task spec_state:review modify spec_state:approved

# Add due date to all draft specs
task spec_state:draft modify due:2025-12-31

# Set high priority for all specs in critical project
task +spec project:critical modify priority:H
```

### Specification Metrics
```bash
# Count specs by state
task spec_state:draft count
task spec_state:review count
task spec_state:approved count
task spec_state:stale count

# Total specs
task +spec count

# Specs by project
task +spec project:account-api count
task +spec project:backend count
```

## 5. Integration with Jira

### Working with Jira-Synced Tasks
```bash
# View all Jira tasks
task export | jq '.[] | select(.jiraid)'

# Add spec state to Jira task
task <jira_task_id> modify +spec spec_state:draft

# View Jira specs
task +spec export | jq '.[] | {id, description, jiraid, spec_state}'
```

### Jira Spec Workflow
```bash
# Jira task becomes spec
task <jira_id> modify +spec spec_state:draft

# Sync spec state with Jira status
task <jira_id> modify spec_state:review  # When Jira status = "In Review"
task <jira_id> modify spec_state:approved  # When Jira status = "Done"
```

## 6. Team Collaboration

### Review Assignment
```bash
# Assign reviewer (if reviewer UDA is configured)
task 38 modify reviewer:alice

# View specs assigned to you
task +spec reviewer:your.name

# View specs you're reviewing
task +spec reviewer:your.name spec_state:review
```

### Comment and Annotation
```bash
# Add review comment
task 38 annotate "Reviewed by Alice: Looks good, need security section"

# Add specification link
task 38 annotate "Spec document: https://docs.company.com/specs/38"

# View all annotations
task 38 info
```

## 7. Automation and Scripts

### Daily Status Script
```bash
#!/bin/bash
# daily_spec_status.sh

echo "=== Specification Status Report ==="
echo "Draft specs: $(task spec_state:draft count)"
echo "Under review: $(task spec_state:review count)"
echo "Approved: $(task spec_state:approved count)"
echo "Stale: $(task spec_state:stale count)"
echo ""
echo "=== Specs Needing Attention ==="
task +spec spec_state:review or spec_state:draft
```

### Weekly Review Script
```bash
#!/bin/bash
# weekly_spec_review.sh

echo "=== Weekly Specification Review ==="
echo "All specs by state:"
task specs
echo ""
echo "Stale specs (need revision):"
task spec_state:stale
echo ""
echo "Overdue specs:"
task +spec +OVERDUE
```

## 8. Best Practices

### Specification Creation
1. **Always use `+spec` tag** for proper categorization
2. **Set meaningful project** for organization
3. **Add due dates** for time-sensitive specs
4. **Use clear, descriptive titles**
5. **Include relevant links** in annotations

### State Management
1. **Keep specs in `draft`** until ready for review
2. **Move to `review`** when seeking feedback
3. **Use `approved`** only when fully ready
4. **Mark as `stale`** when outdated or superseded

### Team Workflow
1. **Regular reviews** of `spec_state:review` tasks
2. **Weekly cleanup** of `spec_state:stale` tasks
3. **Monthly audit** of all specifications
4. **Documentation updates** when processes change

## 9. Troubleshooting

### Common Issues

#### Spec Not Showing in Report
```bash
# Check if task has spec tag
task <id> info | grep Tags

# Add spec tag if missing
task <id> modify +spec
```

#### State Not Updating
```bash
# Check current state
task <id> info | grep SpecState

# Force state update
task <id> modify spec_state:draft
```

#### Colors Not Displaying
```bash
# Force color output
task specs --color

# Check terminal color support
echo $TERM
```

### Recovery Commands
```bash
# View all spec tasks with details
task +spec export

# Reset spec state
task <id> modify spec_state:

# Check configuration
task show | grep spec_state
```

## 10. Keyboard Shortcuts and Aliases

### Useful Aliases (add to .bashrc or .zshrc)
```bash
# Quick spec commands
alias specs='task specs'
alias draft='task spec_state:draft'
alias review='task spec_state:review'
alias approved='task spec_state:approved'
alias stale='task spec_state:stale'

# Project-specific specs
alias auth-specs='task +spec project:auth'
alias api-specs='task +spec project:account-api'
alias frontend-specs='task +spec project:frontend'

# Quick state updates
alias to-review='task modify spec_state:review'
alias approve='task modify spec_state:approved'
```

### Quick Reference
```bash
# View this help
task --help | grep -A 5 -B 5 spec

# Quick spec status
task +spec count

# Today's spec activity
task +spec end:today
```

---

**Remember**: The key to effective specification management is regular state updates and consistent tagging. Make it a habit to update spec states as part of your daily workflow!