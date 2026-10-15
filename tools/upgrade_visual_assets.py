"""Acquire compact CC0 material maps and bake a deterministic road/ground mask."""
from pathlib import Path
import json, urllib.request, numpy as np
from PIL import Image, ImageOps
ROOT=Path(__file__).resolve().parents[1]
DEST=ROOT/'MakeLifeSlower/assets/environment/polish'
DEST.mkdir(parents=True,exist_ok=True)
def fetch(url):
    with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'MakeLifeSlower/1.0'}),timeout=60) as response:return response.read()
manifest=[]
for asset,prefix in [('grass_path_2','path'),('clay_roof_tiles_02','roof'),('clay_plaster','plaster'),('oak_wood_planks','wood')]:
    data=json.loads(fetch('https://api.polyhaven.com/files/'+asset))
    for kind,out in [('Diffuse','color'),('nor_gl','normal')]:
        if kind not in data:continue
        url=data[kind]['1k']['jpg']['url'];target=DEST/(prefix+'_'+out+'.jpg')
        if not target.exists():target.write_bytes(fetch(url))
        manifest.append({'asset':asset,'map':kind,'url':url,'license':'CC0','source':'https://polyhaven.com/a/'+asset})
(DEST/'sources.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
# Keep the plaster's photographed relief, with a restrained warm ivory palette.
source=Image.open(DEST/'plaster_color.jpg').convert('L')
source=ImageOps.autocontrast(source,cutoff=2)
ImageOps.colorize(source,'#c0b59d','#f4ead4').save(DEST/'plaster_warm.jpg',quality=91)
# Distances are baked offline; the web shader needs one mask sample, not a loop over roads.
size=1024
z,x=np.mgrid[0:size,0:size].astype(np.float32)
x=(x+.5)/size*280-140;z=(z+.5)/size*280-140
field=np.full((size,size),1000,dtype=np.float32)
routes=[([(0,12),(7,2),(8,-12),(22,-28),(55,-58)],4.5),([(-3,12),(-26,35),(-49,53)],2),([(40,-58),(82,-58)],5)]
for route,width in routes:
    for (ax,az),(bx,bz) in zip(route,route[1:]):
        dx,dz=bx-ax,bz-az;t=np.clip(((x-ax)*dx+(z-az)*dz)/(dx*dx+dz*dz),0,1)
        distance=np.sqrt((x-ax-t*dx)**2+(z-az-t*dz)**2)-width/2
        field=np.minimum(field,distance)
# Low-frequency edge irregularity, without changing walkable terrain or collision.
field+=np.sin(x*2.1+np.cos(z*1.6))*.16+np.sin(z*3.3+x*.6)*.07
mask=np.clip((.7-field)/1.0,0,1);mask=mask*mask*(3-2*mask)
contact=np.ones((size,size),dtype=np.float32)
for cx,cz,sx,sz in [(-7,4,3.8,3.3),(24,-5,4.8,3.3),(48,-67,3.8,2.8),(62,-67,3.8,2.8),(76,-67,3.8,2.8)]:
    dx=np.maximum(np.abs(x-cx)-sx,0);dz=np.maximum(np.abs(z-cz)-sz,0)
    contact=np.minimum(contact,np.clip(np.sqrt(dx*dx+dz*dz)/1.25,0,1))
rng=np.random.default_rng(673380)
macro=np.asarray(Image.fromarray(np.uint8(rng.random((48,48))*255)).resize((size,size),Image.Resampling.BICUBIC),dtype=np.float32)/255
Image.fromarray(np.uint8(np.stack([mask,contact,macro],axis=2)*255)).save(DEST/'road_mask.png')
print('Compact CC0 maps and 1024px road mask ready')
