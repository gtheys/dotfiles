#!/usr/bin/env bash
set -euo pipefail

THRESHOLD=${MIN_CHANGED_LINES:-70}

git fetch origin --prune
BASE=${BASE:-$(gh pr view --json baseRefName -q .baseRefName)}

# Generate coverage if missing
if [ ! -f coverage/cobertura-coverage.xml ]; then
  yarn test --coverage --coverageReporters=text --coverageReporters=cobertura
fi

echo "Comparing changed-lines coverage vs origin/$BASE with threshold ${THRESHOLD}%"
diff-cover coverage/cobertura-coverage.xml --compare-branch "origin/$BASE" --fail-under "${THRESHOLD}"

echo
echo "Files in diff:"
git diff --name-only "origin/$BASE"
