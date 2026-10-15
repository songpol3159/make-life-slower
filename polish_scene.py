from pathlib import Path
from PIL import Image, ImageFilter
import numpy as np
out=Path('MakeLifeSlower/assets/textures');out.mkdir(parents=True,exist_ok=True)
rng=np.random.default_rng(573)
for name,base in [('soil',[145,116,82]),('meadow',[218,225,201]),('wood',[189,165,128]),('path',[188,171,134])]:
 a=rng.normal(0,3,(256,256,1));arr=np.clip(np.array(base)[None,None,:]+a,0,255).astype(np.uint8);im=Image.fromarray(arr)
 if name=='wood':
  arr=np.array(im).astype(float);grain=4*np.sin(np.arange(256)[:,None]*.7)+2*np.sin(np.arange(256)[:,None]*2.4);arr+=grain[:,:,None];im=Image.fromarray(np.clip(arr,0,255).astype(np.uint8))
 im.save(out/(name+'.png'))
p=Path('MakeLifeSlower/scripts/world.gd');s=p.read_text(encoding='utf-8')
s=s.replace('m.albedo_color=Color(hex);m.roughness=.9;mats[hex]=m','''m.albedo_color=Color(hex);m.roughness=.9
 if hex in ["66523a","947049"] and ResourceLoader.exists("res://assets/textures/soil.png"):
  m.albedo_texture=load("res://assets/textures/soil.png");m.albedo_color=Color("a9a395") if hex=="66523a" else Color.WHITE
 mats[hex]=m''')
s=s.replace('Vector2(0,12),Vector2(20,-5),Vector2(35,-29),Vector2(55,-58)','Vector2(0,12),Vector2(7,2),Vector2(8,-12),Vector2(22,-28),Vector2(55,-58)')
s=s.replace('Vector3(0,0,12),Vector3(20,0,-5),Vector3(35,0,-29),Vector3(55,0,-58)','Vector3(0,0,12),Vector3(7,0,2),Vector3(8,0,-12),Vector3(22,0,-28),Vector3(55,0,-58)')
s=s.replace('var shade=.92+rng.randf()*.08','var shade=.98+.012*sin(v.x*.07)*cos(v.z*.08)')
s=s.replace('st.set_normal(normal);st.set_color','st.set_uv(Vector2(v.x/8.0,v.z/8.0));st.set_normal(normal);st.set_color',1)
s=s.replace('terrain_material=m','m.albedo_texture=load("res://assets/textures/meadow.png");terrain_material=m',1)
s=s.replace('Vector3(43,0,-47),Vector3(78,0,-47)','Vector3(39,0,-47),Vector3(81,0,-47)')
s=s.replace('Vector3((j-3)*4.4,2.0*sin(j*1.9),cos(j*2.1)*3)','Vector3((j-3)*3.2,1.3*sin(j*1.9),cos(j*2.1)*2)')
s=s.replace('Vector3(9,6+(j%3)*2,7)','Vector3(12,7+(j%3)*2,9)')
s=s.replace('var m=SphereMesh.new();m.radial_segments=12;m.rings=6','var m=SphereMesh.new();m.radial_segments=20;m.rings=10',1)
s=s.replace(']:positions.append(p)',']:\n  shade_tree(p)',1)
# Tree shadows near the farm, with forest shadows disabled in distant zones.
s += '''
func shade_tree(p):
 var n=Node3D.new();n.position=p;n.position.y=ground(p);add_child(n)
 cylinder(n,Vector3(0,1.9,0),.28,3.8,"80644b")
 for offset in [Vector3(0,4.5,0),Vector3(-1.2,3.8,.4),Vector3(1.1,3.9,-.4),Vector3(.3,5.3,.3)]:sphere(n,offset,Vector3(4.2,3.2,4.0),"709f57")
 var body=StaticBody3D.new();var c=CollisionShape3D.new();var trunk=CylinderShape3D.new();trunk.radius=.28;trunk.height=3.8;c.shape=trunk;c.position.y=1.9;body.add_child(c);n.add_child(body)
'''
s=s.replace('for v in [Vector3(0,.12,0),edge[(i+1)%edge.size()],edge[i]]:st.set_normal(Vector3.UP);st.add_vertex(v)','for v in [Vector3(0,.12,0),edge[(i+1)%edge.size()],edge[i]]:st.set_uv(Vector2(v.x,v.z)*.42+Vector2.ONE*.5);st.set_normal(Vector3.UP);st.add_vertex(v)')
start=s.index(' var wood="96afa0"');end=s.index(' for j in range(12):',start)
s=s[:start]+''' var rail=SurfaceTool.new();rail.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in range(edge.size()):
  var a=edge[i];var b=edge[(i+1)%edge.size()];var outer_a=Vector3(a.x*1.075,.24,a.z*1.075);var outer_b=Vector3(b.x*1.075,.24,b.z*1.075)
  var inner_a=Vector3(a.x,.24,a.z);var inner_b=Vector3(b.x,.24,b.z)
  for v in [inner_a,outer_b,outer_a,inner_a,inner_b,outer_b]:rail.set_normal(Vector3.UP);rail.add_vertex(v)
  var bottom_a=Vector3(outer_a.x,.04,outer_a.z);var bottom_b=Vector3(outer_b.x,.04,outer_b.z)
  var normal=Vector3((a+b).x,0,(a+b).z).normalized()
  for v in [outer_a,outer_b,bottom_a,outer_b,bottom_b,bottom_a]:rail.set_normal(normal);rail.add_vertex(v)
 shape(n,rail.commit(),Vector3.ZERO,"96afa0")
'''+s[end:]
s=s.replace(' sky_material.sky_top_color=Color("081425").lerp(Color("78b9cf"),daylight)',' var sky_day=clamp(daylight*2.2,0,1)\n sky_material.sky_top_color=Color("081425").lerp(Color("79b9d9"),sky_day)')
s=s.replace('lerp(Color("e0e9d2"),daylight)','lerp(Color("d4e7df"),sky_day)')
s=s.replace('sky_material.ground_horizon_color=sky_material.sky_horizon_color','sky_material.ground_horizon_color=sky_material.sky_horizon_color\n sky_material.ground_bottom_color=Color("111d25").lerp(Color("8eb08b"),sky_day)')
p.write_text(s,encoding='utf-8')
p=Path('MakeLifeSlower/scripts/ui.gd');s=p.read_text(encoding='utf-8').replace('game.playing=false;hud.visible=false;game.modal=true','game.playing=false;hud.visible=false;game.player.visual.visible=false;game.world.update_daylight(10,game.player.position);game.modal=true')
s=s.replace('toast_label.position=Vector2(-370,130)','toast_label.position=Vector2(-370,115)')
s=s.replace('toast_label.visible=toast_time>0','toast_label.visible=toast_time>0 and not game.modal')
p.write_text(s,encoding='utf-8')
p=Path('MakeLifeSlower/scripts/main.gd');s=p.read_text(encoding='utf-8').replace('player.position=Vector3(5,.1,-2);player.yaw=.70;player.pitch=-.30','player.position=Vector3(0,.1,-6);player.yaw=.80;player.pitch=-.43;player.camera_distance=5.5')
p.write_text(s,encoding='utf-8')
