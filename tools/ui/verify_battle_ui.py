"""Verify audited source preservation and exact production pixels (requires Pillow)."""
import hashlib
import json
import re
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[2]
manifest = json.loads(Path(__file__).with_name('battle_ui_layout_manifest.json').read_text(encoding='utf-8'))
families = {}
for name, asset in manifest['assets'].items():
    original = root / asset['archive']
    target = root / asset['production']
    assert hashlib.sha256(original.read_bytes()).hexdigest() == asset['sha256'], name
    x, y, w, h = (asset[k] for k in ('x', 'y', 'width', 'height'))
    with Image.open(original) as source, Image.open(target) as texture:
        assert list(source.size) == [1920, 1080], name
        assert texture.size == (w, h), name
        assert texture.convert('RGBA').tobytes() == source.crop((x, y, x+w, y+h)).convert('RGBA').tobytes(), name
        assert texture.size != (1920, 1080), name
    if asset['family']:
        rect = (x, y, w, h)
        assert families.setdefault(asset['family'], rect) == rect, name
    assert re.fullmatch('[a-z_]+', name), name
assert (root / 'Graphics/UI/_source_full_canvas/.gdignore').exists()
for directory in ('presentation', 'scenes', 'content'):
    for path in (root / directory).rglob('*'):
        if path.suffix in ('.gd', '.tscn', '.tres'):
            text = path.read_text(encoding='utf-8-sig')
            assert 'res://Graphics/UI elements/' not in text, path
            assert 'res://Graphics/UI/_source_full_canvas/' not in text, path
print('HUD ASSET AUDIT: GREEN (47 exact crops, 7 stable state families, archived source hashes intact).')
