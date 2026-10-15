from pathlib import Path
import shutil,zipfile,json,html
from PIL import Image,ImageOps,ImageDraw,ImageFont
root=Path(__file__).resolve().parent;out=root/'Model_Previews';out.mkdir(exist_ok=True)
source=Path(r'C:\Users\pubet\Downloads\gamedev model\output')
folders=[source/'characters'/p for p in ['player','seed_merchant','livestock_merchant','carpenter']]
for sp in ['cow','chicken','duck','sheep','goat','pig','dog','cat']:
    folders.append(source/'friendly'/sp/'young')
    folders.append(source/'cow' if sp=='cow' else source/sp/'adult')
originals=[]
for folder in folders:
    for path in folder.glob('*.png'):
        if not any(token in path.stem.lower() for token in ['preview','side','front']):continue
        target=out/('Original_'+path.name);shutil.copy2(path,target);originals.append(target.name)
keys=[item['asset'] for item in json.loads((root/'MakeLifeSlower/assets/models/manifest.json').read_text())]
font=ImageFont.truetype(r'C:\Windows\Fonts\segoeui.ttf',22)
titlefont=ImageFont.truetype(r'C:\Windows\Fonts\segoeuib.ttf',35)
sheet=Image.new('RGB',(1280,100+360*5),'#eaf0e9');draw=ImageDraw.Draw(sheet)
draw.text((25,22),'Make Life Slower — Current Models',font=titlefont,fill='#294737')
for i,key in enumerate(keys):
    x=(i%4)*320;y=100+(i//4)*360
    image=Image.open(out/(key+'_Preview.png')).convert('RGB');image=ImageOps.contain(image,(300,300))
    sheet.paste(image,(x+(320-image.width)//2,y));draw.text((x+15,y+307),key.replace('_',' ').title(),font=font,fill='#294737')
sheet.save(out/'00_All_Current_Models.jpg',quality=92)
files=sorted(p.name for p in out.glob('*.png'))
cards=''.join(f'<figure data-original="{str(name.startswith("Original_")).lower()}"><a href="{html.escape(name)}"><img loading="lazy" src="{html.escape(name)}"></a><figcaption>{html.escape(name.removesuffix(".png").replace("_"," "))}</figcaption></figure>' for name in files)
(out/'00_Open_Gallery.html').write_text('''<!doctype html><meta charset="utf-8"><title>Make Life Slower · Models</title><style>body{background:#eef3ea;color:#284335;font:17px system-ui;margin:30px}h1{font-size:30px}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:18px}figure{margin:0;background:white;border-radius:16px;overflow:hidden}img{display:block;width:100%;aspect-ratio:1;object-fit:contain}figcaption{padding:14px;font-size:14px}button{padding:12px;border:0;border-radius:12px;background:#284335;color:white;margin:4px;cursor:pointer}</style><h1>Make Life Slower · Model Previews</h1><p>รวมรูปไว้หน้าเดียว · รูปโมเดลที่ใช้ในเกมและรูปต้นฉบับ · คลิกรูปเพื่อดูขนาดเต็ม</p><button onclick="filter('all')">ทั้งหมด</button><button onclick="filter('false')">โมเดลในเกมปัจจุบัน</button><button onclick="filter('true')">รูปต้นฉบับ</button><div class="grid">'''+cards+'''</div><script>function filter(v){document.querySelectorAll('figure').forEach(c=>c.hidden=v!=='all'&&c.dataset.original!==v)}</script>''',encoding='utf-8')
(out/'README.txt').write_text('รูปทั้งหมดอยู่ในโฟลเดอร์เดียว\n00_Open_Gallery.html: ดูรูปทั้งหมดหน้าเดียว\n00_All_Current_Models.jpg: รูปรวม 20 โมเดลปัจจุบัน\nไฟล์ชื่อ cow_young เป็นต้น: โมเดลในเกมปัจจุบัน 2 มุมต่อโมเดล\nOriginal_: รูปเรนเดอร์ต้นฉบับจากไฟล์ที่ใช้ทำโมเดลเกม (รายละเอียดก่อนลด polygon)\n',encoding='utf-8')
zip_path=root/'Model_Previews.zip'
with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(out.iterdir()):
        if path.is_file():archive.write(path,'Model_Previews/'+path.name)
with zipfile.ZipFile(zip_path) as archive:assert archive.testzip() is None
dest=Path(r'C:\Users\pubet\Downloads\gamedev model');shutil.copytree(out,dest/'Model_Previews',dirs_exist_ok=True);shutil.copy2(zip_path,dest/'Model_Previews.zip')
publish=root/'publish/make-life-slower/docs';shutil.copy2(zip_path,publish/'Model_Previews.zip');shutil.copy2(out/'00_All_Current_Models.jpg',publish/'models-overview.jpg')
print(json.dumps({'current_views':len(keys)*2,'original_previews':len(originals),'zip_bytes':zip_path.stat().st_size,'destination':str(dest/'Model_Previews.zip')}))
