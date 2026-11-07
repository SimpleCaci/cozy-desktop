from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import math, struct, json
import argparse, os
parser=argparse.ArgumentParser(description='Rebuild the geometric cursor artwork; requires Pillow.')
parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[2]/'themes'/'starter'/'cursors')
OUT=parser.parse_args().output
OUT.mkdir(parents=True,exist_ok=True)
S=6; INK='#172833'; WHITE='#fffdf2'; GOLD='#eac15d'; BLUE='#98c3da'
SIZES=(24,32,48,64)
class Art:
 def __init__(self): self.im=Image.new('RGBA',(32*S,32*S));self.d=ImageDraw.Draw(self.im)
 def pt(self,p): return tuple(round(v*S) for v in p)
 def poly(self,pts,fill=INK,outline=WHITE,w=1.5):
  p=[self.pt(t) for t in pts];self.d.polygon(p,fill=fill)
  if outline:self.d.line(p+[p[0]],fill=outline,width=round(w*S),joint='curve')
 def ellipse(self,b,fill=INK,outline=WHITE,w=1.4): self.d.ellipse(self.pt(b),fill=fill,outline=outline,width=round(w*S) if outline else 1)
 def line(self,pts,fill=INK,w=2.2,outline=True):
  p=[self.pt(t) for t in pts]
  if outline:self.d.line(p,fill=WHITE,width=round((w+2)*S),joint='curve')
  self.d.line(p,fill=fill,width=round(w*S),joint='curve')
 def image(self,size=32):return self.im.resize((size,size),Image.Resampling.LANCZOS)
def cat(a,cx=25,cy=25,r=5):
 a.poly([(cx-r,cy-2),(cx-r+0.2,cy-r-2),(cx-1,cy-r+0.5),(cx+r-0.2,cy-r-2),(cx+r,cy-2),(cx+r,cy+3),(cx+1,cy+r),(cx-r,cy+3)],w=1.15)
 a.ellipse((cx-3,cy-1,cx-1.5,cy+1),WHITE,None);a.ellipse((cx+1,cy-1,cx+2.5,cy+1),WHITE,None)
 a.ellipse((cx-0.5,cy+1.8,cx+0.5,cy+2.5),GOLD,None)
def arrow(a,badge=True):
 a.poly([(2,1),(2,23),(8,18),(13,29),(17,27),(12,17),(23,17)],w=1.6)
 a.line([(5,7),(5,14)],GOLD,0.8,False)
 if badge:cat(a)
def rotate(pts,deg):
 t=math.radians(deg);return [(16+(x-16)*math.cos(t)-(y-16)*math.sin(t),16+(x-16)*math.sin(t)+(y-16)*math.cos(t)) for x,y in pts]
def cursor_art(role,frame=0):
 a=Art()
 if role=='Arrow':arrow(a);hot=(2,1)
 elif role=='Help':
  arrow(a,False);a.ellipse((19,19,31,31),INK,WHITE,1.2)
  f=ImageFont.truetype(str(Path(os.environ.get('WINDIR', r'C:\Windows'))/'Fonts'/'segoeuib.ttf'),11*S);a.d.text((22*S,17*S),'?',font=f,fill=GOLD);hot=(2,1)
 elif role=='AppStarting':
  arrow(a,False);cx,cy=25,25;a.ellipse((19,19,31,31),INK,WHITE,1)
  for i in range(8):
   ang=2*math.pi*(i/8+frame/16);x=cx+4*math.cos(ang);y=cy+4*math.sin(ang)
   a.ellipse((x-0.8,y-0.8,x+0.8,y+0.8),GOLD if i<4 else WHITE,None)
  hot=(2,1)
 elif role=='Wait':
  cat(a,16,16,6)
  t=2*math.pi*frame/16
  for j in range(2):
   ang=t+j*math.pi;x=16+11*math.cos(ang);y=16+11*math.sin(ang)
   a.ellipse((x-2.8,y-2.8,x+2.8,y+2.8),GOLD if j==0 else BLUE,WHITE,0.9)
   if j==1:a.ellipse((x+0.1,y-2,x+2.8,y+1.3),INK,None)
  hot=(16,16)
 elif role=='Crosshair':
  for pts in [[(16,2),(16,11)],[(16,21),(16,30)],[(2,16),(11,16)],[(21,16),(30,16)]]:a.line(pts,w=1.8)
  a.ellipse((14.5,14.5,17.5,17.5),GOLD,WHITE,0.8);hot=(16,16)
 elif role=='IBeam':
  a.line([(16,3),(16,29)],w=1.8)
  a.line([(11,3),(21,3)],w=1.8);a.line([(11,29),(21,29)],w=1.8)
  a.ellipse((14.7,14.7,17.3,17.3),GOLD,None);hot=(16,16)
 elif role=='NWPen':
  a.poly([(3,29),(6,20),(23,3),(29,9),(12,26)],w=1.6)
  a.poly([(3,29),(6,20),(12,26)],GOLD,WHITE,0.8);a.line([(10,22),(24,8)],BLUE,1.1,False);hot=(3,29)
 elif role=='No':
  a.ellipse((3,3,29,29),INK,WHITE,1.8);a.ellipse((9,9,23,23),None,GOLD,1.5)
  a.line([(8,24),(24,8)],GOLD,3,True);hot=(16,16)
 elif role in ('SizeNS','SizeWE','SizeNWSE','SizeNESW'):
  pts=[(16,2),(9,9),(13,9),(13,23),(9,23),(16,30),(23,23),(19,23),(19,9),(23,9)]
  angle={'SizeNS':0,'SizeWE':90,'SizeNWSE':-45,'SizeNESW':45}[role]
  a.poly(rotate(pts,angle),w=1.5);a.ellipse((14.5,14.5,17.5,17.5),GOLD,None);hot=(16,16)
 elif role=='SizeAll':
  a.poly([(16,1),(10,8),(13,8),(13,13),(8,13),(8,10),(1,16),(8,22),(8,19),(13,19),(13,24),(10,24),(16,31),(22,24),(19,24),(19,19),(24,19),(24,22),(31,16),(24,10),(24,13),(19,13),(19,8),(22,8)],w=1.3)
  a.ellipse((14,14,18,18),GOLD,None);hot=(16,16)
 elif role=='UpArrow':
  a.poly([(16,2),(5,13),(11,13),(11,29),(21,29),(21,13),(27,13)],w=1.6)
  a.line([(16,15),(16,24)],GOLD,1,False);hot=(16,2)
 elif role=='Hand':
  a.poly([(11,16),(11,3),(13,1),(16,3),(16,13),(19,11),(22,13),(25,13),(28,16),(28,24),(24,30),(14,30),(5,21),(5,18),(8,17)],w=1.6)
  a.ellipse((17,21,23,26),GOLD,None);a.line([(20,16),(20,19)],BLUE,0.8,False);hot=(13,1)
 elif role=='Pin':
  arrow(a,False);a.poly([(24,31),(19,23),(19,19),(22,16),(26,16),(30,19),(30,23)],BLUE,WHITE,1.1)
  a.ellipse((22,19,27,24),GOLD,INK,0.6);hot=(2,1)
 elif role=='Person':
  arrow(a,False);a.ellipse((22,17,28,23),GOLD,WHITE,1)
  a.ellipse((19,23,31,31),BLUE,WHITE,1);hot=(2,1)
 else:raise ValueError(role)
 return a,hot

