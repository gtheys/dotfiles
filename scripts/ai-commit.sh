#!/usr/bin/env bash
set -euo pipefail

branch=$(git rev-parse --abbrev-ref HEAD)
jira=$(echo "$branch" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | head -1 || true)

diff=$(git diff --cached)
if [ -z "$diff" ]; then
  echo "No staged changes." >&2
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
has_commitlint=false
rules=""

for cfg in commitlint.config.js commitlint.config.cjs commitlint.config.mjs \
  commitlint.config.ts .commitlintrc.js .commitlintrc.cjs \
  .commitlintrc.json .commitlintrc.yml .commitlintrc.yaml .commitlintrc; do
  if [ -f "$repo_root/$cfg" ]; then
    has_commitlint=true
    rules=$(cat "$repo_root/$cfg")
    break
  fi
done

if [ "$has_commitlint" = false ] && [ -f "$repo_root/package.json" ]; then
  if grep -q '"commitlint"' "$repo_root/package.json" 2>/dev/null; then
    has_commitlint=true
    rules=$(cat "$repo_root/package.json")
  fi
fi

llm_args=(-t commit --model claude-haiku-4.5)
[ -n "$jira" ] && llm_args+=(-p jira "$jira")
[ -n "$rules" ] && llm_args+=(-p rules "$rules")

msg=$(echo "$diff" | llm "${llm_args[@]}")

tmpfile=$(mktemp --suffix=.gitcommit)
echo "$msg" >"$tmpfile"

${EDITOR:-nvim} "$tmpfile"

if [ "$has_commitlint" = true ]; then
  echo "commitlint config detected — validating message..."
  if npx --no-install commitlint --edit "$tmpfile"; then
    git commit -F "$tmpfile"
  else
    echo "❌ commitlint failed, aborting. Message was:" >&2
    cat "$tmpfile" >&2
    rm -f "$tmpfile"
    exit 1
  fi
else
  echo "No commitlint config found — skipping validation."
  git commit -F "$tmpfile"
fi

rm -f "$tmpfile"
git log --oneline -n 5
