#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
README="${REPO_ROOT}/README.md"
DIAGRAM="${REPO_ROOT}/.diagram-generated.mmd"

# Generate diagram via nix
nix eval --raw .#diagrams-mermaid > "$DIAGRAM"

awk '
  /^<!-- BEGIN:AUTO-GENERATED -->$/ {
    print;
    print "```mermaid";
    while ((getline line < "'"$DIAGRAM"'") > 0) {
      print "    " line;
    }
    close("'"$DIAGRAM"'");
    print "```";
    while ((getline) > 0) {
      if (/^<!-- END:AUTO-GENERATED -->$/) {
        print;
        break;
      }
    }
    next;
  }
  { print }
' "$README" > "${README}.tmp" && mv "${README}.tmp" "$README"

rm -f "$DIAGRAM"
echo "✓ README.md diagram updated"