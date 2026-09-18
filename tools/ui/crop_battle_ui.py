"""Build lossless HUD crops from the audited manifest; keep original exports.

Run with Python + Pillow. No resize, recoloring or runtime JSON dependency.
"""
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
manifest = json.loads(Path(__file__).with_name('battle_ui_layout_manifest.json').read_text(encoding='utf-8'))
archive_root = ROOT / 'Graphics/UI/_source_full_canvas'
archive_root.mkdir(parents=True, exist_ok=True)
(archive_root / '.gdignore').touch()
for asset in manifest['assets'].values():
    source, archive = ROOT / asset['source'], ROOT / asset['archive']
    original = source if source.exists() else archive
    assert original.resolve().is_relative_to(ROOT.resolve())
    assert archive.resolve().is_relative_to(archive_root.resolve())
    assert hashlib.sha256(original.read_bytes()).hexdigest() == asset['sha256'], original
    with Image.open(original) as image:
        assert list(image.size) == manifest['source_canvas'], original
        x, y, w, h = (asset[k] for k in ('x', 'y', 'width', 'height'))
        target = ROOT / asset['production']
        target.parent.mkdir(parents=True, exist_ok=True)
        image.crop((x, y, x + w, y + h)).save(target)
    if source.exists():
        assert not archive.exists(), archive
        archive.parent.mkdir(parents=True, exist_ok=True)
        source.rename(archive)
        sidecar = Path(str(source) + '.import')
        if sidecar.exists():
            sidecar.rename(Path(str(archive) + '.import'))
print('47 lossless HUD crops built; originals archived.')
