# Exit immediately if a command exits with a non-zero status.
set -e

DRY_RUN=false

# Check for the --dry-run argument.
for arg in "$@"; do
  if [ "$arg" == "--dry-run" ]; then
    DRY_RUN=true
  fi
done

# Determine the target branch for comparison.
TARGET_BRANCH="origin/${GITHUB_BASE_REF:-main}"

# Find the merge base to accurately get the diff.
MERGE_BASE=$(git merge-base HEAD "$TARGET_BRANCH")

# Get a newline-separated list of changed files.
CHANGED_FILES_LIST=$(git diff --name-only "$MERGE_BASE" HEAD | grep -E '\.(js|jsx|ts|tsx)$' || true)

echo "✨ Changed files:"
echo "$CHANGED_FILES_LIST"

# Check if any relevant files have changed.
if [ -z "$CHANGED_FILES_LIST" ]; then
  echo "✅ No relevant file changes to test."
  exit 0
fi

# Build the arguments for --collectCoverageFrom.
COVERAGE_ARGS=()
for file in $CHANGED_FILES_LIST; do
  COVERAGE_ARGS+=("--collectCoverageFrom=$file")
done

# Print Jest command for dry-run mode.
if $DRY_RUN; then
  echo "DRY RUN: Jest would run the following command:"
  echo "yarn jest --findRelatedTests $CHANGED_FILES_LIST --coverage ${COVERAGE_ARGS[@]} --passWithNoTests"
  exit 0
fi

# Run Jest, now properly scoped if not in dry-run mode.
echo "🔍 Scoping tests to changed files..."
yarn jest --findRelatedTests $CHANGED_FILES_LIST \
  --coverage \
  "${COVERAGE_ARGS[@]}" \
  --passWithNoTests
