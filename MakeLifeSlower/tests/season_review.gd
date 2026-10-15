extends SceneTree
func _initialize():call_deferred("run")
func shot(name):
 await create_timer(.7).timeout;await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://season_"+name+"_preview.png")
func run():
 var farm=root.get_node("Farm");farm.save_enabled=false;root.get_node("Lang").set_language("th")
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.start_game(false);g.modal=true;g.player.set_physics_process(false);g.player.visual.visible=false;g.ui.hud.visible=false;g.ui.toast_time=0
 for record in [["spring",1],["rain",2],["autumn",19],["winter",26]]:
  farm.data.day=record[1];farm.data.hour=10;g.world.refresh();g.world.season_fx.sync();g.player.position=Vector3(-26,5,20);g.player.camera.global_position=g.player.position;g.player.camera.look_at(Vector3(-7,1,-8));g.world.update_daylight(10,g.player.position);await shot(record[0])
 farm.data.day=1;g.world.season_fx.sync();g.begin_sleep();await shot("sleep");g.sleep_scene.finish();await process_frame
 g.modal=false;var npc=g.world.targets.filter(func(n):return n.get_meta("kind","")=="market")[0];g.player.position=npc.position+Vector3(0,0,1);g.target=npc;g.using_controller=true;g.update_npc();g.ui.hud.visible=true;g.ui.update_hud();await shot("npc")
 g.ui.journal();await shot("requests")
 g.ui.close();g.ui.hud.visible=false;g.player.set_physics_process(false);g.player.camera.global_position=Vector3(6,2.6,8);g.player.camera.look_at(Vector3(12,.7,8));await shot("fence")
 print("SEASON_REVIEW_RENDERED");g.queue_free();await process_frame;await process_frame;quit()
