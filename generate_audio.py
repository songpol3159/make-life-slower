"""Original quiet loop and synthesized sound cues for the prototype."""
import os,wave,subprocess
import numpy as np
ROOT=os.path.join(os.path.dirname(__file__),'MakeLifeSlower','assets','audio');os.makedirs(ROOT,exist_ok=True)
SR=22050;rng=np.random.default_rng(673380)
def write(name,x,ogg=False):
    x=np.asarray(x);x=x/max(1,np.max(np.abs(x))*1.05);p=os.path.join(ROOT,name+'.wav')
    with wave.open(p,'wb') as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes((x*32767).astype('<i2').tobytes())
    if ogg:
        subprocess.run(['ffmpeg','-v','error','-y','-i',p,'-c:a','libvorbis','-q:a','3',os.path.join(ROOT,name+'.ogg')],check=True);os.remove(p)
def note(freq,duration,kind='bell'):
    t=np.arange(int(duration*SR))/SR
    if kind=='pad':return (np.sin(2*np.pi*freq*t)+.18*np.sin(2*np.pi*freq*2*t))*np.minimum(t/.25,1)*np.minimum((duration-t)/.25,1)*.1
    return (np.sin(2*np.pi*freq*t)+.25*np.sin(2*np.pi*freq*2*t)+.06*np.sin(2*np.pi*freq*3*t))*np.minimum(t/.008,1)*np.exp(-t*3)*.18
def hz(midi):return 440*2**((midi-69)/12)
duration=32;music=np.zeros(SR*duration)
def add(x,start):
    a=int(start*SR);b=min(len(music),a+len(x));music[a:b]+=x[:b-a]
chords=[[60,64,67],[57,60,64],[53,57,60],[55,59,62]]
for bar in range(8):
    chord=chords[bar%4];start=bar*4
    for m in chord:add(note(hz(m),4,'pad'),start)
    for beat in range(8):add(note(hz(chord[beat%3]+12),1.8),start+beat*.5)
    add(note(hz(chord[0]-12),3),start)
    if bar%2==0:add(note(hz([76,74,72,71][bar//2]),2.5),start+.75)
for delay,gain in [(.13,.17),(.27,.11),(.44,.06)]:music+=np.roll(music,int(delay*SR))*gain
write('meadow',music*.65,True)
t=np.arange(SR*16)/SR;noise=rng.normal(0,1,len(t));smooth=np.convolve(noise,np.ones(120)/120,mode='same');ambient=smooth*.09
for s in [1,4,8,12]:
    a=int(s*SR);tt=np.arange(int(.45*SR))/SR;chirp=np.sin(2*np.pi*(1900*tt+900*tt**2))*np.sin(np.pi*tt/.45)**2*.028;ambient[a:a+len(chirp)]+=chirp
write('valley',ambient,True)
write('step',rng.normal(0,1,int(.12*SR))*np.exp(-np.arange(int(.12*SR))/SR*40)*.06)
write('water',rng.normal(0,1,int(.35*SR))*np.sin(np.linspace(0,np.pi,int(.35*SR)))**2*.08)
for n,m in [('harvest',79),('buy',76),('click',72),('save',81)]:write(n,note(hz(m),.35))
for name,f in [('cow',125),('goat',340),('sheep',310),('pig',140),('chicken',750),('duck',480),('dog',260),('cat',540)]:
    tt=np.arange(int(.65*SR))/SR;phase=2*np.pi*(f*tt+f*.18*np.sin(tt*5));env=np.sin(np.pi*tt/.65)**2
    x=(np.sin(phase)+.4*np.sin(phase*2)+.17*np.sin(phase*3))*env*.09;write(name,x)
print('Original audio generated')
