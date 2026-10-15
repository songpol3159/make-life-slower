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
 g.ui.update_hud();await process_frame
 verify(g.ui.help_glyphs.size.x>1000,"HUD guide fills width")
 for group in g.ui.help_glyphs.get_children():
  verify(group.get_child(1).size.x>8 and group.get_child(1).autowrap_mode==TextServer.AUTOWRAP_OFF,"Guide labels have room and cannot wrap")
 var font=load("res://scripts/ui_font.gd").get_font()
 for code in [0x2190,0x2191,0x2192,0x2193,0x0e01,0x0e48,0x53]:verify(font.has_char(code) or font.fallbacks.any(func(f):return f.has_char(code)),"Bundled font includes needed character "+str(code))
 verify(font.fallbacks.size()==3 and not font.allow_system_fallback,"Web does not require system fonts")
 verify(font.get_height(17)<=load("res://assets/fonts/NotoSansThai.ttf").get_height(17),"Fallbacks do not inflate ordinary UI line height")
 for position in [Vector3(-56,2,34),Vector3(-46,2,57)]:
  var query=PhysicsRayQueryParameters3D.create(position,position-Vector3(0,4,0));query.exclude=[g.player.get_rid(),g.world.truck.get_rid()]
  var hit=g.world.get_world_3d().direct_space_state.intersect_ray(query)
  verify(not hit.is_empty() and hit.position.y>.35,"Deck collision matches visible surface")
  g.player.position=Vector3(position.x,-.5,position.z);g.player.velocity=Vector3.ZERO
  await physics_frame;await physics_frame;verify(g.player.position.y>.30,"Old sunken position recovers on deck")
 g.start_fishing();var session=g.activity;verify(session!=null and session.state=="cast","Fishing starts from in-world spot")
 verify(g.modal and not g.player.is_physics_processing(),"Fishing pauses movement")
 var key=InputEventKey.new();key.keycode=KEY_SPACE;key.pressed=true;session._input(key)
 verify(session.state=="wait","Keyboard casts")
 session.advance(5);verify(session.state=="bite","Float waits before bite")
 var pad=InputEventJoypadButton.new();pad.button_index=JOY_BUTTON_A;pad.pressed=true;session._input(pad)
 verify(session.state=="reel" and session.holding,"Controller hooks and reels")
 var before=farm.bag_count()
 session.catch_progress=1;session.advance(0)
 verify(session.state=="landed" and farm.bag_count()==before+1,"Fish lands in inventory")
 session.land_fish();verify(farm.bag_count()==before+1,"Landing cannot double award")
 verify(farm.price(session.caught_fish)>0,"Caught fish can be sold")
 session.press();verify(session.state=="cast" and not session.landed,"Second cast resets reward guard")
 session.board._gui_input(InputEventMouseButton.new());session.press();session.advance(5);session.press();session.tension=1;session.marker=0;session.advance(.01)
 verify(session.state=="cast" and farm.bag_count()==before+1,"Tension failure awards no fish")
 pad.button_index=JOY_BUTTON_B;session._input(pad);await process_frame
 verify(g.activity==null and not g.modal and g.player.is_physics_processing(),"Controller cancel restores movement and HUD")
 var admin=load("res://scripts/admin.gd").new(g);verify(not admin.command("teleport",{"key":"fishing"}),"Locked admin cannot teleport");admin.unlocked=true;verify(not admin.command("teleport",{"key":"unknown"}),"Teleport validates location");verify(admin.command("teleport",{"key":"fishing"}) and g.player.position.x < -46,"Admin can reach fishing deck for testing")
 var id=int(farm.data.animals[1].id);farm.data.animals[1].age=5;g.start_activity(id);var milk=g.activity
 milk.phase=0;milk.milk(milk.expected);verify(milk.score==0,"Milk rejects a missed target")
 var width=milk.window_width;milk.phase=milk.window_center;milk.milk(milk.expected)
 verify(milk.score==1 and milk.window_width<width and not is_equal_approx(milk.window_base,.5),"Milk band shrinks and shifts after success")
 milk.cancel();await process_frame
 print("FISHING_UI_TESTS ",checks," checks, ",failures," failures");g.queue_free();await process_frame;await process_frame;quit(1 if failures else 0)
