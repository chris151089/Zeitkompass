"""Prüft Screenshots auf pixelgenaue ganzzahlige Skalierung der internen Auflösung 320x180.

Jeder interne Pixel muss im Screenshot ein gleichfarbiger Block von Faktor x Faktor Pixeln sein,
der Bereich außerhalb des Spielbilds schwarz. Aufruf: python3 check_scaling.py shot1.png ...
"""
import sys

from PIL import Image

BASE_W, BASE_H = 320, 180
BORDER_COLOR = (242, 193, 78)  # 1-px-Rahmen des Testbilds


def check(path: str) -> bool:
    im = Image.open(path).convert("RGB")
    w, h = im.size
    f = max(1, min(w // BASE_W, h // BASE_H))
    ox, oy = (w - BASE_W * f) // 2, (h - BASE_H * f) // 2
    px = im.load()
    bad = 0
    for by in range(BASE_H):
        for bx in range(BASE_W):
            x0, y0 = ox + bx * f, oy + by * f
            c = px[x0, y0]
            for dy in range(f):
                for dx in range(f):
                    if px[x0 + dx, y0 + dy] != c:
                        bad += 1
    border_ok = px[ox, oy] == BORDER_COLOR and px[ox + BASE_W * f - 1, oy + BASE_H * f - 1] == BORDER_COLOR
    margins_black = all(
        px[x, y] == (0, 0, 0)
        for x, y in [(0, 0), (w - 1, h - 1)]
        if ox > 0 or oy > 0
    )
    ok = bad == 0 and border_ok and margins_black
    print(f"{'OK ' if ok else 'FEHLER'} {path}: {w}x{h}, Faktor {f}, Rand ({ox},{oy}), "
          f"uneinheitliche Pixel {bad}, Rahmen {'ok' if border_ok else 'falsch'}")
    return ok


if __name__ == "__main__":
    results = [check(p) for p in sys.argv[1:]]
    sys.exit(0 if results and all(results) else 1)
