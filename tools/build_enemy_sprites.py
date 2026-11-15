"""Bringt Gegner-Sprites aus Pixel Crawler auf einheitliche 64x64-Zellen mit gemeinsamem Fußpunkt.

Quelle: Idle-Frames sind 32x32, Run/Death 64x64 – Füße jeweils an der Unterkante, Blick nach rechts.
Ausgabe: assets/sprites/enemies/<name>/<anim>.png, Fußpunkt jeder Zelle bei (32, 60).
Aufruf (aus dem Projektordner): python3 tools/build_enemy_sprites.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MOBS = ROOT / "assets/packs/pixel_crawler/Entities/Mobs"
OUT = ROOT / "assets/sprites/enemies"
CELL = 64
FOOT = (32, 60)

ENEMIES = {
    "orc": MOBS / "Orc Crew/Orc",
    "skeleton": MOBS / "Skeleton Crew/Skeleton - Base",
}
ANIMS = {"idle": "Idle", "run": "Run", "death": "Death"}


def convert(src: Path, dst: Path) -> None:
    sheet = Image.open(src).convert("RGBA")
    size = sheet.height  # quadratische Frames
    count = sheet.width // size
    out = Image.new("RGBA", (CELL * count, CELL), (0, 0, 0, 0))
    for i in range(count):
        frame = sheet.crop((i * size, 0, (i + 1) * size, size))
        # Bildmitte unten -> Fußpunkt
        out.paste(frame, (i * CELL + FOOT[0] - size // 2, FOOT[1] - size), frame)
    dst.parent.mkdir(parents=True, exist_ok=True)
    out.save(dst)


def main() -> None:
    for name, folder in ENEMIES.items():
        for anim, src_name in ANIMS.items():
            convert(folder / src_name / f"{src_name}-Sheet.png", OUT / name / f"{anim}.png")
    print(f"Gegner-Sprites geschrieben nach {OUT}")


if __name__ == "__main__":
    main()
