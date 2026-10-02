#!/bin/bash
set -euo pipefail

if [ -z "${1:-}" ] || [[ "$1" =~ ^[[:space:]]*$ ]]; then
    echo "Error: Skill name must be a non-empty, non-whitespace value" >&2
    exit 1
fi

name="$1"
mkdir -p "$name"

if ! [ -f "$name/SKILL.md" ]; then
    cat > "$name/SKILL.md" <<EOF
---
name: $name
description: something. Use when something.
license: MIT
user-invocable: true
metadata:
  deprecated: no
---

EOF
    echo "Created new skill: $name/SKILL.md"
else
    echo "File $name/SKILL.md already exists"
fi
