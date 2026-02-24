#!/bin/bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: scripts/check-links.sh

Validates internal Markdown links in tracked *.md files.

- Checks local file paths like (docs/foo.md) and (../bar.md#section)
- Ignores external links (http/https/mailto) and anchors-only links (#section)
EOF
  exit 0
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

failures=0

while IFS= read -r file; do
  while IFS= read -r raw; do
    target="$raw"

    target="${target#${target%%[![:space:]]*}}"
    target="${target%${target##*[![:space:]]}}"

    if [[ -z "$target" ]]; then
      continue
    fi

    target="${target%%[[:space:]]*}"

    target="${target#\"}"
    target="${target%\"}"

    if [[ "$target" =~ ^https?:// ]] || [[ "$target" =~ ^mailto: ]]; then
      continue
    fi

    if [[ "$target" =~ ^# ]]; then
      continue
    fi

    target_path="${target%%#*}"
    target_path="${target_path%%\?*}"

    if [[ "$target_path" =~ :// ]]; then
      continue
    fi

    base_dir="$(cd "$(dirname "$file")" && pwd)"
    abs_target="$base_dir/$target_path"

    if ! abs_target="$(python3 - "$abs_target" <<'PY'
import os
import sys
import urllib.parse

if len(sys.argv) < 2:
    raise SystemExit(2)

raw = urllib.parse.unquote(sys.argv[1])
print(os.path.normpath(raw))
PY
)"; then
      echo "[link-check] ERROR: failed to normalize path: $file -> $target" >&2
      failures=$((failures + 1))
      continue
    fi

    if [[ ! -e "$abs_target" ]]; then
      echo "[link-check] MISSING: $file -> $target" >&2
      failures=$((failures + 1))
    fi
  done < <(
    python3 - "$file" <<'PY'
import re
import sys

if len(sys.argv) < 2:
    raise SystemExit(2)

path = sys.argv[1]
text = open(path, 'r', encoding='utf-8', errors='replace').read()

fenced = re.compile(r'(^|\n)(```|~~~)[^\n]*\n.*?\n\2\s*(\n|$)', re.DOTALL)
text = fenced.sub('\n', text)

inline_code = re.compile(r'`[^`]*`')
text = inline_code.sub('', text)

pattern = re.compile(r'(?<!\!)\[[^\]]*\]\(([^)]+)\)')

for m in pattern.finditer(text):
    print(m.group(1).strip())
PY
  )

done < <(
  git ls-files \
    'README*.md' \
    'CHANGELOG.md' \
    'AGENTS.md' \
    'docs/**/*.md'
)

if [[ $failures -gt 0 ]]; then
  echo "[link-check] FAILED: $failures missing link target(s)" >&2
  exit 1
fi

echo "[link-check] OK"
