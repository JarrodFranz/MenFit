"""Regenerates ios/Runner/Assets.xcassets/AppIcon.appiconset from the app emblem.

Why a script and not a package: the Android, web and Windows icons were cut
by hand in the branding round (git log --grep=branding); iOS was forgotten
and TestFlight showed the Flutter template icon (2026-09-06). This reads the
appiconset's own Contents.json so it follows whatever sizes Xcode asks for,
flattens the RGBA emblem onto white (App Store rejects an alpha channel in
the 1024 marketing icon), and overwrites every listed PNG.

    python scripts/generate_ios_icons.py            # regenerate
    python scripts/generate_ios_icons.py --check    # exit 1 if any icon is stale

Needs Pillow (present on the dev machine's Python). Source of truth:
assets/images/app_icon.png (1024x1024, RGBA).
"""

from __future__ import annotations

import io
import json
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "assets" / "images" / "app_icon.png"
ICON_SET = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
BACKGROUND = (255, 255, 255)


def render(source: Image.Image, pixels: int) -> bytes:
    flat = Image.new("RGB", source.size, BACKGROUND)
    flat.paste(source, mask=source.getchannel("A") if source.mode == "RGBA" else None)
    icon = flat.resize((pixels, pixels), Image.LANCZOS)
    buffer = io.BytesIO()
    icon.save(buffer, format="PNG", optimize=True)
    return buffer.getvalue()


def main(check_only: bool) -> int:
    source = Image.open(SOURCE)
    if source.size != (1024, 1024):
        print(f"source must be 1024x1024, got {source.size}")
        return 1
    manifest = json.loads((ICON_SET / "Contents.json").read_text(encoding="utf-8"))
    stale = 0
    for entry in manifest["images"]:
        points = float(entry["size"].split("x")[0])
        scale = int(entry["scale"].rstrip("x"))
        pixels = round(points * scale)
        target = ICON_SET / entry["filename"]
        data = render(source, pixels)
        if check_only:
            if not target.exists() or target.read_bytes() != data:
                print(f"stale: {target.name} ({pixels}px)")
                stale += 1
            continue
        target.write_bytes(data)
        print(f"wrote {target.name} ({pixels}px)")
    if check_only:
        print("all icons current" if stale == 0 else f"{stale} stale icon(s)")
        return 1 if stale else 0
    return 0


if __name__ == "__main__":
    sys.exit(main("--check" in sys.argv[1:]))
