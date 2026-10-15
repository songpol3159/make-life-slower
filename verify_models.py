import os,json,struct,io
from PIL import Image
root=os.path.join(os.path.dirname(__file__),'MakeLifeSlower','assets','models')
files=[n for n in os.listdir(root) if n.endswith('.glb')]
assert len(files)==20,len(files)
for name in files:
    data=open(os.path.join(root,name),'rb').read();magic,version,size=struct.unpack_from('<III',data)
    assert magic==0x46546c67 and version==2 and size==len(data),name
    length,kind=struct.unpack_from('<II',data,12);doc=json.loads(data[20:20+length]);offset=20+length;blen,bkind=struct.unpack_from('<II',data,offset);binary=data[offset+8:offset+8+blen]
    assert doc.get('skins') and doc.get('meshes'),name
    animations=[a['name'] for a in doc.get('animations',[])]
    human=name[:-4] in ['player','seed','livestock','carpenter']
    for clip in ['Idle','Walk','Use' if human else 'Eat']:assert any(clip in a for a in animations),(name,clip,animations)
    for image in doc.get('images',[]):
        if 'bufferView' in image:
            view=doc['bufferViews'][image['bufferView']];start=view.get('byteOffset',0);im=Image.open(io.BytesIO(binary[start:start+view['byteLength']]))
            assert max(im.size)<=512,(name,im.size)
print('MODEL_VALIDATION_PASSED',len(files),'animated assets, texture sizes <=512')
