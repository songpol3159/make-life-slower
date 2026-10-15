extends SceneTree
var checks=0
var failures=0
func _initialize():call_deferred("run")
func verify(value,message):
 checks+=1
 if not value:failures+=1;push_error(message)
func run():
 var farm=root.get_node("Farm");farm.save_enabled=false
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.start_game(false);g.modal=true
 await process_frame;await process_frame
 var equipment=load("res://scripts/equipment_assets.gd")
 for key in ["watering_can","fishing_rod","tool-hoe","tool-hoe-upgraded"]:
  var model=equipment.make(key,.7);g.world.add_child(model);var box=equipment.bounds(model)
  verify(is_equal_approx(max(box.size.x,max(box.size.y,box.size.z)),.7),"Imported equipment normalized: "+key)
  verify(model.find_children("*","MeshInstance3D",true,false).size()>0,"Equipment geometry exists: "+key);model.queue_free()
 var mask=Image.load_from_file("res://assets/environment/polish/road_mask.png")
 for p in [Vector2(0,12),Vector2(8,-12),Vector2(55,-58),Vector2(-26,35),Vector2(70,-58)]:
  var uv=(p+Vector2.ONE*140)/280;verify(mask.get_pixel(int(uv.x*1024),int(uv.y*1024)).r>.85,"Painted path matches route "+str(p))
 var clear=(Vector2(-18,24)+Vector2.ONE*140)/280;verify(mask.get_pixel(int(clear.x*1024),int(clear.y*1024)).r<.1,"Decoration garden remains grass")
 verify(g.world.terrain_material.get_shader_parameter("road_mask")!=null,"Ground uses one baked mask texture")
 for position in [Vector3(0,2,12),Vector3(-18,2,24)]:
  var query=PhysicsRayQueryParameters3D.create(position,position-Vector3(0,4,0));query.exclude=[g.player.get_rid(),g.world.truck.get_rid()];var hit=g.world.get_world_3d().direct_space_state.intersect_ray(query)
  verify(not hit.is_empty() and abs(hit.position.y-g.world.ground(position))<.03,"Path/grass collision has no raised strip")
 farm.data.day=26;g.world.season_fx.sync();verify(g.world.mats["75584c"].get_shader_parameter("snow_amount")==1,"Textured roof keeps seasonal snow")
 farm.data.day=1;g.world.season_fx.sync();verify(g.world.mats["75584c"].get_shader_parameter("snow_amount")==0,"Roof snow melts")
 g.tool=1;g.player.shown_tool=-1;g.player.tool_visual();verify(g.player.hand_tool.get_child_count()==1,"Watering tool uses imported model")
 g.start_fishing();verify(g.activity.scene.find_children("*","MeshInstance3D",true,false).size()>3,"Fishing uses imported rod/reel model");g.activity.cancel()
 print("VISUAL_POLISH_TESTS ",checks," checks, ",failures," failures");g.queue_free();await process_frame;await process_frame;quit(1 if failures else 0)
