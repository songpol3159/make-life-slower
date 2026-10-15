extends Node3D
var world
var signature=""
var targets=[]
var lamps=[]
var timer=0.0
func _process(dt):
 timer+=dt
 if timer<.4:return
 timer=0
 Life.ensure()
 var key=JSON.stringify(Farm.data.decorations)+JSON.stringify(Farm.data.machines.keys())+Life.festival()+Lang.language
 if key!=signature:signature=key;rebuild()
 var night=Farm.data.hour<6 or Farm.data.hour>=18
 for lamp in lamps:lamp.visible=night
func target(node,kind,title):
 node.set_meta("kind",kind);node.set_meta("title",title);world.targets.append(node);targets.append(node)
func collide(node,size):
 var body=StaticBody3D.new();var shape=CollisionShape3D.new();var box=BoxShape3D.new();box.size=size;shape.shape=box;shape.position.y=size.y*.5;body.add_child(shape);node.add_child(body)
func rebuild():
 for node in targets:world.targets.erase(node)
 targets.clear();lamps.clear()
 for child in get_children():child.queue_free()
 for record in Farm.data.decorations:
  var node=Node3D.new();add_child(node);node.position=Vector3(record.x,0,record.z);node.position.y=world.ground(node.position);node.rotation.y=record.rotation
  match record.kind:
   "path":world.cylinder(node,Vector3(0,.025,0),.57,.05,"bcac8a")
   "fence":
    for x in [-.55,.55]:world.cylinder(node,Vector3(x,.55,0),.065,1.1,"bca078")
    for y in [.4,.8]:world.box(node,Vector3(0,y,0),Vector3(1.1,.08,.08),"d8bd91")
    collide(node,Vector3(1.2,1.1,.18))
   "lamp":
    world.cylinder(node,Vector3(0,.7,0),.045,1.4,"655642");world.box(node,Vector3(0,1.5,0),Vector3(.28,.34,.28),"e8d29a");world.cone(node,Vector3(0,1.77,0),.24,.2,"655642")
    var light=OmniLight3D.new();light.position.y=1.5;light.light_color=Color("ffe1a0");light.omni_range=4;light.light_energy=.7;light.shadow_enabled=false;node.add_child(light);lamps.append(light);collide(node,Vector3(.25,1.6,.25))
   "pot":
    world.cylinder(node,Vector3(0,.2,0),.24,.4,"b67759");world.cylinder(node,Vector3(0,.42,0),.27,.08,"cb8e6b")
    for x in [-.12,0,.12]:
     world.cylinder(node,Vector3(x,.6,0),.014,.36,"75955c")
     for a in range(5):world.sphere(node,Vector3(x+cos(a*TAU/5)*.08,.8,sin(a*TAU/5)*.08),Vector3(.10,.045,.10),"edc1b9")
     world.sphere(node,Vector3(x,.82,0),Vector3(.065,.035,.065),"e6c479")
    collide(node,Vector3(.5,.5,.5))
 for i in range(Life.RECIPES.size()):
  var kind=Life.RECIPES.keys()[i]
  if not Farm.data.machines.has(kind):continue
  var machine=Node3D.new();add_child(machine);machine.position=Vector3(-19+i*2.4,0,13);machine.position.y=world.ground(machine.position)
  world.box(machine,Vector3(0,.38,0),Vector3(1.35,.7,.8),"977857");world.box(machine,Vector3(0,.77,0),Vector3(1.45,.1,.9),"d6bd8e")
  world.cylinder(machine,Vector3(0,1,0),.32,.42,{"cheese":"e1bd62","mayo":"e6d9b2","yarn":"9ab5b1","pickles":"91aa71"}[kind])
  target(machine,"processing",Lang.t("โรงแปรรูป")+" · "+Life.item_title(kind));collide(machine,Vector3(1.4,1.2,.9))
  world.label3(machine,Life.item_title(kind),Vector3(0,1.6,0),20)
 if Life.festival()!="":
  var stage=Node3D.new();add_child(stage);stage.position=Vector3(53,0,-49);stage.position.y=world.ground(stage.position)
  for x in [-2,2]:world.cylinder(stage,Vector3(x,1.5,0),.065,3,"a58d64")
  for i in range(7):
   var flag=world.box(stage,Vector3(-1.8+i*.6,2.7,0),Vector3(.42,.35,.035),["dc9e80","e0c479","a7bd9b"][i%3]);flag.rotation.z=.15 if i%2 else -.15
  world.label3(stage,Life.festival_title(Life.festival()),Vector3(0,2,0),24);target(stage,"festival",Life.festival_title(Life.festival()))
