"""Erzeugt den Platzhalter-Helden (bis ein Figuren-Paket feststeht).

Ausgabe: assets/sprites/player/player_placeholder.png
Aufbau: Frames 32x48. Zeilen = Richtung (down, left, right, up),
Spalten = idle_0, idle_1, walk_0..walk_3.
Aufruf (aus dem Projektordner): python3 tools/build_player_placeholder.py
"""
from pathlib import Path

from PIL import Image

W, H = 32, 48
OUT = Path(__file__).resolve().parent.parent / "assets/sprites/player/player_placeholder.png"

C = {
    "outline": (43, 29, 26, 255),
    "skin": (232, 183, 150, 255),
    "skin_dark": (196, 140, 110, 255),
    "hair": (122, 74, 42, 255),
    "hair_light": (158, 102, 58, 255),
    "tunic": (47, 127, 134, 255),
    "tunic_light": (79, 166, 160, 255),
    "tunic_dark": (33, 92, 100, 255),
    "belt": (196, 154, 58, 255),
    "pants": (74, 59, 92, 255),
    "pants_dark": (52, 40, 68, 255),
    "boots": (78, 50, 36, 255),
    "eye": (30, 24, 30, 255),
}


def rect(img, x0, y0, x1, y1, color):
    """Gefülltes Rechteck inkl. x1/y1."""
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if 0 <= x < img.width and 0 <= y < img.height:
                img.putpixel((x, y), C[color])


def outline(img):
    px = img.load()
    edge = []
    for y in range(img.height):
        for x in range(img.width):
            if px[x, y][3] != 0:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < img.width and 0 <= ny < img.height and px[nx, ny][3] != 0 and px[nx, ny] != C["outline"]:
                    edge.append((x, y))
                    break
    for p in edge:
        px[p] = C["outline"]


# Beinphasen pro Frame: (Versatz links, Versatz rechts) – negativ = Bein angehoben/nach vorn
WALK_LEGS = [(0, 0), (-2, 1), (0, 0), (1, -2)]
WALK_BOB = [0, -1, 0, -1]
WALK_ARMS = [0, 2, 0, -2]
# Seitenansicht: Schrittweite der Beine nach vorn/hinten
SIDE_STRIDE = [0, 3, 0, -3]


def draw_front(img, back: bool, bob: int, legs, arms: int):
    o = bob
    # Beine
    ll, rl = legs
    rect(img, 11, 34 + o, 14, 42 + o + ll, "pants")
    rect(img, 11, 43 + o + ll, 14, 45 + o + ll, "boots")
    rect(img, 17, 34 + o, 20, 42 + o + rl, "pants")
    rect(img, 17, 43 + o + rl, 20, 45 + o + rl, "boots")
    # Arme (schwingen gegengleich)
    rect(img, 7, 21 + o, 8, 29 + o + arms, "tunic_dark")
    rect(img, 7, 30 + o + arms, 8, 31 + o + arms, "skin")
    rect(img, 23, 21 + o, 24, 29 + o - arms, "tunic_dark")
    rect(img, 23, 30 + o - arms, 24, 31 + o - arms, "skin")
    # Körper
    rect(img, 9, 20 + o, 22, 33 + o, "tunic")
    rect(img, 10, 21 + o, 12, 28 + o, "tunic_light")
    rect(img, 9, 30 + o, 22, 31 + o, "belt")
    if not back:
        rect(img, 15, 30 + o, 16, 31 + o, "outline")  # Kompass-Schnalle
    # Kopf
    rect(img, 10, 8 + o, 21, 19 + o, "skin")
    rect(img, 10, 18 + o, 21, 19 + o, "skin_dark")
    if back:
        rect(img, 9, 5 + o, 22, 18 + o, "hair")
        rect(img, 11, 6 + o, 15, 8 + o, "hair_light")
    else:
        rect(img, 9, 5 + o, 22, 10 + o, "hair")
        rect(img, 9, 11 + o, 10, 15 + o, "hair")
        rect(img, 21, 11 + o, 22, 15 + o, "hair")
        rect(img, 11, 6 + o, 15, 7 + o, "hair_light")
        rect(img, 13, 13 + o, 13, 15 + o, "eye")
        rect(img, 18, 13 + o, 18, 15 + o, "eye")


def draw_side(img, bob: int, stride: int, arms: int):
    """Blick nach rechts."""
    o = bob
    rl = stride
    # hinteres Bein (dunkler), vorderes Bein – Schritt nach vorn/hinten
    rect(img, 13 + rl, 34 + o, 16 + rl, 42 + o, "pants_dark")
    rect(img, 13 + rl, 43 + o, 17 + rl, 45 + o, "boots")
    rect(img, 15 - rl, 34 + o, 18 - rl, 42 + o, "pants")
    rect(img, 15 - rl, 43 + o, 19 - rl, 45 + o, "boots")
    # Körper
    rect(img, 11, 20 + o, 20, 33 + o, "tunic")
    rect(img, 12, 21 + o, 13, 28 + o, "tunic_light")
    rect(img, 11, 30 + o, 20, 31 + o, "belt")
    # Arm (schwingt gegen das vordere Bein)
    arms = -arms
    rect(img, 15 + arms, 21 + o, 17 + arms, 29 + o, "tunic_dark")
    rect(img, 15 + arms, 30 + o, 17 + arms, 31 + o, "skin")
    # Kopf
    rect(img, 11, 8 + o, 21, 19 + o, "skin")
    rect(img, 11, 18 + o, 21, 19 + o, "skin_dark")
    rect(img, 10, 5 + o, 21, 10 + o, "hair")
    rect(img, 10, 11 + o, 15, 16 + o, "hair")
    rect(img, 12, 6 + o, 16, 7 + o, "hair_light")
    rect(img, 22, 13 + o, 22, 15 + o, "skin")  # Nase
    rect(img, 19, 13 + o, 19, 15 + o, "eye")


def frame(direction: str, index: int) -> Image.Image:
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    if index < 2:  # idle: leichtes Atmen
        bob, legs, arms, stride = (0 if index == 0 else 1), (0, 0), 0, 0
        if bob:  # beim Atmen bleiben die Füße am Boden
            legs = (-1, -1)
    else:
        i = index - 2
        bob, legs, arms, stride = WALK_BOB[i], WALK_LEGS[i], WALK_ARMS[i], SIDE_STRIDE[i]
    if direction in ("down", "up"):
        draw_front(img, direction == "up", bob, legs, arms)
    else:
        draw_side(img, bob, stride, arms)
        if direction == "left":
            img = img.transpose(Image.FLIP_LEFT_RIGHT)
    outline(img)
    return img


def main():
    directions = ["down", "left", "right", "up"]
    sheet = Image.new("RGBA", (W * 6, H * len(directions)), (0, 0, 0, 0))
    for row, d in enumerate(directions):
        for col in range(6):
            sheet.paste(frame(d, col), (col * W, row * H))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(OUT)
    print(f"geschrieben: {OUT} ({sheet.width}x{sheet.height})")


if __name__ == "__main__":
    main()
