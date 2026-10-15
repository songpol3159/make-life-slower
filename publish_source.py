"""Copy the editable project and development code into the publishing checkout.

Does not commit, push, copy credentials, or modify the playable docs build.
"""
from pathlib import Path
import hashlib
import shutil

ROOT = Path(__file__).resolve().parent
DEST = ROOT / 'publish' / 'make-life-slower'
EXCLUDED = {'.godot', 'build', 'export_templates', '__pycache__', '.git'}
copied = []

def copy(source, relative):
    target = DEST / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
    assert hashlib.sha256(source.read_bytes()).digest() == hashlib.sha256(target.read_bytes()).digest()
    copied.append(target)

for folder in ('MakeLifeSlower', 'Rigged_Game_Models'):
    for source in (ROOT / folder).rglob('*'):
        relative = source.relative_to(ROOT)
        if not source.is_file() or EXCLUDED.intersection(relative.parts):
            continue
        name = source.name.lower()
        if ('private' in name or name.endswith(('.tmp', '.blend1', '.blend2'))
                or '_preview.png' in name or name.startswith('preview.png')):
            continue
        copy(source, relative)

for source in ROOT.glob('*.py'):
    copy(source, source.name)
for name in ('prepare_visual_preview.py', 'localize_game.py',
             'upgrade_visual_assets.py', 'fetch_nature_selective.py'):
    copy(ROOT / 'tools' / name, Path('tools') / name)
print(f'Copied and SHA256 verified {len(copied)} files ({sum(p.stat().st_size for p in copied):,} bytes).')
