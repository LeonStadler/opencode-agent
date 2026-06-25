#!/usr/bin/env bash
# Remove agents, rules, and skills installed via install.sh.
# Usage:
#   bash uninstall.sh              → global (~/.config/opencode/)
#   bash uninstall.sh /my/project  → project-specific (.opencode/ + opencode.json)

set -euo pipefail

usage() {
  echo "Usage: bash uninstall.sh [TARGET]"
  echo ""
  echo "  (no argument)       Remove from ~/.config/opencode/"
  echo "  /path/to/project    Remove from .opencode/"
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

echo "→ Uninstalling OpenCode Agent Suite ($MODE)"
echo "  Target: $DEST"
echo ""

if [[ "$MODE" == "global" ]]; then
  rm -rf "$DEST/agents" "$DEST/rules" "$DEST/skills"
  rm -f "$DEST/AGENTS.md"

  cat > "$CONFIG" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json"
}
EOF

  echo "  Removed agents/, rules/, skills/, AGENTS.md"
  echo "  Reset opencode.jsonc"
else
  rm -rf "$DEST"
  rm -f "$CONFIG"
  echo "  Removed .opencode/ and opencode.json"
fi

echo ""
echo "✓ Done. Restart OpenCode, then run bash install.sh for a clean reinstall."
