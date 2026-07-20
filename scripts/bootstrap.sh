#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for tool in swift git hdiutil codesign iconutil; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Missing required tool: $tool" >&2
        exit 1
    fi
done

cd "$ROOT"
swift run OssIslandCoreChecks
"$ROOT/scripts/create-dmg.sh"

echo
echo "Development setup is ready."
echo "Run: swift run OssIsland"
echo "Emit an event: swift run oss-island-event working --agent Codex --title 'Hello island'"
