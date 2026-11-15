#!/usr/bin/env bash
# Führt alle GUT-Tests headless aus.  Nutzung: ./run_tests.sh   (GODOT=/pfad/zu/godot ./run_tests.sh)
# Schlägt auch fehl, wenn ein Skript nicht kompiliert – GUT überspringt solche Testdateien sonst stillschweigend.
set -uo pipefail
cd "$(dirname "$0")"
GODOT="${GODOT:-godot}"
# Beim ersten Lauf (oder nach neuen class_names) muss importiert werden.
"$GODOT" --headless --import >/dev/null 2>&1 || true
mkdir -p test_results
LOG=test_results/gut_output.txt
"$GODOT" --headless -s res://addons/gut/gut_cmdln.gd -gexit "$@" 2>&1 | tee "$LOG"
status=${PIPESTATUS[0]}
if grep -qE "SCRIPT ERROR|Parse Error|Failed to load script" "$LOG"; then
	echo "FEHLER: Skriptfehler gefunden (siehe oben) – Tests gelten als fehlgeschlagen." >&2
	exit 1
fi
exit "$status"
