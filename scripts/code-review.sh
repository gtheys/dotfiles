git fetch origin --prune
BASE=$(gh pr view --json baseRefName -q .baseRefName)

opencode run "agent code-reviewer BASE is $BASE. Start by listing changed files using:
- git diff --name-status origin/$BASE...HEAD
- git diff --numstat origin/$BASE...HEAD
Then print the 'Changed Files' section (with totals) before the review."
