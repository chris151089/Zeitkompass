"""Zeichnet kleine UI-Grafiken (Herzen für die Lebensanzeige), passend zur 16er-Pixelgröße.

Ausgabe: assets/sprites/ui/hearts.png – 3 Frames à 9x8: voll, halb, leer.
Aufruf (aus dem Projektordner): python3 tools/build_ui_sprites.py
"""
from pathlib import Path

from PIL import Image

OUT = Path(__file__).resolve().parent.parent / "assets/sprites/ui/hearts.png"
# . leer, o Umriss, r Rot, h Glanz, d dunkel (leeres Herz)
HEART = [
    ".oo...oo.",
    "orroooro.",
    "orhrrrrro",
    "orrrrrrro",
    ".orrrrro.",
    "..orrro..",
    "...oro...",
    "....o....",
]
COLORS = {
    "o": (40, 22, 30, 255),
    "r": (214, 52, 64, 255),
    "h": (255, 170, 170, 255),
    "d": (88, 62, 72, 255),
}


def draw(fill_left: bool, fill_right: bool) -> Image.Image:
    img = Image.new("RGBA", (9, 8), (0, 0, 0, 0))
    for y, row in enumerate(HEART):
        for x, ch in enumerate(row):
            if ch == ".":
                continue
            if ch in "rh":
                filled = fill_left if x <= 4 else fill_right
                ch = ch if filled else "d"
            img.putpixel((x, y), COLORS[ch])
    return img


def main() -> None:
    sheet = Image.new("RGBA", (27, 8), (0, 0, 0, 0))
    for i, (left, right) in enumerate([(True, True), (True, False), (False, False)]):
        sheet.paste(draw(left, right), (i * 9, 0))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(OUT)
    print(f"geschrieben: {OUT}")


if __name__ == "__main__":
    main()
