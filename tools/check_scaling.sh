#!/usr/bin/env bash
# Startet das Testbild auf einem virtuellen Bildschirm (Xvfb) in mehreren Auflösungen,
# macht Screenshots und prüft, dass ganzzahlig und pixelgenau skaliert wird.
# Benötigt: Xvfb, ImageMagick (import), Python 3 mit Pillow.
# Nutzung: GODOT=/pfad/zu/godot tools/check_scaling.sh [Ausgabeordner]
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
OUT="${1:-test_results/scaling}"
mkdir -p "$OUT"
RESOLUTIONS=(1920x1080 2560x1440 3840x2160 1366x768)

for r in "${RESOLUTIONS[@]}"; do
	Xvfb :99 -screen 0 "${r}x24" >/dev/null 2>&1 &
	xvfb_pid=$!
	sleep 1
	DISPLAY=:99 "$GODOT" --path . --resolution "$r" --position 0,0 >"$OUT/godot_$r.log" 2>&1 &
	godot_pid=$!
	sleep "${WAIT_SECONDS:-8}"
	DISPLAY=:99 import -window root "$OUT/shot_$r.png"
	kill "$godot_pid" "$xvfb_pid" 2>/dev/null || true
	wait "$godot_pid" "$xvfb_pid" 2>/dev/null || true
done

python3 tools/check_scaling.py "$OUT"/shot_*.png
