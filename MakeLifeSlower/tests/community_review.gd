extends SceneTree
func _initialize():call_deferred("run")
func shot(name):
 await create_timer(.5).timeout;await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://community_"+name+"_preview.png")
func run():
 var farm=root.get_node("Farm");farm.save_enabled=false;root.get_node("Lang").set_language("th")
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.start_game(false);g.modal=true;g.player.set_physics_process(false);g.player.visual.visible=false;g.ui.toast_time=0
 farm.data.money=5000;farm.data.day=6;farm.data.hour=16;farm.add_good("tomato",2);farm.add_good("milk",5);farm.add_good("egg",5)
 for key in ["cheese","mayo","yarn"]:root.get_node("Life").buy_machine(key)
 root.get_node("Life").start_batch("cheese")
 root.get_node("Life").place_decoration("lamp",Vector2(-18,20),0)
 root.get_node("Life").place_decoration("pot",Vector2(-16,20),0)
 root.get_node("Life").place_decoration("fence",Vector2(-14,20),0)
 root.get_node("Life").place_decoration("path",Vector2(-18,22),PI/2)
 g.ui.hud.visible=false;g.player.camera.global_position=Vector3(-26,9,29);g.player.camera.look_at(Vector3(-13,.3,17));g.world.update_daylight(16,g.player.position);await shot("garden_world")
 for menu in ["processing","calendar","decorations","saves"]:g.ui.community.call(menu);await shot(menu)
 g.ui.community.npc("market");await shot("npc")
 g.ui.community.editor("lamp");await shot("editor")
 root.get_node("Lang").set_language("en");g.ui.community.processing();await shot("english")
 g.ui.close();g.modal=true;g.start_fishing();g.activity.press();g.activity.advance(5);g.activity.press();g.activity.state_time=4.8;g.activity.fish_phase=0;g.activity.advance(.01);await shot("fishing");g.activity.cancel()
 print("COMMUNITY_REVIEW_RENDERED");g.queue_free();await process_frame;await process_frame;quit()
