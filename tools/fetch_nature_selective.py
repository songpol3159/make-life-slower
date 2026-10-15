from pathlib import Path
import urllib.request,struct,zlib,json
root=Path(__file__).resolve().parents[1];folder=root/'tools/visual_assets';folder.mkdir(exist_ok=True)
url='https://kenney.nl/media/pages/assets/nature-kit/37ac38a37b-1677698939/kenney_nature-kit.zip'
def chunk(range_text):
 request=urllib.request.Request(url,headers={'User-Agent':'MakeLifeSlower-Preview/1.0','Range':'bytes='+range_text})
 with urllib.request.urlopen(request,timeout=35) as r:
  if r.status!=206:raise RuntimeError('Server does not support selective ZIP download')
  return r.read()
tail=chunk('-65536');end=tail.rfind(b'PK\x05\x06');record=struct.unpack_from('<4s4H2IH',tail,end);size,offset=record[5:7]
cd=chunk(f'{offset}-{offset+size-1}')
files=[];pos=0
while cd[pos:pos+4]==b'PK\x01\x02':
 v=struct.unpack_from('<4s6H3I5H2I',cd,pos);name=cd[pos+46:pos+46+v[10]].decode('utf-8');files.append({'name':name,'method':v[4],'size':v[8],'offset':v[16]});pos+=46+v[10]+v[11]+v[12]
(folder/'nature_index.json').write_text(json.dumps(files,indent=2))
print('\n'.join(f['name'] for f in files if f['name'].endswith('.glb')),flush=True)