def dib(im):
 w,h=im.size
 xor=im.transpose(Image.Transpose.FLIP_TOP_BOTTOM).tobytes('raw','BGRA')
 stride=((w+31)//32)*4;mask=bytearray(stride*h);alpha=im.getchannel('A')
 for row in range(h):
  y=h-1-row
  for x in range(w):
   if alpha.getpixel((x,y))==0:mask[row*stride+x//8]|=1<<(7-x%8)
 return struct.pack('<IIIHHIIIIII',40,w,h*2,1,32,0,len(xor)+len(mask),0,0,0,0)+xor+mask

def cur_bytes(art,hot):
 blobs=[];entries=[];off=6+16*len(SIZES)
 for size in SIZES:
  im=art.image(size);data=dib(im);x=round(hot[0]*size/32);y=round(hot[1]*size/32)
  entries.append(struct.pack('<BBBBHHII',size,size,0,0,x,y,len(data),off));blobs.append(data);off+=len(data)
 return struct.pack('<HHH',0,2,len(SIZES))+b''.join(entries)+b''.join(blobs)
def chunk(name,data):return name+struct.pack('<I',len(data))+data+(b'\0' if len(data)%2 else b'')
def ani_bytes(role):
 frames=[]
 for f in range(16):
  art,hot=cursor_art(role,f);frames.append(chunk(b'icon',cur_bytes(art,hot)))
 header=struct.pack('<9I',36,16,16,0,0,0,0,5,1)
 body=b'ACON'+chunk(b'anih',header)+chunk(b'LIST',b'fram'+b''.join(frames))
 return b'RIFF'+struct.pack('<I',len(body))+body
roles=['Arrow','Help','AppStarting','Wait','Crosshair','IBeam','NWPen','No','SizeNS','SizeWE','SizeNWSE','SizeNESW','SizeAll','UpArrow','Hand','Pin','Person']
meta={}
for role in roles:
 art,hot=cursor_art(role)
 art.image(128).save(OUT/(role+'.png'))
 ext='.ani' if role in ('Wait','AppStarting') else '.cur'
 data=ani_bytes(role) if ext=='.ani' else cur_bytes(art,hot)
 (OUT/(role+ext)).write_bytes(data)
 meta[role]={'file':role+ext,'hotspot32':hot,'sizes':list(SIZES),'frames':16 if ext=='.ani' else 1}
 if ext=='.ani':
  frames=[cursor_art(role,f)[0].image(96) for f in range(16)]
  frames[0].save(OUT/(role+'-preview.gif'),save_all=True,append_images=frames[1:],duration=83,loop=0,disposal=2,transparency=0)
(OUT/'manifest.json').write_text(json.dumps(meta,indent=2))
# Review sheet: normal-size pointers on both light and dark surfaces, then a larger detail.
w,h=960,680;sheet=Image.new('RGB',(w,h),'#d9e9ef');draw=ImageDraw.Draw(sheet)
font=ImageFont.truetype(str(Path(os.environ.get('WINDIR', r'C:\Windows'))/'Fonts'/'segoeui.ttf'),15)
for i,role in enumerate(roles):
 col=i%6;row=i//6;x=col*160;y=row*220
 draw.rectangle((x+4,y+4,x+156,y+208),fill='#fdf8e9')
 draw.rectangle((x+80,y+4,x+156,y+68),fill=INK)
 a,_=cursor_art(role);small=a.image(32);large=a.image(96)
 sheet.paste(small,(x+25,y+22),small);sheet.paste(small,(x+103,y+22),small)
 sheet.paste(large,(x+32,y+78),large)
 draw.text((x+12,y+184),role,font=font,fill=INK)
sheet.save(OUT/'cursor-preview.png')
print(json.dumps({'roles':len(meta),'animated':2,'sizes':SIZES,'path':str(OUT)}))

