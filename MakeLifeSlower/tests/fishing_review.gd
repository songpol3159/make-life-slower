extends SceneTree
func _initialize():call_deferred("run")
func shot(name):
 await create_timer(.35).timeout;await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://"+name+"_preview.png")
func run():
 var farm=root.get_node("Farm");farm.save_enabled=false;root.get_node("Lang").set_language("th")
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.start_game(false);g.modal=true;farm.data.hour=10;g.ui.toast_time=0;g.world.update_daylight(10,g.player.position)
 g.player.position=Vector3(-44,.355,57);g.player.yaw=PI/2;g.player.pitch=-.12;g.player.first_person=false;g.ui.update_hud();await shot("fishing_dock")
 g.using_controller=false;g.start_fishing();var session=g.activity;session.press();session.advance(5);session.press();session.catch_progress=.42;session.marker=.55;await shot("fishing_reel")
 session.catch_progress=1;session.advance(0);await shot("fishing_caught");session.cancel();await process_frame
 var cow=farm.data.animals[1];cow.age=5;cow.product=2;g.using_controller=true;g.start_activity(cow.id)
 for i in range(3):g.activity.phase=g.activity.window_center;g.activity.milk(g.activity.expected)
 await shot("milk_moving");g.activity.cancel();await process_frame
 g.player.position=Vector3(2,.1,10);g.player.yaw=0;g.using_controller=true;g.ui.update_hud();await shot("hud_controller")
 g.using_controller=false;g.ui.update_hud();await shot("hud_keyboard")
 print("FISHING_REVIEW_RENDERED");g.queue_free();await process_frame;await process_frame;quit()
