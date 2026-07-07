#!/bin/bash
set -euo pipefail

name="${1:-Skill name must be specified}"
mkdir -p "$name"

if ! [ -f "$name/SKILL.md" ]; then
echo "---
name: $name
description: something. Use when something.
license: MIT
user-invocable: true
metadata:
  deprecated: no
---

" > "$name/SKILL.md"
	echo "Created new skill: $name/SKILL.md"
else
	echo "File $name/SKILL.md already exists"
fi
