extends SceneTree
var checks=0
var failures=0
func _initialize():call_deferred("run")
func verify(value,message):
 checks+=1
 if not value:failures+=1;push_error(message)
func run():
 var farm=root.get_node("Farm");farm.save_enabled=false
 verify(farm.season_index(1)==0 and farm.season_index(22)==3 and farm.season_index(29)==0,"Seven day seasons cycle")
 for day in range(1,29):verify(farm.weather_for(day)==farm.weather_for(day),"Forecast deterministic")
 farm.data.plots[0].tilled=true;farm.data.plots[0].crop="carrot";farm.data.day=2;farm.apply_rain_water();verify(farm.data.plots[0].water,"Rain waters the farm")
 farm.ensure_orders();verify(farm.data.orders.size()==2,"Requests migrate into existing saves")
 var order=farm.data.orders[0];var money=farm.data.money
 verify(not farm.deliver_order(order.id) and farm.data.money==money,"Missing items cannot earn rewards")
 farm.add_good(order.item,order.amount);verify(farm.deliver_order(order.id),"Complete delivery accepted")
 verify(farm.data.money==money+order.reward,"Delivery pays reward")
 verify(not farm.deliver_order(order.id),"Duplicate delivery refused")
 var deadline=int(order.deadline);farm.data.day=deadline+1;farm.ensure_orders();verify(not farm.data.orders.any(func(o):return o.id==order.id),"Expired orders replaced without penalty")
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.start_game(false);g.modal=true
 verify(g.world.season_fx.snow==0,"First spring starts green")
 farm.data.day=26;g.world.season_fx.sync();verify(g.world.season_fx.snow==1 and g.world.season_fx.weather=="snow","Deep winter is snowy")
 verify(g.world.terrain_material.get_shader_parameter("snow_amount")==1,"Snow changes ground shader")
 verify(g.world.season_materials.size()>0,"Tree leaf materials support seasons")
 farm.data.day=18;g.world.season_fx.sync();verify(g.world.season_fx.autumn>.5,"Autumn foliage warms")
 var npc=g.world.targets.filter(func(n):return n.get_meta("kind","")=="market")[0]
 g.player.position=npc.position+Vector3(0,0,1);g.target=npc;g.modal=false;g.update_npc();g.ui.update_hud();await process_frame
 verify(g.ui.npc_dialog.visible and not g.ui.action_glyph.visible and not g.ui.prompt.visible,"NPC shows only one interaction prompt")
 verify(g.ui.npc_action_row.get_child_count()==2,"NPC action has glyph and text")
 g.begin_sleep();await process_frame
 verify(g.sleep_scene.caption.get_theme_font("font")==g.ui.theme.default_font,"Sleep uses bundled Thai font")
 g.sleep_scene.finish();await process_frame
 print("SEASON_TESTS ",checks," checks, ",failures," failures");g.queue_free();await process_frame;await process_frame;quit(1 if failures else 0)
