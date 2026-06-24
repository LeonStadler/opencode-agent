#!/usr/bin/env bash
# Entfernt die via install.sh installierten Agents, Rules und Skills.
# Usage:
#   bash uninstall.sh              → global (~/.config/opencode/)
#   bash uninstall.sh /mein/projekt → projektspezifisch (.opencode/ + opencode.json)

set -euo pipefail

usage() {
  echo "Usage: bash uninstall.sh [ZIEL]"
  echo ""
  echo "  (kein Argument)     Global aus ~/.config/opencode/ entfernen"
  echo "  /pfad/zu/projekt    Projektspezifisch aus .opencode/ entfernen"
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

echo "→ Deinstalliere OpenCode Agent Suite ($MODE)"
echo "  Ziel: $DEST"
echo ""

if [[ "$MODE" == "global" ]]; then
  rm -rf "$DEST/agents" "$DEST/rules" "$DEST/skills"
  rm -f "$DEST/AGENTS.md"

  cat > "$CONFIG" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json"
}
EOF

  echo "  agents/, rules/, skills/, AGENTS.md entfernt"
  echo "  opencode.jsonc zurückgesetzt"
else
  rm -rf "$DEST"
  rm -f "$CONFIG"
  echo "  .opencode/ und opencode.json entfernt"
fi

echo ""
echo "✓ Fertig. OpenCode neu starten, dann bash install.sh für saubere Neuinstallation."
