extends SceneTree
func _initialize():call_deferred("run")
func run():
 var farm=root.get_node("Farm");farm.save_enabled=false;root.get_node("Lang").set_language("th")
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.start_game(false);farm.data.barn_level=2
 for species in ["duck","goat","sheep","pig","dog","cat"]:farm.add_animal(species,0,false)
 for a in farm.data.animals:a.age=5;a.product=2
 g.world.refresh();await process_frame
 for a in farm.data.animals:
  g.using_controller=a.species in ["cow","cat","duck","dog"];g.start_activity(int(a.id));await create_timer(.6).timeout;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://activity_"+a.species+"_preview.png")
  g.activity.cancel();await process_frame
 g.begin_sleep();await create_timer(.8).timeout;await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://activity_sleep_preview.png");g.sleep_scene.finish();await process_frame
 root.get_node("Lang").set_language("en");g.using_controller=true;g.start_activity(int(farm.data.animals[1].id));await create_timer(.5).timeout;await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://activity_english_preview.png");g.activity.cancel();await process_frame
 print("ACTIVITY_REVIEW_RENDERED");g.queue_free();await process_frame;await process_frame;quit()
