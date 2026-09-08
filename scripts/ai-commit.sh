#!/usr/bin/env bash
set -euo pipefail

branch=$(git rev-parse --abbrev-ref HEAD)
jira=$(echo "$branch" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | head -1 || true)

diff=$(git diff --cached)
if [ -z "$diff" ]; then
  echo "No staged changes." >&2
  exit 1
fi

# ponytail: doc-only commits send headings + stat — 7b fixates on full doc body and reports described plan as done work
staged_files=$(git diff --cached --name-only)
if ! echo "$staged_files" | grep -qvE '\.(md|txt|rst|adoc|ad)$'; then
  outline=$(git diff --cached -U0 -- . | grep -E '^(diff --git|@@|\+#{1,3} )' | head -80)
  diff="Only these documentation files changed (describe the doc change — what was added/edited/removed — NOT the topic the docs discuss). Write a 2-4 line body listing what each file adds or edits:
$outline

$(git diff --cached --stat)"
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

llm_args=(-t commit -m qwen -p jira "$jira" -p rules "$rules" -o temperature 0.1)

clean_msg() {
  sed -e '/^```/d' -e 's/^markdown$//' | sed -e '/./,$!d'
}

valid_subject() {
  # ponytail: 7b flaky on format; regex-check subject AND require body so retries catch it before the editor does
  local subj body
  subj=$(head -1)
  echo "$subj" | grep -qE '^(feat|fix|refactor|docs|test|chore|perf|ci|build|revert|style)(\([a-z0-9._/-]+\))?: .+' || return 1
  body=$(tail -n +2 | sed '/^Refs:/d' | grep -c '.')
  [ "$body" -ge 1 ]
}

# ponytail: retry up to 3x — small model ~50% format compliance on large doc diffs
msg=""
for attempt in 1 2 3; do
  msg=$(echo "$diff" | llm "${llm_args[@]}" | clean_msg)
  if echo "$msg" | valid_subject; then
    break
  fi
  echo "attempt $attempt: bad format, retrying..." >&2
done
echo "$msg" | valid_subject || echo "⚠️ model output bad format after retries — fix in editor" >&2

if [ -n "$jira" ] && ! echo "$msg" | grep -q "Refs: $jira"; then
  msg="${msg}

Refs: $jira"
fi

# ponytail: 7b drops body ~randomly even at temp 0.1; deterministic fallback — file list is always truthful
body_lines=$(echo "$msg" | tail -n +2 | sed '/^Refs:/d' | grep -c '.' || true)
if [ "$body_lines" -lt 1 ]; then
  fallback=$(git diff --cached --name-status | sed -e 's/^A\t/- Added /' -e 's/^M\t/- Updated /' -e 's/^D\t/- Deleted /' -e 's/^R[0-9]*\t[^\t]*\t/- Renamed /')
  msg="${msg}

${fallback}"
fi

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
