"""Prepare only the playable web export for a separate publishing repository."""
from pathlib import Path
import shutil,subprocess,json,os,re
root=Path(__file__).resolve().parent
deploy=root/'publish'/'make-life-slower'
docs=deploy/'docs';docs.mkdir(parents=True,exist_ok=True)
for source in (root/'MakeLifeSlower'/'build'/'web').iterdir():
    if source.is_file():shutil.copy2(source,docs/source.name)
current={p.name for p in (root/'MakeLifeSlower'/'build'/'web').iterdir()}
for old in docs.iterdir():
    if old.name not in current and (old.name=='index.pck' or re.fullmatch(r'game-[a-f0-9]{16}\.pck',old.name)):old.unlink()
(docs/'.nojekyll').write_text('')
if not (deploy/'.gitignore').exists():
    (deploy/'.gitignore').write_text('.DS_Store\nThumbs.db\n')
if not (deploy/'README.md').exists():
    (deploy/'README.md').write_text('''# Make Life Slower

A cozy 3D farming demo for desktop web browsers, made with Godot.

## Play and update

Enable GitHub Pages: Settings → Pages → Deploy from a branch → main → /docs.
The published URL remains the same when new builds are pushed to main.

To update, replace the files in docs with the latest web export, commit, and push.
Keep the filenames and save format compatible to preserve existing browser saves.
Saves stay on each browser and origin; a localhost save will not automatically
transfer to GitHub Pages. Controller navigation is supported in game and menus.

## Controls

WASD: move; mouse: look; Shift: run; E: interact; 1–4: tools; V: FPS/TPS;
I: inventory; M: map; L: lantern; Esc: menu. Xbox: sticks move/look, A interact,
X use, Y inventory, shoulders tools, Start pause. In menus, D-pad/stick selects,
left/right adjusts, A confirms and B returns.

This repository contains the web release and third-party license notices.

## Latest update — October 15, 2026

Cozy environment polish: feathered dirt paths painted into the terrain, short-grass
variation, textured plaster/timber/roof tiles, fuller tree crowns and warmer light.
Free CC0 watering can, hoe variants and fishing rod replace placeholder equipment.

Open the pause menu or gardener journal for processing machines, garden decoration,
the calendar/festivals and save slots. Visit shopkeepers to talk, give gifts and
unlock rewards. Fishing includes species-specific movement and surges.

Three save slots support JSON file export/import. Export a backup before clearing
browser data or moving between localhost and this site; saves are not cloud synced.
The original save remains in slot 1. Export a slot before importing a replacement.

See docs/LICENSES.md for equipment and environment attribution.
''',encoding='utf-8')
if not (deploy/'.git').exists():subprocess.run(['git','init','-b','main',str(deploy)],check=True,capture_output=True)
if os.environ.get('PUBLISH_GITHUB_LOGIN'):
    login=os.environ['PUBLISH_GITHUB_LOGIN'];uid=os.environ['PUBLISH_GITHUB_ID']
    subprocess.run(['git','-C',str(deploy),'config','user.name',login],check=True)
    subprocess.run(['git','-C',str(deploy),'config','user.email',f'{uid}+{login}@users.noreply.github.com'],check=True)
subprocess.run(['git','-C',str(deploy),'add','docs','.gitignore','README.md'],check=True)
if subprocess.run(['git','-C',str(deploy),'diff','--cached','--quiet']).returncode:
    subprocess.run(['git','-C',str(deploy),'commit','-m',os.environ.get('PUBLISH_MESSAGE','Update playable farming demo')],check=True,capture_output=True)
print(json.dumps({'repository':str(deploy),'web_bytes':sum(p.stat().st_size for p in docs.iterdir() if p.is_file())}))
