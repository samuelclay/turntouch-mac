# Integration icons

Editable sources for Kasa (smart plug), Nanoleaf (light panels), and Govee (LED strip).
These match the existing 512 × 512 transparent icons, using Turn Touch blue `#4383c0`
and rounded outlines. Keep transparent areas transparent so native tinting works.

Export each SVG at 512 × 512 to its matching PNG in the parent directory. For example,
with CairoSVG installed: `cairosvg mode_kasa.svg -o ../mode_kasa.png`.
Keep these SVG/PNG pairs synchronized between the iOS and Mac repositories.
Then run `python3 scripts/import_ios.py` from the Android repository to refresh its
assets and catalog mappings; iOS artwork takes precedence over Mac artwork.
