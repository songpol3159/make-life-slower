from pathlib import Path
p=Path('MakeLifeSlower/scripts/world.gd');s=p.read_text(encoding='utf-8')
def replace_func(name,new):
 global s
 start=s.index('func '+name+'(');end=s.find('\nfunc ',start+5)
 s=s[:start]+new.rstrip()+'\n'+(s[end+1:] if end!=-1 else '')
s=s.replace('var crop_visuals','var sky_material\nvar sun_disc\nvar moon_disc\nvar lantern\nvar village_lights=[]\nvar clouds\nvar crop_visuals',1)
s=s.replace('sky.sky_material=sm','sky_material=sm;sky.sky_material=sm')
s=s.replace('  if o.skin or o.material_override==terrain_material:continue','  if o.skin or o.material_override==terrain_material or o.get_meta("dynamic",false):continue')
s=s.replace('ancestor==house or ancestor==truck','ancestor.get_meta("dynamic",false) or ancestor==house or ancestor==truck')
s=s.replace(' batch_static(self)',' batch_static(self)\n setup_lights()',1)
s=s.replace('st.set_color(Color(.27*shade,.44*shade,.24*shade))','st.set_color(Color(.36*shade,.55*shade,.27*shade))')
s=s.replace('for i in range(35):','for i in range(12):',1)
replace_func('mountains','''func mountains():
 # Two peaks share the northern horizon; the other map edges stay open.
 for i in range(2):
  var h=115.0 if i==0 else 150.0;var p=Vector3(-100+i*185,-5,-350-i*45)
  var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);var rings=[]
  for ring in range(6):
   var verts=[]
   for j in range(20):
    var a=float(j)/20*TAU;var t=float(ring)/5;var radius=(1-t)*135*(.9+rng.randf()*.15)
    verts.append(p+Vector3(sin(a)*radius+t*18,t*h+sin(j*1.7)*h*.025,cos(a)*radius))
   rings.append(verts)
  for r in range(5):
   for j in range(20):
    for idx in [[r,j],[r+1,j],[r,(j+1)%20],[r,(j+1)%20],[r+1,j],[r+1,(j+1)%20]]:
     var v=rings[idx[0]][idx[1]];st.set_color(Color("ecefdf") if v.y>h*.68 else Color("879f9b") if v.y>h*.32 else Color("6f927c"));st.add_vertex(v)
  st.generate_normals();var o=MeshInstance3D.new();o.mesh=st.commit();var m=StandardMaterial3D.new();m.vertex_color_use_as_albedo=true;m.roughness=1;m.cull_mode=BaseMaterial3D.CULL_DISABLED;o.material_override=m;o.set_meta("mountain",true);add_child(o)
 clouds=Node3D.new();clouds.set_meta("dynamic",true);add_child(clouds)
 for i in range(8):
  var group=Node3D.new();group.position=Vector3(-210+i*60,60+(i%3)*9,-160+(i%4)*60);clouds.add_child(group)
  for j in range(7):
   var offset=Vector3((j-3)*4.4,2.0*sin(j*1.9),cos(j*2.1)*3)
   var cloud=sphere(group,offset,Vector3(9,6+(j%3)*2,7),"f4f0df");cloud.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
''')
replace_func('trees','''func trees():
 # Forest clusters leave the farm, market, roads and lake shore clear.
 var positions=[]
 var zones=[Vector2(-103,-67),Vector2(107,-5),Vector2(76,101),Vector2(-98,104),Vector2(7,-119)]
 for i in range(230):
  var zone=zones[i%zones.size()];var a=rng.randf()*TAU;var r=sqrt(rng.randf())*32
  var p=Vector3(zone.x+cos(a)*r,0,zone.y+sin(a)*r)
  if abs(p.x)>137 or abs(p.z)>137 or near_road(p,6) or abs(p.x+62)<10:continue
  if p.distance_to(Vector3(-58,0,57))<23:continue
  p.y=ground(p);positions.append(p)
  var body=StaticBody3D.new();var c=CollisionShape3D.new();var trunk=CylinderShape3D.new();trunk.radius=.30;trunk.height=3.6;c.shape=trunk;c.position.y=1.8;body.position=p;body.set_meta("tree",true);body.add_child(c);add_child(body)
 # A handful of shade trees close to home, all away from walking routes.
 for p in [Vector3(-22,0,9),Vector3(-25,0,-30),Vector3(39,0,30),Vector3(85,0,-43)]:positions.append(p)
 for part in range(5):
  var mesh
  if part==0:
   mesh=CylinderMesh.new();mesh.top_radius=.19;mesh.bottom_radius=.32;mesh.height=3.8;mesh.radial_segments=8
  else:mesh=SphereMesh.new();mesh.radial_segments=12;mesh.rings=6
  var mm=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=mesh;mm.instance_count=positions.size()
  for i in range(positions.size()):
   var scale_v=.8+float(i%7)*.085;var offsets=[Vector3(0,1.9,0),Vector3(0,4.4,0),Vector3(-1.2,3.7,.4),Vector3(1.1,3.9,-.4),Vector3(.3,5.3,.3)]
   var size=Vector3.ONE*scale_v if part==0 else Vector3(4.3,3.3,4.0)*scale_v
   mm.set_instance_transform(i,Transform3D(Basis().scaled(size),positions[i]+offsets[part]*scale_v))
  var inst=MultiMeshInstance3D.new();inst.multimesh=mm;inst.material_override=mat(["80644b","5e934e","6c9c54","709f57","82ad62"][part]);inst.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(inst)
 flowers()
func flowers():
 var groups={};var petal=SphereMesh.new();petal.radial_segments=8;petal.rings=4
 var stem=CylinderMesh.new();stem.top_radius=.018;stem.bottom_radius=.018;stem.height=.28;stem.radial_segments=5
 for i in range(120):
  var centers=[Vector3(-20,0,8),Vector3(-24,0,-28),Vector3(42,0,-47),Vector3(81,0,-48),Vector3(-39,0,62)]
  var p=centers[i%5]+Vector3(rng.randf_range(-2.5,2.5),0,rng.randf_range(-2,2));p.y=ground(p)
  if near_road(p,3):continue
  crop_part(groups,"stems",stem,p+Vector3(0,.14,0),Vector3.ONE,"60844a")
  crop_part(groups,"leaves",petal,p+Vector3(.08,.10,0),Vector3(.19,.055,.075),"6a9852",.3)
  var color=["efd483","e7b4b3","f1ead7"][i%3]
  for j in range(5):crop_part(groups,"petals"+str(i%3),petal,p+Vector3(sin(j*TAU/5)*.075,.3,cos(j*TAU/5)*.075),Vector3(.12,.045,.10),color)
  crop_part(groups,"centers",petal,p+Vector3(0,.32,0),Vector3(.075,.055,.075),"c7a551")
 for group in groups.values():
  var mm=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=group.mesh;mm.instance_count=group.transforms.size()
  for i in range(group.transforms.size()):mm.set_instance_transform(i,group.transforms[i])
  var inst=MultiMeshInstance3D.new();inst.multimesh=mm;inst.material_override=mat(group.color);inst.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(inst)
''')
replace_func('grass','''func grass():
 # Smooth meadow instead of thousands of individual grass blades.
 box(self,Vector3(-46,.20,57),Vector3(10,.22,2),"a18560")
 bench(Vector3(-44,0,62),PI/2)
func bench(p,angle=0.0):
 var holder=Node3D.new();holder.position=p;holder.rotation.y=angle;holder.set_meta("bench",true);add_child(holder)
 box(holder,Vector3(0,.55,0),Vector3(2,.16,.65),"a48761")
 box(holder,Vector3(0,.95,.27),Vector3(2,.55,.13),"b79a71")
 for x in [-.75,.75]:box(holder,Vector3(x,.26,0),Vector3(.12,.52,.5),"80644b")
 var body=StaticBody3D.new();var c=CollisionShape3D.new();var sh=BoxShape3D.new();sh.size=Vector3(2,1.2,.7);c.shape=sh;c.position.y=.6;body.add_child(c);holder.add_child(body)
''')
start=s.index(' for i in range(4):',s.index('func village'));end=s.index('func farm_buildings',start)
s=s[:start]+''' for p in [Vector3(43,0,-47),Vector3(78,0,-47)]:bench(p,PI)
 # Parking bays sit beside the village lane, outside shop entrances.
 for x in [61,66]:
  box(self,Vector3(x,.025,-51),Vector3(3.7,.05,5),"c5b991")
  for side in [-1,1]:box(self,Vector3(x+side*1.7,.065,-51),Vector3(.08,.025,4.5),"eee0bd")
'''+s[end:]
s=s.replace('Vector3(48,0,-62),"market"','Vector3(46.2,0,-63),"market"').replace('Vector3(62,0,-62),"livestock"','Vector3(60.2,0,-63),"livestock"').replace('Vector3(76,0,-62),"upgrade"','Vector3(74.2,0,-63),"upgrade"')
s=s.replace('  box(n,Vector3(0,.06,0),Vector3(2.4,.12,2.4),"b09c75" if not p.tilled else "695d40" if p.water else "917552")','''  rounded_plot(n,"b5aa7c" if not p.tilled else "66523a" if p.water else "947049",i<Farm.max_plots())''')
s += '''
func rounded_plot(n,color,unlocked):
 # A rounded outline is built from short straight rails and quarter-circle corners.
 var soil=CylinderMesh.new();soil.top_radius=1;soil.bottom_radius=1;soil.height=.10;soil.radial_segments=32
 # Rounded-square mesh with a subtly uneven soil top.
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);var edge=[]
 for corner in range(4):
  var center=[Vector2(.97,.97),Vector2(-.97,.97),Vector2(-.97,-.97),Vector2(.97,-.97)][corner]
  for j in range(7):
   var a=(corner*90+j*15)*PI/180;edge.append(Vector3(center.x+cos(a)*.21,.12,center.y+sin(a)*.21))
 for i in range(edge.size()):
  for v in [Vector3(0,.12,0),edge[(i+1)%edge.size()],edge[i]]:st.set_normal(Vector3.UP);st.add_vertex(v)
 shape(n,st.commit(),Vector3.ZERO,color)
 if not unlocked:return
 var wood="96afa0"
 for side in [-1,1]:
  box(n,Vector3(side*1.2,.14,0),Vector3(.09,.20,1.94),wood)
  box(n,Vector3(0,.14,side*1.2),Vector3(1.94,.20,.09),wood)
 for corner in range(4):
  var center=[Vector2(.97,.97),Vector2(-.97,.97),Vector2(-.97,-.97),Vector2(.97,-.97)][corner]
  for j in range(6):
   var a=(corner*90+j*15+7.5)*PI/180
   var rail=box(n,Vector3(center.x+cos(a)*.23,.14,center.y+sin(a)*.23),Vector3(.09,.20,.063),wood);rail.rotation.y=-a
 for j in range(12):
  var a=j*2.39;var r=.25+float(j%4)*.2;sphere(n,Vector3(sin(a)*r,.125,cos(a)*r),Vector3(.035,.015,.027),"a58a65")
 batch_static(n)
func setup_lights():
 sun_disc=sphere(self,Vector3(0,140,-270),Vector3.ONE*13,"fff0c2");sun_disc.set_meta("dynamic",true)
 var glow=mat("fff0c2").duplicate();glow.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;sun_disc.material_override=glow;sun_disc.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 moon_disc=sphere(self,Vector3(120,140,-240),Vector3.ONE*9,"e2e9dd");moon_disc.set_meta("dynamic",true);var moonmat=glow.duplicate();moonmat.albedo_color=Color("e2e9dd");moon_disc.material_override=moonmat
 lantern=OmniLight3D.new();lantern.omni_range=8;lantern.light_color=Color("ffd59c");lantern.light_energy=1.4;lantern.shadow_enabled=false;add_child(lantern)
 for p in [Vector3(-7,2.2,7.4),Vector3(24,2.1,-1.6),Vector3(48,2.3,-63.4),Vector3(62,2.3,-63.4),Vector3(76,2.3,-63.4)]:
  var lamp=OmniLight3D.new();lamp.position=p;lamp.omni_range=6;lamp.light_color=Color("ffcb82");lamp.light_energy=1.1;lamp.shadow_enabled=false;add_child(lamp);village_lights.append(lamp)
  var bulb=sphere(self,p,Vector3(.16,.24,.16),"ffe3a7");bulb.material_override=glow
func update_daylight(hour,player_position):
 var daylight=clamp(sin((hour-6)/12*PI),0.0,1.0)
 sun.light_energy=.035+daylight*.85;sun.rotation_degrees=Vector3(-max(8,daylight*65),-30,0)
 var e=environment.environment;e.ambient_light_energy=.045+daylight*.37;e.fog_light_color=Color("18293f").lerp(Color("c6ddce"),daylight)
 sky_material.sky_top_color=Color("081425").lerp(Color("78b9cf"),daylight)
 sky_material.sky_horizon_color=Color("263a4d").lerp(Color("e0e9d2"),daylight)
 sky_material.ground_horizon_color=sky_material.sky_horizon_color
 sun_disc.visible=hour>6 and hour<18;sun_disc.position=Vector3(-cos((hour-6)/12*PI)*270,daylight*170,-260)
 moon_disc.visible=not sun_disc.visible
 lantern.visible=daylight<.15;lantern.position=player_position+Vector3(0,1.5,-.4)
 for lamp in village_lights:lamp.visible=daylight<.25
'''
# More leaves and stronger crop silhouettes, retaining grouped draw calls.
s=s.replace('Vector3(.09,.35,.13)*grow','Vector3(.13,.48,.16)*grow').replace('Vector3(.36,.14,.29)*grow','Vector3(.44,.16,.34)*grow').replace('Vector3(.5,.12,.4)*grow','Vector3(.60,.15,.48)*grow')
p.write_text(s,encoding='utf-8')
