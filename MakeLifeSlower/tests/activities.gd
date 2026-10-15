extends SceneTree
var checks=0
var failures=0
func _initialize():call_deferred("run")
func verify(value,message):
 checks+=1
 if not value:failures+=1;push_error(message)
func run():
 var farm=root.get_node("Farm");farm.save_enabled=false
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.start_game(false);farm.data.barn_level=2
 for species in ["duck","goat","sheep","pig","dog","cat"]:farm.add_animal(species,0,false)
 for a in farm.data.animals:a.age=5;a.product=2
 g.world.refresh();await process_frame
 for a in farm.data.animals:
  var id=int(a.id);var previous=int(a.bond);g.start_activity(id);await process_frame
  var session=g.activity
  verify(session!=null and session.mode==a.species,"Correct activity for "+a.species)
  verify(g.modal and not g.ui.hud.visible,"World paused during activity")
  match session.mode:
   "chicken","sheep":
    for i in range(6):session.pointer_action(session.board.cell_rect(i).get_center(),session.board.size)
   "cow":
    for i in range(6):
     session.phase=session.window_center;var event=InputEventKey.new();event.keycode=KEY_UP if i%2==0 else KEY_DOWN;event.pressed=true;session._input(event)
   "duck":
    for direction in [3,3,3,3,0,0,0,0,2,2,2,1,1,1]:session.direction(direction)
   "goat":
    for i in range(6):session.cursor=session.goal;session.confirm_action()
   "pig":
    for target in [3,11,18]:session.cursor=target;session.confirm_action()
   "dog":
    for i in range(3):session.pulse=0;session.phase=.5;session.confirm_action();await create_timer(2).timeout
   "cat":
    for i in range(6):
     session.cursor=session.goal;var event=InputEventJoypadButton.new();event.button_index=JOY_BUTTON_A;event.pressed=true;session._input(event)
  verify(session.finished,"Activity can be completed for "+a.species)
  verify(int(a.bond)==previous+6,"Daily bond reward")
  farm.finish_activity(id,"pet");verify(int(a.bond)==previous+6,"Repeat cannot farm bond")
  session.cancel();await process_frame;verify(not g.modal and g.ui.hud.visible,"Input and HUD restored")
 g.start_activity(int(farm.data.animals[0].id));var cancelled=g.activity;var event=InputEventJoypadButton.new();event.button_index=JOY_BUTTON_B;event.pressed=true;cancelled._input(event);await process_frame
 verify(g.activity==null and not g.modal,"Controller cancel works")
 farm.data.animals[0].age=0;g.start_activity(int(farm.data.animals[0].id));verify(g.activity.mode=="pet","Chick receives age-appropriate care");g.activity.cancel();await process_frame
 var admin=load("res://scripts/admin.gd").new(g)
 verify(not admin.command("money",{"amount":50000}),"Locked admin cannot mutate state")
 verify(not admin.authenticate("admin") and not admin.authenticate("123456"),"Default passwords rejected")
 var password=OS.get_environment("MLS_ADMIN_TEST_PASSWORD")
 if password!="":verify(admin.authenticate(password),"Private password authenticates without storing plaintext in project")
 admin.unlocked=true;verify(admin.command("animal",{"key":"cow","adult":true,"breed":1}),"Admin spawns selected stage and breed")
 verify(admin.command("season",{"index":3}) and int((farm.data.day-1)/7)%4==3,"Admin changes season")
 verify(not admin.command("item",{"key":"not-a-real-item"}),"Admin validates item key")
 var a=farm.data.animals[0];a.age=5;var bond=a.bond;farm.next_day();farm.finish_activity(a.id,"pet");verify(a.bond==bond+6,"Daily reward resets next day")
 for hour in [8,12,17,22]:
  g.world.update_daylight(hour,g.player.position)
  verify(g.world.sun.global_basis.z.dot(g.world.sun_direction)>.999,"Sun rays match visible sun")
  verify(g.world.moon_light.global_basis.z.dot(g.world.moon_direction)>.999,"Moon rays match visible moon")
 var plot=farm.data.plots[0];plot.tilled=true;plot.crop="carrot";plot.water=true;g.world.refresh();await process_frame
 farm.next_day();await process_frame
 verify(not plot.water,"Water resets at day rollover")
 var wet=false
 for child in g.world.plot_visuals.get_children():
  if child.material_override.albedo_color.is_equal_approx(Color("66523a")):wet=true
 verify(not wet,"Old wet soil mesh is removed from batch")
 var day=int(farm.data.day);g.begin_sleep();await process_frame;verify(g.sleep_scene!=null and not g.player.is_physics_processing(),"Sleep cinematic owns camera")
 g.sleep_scene.finish();await process_frame;verify(farm.data.day==day+1 and g.player.is_physics_processing() and not g.modal,"Skip completes sleep once and restores play")
 verify(g.ui.root!=null,"HUD remains usable after systems")
 print("ACTIVITY_TESTS ",checks," checks, ",failures," failures")
 g.queue_free();await process_frame;await process_frame;quit(1 if failures else 0)
