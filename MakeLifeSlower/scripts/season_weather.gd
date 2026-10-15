extends Node3D
var world
var day=-1
var weather="clear"
var snow=0.0
var autumn=0.0
var rain_particles
var snow_particles
var leaf_particles
func _init(owner):world=owner
func _ready():
 rain_particles=particles(300,1.4,14,Color("b9d1dc"),true)
 snow_particles=particles(220,6,1.5,Color("f2f6f7"),false)
 leaf_particles=particles(35,7,.7,Color("dca659"),false)
 sync()
func particles(count,lifetime,speed,color,rain):
 var p=CPUParticles3D.new();p.amount=count;p.lifetime=lifetime;p.emitting=false;p.local_coords=false;p.emission_shape=CPUParticles3D.EMISSION_SHAPE_BOX;p.emission_box_extents=Vector3(11,.1,11);p.direction=Vector3.DOWN;p.spread=12;p.gravity=Vector3(.08,-.4,.06);p.initial_velocity_min=speed*.8;p.initial_velocity_max=speed;p.scale_amount_min=.8;p.scale_amount_max=1.2
 var mesh=BoxMesh.new();mesh.size=Vector3(.009,.19,.009) if rain else Vector3.ONE*.045;var material=StandardMaterial3D.new();material.albedo_color=color;material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;mesh.material=material;p.mesh=mesh;p.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(p);return p
func sync():
 day=int(Farm.data.day);weather=Farm.weather_for(day)
 var season=Farm.season_index();var within=(day-1)%7
 snow=clamp((within+1)*.22,0,1) if season==3 else max(0.0,1.0-(within+1)*.4) if season==0 and day>28 else 0.0
 autumn=smoothstep(0,4,float(within+1)) if season==2 else 0.0
 world.terrain_material.set_shader_parameter("snow_amount",snow)
 world.terrain_material.set_shader_parameter("season_tint",Color("dcc68d") if season==2 else Color("e0efcf") if season==0 else Color.WHITE)
 for material in world.season_materials:material.set_shader_parameter("autumn",autumn);material.set_shader_parameter("snow_amount",snow)
 if world.mats.has("75584c"):world.mats["75584c"].set_shader_parameter("snow_amount",snow)
 Farm.apply_rain_water()
func _process(_dt):
 if int(Farm.data.day)!=day:sync()
 if not world.game or not world.game.player:return
 var p=world.game.player.position
 for effect in [rain_particles,snow_particles,leaf_particles]:effect.position=p+Vector3(0,8,0)
 var roof=false
 for building in [[Vector2(-7,4),Vector2(4,3.5)],[Vector2(24,-5),Vector2(5,3.5)],[Vector2(48,-67),Vector2(4,3)],[Vector2(62,-67),Vector2(4,3)],[Vector2(76,-67),Vector2(4,3)]]:
  if abs(p.x-building[0].x)<building[1].x and abs(p.z-building[0].y)<building[1].y:roof=true
 rain_particles.emitting=weather=="rain" and not roof
 snow_particles.emitting=weather=="snow" and not roof
 leaf_particles.emitting=Farm.season_index()==2 and not roof
func lighting():
 if weather in ["rain","snow"]:world.sun.light_energy*=.72
