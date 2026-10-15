extends SceneTree
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(value,message):
 checks+=1
 if not value:failures+=1;push_error(message)
func thai(text):
 for c in str(text).length():
  if str(text).unicode_at(c)>=0x0e01 and str(text).unicode_at(c)<=0x0e5b and str(text).unicode_at(c)!=0x0e3f:return true
 return false
func run():
 var farm=root.get_node("Farm");var life=root.get_node("Life");farm.save_enabled=false;farm.new_game();life.ensure()
 var store=load("res://scripts/save_store.gd")
 check(store.valid(farm.data),"New save validates")
 var legacy=farm.data.duplicate(true)
 for field in ["friends","machines","decorations","festival_claims"]:legacy.erase(field)
 check(store.valid(legacy),"Legacy saves remain compatible")
 farm.data=legacy;life.ensure();check(farm.data.friends.size()==3,"Existing saves get three villagers")
 farm.data.money=10000;farm.add_good("milk",6)
 check(life.buy_machine("cheese") and not life.buy_machine("cheese"),"Buy one machine only")
 check(life.start_batch("cheese") and farm.qty("milk")==4,"Starting consumes exact ingredients")
 check(not life.start_batch("cheese") and not life.collect_batch("cheese"),"Cannot duplicate busy batch or collect early")
 farm.next_day();check(life.collect_batch("cheese") and farm.qty("cheese")==1,"Batch matures overnight")
 check(not life.collect_batch("cheese"),"Cannot double collect")
 check(farm.sell_good("cheese",1)==115,"Processed goods sell at configured price")
 farm.take("milk",farm.qty("milk"));farm.add_good("milk_premium",2);check(life.start_batch("cheese"),"Premium ingredients accepted")
 farm.next_day();check(life.collect_batch("cheese") and farm.qty("cheese_premium")==1,"Premium quality retained")
 farm.data.day=1
 check(life.friend_action("market") and not life.friend_action("market"),"Talk once daily")
 check(not life.friend_action("market",true),"Gift requires inventory")
 farm.add_good("tomato",4)
 check(life.friend_action("market",true) and not life.friend_action("market",true),"Gift once daily consumes one")
 check(farm.qty("tomato")==3 and farm.data.friends.market.points==11,"Ordinary friendship points")
 farm.data.day=2;life.friend_action("market",true)
 check(farm.data.friends.market.points==31 and life.unlocked("pickles"),"Birthday bonus unlocks recipe")
 farm.data.friends.upgrade.points=40;check(life.machine_cost("cheese")==216,"Friend discount applies")
 for day in [6,13,20,27]:check(life.festival(day)!="","Seasonal festival scheduled")
 farm.data.day=6;var money=farm.data.money
 check(life.claim_festival() and farm.data.money==money+250 and farm.qty("tomato")==0,"Festival consumes contribution and pays")
 check(not life.claim_festival(),"Festival reward cannot repeat")
 farm.data.day=13;farm.data.stats.festival_day=12;farm.data.stats.festival_fish_day=8;check(life.festival_progress()==0,"Fishing festival ignores previous day")
 farm.data.stats.festival_day=13;farm.data.stats.festival_fish_day=3;check(life.claim_festival(),"Fishing festival counts same-day catches")
 check(life.place_decoration("pot",Vector2(-18,20),0),"Place decoration in garden")
 var id=int(farm.data.decorations[0].id)
 check(not life.place_decoration("fence",Vector2(-18,20),0),"Overlapping placement rejected")
 check(not life.place_decoration("pot",Vector2(0,0),0),"Buildings and roads outside allowed garden")
 money=farm.data.money;check(life.place_decoration("pot",Vector2(-16,22),PI/2,id) and farm.data.money==money,"Move and rotate without charging again")
 check(life.remove_decoration(id) and farm.data.money==money+22,"Remove refunds half price")
 check(not life.remove_decoration(id),"No repeated refund")
 var raw=store.envelope(farm.data);check(not store.decode(raw).is_empty(),"Export/import roundtrip")
 var wrapper=JSON.parse_string(raw);wrapper.payload+=" ";check(store.decode(JSON.stringify(wrapper)).is_empty(),"Checksum rejects corruption")
 var bad=farm.data.duplicate(true);bad.plots=[];check(not store.valid(bad),"Reject missing plots")
 bad=farm.data.duplicate(true);bad.decorations=[{"kind":"bad"}];check(not store.valid(bad),"Reject invalid decorations")
 bad=farm.data.duplicate(true);bad.machines.cheese.busy="yes";check(not store.valid(bad),"Reject malformed processing state")
 check(farm.slot_path(1)!=farm.slot_path(2) and farm.slot_path(2)!=farm.slot_path(3),"Three isolated save slots")
 var path="user://community_test_save.json"
 check(store.write(path,farm.data),"Atomic save writes valid file")
 var original=farm.data.money;farm.data.money=1234;check(store.write(path,farm.data),"Second save writes backup")
 check(store.read(path+".bak").money==original,"Backup preserves previous save")
 var broken=FileAccess.open(path,FileAccess.WRITE);broken.store_string("broken");broken.close()
 farm.save_path=path;check(farm.load_game() and farm.data.money==original,"Load recovers valid backup")
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(path+suffix):DirAccess.remove_absolute(path+suffix)
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.start_game(false);g.modal=true
 await process_frame;await process_frame
 for language in ["th","en"]:
  root.get_node("Lang").set_language(language)
  for menu in ["processing","people","calendar","decorations","saves"]:
   g.ui.community.call(menu);await process_frame
   check(g.ui.body.get_child_count()>0,"Menu builds: "+menu)
   if language=="en":
    for c in g.ui.overlay.find_children("*","Control",true,false):
     if c is Label or c is BaseButton:check(not thai(c.text),"New menu translated: "+c.text)
  g.ui.community.editor("lamp");await process_frame;check(g.ui.menu_controls().size()>=5,"Garden editor keyboard/controller controls")
  var controls=g.ui.menu_controls();var spinner=controls.filter(func(c):return c is SpinBox)[0];spinner.grab_focus();var previous=spinner.value;g.ui.adjust_control(1);check(spinner.value>previous,"Controller adjusts garden placement")
  farm.data.friends.market.talk_day=0;g.ui.community.npc("market");await process_frame
  var chat=g.ui.menu_controls().filter(func(c):return c is Button and c.text in ["Chat","พูดคุย"])[0];chat.grab_focus();g.ui.activate_control();check(farm.data.friends.market.talk_day==farm.data.day,"Controller activates NPC interaction")
 root.get_node("Lang").set_language("th");g.ui.close();g.modal=true
 g.start_fishing();var fishing=g.activity
 fishing.press();fishing.press();check(fishing.state=="cast","Early hook rejected")
 for kind in ["perch","trout","carp"]:
  fishing.state="reel";fishing.state_time=0;fishing.fish_kind=kind;fishing.fish_phase=.3;fishing.marker=.5;fishing.catch_progress=0;fishing.tension=.12;fishing.misses=0;fishing.landed=false
  for frame in range(3600):
   fishing.holding=fishing.marker<fishing.fish_position
   if fishing.surging and fishing.tension>.65:fishing.holding=false
   fishing.advance(1.0/60)
   if fishing.state!="reel":break
  check(fishing.state=="landed","Fishing remains winnable: "+kind)
 fishing.cancel();g.queue_free();await process_frame;await process_frame
 print("COMMUNITY_TESTS ",checks," checks, ",failures," failures");quit(1 if failures else 0)
