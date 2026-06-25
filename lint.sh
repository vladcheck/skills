#!/usr/bin/env bash
set -euo pipefail

SKILL_FILE="${1:-SKILL.md}"

# Extract YAML frontmatter
extract_frontmatter() {
  sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | sed '1d;$d'
}

# Validate name field
validate_name() {
  local name
  name=$(extract_frontmatter | grep "^name:" | sed 's/name: *//' | tr -d '"')
  if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "✗ Invalid name format: '$name'"
    return 1
  fi
  echo "✓ Name valid: $name"
}

# Validate description field
validate_description() {
  local desc
  desc=$(extract_frontmatter | grep "^description:" | sed 's/description: *//' | tr -d '"')
  local len=${#desc}
  if [ "$len" -lt 1 ] || [ "$len" -gt 1024 ]; then
    echo "✗ Description length invalid: $len chars (must be 1-1024)"
    return 1
  fi
  echo "✓ Description valid: $len chars"
}

# Check required fields
validate_required() {
  local fm
  fm=$(extract_frontmatter)
  if ! echo "$fm" | grep -q "^name:"; then
    echo "✗ Missing required field: name"
    return 1
  fi
  if ! echo "$fm" | grep -q "^description:"; then
    echo "✗ Missing required field: description"
    return 1
  fi
  echo "✓ Required fields present"
}

# Check directory name matches skill name
validate_dir_match() {
  local name dir
  name=$(extract_frontmatter | grep "^name:" | sed 's/name: *//' | tr -d '"')
  dir=$(basename "$(dirname "$SKILL_FILE")")
  if [ "$name" != "$dir" ]; then
    echo "⚠ Warning: skill name '$name' does not match directory '$dir'"
  else
    echo "✓ Name matches directory"
  fi
}

# Run all checks
echo "Linting: $SKILL_FILE"
validate_required || exit 1
validate_name || exit 1
validate_description || exit 1
validate_dir_match
echo "✓ All checks passed"
