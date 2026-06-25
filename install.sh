#!/usr/bin/env bash
# Install agents, rules, and skills from this repo into OpenCode.
# Usage:
#   bash install.sh              → global (~/.config/opencode/)
#   bash install.sh /my/project  → project-specific (.opencode/ + opencode.json)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "Usage: bash install.sh [TARGET]"
  echo ""
  echo "  (no argument)       Global install to ~/.config/opencode/"
  echo "  /path/to/project    Project-specific install to .opencode/"
  exit 1
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

if [[ $# -eq 0 ]]; then
  MODE="global"
  DEST="$HOME/.config/opencode"
  CONFIG="$DEST/opencode.jsonc"
elif [[ $# -eq 1 ]]; then
  MODE="project"
  PROJECT="$(cd "$1" && pwd)"
  DEST="$PROJECT/.opencode"
  CONFIG="$PROJECT/opencode.json"
else
  usage
fi

echo "→ Installing OpenCode Agent Suite ($MODE)"
echo "  Source:  $REPO_ROOT"
echo "  Target:  $DEST"
echo ""

mkdir -p "$DEST/agents" "$DEST/rules" "$DEST/skills"
[[ "$MODE" == "project" ]] && mkdir -p "$DEST/state"

echo "  Agents …"
cp -R "$REPO_ROOT/agents/"* "$DEST/agents/"

echo "  Rules …"
cp -R "$REPO_ROOT/rules/"* "$DEST/rules/"

echo "  Skills …"
rm -rf "$DEST/skills/"*
cp -R "$REPO_ROOT/skills/"* "$DEST/skills/"

if [[ "$MODE" == "global" ]]; then
  cp "$REPO_ROOT/templates/opencode.global.jsonc" "$CONFIG"
  cp "$REPO_ROOT/templates/AGENTS.md" "$DEST/AGENTS.md"
else
  cp "$REPO_ROOT/templates/opencode.project.json" "$CONFIG"
  if [[ ! -f "$PROJECT/AGENTS.md" ]]; then
    cp "$REPO_ROOT/templates/AGENTS.md" "$PROJECT/AGENTS.md"
    echo "  Created AGENTS.md (project root)"
  fi
fi

echo ""
echo "✓ Done. Restart OpenCode, then use @Coordinator."
echo ""
echo "  Agents: $(ls "$DEST/agents" | wc -l | tr -d ' ')  |  Rules: $(ls "$DEST/rules" | wc -l | tr -d ' ')  |  Skills: $(ls "$DEST/skills" | wc -l | tr -d ' ')"
