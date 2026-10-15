extends Node3D
var game
var record_id
var model
var ap
var stage=""
var destination=Vector3.ZERO
var wander=0.0
var voice=0.0
var eat_time=0.0
func _ready():
 set_meta("kind","animal");set_meta("id",record_id)
 var a=Farm.animal_by_id(record_id);position=Vector3(float(a.x),0,float(a.z));refresh()
func refresh():
 var a=Farm.animal_by_id(record_id)
 if a.is_empty():return
 set_meta("title",Farm.SPECIES[a.species].title+(" ★" if int(a.breed)>0 else "")+(Lang.t(" · โตเต็มวัย") if Farm.mature(a) else Lang.t(" · วัยเด็ก")))
 var next="adult" if Farm.mature(a) else "young"
 if next==stage:return
 stage=next
 if model:model.visible=false;model.queue_free()
 model=load("res://assets/models/"+a.species+"_"+stage+".glb").instantiate();add_child(model);model.rotation.y=PI/2
 if a.species in ["cat","dog"]:model.scale=Vector3.ONE*(1.4 if next=="young" else 1.25)
 ap=model.find_child("AnimationPlayer",true,false);play("Idle")
func play(which):
 if not ap:return
 for anim in ap.get_animation_list():
  if which in anim:
   if ap.current_animation!=anim:ap.get_animation(anim).loop_mode=Animation.LOOP_LINEAR;ap.play(anim,.18)
   break
func _process(dt):
 if not game or not game.playing or game.modal:return
 var a=Farm.animal_by_id(record_id)
 if a.is_empty():return
 wander-=dt;voice-=dt
 var pet=a.species in ["dog","cat"]
 if pet:
  var slot=0
  for other in Farm.data.animals:
   if int(other.id)==int(record_id):break
   if other.species in ["dog","cat"]:slot+=1
  var right=Vector3(cos(game.player.yaw),0,-sin(game.player.yaw));var behind=Vector3(sin(game.player.yaw),0,cos(game.player.yaw))
  destination=game.player.position+right*(-1.35 if slot%2==0 else 1.35)+behind*(2.1+floor(slot/2.0)*1.4)
  for other in game.world.animals.values():
   if other==self:continue
   var away=position-other.position;away.y=0
   if away.length()<1.25:destination+=away.normalized()*(1.25-away.length())*3
 elif wander<=0:destination=Vector3(randf_range(14,34),0,randf_range(2,20));wander=randf_range(4,10)
 var d=destination-position;d.y=0
 eat_time=max(0,eat_time-dt)
 if eat_time>0:play("Eat")
 elif d.length()>(.45 if pet else .8):
  rotation.y=lerp_angle(rotation.y,atan2(d.x,d.z),min(1,dt*4))
  var forward=Vector3(sin(rotation.y),0,cos(rotation.y));var alignment=forward.dot(d.normalized())
  if alignment>.2:position+=forward*dt*(1.8 if pet else .55)*alignment;play("Walk")
  else:play("Idle")
 else:play("Idle")
 position.y=game.world.ground(position)
 a.x=position.x;a.z=position.z
 if voice<=0:
  voice=randf_range(16,35)
  if position.distance_to(game.player.position)<15:game.audio.play_sfx(a.species,-8)
