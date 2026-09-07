"""Generates MenFit placeholder brand assets in the Forge palette.

    python scripts/generate_brand_assets.py

Overwrites assets/images/{app_icon,menfit_logo,menfit_logo_solid,menfit_splash}.png,
the Android mipmaps and native splash drawable, web icons and the Windows
.ico, then calls generate_ios_icons.py. Replace with real artwork later by
overwriting assets/images/app_icon.png and re-running.
"""
from __future__ import annotations
import subprocess, sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
IMG = ROOT / "assets" / "images"
CHARCOAL, ORANGE, OFFWHITE = (18, 18, 18, 255), (255, 109, 58, 255), (250, 248, 245, 255)

def font(size: int):
    for name in ("arialbd.ttf", "Arial Bold.ttf", "DejaVuSans-Bold.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()

def emblem(size: int, bg, fg, rounded=True) -> Image.Image:
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    r = size * 0.22 if rounded else 0
    d.rounded_rectangle((0, 0, size - 1, size - 1), radius=r, fill=bg)
    # Barbell: bar + two plates each side.
    y = size / 2; bar_h = size * 0.07
    d.rounded_rectangle((size*0.14, y-bar_h/2, size*0.86, y+bar_h/2), radius=bar_h/2, fill=fg)
    for x0 in (0.16, 0.24, 0.70, 0.78):
        d.rounded_rectangle((size*x0, size*0.30, size*(x0+0.06), size*0.70), radius=size*0.02, fill=fg)
    return im

def wordmark(width: int, height: int, bg, fg) -> Image.Image:
    im = Image.new("RGBA", (width, height), bg)
    d = ImageDraw.Draw(im)
    f = font(int(height * 0.42))
    text = "MenFit"
    tw, th = d.textbbox((0, 0), text, font=f)[2:]
    d.text(((width - tw) / 2, (height - th) / 2 - height * 0.05), text, font=f, fill=fg)
    return im

def main() -> None:
    IMG.mkdir(parents=True, exist_ok=True)
    icon = emblem(1024, CHARCOAL, ORANGE)
    icon.save(IMG / "app_icon.png")
    emblem(1024, (0, 0, 0, 0), ORANGE, rounded=False).save(IMG / "menfit_logo.png")
    emblem(1024, CHARCOAL, ORANGE).save(IMG / "menfit_logo_solid.png")
    splash = Image.new("RGBA", (1242, 2688), CHARCOAL)
    e = emblem(420, CHARCOAL, ORANGE)
    splash.alpha_composite(e, ((1242 - 420) // 2, 900))
    splash.alpha_composite(wordmark(1242, 300, CHARCOAL, OFFWHITE), (0, 1360))
    splash.save(IMG / "menfit_splash.png")
    # Android mipmaps.
    res = ROOT / "android" / "app" / "src" / "main" / "res"
    for folder, px in {"mipmap-mdpi": 48, "mipmap-hdpi": 72, "mipmap-xhdpi": 96, "mipmap-xxhdpi": 144, "mipmap-xxxhdpi": 192}.items():
        d = res / folder; d.mkdir(exist_ok=True)
        icon.resize((px, px), Image.LANCZOS).save(d / "ic_launcher.png")
        icon.resize((px, px), Image.LANCZOS).save(d / "ic_launcher_round.png")
        fg = Image.new("RGBA", (px * 108 // 48,) * 2, (0, 0, 0, 0))
        inner = emblem(px, (0, 0, 0, 0), ORANGE, rounded=False)
        fg.alpha_composite(inner, ((fg.width - px) // 2,) * 2)
        fg.save(d / "ic_launcher_foreground.png")
    # Android native splash drawable (launch_background.xml -> @drawable/splash_logo).
    for folder in ("drawable", "drawable-v21"):
        d = res / folder
        if (d / "splash_logo.png").exists():
            icon.resize((240, 240), Image.LANCZOS).save(d / "splash_logo.png")
    # Web + Windows.
    web = ROOT / "web" / "icons"; web.mkdir(exist_ok=True)
    for name, px in {"Icon-192.png": 192, "Icon-512.png": 512, "Icon-maskable-192.png": 192, "Icon-maskable-512.png": 512}.items():
        icon.resize((px, px), Image.LANCZOS).save(web / name)
    icon.resize((32, 32), Image.LANCZOS).save(ROOT / "web" / "favicon.png")
    icon.convert("RGBA").save(ROOT / "windows" / "runner" / "resources" / "app_icon.ico", sizes=[(16, 16), (32, 32), (48, 48), (256, 256)])
    subprocess.check_call([sys.executable, str(ROOT / "scripts" / "generate_ios_icons.py")])
    print("brand assets written")

if __name__ == "__main__":
    main()
