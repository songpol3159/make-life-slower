from pathlib import Path
from PIL import Image, ImageDraw
out=Path('MakeLifeSlower/assets/icons');out.mkdir(parents=True,exist_ok=True)
S=384
def save(name,draw):
 im=Image.new('RGBA',(S,S));d=ImageDraw.Draw(im);d.rounded_rectangle((8,8,376,376),radius=74,fill='#e7e8d3');draw(d);im.resize((128,128),Image.Resampling.LANCZOS).save(out/(name+'.png'))
def leaf(d,xy):d.ellipse(xy,fill='#799a58')
def carrot(d):
 d.polygon([(133,130),(248,154),(146,306)],fill='#e8a255');d.line([(160,179),(190,183)],fill='#cb813b',width=9)
 for a in [(142,60,184,151),(174,45,216,147),(196,69,248,143)]:leaf(d,a)
def tomato(d):
 d.ellipse((86,114,297,315),fill='#d7715a');d.ellipse((122,137,170,175),fill='#ed9a7b')
 for pts in [[(192,122),(147,85),(165,138)],[(192,122),(238,76),(226,142)],[(192,122),(275,139),(211,157)],[(192,122),(105,141),(172,157)]]:d.polygon(pts,fill='#6f9253')
def pumpkin(d):
 for x in [91,118,158,200]:d.ellipse((x,140,x+94,305),fill='#dcaa59',outline='#c99443',width=6)
 d.rounded_rectangle((181,105,207,159),10,fill='#7a8850');leaf(d,(208,97,264,130))
def bag(d):
 d.rounded_rectangle((105,105,278,300),24,fill='#bc9d72');d.rectangle((117,133,266,153),fill='#e5cea2');leaf(d,(151,180,216,250));d.line((194,232,216,178),fill='#526f4b',width=10)
def house(d):
 d.rounded_rectangle((95,177,294,308),12,fill='#b9946b');d.polygon([(69,185),(191,78),(315,185)],fill='#806854');d.rounded_rectangle((157,221,216,308),9,fill='#6f8070');d.rectangle((108,210,139,252),fill='#abcac1');d.rectangle((241,210,272,252),fill='#abcac1')
def farm(d):
 d.rounded_rectangle((67,152,318,310),35,fill='#93afa0');d.rounded_rectangle((82,168,303,293),26,fill='#92744e')
 for x in [110,192,272]:
  d.line((x,260,x,208),fill='#64894e',width=12);leaf(d,(x-33,197,x,223));leaf(d,(x,183,x+33,210))
def tool(d):
 d.rounded_rectangle((101,171,253,293),25,fill='#7da5a0');d.ellipse((234,148,297,251),outline='#7da5a0',width=18);d.polygon([(110,195),(70,146),(51,154),(84,245)],fill='#7da5a0');d.ellipse((57,134,92,164),fill='#678f8b')
def wool(d):
 for x,y in [(102,180),(158,140),(211,140),(247,187),(191,225),(138,231)]:d.ellipse((x-42,y-42,x+61,y+61),fill='#f4eedb',outline='#c8c7b2',width=4)
def egg(d):d.ellipse((121,81,261,309),fill='#f3dfb7');d.ellipse((143,111,177,167),fill='#fff0d0')
def milk(d):
 d.rounded_rectangle((130,95,251,310),25,fill='#e8eee2');d.rounded_rectangle((151,69,231,108),12,fill='#9aac96');d.rounded_rectangle((139,179,242,258),14,fill='#91b8b0');d.ellipse((174,201,207,240),fill='#f5e8cd')
def meat(d):d.ellipse((81,115,303,294),fill='#c28c78',outline='#ead8bd',width=19);d.ellipse((191,181,249,245),fill='#ebdfc5')
for n,fn in {'carrot':carrot,'tomato':tomato,'pumpkin':pumpkin,'feed':bag,'home':house,'barn':house,'farm':farm,'tool':tool,'wool':wool,'egg':egg,'duck_egg':egg,'milk':milk,'goat_milk':milk,'meat':meat}.items():save(n,fn)
