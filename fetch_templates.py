import io,os,zipfile,urllib.request,json
URL='https://godot-releases.nbg1.your-objectstorage.com/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz'
class RemoteZip(io.RawIOBase):
    def __init__(self):
        req=urllib.request.Request(URL,method='HEAD')
        with urllib.request.urlopen(req,timeout=60) as r:self.size=int(r.headers['Content-Length'])
        self.pos=0
    def seekable(self):return True
    def readable(self):return True
    def tell(self):return self.pos
    def seek(self,pos,whence=0):
        self.pos=pos if whence==0 else self.pos+pos if whence==1 else self.size+pos
        return self.pos
    def read(self,n=-1):
        if n<0:n=self.size-self.pos
        if n<=0:return b''
        end=min(self.size,self.pos+n)-1
        req=urllib.request.Request(URL,headers={'Range':f'bytes={self.pos}-{end}'})
        with urllib.request.urlopen(req,timeout=120) as r:
            if r.status!=206:raise RuntimeError('Server does not support partial downloads')
            data=r.read()
        self.pos+=len(data);return data
out=os.path.join(os.path.dirname(__file__),'tools','templates');os.makedirs(out,exist_ok=True)
with zipfile.ZipFile(RemoteZip()) as z:
    for info in z.infolist():
        name=info.filename.rsplit('/',1)[-1]
        if name in ['web_nothreads_release.zip','web_nothreads_debug.zip','windows_release_x86_64.exe','version.txt']:
            if os.path.exists(os.path.join(out,name)) and os.path.getsize(os.path.join(out,name))==info.file_size:continue
            print('Fetching',name,info.compress_size,flush=True)
            with open(os.path.join(out,name),'wb') as f:f.write(z.read(info))
print('Templates ready',flush=True)
