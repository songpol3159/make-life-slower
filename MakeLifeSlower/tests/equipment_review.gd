extends SceneTree
func _initialize():call_deferred("run")
func run():
 var farm=root.get_node("Farm");farm.save_enabled=false
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.start_game(false);g.modal=true;g.player.set_physics_process(false);g.player.visual.visible=false;g.ui.hud.visible=false;g.ui.toast_time=0
 g.player.position=Vector3(-16,0,-2);g.player.camera.position=Vector3(0,1.5,0);g.player.camera.rotation=Vector3(-.1,0,0);g.world.update_daylight(14,g.player.position)
 for tool in [0,1]:
  g.tool=tool;g.player.shown_tool=-1;g.player.tool_visual();g.player.hand_tool.visible=true
  if g.player.body_tool:g.player.body_tool.visible=false
  await create_timer(.5).timeout;await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://equipment_"+str(tool)+"_preview.png")
 quit()
