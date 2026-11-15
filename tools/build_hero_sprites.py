"""Kleidet den nackten Grundkörper „Body_A“ aus Pixel Crawler ein (nur Umfärben).

Die Animationen bleiben unverändert; Hautpixel werden je nach Höhe im Körper zu
Haaren, Tunika, Hose oder Stiefeln umgefärbt. Gesicht und Hände bleiben Haut.
Ausgabe: assets/sprites/hero/<animation>_<richtung>.png (Frames 64x64)
Aufruf (aus dem Projektordner): python3 tools/build_hero_sprites.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets/packs/pixel_crawler/Entities/Characters/Body_A/Animations"
OUT = ROOT / "assets/sprites/hero"
FRAME = 64

# Animation -> (Ordner, Dateiname je Richtung)
ANIMATIONS = {
    "idle": ("Idle_Base", {"down": "Idle_Down", "side": "Idle_Side", "up": "Idle_Up"}),
    "walk": ("Walk_Base", {"down": "Walk_Down", "side": "Walk_Side", "up": "Walk_Up"}),
    "run": ("Run_Base", {"down": "Run_Down", "side": "Run_Side", "up": "Run_Up"}),
    "slice": ("Slice_Base", {"down": "Slice_Down", "side": "Slice_Side", "up": "Slice_Up"}),
    "pierce": ("Pierce_Base", {"down": "Pierce_Down", "side": "Pierce_Side", "up": "Pierce_Top"}),
    "crush": ("Crush_Base", {"down": "Crush_Down", "side": "Crush_Side", "up": "Crush_Up"}),
    "hit": ("Hit_Base", {"down": "Hit_Down", "side": "Hit_Side", "up": "Hit_Up"}),
    "death": ("Death_Base", {"down": "Death_Down", "side": "Death_Side", "up": "Death_Up"}),
}

# Hautfarben des Grundkörpers, von hell nach dunkel
SKIN = [(250, 200, 149), (217, 160, 102), (162, 101, 67), (118, 61, 43)]

# Zielpaletten (gleiche Reihenfolge: Licht, Grundton, Schatten, Tiefschatten)
PALETTES = {
    "hair": [(150, 92, 52), (120, 70, 40), (86, 48, 30), (60, 32, 22)],
    "tunic": [(96, 180, 170), (58, 140, 140), (38, 100, 108), (26, 70, 80)],
    "belt": [(232, 196, 96), (196, 154, 58), (150, 110, 40), (110, 78, 30)],
    "pants": [(110, 92, 130), (84, 68, 104), (60, 47, 78), (42, 32, 56)],
    "boots": [(130, 90, 60), (100, 66, 44), (74, 46, 32), (52, 32, 22)],
}

# Zonen nach Zeilen ab Oberkante des Kopfes (stehende Figur, ca. 30 px hoch)
ZONES = [
    (0, 4, "hair"),     # Haaransatz
    (5, 11, None),      # Gesicht bleibt Haut
    (12, 19, "tunic"),
    (20, 20, "belt"),
    (21, 25, "pants"),
    (26, 99, "boots"),
]
# Blick nach oben: Hinterkopf komplett Haare
ZONES_UP = [(0, 11, "hair")] + ZONES[2:]
# Hände (seitlich am Körper) bleiben Haut: Spalten außerhalb dieses Bereichs um die Körpermitte
TORSO_HALF_WIDTH = 5


def zone_for(row: int, zones) -> str | None:
    for start, end, name in zones:
        if start <= row <= end:
            return name
    return None


# Kopf erkennen: erste Zeile mit so vielen Hautpixeln (Arme sind schmaler)
HEAD_MIN_WIDTH = 5


def _is_skin(p) -> bool:
    return p[3] > 0 and p[:3] in SKIN


def recolor_frame(frame: Image.Image, direction: str) -> Image.Image:
    px = frame.load()
    skin = [(x, y) for y in range(FRAME) for x in range(FRAME) if _is_skin(px[x, y])]
    if not skin:
        return frame
    xs = [x for x, _ in skin]
    ys = [y for _, y in skin]
    if max(xs) - min(xs) > (max(ys) - min(ys)) * 1.3:
        return _recolor_lying(frame, direction, min(xs), max(xs))
    row_width = {}
    for _, y in skin:
        row_width[y] = row_width.get(y, 0) + 1
    head_top = min(y for y, n in row_width.items() if n >= HEAD_MIN_WIDTH) - 1
    # Rumpfmitte aus den Zeilen unterhalb des Kopfes (ohne erhobene Arme)
    body_xs = [x for x, y in skin if head_top + 12 <= y <= head_top + 20]
    center = (min(body_xs) + max(body_xs)) // 2 if body_xs else (min(xs) + max(xs)) // 2
    zones = ZONES_UP if direction == "up" else ZONES
    out = frame.copy()
    opx = out.load()
    for y in range(FRAME):
        name = zone_for(y - head_top, zones)
        if name is None:
            continue
        for x in range(FRAME):
            p = px[x, y]
            if p[3] == 0 or p[:3] not in SKIN:
                continue
            # Hände/Unterarme neben dem Rumpf bleiben Haut (nur in Tunika-/Gürtelhöhe)
            if name in ("tunic", "belt") and abs(x - center) > TORSO_HALF_WIDTH and y - head_top >= 16:
                continue
            shade = SKIN.index(p[:3])
            opx[x, y] = PALETTES[name][shade] + (p[3],)
    return out


# Liegende Figur (Tod): Kopf liegt in Blickrichtung, Rest wird Kleidung
LYING_HEAD_WIDTH = 9


def _recolor_lying(frame: Image.Image, direction: str, x_min: int, x_max: int) -> Image.Image:
    out = frame.copy()
    px = out.load()
    head_on_right = direction != "up"
    for y in range(FRAME):
        for x in range(FRAME):
            p = px[x, y]
            if not _is_skin(p):
                continue
            from_head = (x_max - x) if head_on_right else (x - x_min)
            if from_head < LYING_HEAD_WIDTH:
                name = "hair" if from_head < 3 else None
            elif from_head < LYING_HEAD_WIDTH + 8:
                name = "tunic"
            elif from_head < LYING_HEAD_WIDTH + 13:
                name = "pants"
            else:
                name = "boots"
            if name:
                px[x, y] = PALETTES[name][SKIN.index(p[:3])] + (p[3],)
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for anim, (folder, files) in ANIMATIONS.items():
        for direction, name in files.items():
            sheet = Image.open(SRC / folder / f"{name}-Sheet.png").convert("RGBA")
            out = Image.new("RGBA", sheet.size, (0, 0, 0, 0))
            for i in range(sheet.width // FRAME):
                frame = sheet.crop((i * FRAME, 0, (i + 1) * FRAME, FRAME))
                out.paste(recolor_frame(frame, direction), (i * FRAME, 0))
            out.save(OUT / f"{anim}_{direction}.png")
    print(f"Held-Sprites geschrieben nach {OUT}")


if __name__ == "__main__":
    main()
