extends SceneTree
func _initialize():call_deferred("run")
func run():
 var farm=root.get_node("Farm");farm.save_enabled=false
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.start_game(false);g.modal=true;g.player.set_physics_process(false);g.player.visual.visible=false;g.ui.hud.visible=false;g.ui.toast_time=0
 var nature=load("res://scripts/nature_assets.gd").new(g.world)
 var i=0
 for key in ["CommonTree_1","CommonTree_3","CommonTree_4"]:
  nature.place(key,Vector3(-15+i*10,0,42),8,0,true);g.world.label3(g.world,key,Vector3(-15+i*10,9,42),30);i+=1
 nature.flush(g.world);g.player.position=Vector3(-4,6,63);g.player.camera.global_position=g.player.position;g.player.camera.look_at(Vector3(-4,4,42));g.world.update_daylight(15,g.player.position)
 await create_timer(.8).timeout;await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://tree_lineup_preview.png");quit()
