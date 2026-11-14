#!/usr/bin/env bash
# Führt alle GUT-Tests headless aus.  Nutzung: ./run_tests.sh   (GODOT=/pfad/zu/godot ./run_tests.sh)
set -euo pipefail
cd "$(dirname "$0")"
GODOT="${GODOT:-godot}"
# Beim ersten Lauf (oder nach neuen class_names) muss importiert werden.
"$GODOT" --headless --import >/dev/null 2>&1 || true
mkdir -p test_results
exec "$GODOT" --headless -s res://addons/gut/gut_cmdln.gd -gexit "$@"
