import os,subprocess,zipfile,json,shutil,hashlib,re
ROOT=os.path.dirname(os.path.abspath(__file__));PROJECT=os.path.join(ROOT,'MakeLifeSlower');ENGINE=os.path.join(ROOT,'tools','godot','Godot_v4.7.2-stable_win64_console.exe');T=os.path.join(ROOT,'tools','templates')
def path(p):return p.replace('\\','/')
presets=''
for i,(name,platform,output,release,debug) in enumerate([('Web','Web','build/web/index.html','web_nothreads_release.zip','web_nothreads_debug.zip'),('Windows','Windows Desktop','build/windows/MakeLifeSlower.exe','windows_release_x86_64.exe','windows_release_x86_64.exe')]):
    os.makedirs(os.path.join(PROJECT,os.path.dirname(output)),exist_ok=True)
    presets+=f'''[preset.{i}]
name="{name}"
platform="{platform}"
runnable=true
export_filter="all_resources"
include_filter="assets/locales/*.json"
exclude_filter="tests/*,build/*,*_preview.png,preview.png,*.md,assets/fonts/OFL.txt,assets/models/manifest.json"
export_path="{output}"
script_export_mode=2

[preset.{i}.options]
custom_template/debug="{path(os.path.join(T,debug))}"
custom_template/release="{path(os.path.join(T,release))}"
'''
    if platform=='Web':presets+='''variant/extensions_support=false
variant/thread_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/head_include="<meta name='theme-color' content='#263d31'>"
progressive_web_app/enabled=false
'''
    else:presets+='binary_format/embed_pck=true\n'
    presets+='\n'
cfg=os.path.join(PROJECT,'export_presets.cfg')
with open(cfg,'w',encoding='utf-8') as f:f.write(presets)
for name in ['Web','Windows']:
    print('Exporting',name,flush=True)
    subprocess.run([ENGINE,'--headless','--path',PROJECT,'--export-release',name],check=True)
# Make the project reusable on another machine with standard installed templates.
portable=presets
for name in ['web_nothreads_release.zip','web_nothreads_debug.zip','windows_release_x86_64.exe']:portable=portable.replace(path(os.path.join(T,name)),'')
with open(cfg,'w',encoding='utf-8') as f:f.write(portable)
build=os.path.join(PROJECT,'build')
# Give each data pack a content-addressed filename so browsers cannot reuse an old game build.
web=os.path.join(build,'web')
pack=os.path.join(web,'index.pck')
pack_name='game-'+hashlib.sha256(open(pack,'rb').read()).hexdigest()[:16]+'.pck'
for old in os.listdir(web):
    if re.fullmatch(r'game-[a-f0-9]{16}\.pck',old):os.remove(os.path.join(web,old))
os.replace(pack,os.path.join(web,pack_name))
html_path=os.path.join(web,'index.html')
html_text=open(html_path,encoding='utf-8').read()
match=re.search(r'const GODOT_CONFIG = (\{.*?\});',html_text)
config=json.loads(match.group(1));config['mainPack']=pack_name
config['fileSizes'][pack_name]=config['fileSizes'].pop('index.pck')
html_text=html_text[:match.start(1)]+json.dumps(config,separators=(',',':'))+html_text[match.end(1):]
with open(html_path,'w',encoding='utf-8') as f:f.write(html_text)
for folder in ['web','windows']:
    output=os.path.join(build,folder)
    for name in os.listdir(output):
        if name.endswith('.import'):os.remove(os.path.join(output,name))
    shutil.copyfile(os.path.join(PROJECT,'LICENSES.md'),os.path.join(output,'LICENSES.md'))
    shutil.copyfile(os.path.join(PROJECT,'assets','fonts','OFL.txt'),os.path.join(output,'NotoSansThai-OFL.txt'))
    for license_name in ['NotoSans-OFL.txt','NotoSansSymbols-OFL.txt','NotoSansSymbols2-OFL.txt']:
        license_file=os.path.join(PROJECT,'assets','fonts',license_name)
        if os.path.isfile(license_file):shutil.copyfile(license_file,os.path.join(output,license_name))
with open(os.path.join(build,'web','README_WEB.txt'),'w',encoding='utf-8') as f:f.write('Make Life Slower — Alpine Farm\nUpload this ZIP as an HTML5 game to itch.io, or host all files on GitHub Pages. index.html must be at the root. Single-threaded WebGL 2 build; no special cross-origin headers required.\nControls: WASD walk, mouse look, Shift run, V FPS/TPS, 1–4 tools, E interact, I inventory, M map, Esc pause/settings.\nServe over HTTP(S); do not open index.html directly as a local file. Saves are per website/browser.\n')
for name,folder in [('MakeLifeSlower_Web','web'),('MakeLifeSlower_Windows','windows')]:
    with zipfile.ZipFile(os.path.join(build,name+'.zip'),'w',zipfile.ZIP_DEFLATED) as z:
        for f in os.listdir(os.path.join(build,folder)):z.write(os.path.join(build,folder,f),f)
with zipfile.ZipFile(os.path.join(build,'MakeLifeSlower_Source.zip'),'w',zipfile.ZIP_DEFLATED) as z:
    for directory,dirs,files in os.walk(PROJECT):
        dirs[:]=[d for d in dirs if d not in ['.godot','build','.git']]
        for file in files:
            if file.endswith('_preview.png') or file=='preview.png':continue
            p=os.path.join(directory,file);z.write(p,os.path.relpath(p,PROJECT))
print('Release packages ready',flush=True)
