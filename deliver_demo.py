import os,shutil,zipfile,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
DEST=Path(r'C:\Users\pubet\Downloads\gamedev model').resolve()
assert DEST.name=='gamedev model' and DEST.parent.name=='Downloads'
project=ROOT/'MakeLifeSlower'
# The source archive is independent of the local runtime and generated builds.
with zipfile.ZipFile(project/'build'/'MakeLifeSlower_Source.zip','w',zipfile.ZIP_DEFLATED) as archive:
    for directory,dirs,files in os.walk(project):
        dirs[:]=[d for d in dirs if d not in ['.godot','build','.git']]
        for name in files:
            if name.endswith('_preview.png') or name=='preview.png':continue
            path=Path(directory)/name;archive.write(path,path.relative_to(project))
def ignored(directory,names):return [n for n in names if n=='.godot' or n=='preview.png' or n.endswith('.tmp') or n.endswith('.blend1')]
shutil.copytree(project,DEST/'MakeLifeSlower',dirs_exist_ok=True,ignore=ignored)
shutil.copytree(ROOT/'Rigged_Game_Models',DEST/'Rigged_Game_Models',dirs_exist_ok=True,ignore=ignored)
for name in ['build_game_assets.py','generate_audio.py','build_release.py','fetch_templates.py','verify_models.py']:
    shutil.copy2(ROOT/name,DEST/name)
for folder,names in [('godot',['Godot_v4.7.2-stable_win64.exe','Godot_v4.7.2-stable_win64_console.exe','_sc_']),('templates',['version.txt','web_nothreads_release.zip','web_nothreads_debug.zip','windows_release_x86_64.exe'])]:
    target=DEST/'tools'/folder;target.mkdir(parents=True,exist_ok=True)
    for name in names:shutil.copy2(ROOT/'tools'/folder/name,target/name)
manifest={}
for name in ['MakeLifeSlower_Web.zip','MakeLifeSlower_Windows.zip','MakeLifeSlower_Source.zip']:
    source=project/'build'/name;target=DEST/'MakeLifeSlower'/'build'/name
    digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    assert digest(source)==digest(target),name
    with zipfile.ZipFile(target) as archive:assert archive.testzip() is None
    manifest[name]={'bytes':target.stat().st_size,'sha256':digest(target)}
with open(DEST/'MakeLifeSlower'/'build'/'delivery_manifest.json','w') as f:json.dump(manifest,f,indent=2)
print(json.dumps({'destination':str(DEST/'MakeLifeSlower'),'packages':manifest,'rigged_blend_files':len(list((DEST/'Rigged_Game_Models').glob('*.blend')))},indent=2))
