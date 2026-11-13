#!/usr/bin/env python3
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops

PRIMARY = (0x23, 0x6B, 0x40, 255)
PRIMARY_DARK = (0x18, 0x4F, 0x2E, 255)
ACCENT = (0xF5, 0x7C, 0x00, 255)
WHITE = (255, 255, 255, 255)

CANVAS = 1024
SAFE = CANVAS * 72 / 108
DISC = SAFE * 0.96
PIN = DISC * 100 / 120
STAR_D = DISC * 20 / 120
STAR_ICON = STAR_D * 12 / 20
DISC_LEFT = (CANVAS - DISC) / 2
STAR_TOP = (CANVAS - DISC) / 2 + DISC * 10 / 120
STAR_RIGHT = (CANVAS - DISC) / 2 + DISC * 20 / 120
STAR_LEFT = CANVAS - STAR_RIGHT - STAR_D


def quad_points(p0, p1, p2, steps=80):
    pts = []
    for i in range(steps + 1):
        t = i / steps
        mt = 1 - t
        pts.append((
            mt * mt * p0[0] + 2 * mt * t * p1[0] + t * t * p2[0],
            mt * mt * p0[1] + 2 * mt * t * p1[1] + t * t * p2[1],
        ))
    return pts


def pin_polygon(cx, cy, size):
    ox, oy = cx - size / 2, cy - size / 2

    def P(x, y):
        return (ox + x, oy + y)

    w = h = size
    pts = [P(w / 2, h * 0.1), P(w * 0.85, h * 0.3)]
    pts += quad_points(P(w * 0.85, h * 0.3), P(w * 0.9, h * 0.5), P(w * 0.85, h * 0.7))
    pts += [P(w / 2, h * 0.9), P(w * 0.15, h * 0.7)]
    pts += quad_points(P(w * 0.15, h * 0.7), P(w * 0.1, h * 0.5), P(w * 0.15, h * 0.3))
    return pts, ox, oy


def draw_star(draw, cx, cy, r, fill):
    inner = r * 0.4
    pts = []
    for i in range(10):
        ang = math.radians(-90 + i * 36)
        rad = r if i % 2 == 0 else inner
        pts.append((cx + rad * math.cos(ang), cy + rad * math.sin(ang)))
    draw.polygon(pts, fill=fill)


def render_foreground():
    img = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse(
        [DISC_LEFT, DISC_LEFT, DISC_LEFT + DISC, DISC_LEFT + DISC],
        fill=WHITE,
    )

    cx = cy = CANVAS / 2
    poly, ox, oy = pin_polygon(cx, cy, PIN)

    scale = 2
    W = CANVAS * scale

    def S(p):
        return (p[0] * scale, p[1] * scale)

    spol = [S(p) for p in poly]
    mask = Image.new("L", (W, W), 0)
    ImageDraw.Draw(mask).polygon(spol, fill=255)

    left = ox * scale
    mid = (ox + PIN / 3) * scale
    right = (ox + 2 * PIN / 3) * scale
    end = (ox + PIN) * scale

    bands = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bands)
    bd.rectangle([left, 0, mid, W], fill=ACCENT)
    bd.rectangle([mid, 0, right, W], fill=WHITE)
    bd.rectangle([right, 0, end, W], fill=PRIMARY)

    k = (PIN / 100) * scale
    sw = 4 * k
    x_c = (ox + PIN / 2) * scale
    y_v1 = (oy + PIN * 0.35) * scale
    y_v2 = (oy + PIN * 0.65) * scale
    y_c = (oy + PIN * 0.5) * scale
    x_h1 = (ox + PIN / 2 - 8 * (PIN / 100)) * scale
    x_h2 = (ox + PIN / 2 + 8 * (PIN / 100)) * scale

    cross = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    ImageDraw.Draw(cross).rectangle([x_c - sw / 2, y_v1, x_c + sw / 2, y_v2], fill=PRIMARY)
    ImageDraw.Draw(cross).rectangle([x_h1, y_c - sw / 2, x_h2, y_c + sw / 2], fill=PRIMARY)
    mid_mask = Image.new("L", (W, W), 0)
    ImageDraw.Draw(mid_mask).rectangle([mid, 0, right, W], fill=255)
    ca = ImageChops.multiply(cross.split()[-1], mid_mask)
    bands.paste(cross, (0, 0), ca)

    pin_ss = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    pin_ss.paste(bands, (0, 0), mask)
    pin_img = pin_ss.resize((CANVAS, CANVAS), Image.Resampling.LANCZOS)
    img = Image.alpha_composite(img, pin_img)

    draw = ImageDraw.Draw(img)
    draw.ellipse([STAR_LEFT, STAR_TOP, STAR_LEFT + STAR_D, STAR_TOP + STAR_D], fill=ACCENT)
    draw_star(draw, STAR_LEFT + STAR_D / 2, STAR_TOP + STAR_D / 2, STAR_ICON / 2, WHITE)
    return img


def main():
    root = Path(__file__).resolve().parents[1]
    out_dir = root / "assets" / "images"
    preview = root / "build" / "qa-shots"
    preview.mkdir(parents=True, exist_ok=True)
    fg = render_foreground()
    (out_dir / "logo_foreground.png").parent.mkdir(parents=True, exist_ok=True)
    fg.save(out_dir / "logo_foreground.png", "PNG")
    full = Image.alpha_composite(Image.new("RGBA", (CANVAS, CANVAS), PRIMARY_DARK), fg)
    full.save(out_dir / "logo.png", "PNG")

    chk = Image.new("RGBA", (CANVAS, CANVAS), (255, 255, 255, 255))
    d = ImageDraw.Draw(chk)
    for y in range(0, CANVAS, 32):
        for x in range(0, CANVAS, 32):
            if ((x // 32) + (y // 32)) % 2 == 0:
                d.rectangle([x, y, x + 32, y + 32], fill=(210, 210, 210, 255))
    Image.alpha_composite(chk, fg).resize((512, 512), Image.Resampling.LANCZOS).save(
        preview / "logo_fg_preview.png"
    )
    full.resize((512, 512), Image.Resampling.LANCZOS).save(preview / "logo_full_preview.png")
    print("fg", (out_dir / "logo_foreground.png").stat().st_size, "corner", fg.getpixel((0, 0)))
    print("full", (out_dir / "logo.png").stat().st_size, "corner", full.getpixel((0, 0)))


if __name__ == "__main__":
    main()
