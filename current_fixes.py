from pathlib import Path
P=Path(__file__).parent/'MakeLifeSlower'
def read(n):return (P/'scripts'/n).read_text(encoding='utf-8')
def write(n,s):(P/'scripts'/n).write_text(s,encoding='utf-8')
w=read('world.gd')
w=w.replace('var truck\n','var truck\nvar truck_visual\n')
w=w.replace('func ground(p):return terrain_y(p.x,p.z)', '''func ground(p):
 # Use the same triangle interpolation as the physical terrain mesh.
 var x=clamp(floor((p.x+140)/4)*4-140,-140,136);var z=clamp(floor((p.z+140)/4)*4-140,-140,136)
 var u=clamp((p.x-x)/4,0,1);var v=clamp((p.z-z)/4,0,1)
 var a=terrain_y(x,z);var b=terrain_y(x+4,z);var c=terrain_y(x,z+4);var d=terrain_y(x+4,z+4)
 return a+(b-a)*u+(c-a)*v if u+v<=1 else d+(c-d)*(1-u)+(b-d)*(1-v)''')
w=w.replace('holder.position=p;holder.rotation', 'holder.position=p;holder.position.y=ground(p);holder.rotation')
w=w.replace('var n=target(p,kind,title);var model=', 'var n=target(p,kind,title);n.position.y=ground(p);var model=')
start=w.index(' for z in range(-120,121,12):')
end=w.index(' # Wooden bridge',start)
w=w[:start]+''' var brook=[]
 for z in range(-120,121,2):brook.append(Vector3(-62+sin(z*.04)*8,0,z))
 ribbon(brook,6.2,"a9a77a",.012)
 var water_strip=ribbon(brook,4.7,"78b3bd",.028)
 var wm=ShaderMaterial.new();wm.shader=load("res://assets/water.gdshader");water_strip.material_override=wm;water_strip.set_meta("dynamic",true)
'''+w[end:]
start=w.index('func path(points,width):');end=w.index('func mountains():',start)
w=w[:start]+'''func ribbon(points,width,color,lift):
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in range(points.size()-1):
  var a=points[i];var b=points[i+1];var side=Vector3(b.z-a.z,0,a.x-b.x).normalized()*width*.5
  var corners=[a-side,a+side,b-side,b+side]
  for j in [0,2,1,1,2,3]:
   var v=corners[j];v.y=ground(v)+lift;st.set_uv(Vector2(v.x,v.z)*.15);st.add_vertex(v)
 st.generate_normals();var o=shape(self,st.commit(),Vector3.ZERO,color);o.material_override=mat(color).duplicate();o.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED;return o
func path(points,width):
 var samples=[]
 for i in range(points.size()-1):
  var steps=int(ceil(points[i].distance_to(points[i+1])/2))
  for j in range(steps):samples.append(points[i].lerp(points[i+1],float(j)/steps))
 samples.append(points[-1]);ribbon(samples,width,"bdad88",.025)
'''+w[end:]
# Close both ends of a roof, using its actual pitch instead of a fixed gable height.
w=w.replace(' var roof=box(n,Vector3(s*size.x*.25,size.y+.8,0),Vector3(size.x*.62,.20,size.z+1),"75584c");roof.rotation.z=s*-.40', ' var span=size.x*.5+.5;var ridge=size.y+size.x*.5*tan(.4)\n  var roof=box(n,Vector3(s*span*.5,ridge-span*.5*tan(.4),0),Vector3(span/cos(.4),.20,size.z+1),"75584c");roof.rotation.z=s*-.40')
start=w.index(' var gable=ArrayMesh.new()');end=w.index(' box(n,Vector3(-size.x*.5+.45',start)
w=w[:start]+''' for side in [-1,1]:
  var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
  for v in [Vector3(-size.x*.5,size.y-.04,side*size.z*.5),Vector3(0,size.y+size.x*.5*tan(.4),side*size.z*.5),Vector3(size.x*.5,size.y-.04,side*size.z*.5)]:st.add_vertex(v)
  st.generate_normals();var gable=shape(n,st.commit(),Vector3.ZERO,"98714f");gable.material_override=mat("98714f").duplicate();gable.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED
'''+w[end:]
w=w.replace('if o.position.y>size.y:continue','if o.position.y>size.y and o.mesh.size.z<size.z:continue').replace('if o.mesh.size.y<.3:continue','if o.mesh.size.y<.3 and o.position.y<size.y:continue').replace('body.position=o.position;body.add_child(c);n.add_child(body)','body.position=o.position;body.rotation=o.rotation;body.add_child(c);n.add_child(body)')
# Visually rounded pickup, with a separate suspension visual from the physics body.
start=w.index('func create_truck():');end=w.index('func rounded_plot',start)
w=w[:start]+'''func soft_box(parent,p,size,color,radius=.12):
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);var edge=[]
 var r=min(radius,min(size.x,size.z)*.45)
 for corner in range(4):
  var center=[Vector2(size.x*.5-r,size.z*.5-r),Vector2(-size.x*.5+r,size.z*.5-r),Vector2(-size.x*.5+r,-size.z*.5+r),Vector2(size.x*.5-r,-size.z*.5+r)][corner]
  for j in range(6):
   var a=(corner*90+j*18)*PI/180;edge.append(center+Vector2(cos(a),sin(a))*r)
 for i in range(edge.size()):
  var a=edge[i];var b=edge[(i+1)%edge.size()];var lo=Vector3(a.x,-size.y*.5,a.y);var hi=Vector3(a.x,size.y*.5,a.y);var lb=Vector3(b.x,-size.y*.5,b.y);var hb=Vector3(b.x,size.y*.5,b.y)
  for v in [lo,hi,lb,lb,hi,hb,Vector3(0,size.y*.5,0),hb,hi,Vector3(0,-size.y*.5,0),lo,lb]:st.add_vertex(v)
 st.generate_normals();var o=shape(parent,st.commit(),p,color);o.material_override=mat(color).duplicate();o.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED;return o
func create_truck():
 truck=CharacterBody3D.new();truck.position=Vector3(5,0,14);truck.floor_snap_length=.6;add_child(truck);truck.set_meta("kind","truck");truck.set_meta("title","ขึ้นรถ / ลงรถ · E");targets.append(truck)
 var collision=CollisionShape3D.new();var sh=BoxShape3D.new();sh.size=Vector3(1.8,1.6,3.2);collision.shape=sh;collision.position.y=.8;truck.add_child(collision)
 truck_visual=Node3D.new();truck_visual.set_meta("dynamic",true);truck.add_child(truck_visual)
 soft_box(truck_visual,Vector3(0,.68,0),Vector3(1.72,.5,3.16),"679b8d",.24)
 soft_box(truck_visual,Vector3(0,1.12,-1.03),Vector3(1.68,.34,1.03),"8ab7a3",.23)
 soft_box(truck_visual,Vector3(0,1.42,-.28),Vector3(1.54,.74,1.10),"294b50",.18)
 soft_box(truck_visual,Vector3(0,1.81,-.28),Vector3(1.65,.13,1.23),"dfd8bd",.20)
 for x in [-.79,.79]:
  soft_box(truck_visual,Vector3(x,1.01,-.28),Vector3(.07,.49,1.09),"8ab7a3",.03)
  for z in [-.79,.23]:box(truck_visual,Vector3(x,1.47,z),Vector3(.07,.62,.07),"b7d4bc")
  box(truck_visual,Vector3(x*1.07,1.12,-.19),Vector3(.025,.035,.18),"e5d7b5")
  soft_box(truck_visual,Vector3(x*1.14,1.43,-.72),Vector3(.16,.16,.21),"dfd8bd",.05)
  soft_box(truck_visual,Vector3(x,1.04,1.03),Vector3(.12,.48,1.13),"8ab7a3",.05)
 soft_box(truck_visual,Vector3(0,1.04,1.57),Vector3(1.7,.48,.12),"8ab7a3",.05)
 soft_box(truck_visual,Vector3(0,.96,1.03),Vector3(1.40,.07,1.04),"756b50",.06)
 for x in [-.88,.88]:
  for z in [-1.08,1.07]:
   var wheel=cylinder(truck_visual,Vector3(x,.38,z),.38,.24,"353f3c");wheel.rotation.z=PI/2
   var rim=cylinder(truck_visual,Vector3(x*1.14,.38,z),.22,.035,"d5d2b9");rim.rotation.z=PI/2
   var hub=cylinder(truck_visual,Vector3(x*1.17,.38,z),.08,.04,"718b7e");hub.rotation.z=PI/2
 for z in [-1.61,1.64]:soft_box(truck_visual,Vector3(0,.61,z),Vector3(1.76,.15,.16),"ded6bd",.06)
 soft_box(truck_visual,Vector3(0,.90,-1.596),Vector3(.73,.22,.03),"344b48",.015)
 for x in [-.59,.59]:
  soft_box(truck_visual,Vector3(x,.96,-1.595),Vector3(.29,.22,.045),"fff0c3",.06)
  soft_box(truck_visual,Vector3(x,.96,1.64),Vector3(.18,.24,.04),"c87766",.03)
 batch_static(truck_visual)
func align_truck():
 var front=truck.to_global(Vector3(0,0,-1.08));var back=truck.to_global(Vector3(0,0,1.07))
 var left=truck.to_global(Vector3(-.88,0,0));var right=truck.to_global(Vector3(.88,0,0))
 truck_visual.rotation.x=clamp(atan2(ground(front)-ground(back),2.15),-.35,.35)
 truck_visual.rotation.z=clamp(atan2(ground(right)-ground(left),1.76),-.35,.35)
 truck_visual.position.y=clamp(ground(truck.position)-truck.position.y,-.3,.3)

'''+w[end:]
# Avoid rebatching the visual suspension into the truck root.
w=w.replace(' batch_static(truck)\n','')
write('world.gd',w)
a=read('animal.gd').replace('if model:model.queue_free()','if model:model.visible=false;model.queue_free()')
a=a.replace('ap=model.find_child', 'if a.species in ["cat","dog"]:model.scale=Vector3.ONE*(1.4 if next=="young" else 1.25)\n ap=model.find_child')
a=a.replace('if pet:destination=game.player.position+Vector3(1.5,0,1.5)', '''if pet:
  var slot=0
  for other in Farm.data.animals:
   if int(other.id)==int(record_id):break
   if other.species in ["dog","cat"]:slot+=1
  var right=Vector3(cos(game.player.yaw),0,-sin(game.player.yaw));var behind=Vector3(sin(game.player.yaw),0,cos(game.player.yaw))
  destination=game.player.position+right*(-1.35 if slot%2==0 else 1.35)+behind*(2.1+floor(slot/2.0)*1.4)
  for other in game.world.animals.values():
   if other==self:continue
   var away=position-other.position;away.y=0
   if away.length()<1.25:destination+=away.normalized()*(1.25-away.length())*3''').replace('(2.0 if pet else .8)','(.45 if pet else .8)')
write('animal.gd',a)
s=read('player.gd').replace('  position=car.position+Vector3(0,.3,0);visual.visible=false','  game.world.align_truck()\n  position=car.position+Vector3(0,.3,0);visual.visible=false');write('player.gd',s)
s=read('farm.gd').replace('func save_settings():\n','func save_settings():\n if not save_enabled:return\n');write('farm.gd',s)
m=read('main.gd').replace(' smoke="--smoke" in OS.get_cmdline_user_args()',' if "--smoke" in OS.get_cmdline_user_args():Farm.save_enabled=false\n smoke="--smoke" in OS.get_cmdline_user_args()')
write('main.gd',m)
