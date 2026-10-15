from pathlib import Path
import os, zipfile, shutil, hashlib, json
ROOT=Path(__file__).resolve().parent
if __name__=='__main__':
    delivery=ROOT/'Delivery/MakeLifeSlower_Development_AllAssets.zip'
    with zipfile.ZipFile(delivery,'w',zipfile.ZIP_DEFLATED) as archive:
        for folder in ['MakeLifeSlower','Rigged_Game_Models']:
            for directory,dirs,files in os.walk(ROOT/folder):
                dirs[:]=[d for d in dirs if d not in ['.godot','build','.git']]
                for name in files:
                    if name=='preview.png' or name.endswith('_preview.png') or Path(name).suffix.lower() in ['.cmd','.bat','.exe','.tmp','.blend1']:continue
                    if 'ADMIN_ACCESS_PRIVATE' in name:continue
                    path=Path(directory)/name;archive.write(path,path.relative_to(ROOT))
        archive.write(ROOT/'Delivery/README_DEVELOPMENT.txt','README_DEVELOPMENT.txt')
        archive.write(ROOT/'tools/upgrade_visual_assets.py','tools/upgrade_visual_assets.py')
    with zipfile.ZipFile(delivery) as archive:
        assert archive.testzip() is None
        assert not any('ADMIN_ACCESS_PRIVATE' in n for n in archive.namelist())
    digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    target=Path(r'C:\Users\pubet\Downloads\gamedev model')/delivery.name
    shutil.copy2(delivery,target);assert digest(target)==digest(delivery)
    shutil.copy2(delivery,ROOT/'Checkpoints/Visual_Polish_2026-10-15.zip')
    result={'path':str(delivery),'bytes':delivery.stat().st_size,'sha256':digest(delivery)}
    (ROOT/'Checkpoints/package_manifest.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    print(json.dumps(result,indent=2))
