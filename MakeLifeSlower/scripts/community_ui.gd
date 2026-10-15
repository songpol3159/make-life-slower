extends Node
var ui
var file_callback
var import_slot=1
func t(th,en):return Life.t(th,en)
func hub_buttons():
 for pair in [[t("โรงแปรรูป","Workshop"),processing],[t("ชาวบ้านและความสัมพันธ์","Villagers & friendship"),people],[t("ปฏิทินและเทศกาล","Calendar & festivals"),calendar],[t("ตกแต่งสวน","Decorate garden"),decorations],[t("ช่องเซฟ / นำเข้า / ส่งออก","Save slots / import / export"),saves]]:
  ui.body.add_child(ui.button(pair[0],pair[1]))
func processing():
 Life.ensure();ui.window(t("โรงแปรรูป","Workshop"),t("ใส่วัตถุดิบ รอข้ามวัน แล้วรับสินค้า · เครื่องละหนึ่งงาน","Load ingredients, wait overnight, collect goods · One batch per machine"))
 for key in Life.RECIPES:
  var r=Life.RECIPES[key];var title=Life.item_title(key)
  if not Farm.data.machines.has(key):
   ui.row(title,t("ใช้ %s × %d · รอ %d วัน · ขาย ฿%d","Uses %s × %d · %d days · Sale ฿%d")%[Farm.good_title(r.input),r.amount,r.days,r.price],t("ซื้อเครื่อง ฿%d","Buy machine ฿%d")%Life.machine_cost(key) if Life.unlocked(key) else t("สนิทกับมะลิ 20","Mali friendship 20"),func():Life.buy_machine(key);processing())
  else:
   var m=Farm.data.machines[key];var ready=m.busy and int(Farm.data.day)>=int(m.ready_day)
   var description=t("พร้อมรับแล้ว","Ready to collect") if ready else t("เหลือ %d วัน","%d days remaining")%max(0,int(m.ready_day)-int(Farm.data.day)) if m.busy else t("วัตถุดิบ %s · มี %d / ต้องใช้ %d","Ingredient %s · Have %d / need %d")%[Farm.good_title(r.input),Farm.qty(r.input)+Farm.qty(r.input+"_premium"),r.amount]
   ui.row(title,description,t("รับสินค้า","Collect") if ready else t("กำลังทำ","Processing") if m.busy else t("เริ่มแปรรูป","Start batch"),func():
    var success=Life.collect_batch(key) if ready else Life.start_batch(key)
    if not success:ui.toast(t("ตรวจวัตถุดิบ พื้นที่กระเป๋า หรือรอให้พร้อมก่อน","Check ingredients, bag space, or wait until ready"))
    processing())
func people():
 Life.ensure();ui.window(t("ชาวบ้านและความสัมพันธ์","Villagers & friendship"),t("คุยและให้ของได้วันละครั้ง · ไปพบที่ร้านในหมู่บ้าน","Talk and gift once daily · Meet them at their village shops"))
 for key in Life.PEOPLE:
  ui.row(Lang.t(Life.PEOPLE[key].name),t("ความสนิท %d / 100","Friendship %d / 100")%int(Farm.data.friends[key].points),t("นำทางไปพบ","Set waypoint"),func():ui.game.waypoint={"market":Vector3(46,0,-63),"livestock":Vector3(60,0,-63),"upgrade":Vector3(74,0,-63)}[key];ui.close())
func npc(key):
 Life.ensure();var person=Life.PEOPLE[key];var friend=Farm.data.friends[key]
 ui.window(Lang.t(person.name),t("ความสนิท %d / 100","Friendship %d / 100")%int(friend.points));ui.body.add_child(ui.label(Life.greeting(key),20))
 ui.row(t("พูดคุย","Chat"),t("ความสนิท +3 วันละครั้ง","Friendship +3 once daily"),t("คุยแล้ววันนี้","Chatted today") if int(friend.talk_day)==int(Farm.data.day) else t("พูดคุย","Chat"),func():Life.friend_action(key);npc(key))
 var birthday=(int(Farm.data.day)-1)%28+1=={"market":2,"livestock":3,"upgrade":4}[key]
 ui.row(t("ของขวัญที่ชอบ","Favorite gift"),Farm.good_title(person.gift)+(t(" × 1 · วันเกิด! ความสนิท +20"," × 1 · Birthday! Friendship +20") if birthday else t(" × 1 · ความสนิท +8"," × 1 · Friendship +8")),t("ให้แล้ววันนี้","Gifted today") if int(friend.gift_day)==int(Farm.data.day) else t("ให้ของขวัญ","Give gift"),func():
  if not Life.friend_action(key,true):ui.toast(t("ให้ได้วันละครั้ง และต้องมีของในกระเป๋า","Once daily; the gift must be in your bag"))
  npc(key))
 ui.body.add_child(ui.label({"market":t("ความสนิท 20 ปลดล็อกผักดอง","20 friendship unlocks pickles"),"upgrade":t("ความสนิท 40 ลดราคาเครื่องแปรรูป 10%","40 friendship gives a 10% machine discount"),"livestock":t("ความสนิท 40 ของขวัญอาหารสัตว์ทุกสัปดาห์","40 friendship unlocks weekly feed gifts")}[key],16))
 if key=="livestock" and int(friend.points)>=40:
  ui.body.add_child(ui.button(t("รับอาหารสัตว์ประจำสัปดาห์","Claim weekly feed"),func():
   var week=int((int(Farm.data.day)-1)/7)
   if int(friend.get("feed_week",-1))!=week and Farm.add_good("feed",3):friend.feed_week=week;Farm.commit()
   npc(key)))
 ui.body.add_child(ui.button(t("เปิดร้าน","Open shop"),{"market":ui.market,"livestock":ui.livestock,"upgrade":ui.upgrades}[key]))
func calendar():
 Life.ensure();ui.window(t("ปฏิทินหุบเขา","Valley calendar"),t("ทุกฤดูมี 7 วัน · เทศกาลวันที่ 6 · เข้าร่วมได้จากหน้านี้","7 days per season · Festival on day 6 · Join here"))
 if Life.festival()!="":ui.body.add_child(ui.button(t("วันนี้: ","Today: ")+Life.festival_title(Life.festival())+t(" · เข้าร่วม"," · Join"),festival_screen))
 var start=int((int(Farm.data.day)-1)/7)*7+1
 for day in range(start,start+7):
  var event=Life.festival(day);var birthday={2:t("วันเกิดมะลิ","Mali's birthday"),3:t("วันเกิดภูผา","Phupha's birthday"),4:t("วันเกิดต้น","Ton's birthday")}.get((day-1)%28+1,"")
  ui.row(t("วันที่ %d","Day %d")%day+(t(" · วันนี้"," · Today") if day==int(Farm.data.day) else ""),Farm.weather_title(Farm.weather_for(day))+" · "+(Life.festival_title(event) if event!="" else birthday if birthday!="" else t("วันสบาย ๆ","A peaceful day")),"",func():pass)
 var key=Life.festival()
 if key!="":
  var task={"spring":t("นำมะเขือเทศ 2 ผลมาแบ่งปัน","Share 2 tomatoes"),"fishing":t("จับปลาในวันนี้ 3 ตัว","Catch 3 fish today"),"harvest":t("นำฟักทอง 2 ผลมาแบ่งปัน","Share 2 pumpkins"),"animals":t("เล่นกิจกรรมกับสัตว์ 3 ตัววันนี้","Play activities with 3 animals today")}[key]
  ui.row(Life.festival_title(key),task+" · %d / %d"%[min(Life.festival_progress(),Life.festival_required()),Life.festival_required()],t("เข้าร่วม / รับรางวัล","Join / claim"),func():
   if not Life.claim_festival():ui.toast(t("ทำกิจกรรมให้ครบ หรือวันนี้รับรางวัลแล้ว","Complete the task first, or today's reward was already claimed"))
   calendar())
 else:ui.body.add_child(ui.label(t("ของขวัญวันเกิดเพิ่มความสนิทเป็นพิเศษ","Birthday gifts grant extra friendship"),16))
func festival_screen():
 var key=Life.festival()
 if key=="":calendar();return
 ui.window(Life.festival_title(key),t("ร่วมสนุกได้วันนี้ รางวัล ฿250 และความสนิทชาวบ้าน +5","Join today for ฿250 and +5 villager friendship"))
 var task={"spring":t("แบ่งปันมะเขือเทศ 2 ผล","Share 2 tomatoes"),"fishing":t("จับปลาในวันนี้ 3 ตัว","Catch 3 fish today"),"harvest":t("แบ่งปันฟักทอง 2 ผล","Share 2 pumpkins"),"animals":t("เล่นกิจกรรมกับสัตว์ 3 ตัววันนี้","Play activities with 3 animals today")}[key]
 ui.row(task,"%d / %d"%[min(Life.festival_progress(),Life.festival_required()),Life.festival_required()],t("รับรางวัล","Claim reward"),func():
  if not Life.claim_festival():ui.toast(t("ทำให้ครบก่อน หรือรับรางวัลแล้ววันนี้","Finish the task first, or already claimed today"))
  festival_screen())
 ui.body.add_child(ui.button(t("กลับปฏิทิน","Back to calendar"),calendar))
func decorations():
 Life.ensure();ui.window(t("ตกแต่งสวน","Decorate garden"),t("จัดสวนข้างบ้าน · ย้าย หมุน และขายคืนได้ · สูงสุด 60 ชิ้น","Arrange the garden beside home · Move, rotate, resell · Up to 60 pieces"))
 for key in Life.DECOR:ui.row(Lang.t(Life.DECOR[key].title),t("ราคา ฿%d","Price ฿%d")%Life.DECOR[key].cost,t("เลือกตำแหน่ง","Choose location"),func():editor(key))
 for record in Farm.data.decorations:
  var id=int(record.id)
  ui.row(Lang.t(Life.DECOR[record.kind].title)+" #%d"%id,t("ตำแหน่ง %.1f, %.1f","Position %.1f, %.1f")%[record.x,record.z],t("ย้าย / หมุน","Move / rotate"),func():editor(record.kind,id))
func editor(key,id=-1):
 ui.window(t("วางของในสวน","Place in garden"),t("คลิกแผนผัง หรือปรับ X/Z ด้วยจอย · สีแดงหมายถึงวางไม่ได้","Click the plan or adjust X/Z with the controller · Red means blocked"))
 var map=load("res://scripts/garden_plan.gd").new();map.edit_id=id;map.selected_kind=key;ui.body.add_child(map)
 var x=SpinBox.new();x.focus_mode=Control.FOCUS_ALL;x.min_value=-21;x.max_value=-2;x.step=.5;x.value=-18
 var z=SpinBox.new();z.focus_mode=Control.FOCUS_ALL;z.min_value=18;z.max_value=36;z.step=.5;z.value=20
 var angle=OptionButton.new()
 for deg in [0,90,180,270]:angle.add_item(str(deg)+"°")
 if id>=0:
  for record in Farm.data.decorations:
   if int(record.id)==id:x.value=record.x;z.value=record.z;angle.select(posmod(int(round(record.rotation/(PI/2))),4))
 map.point=Vector2(x.value,z.value);map.angle=angle.selected*PI/2
 for pair in [["X",x],["Z",z],[t("หมุน","Rotate"),angle]]:var h=HBoxContainer.new();ui.body.add_child(h);h.add_child(ui.label(pair[0],16));h.add_child(pair[1])
 x.value_changed.connect(func(v):map.point.x=v;map.queue_redraw());z.value_changed.connect(func(v):map.point.y=v;map.queue_redraw());angle.item_selected.connect(func(v):map.angle=v*PI/2;map.queue_redraw())
 map.picked.connect(func(p):x.value=p.x;z.value=p.y)
 ui.body.add_child(ui.button(t("ยืนยันตำแหน่ง","Confirm position"),func():
  if Life.place_decoration(key,Vector2(x.value,z.value),angle.selected*PI/2,id):decorations()
  else:ui.toast(t("วางไม่ได้: ชนของอื่น เงินไม่พอ หรือสวนเต็ม","Cannot place: overlapping, insufficient money, or garden full"))))
 if id>=0:ui.body.add_child(ui.button(t("ขายคืนครึ่งราคา","Sell for half price"),func():ui.confirm(t("ขายของตกแต่ง?","Sell decoration?"),t("รับเงินคืนครึ่งราคา","Receive half the original price"),func():Life.remove_decoration(id);decorations())))
func saves(new_mode=false):
 ui.window(t("ช่องเซฟ","Save slots"),t("เซฟอยู่ในเบราว์เซอร์นี้ · ส่งออกไฟล์ไว้ก่อนย้ายเครื่องหรือล้างข้อมูล","Saves stay in this browser · Export before moving devices or clearing data"))
 for slot in range(1,4):
  var info=Farm.slot_info(slot)
  var description=t("ว่าง","Empty") if info.is_empty() else t("วันที่ %d · ฿%d · บันทึก %s","Day %d · ฿%d · Saved %s")%[info.day,info.money,str(info.get("saved_at",t("เซฟเดิม","Legacy save")))]
  ui.row(t("ช่อง %d","Slot %d")%slot+(t(" · ใช้อยู่"," · Active") if ui.game.playing and Farm.save_path==Farm.slot_path(slot) else ""),description,t("เริ่มใหม่","New game") if new_mode or info.is_empty() else t("โหลด","Load"),func():
   var launch=func():
    if ui.game.playing:ui.game.save()
    Farm.select_slot(slot);ui.game.start_game(not new_mode and not info.is_empty())
   if new_mode and not info.is_empty():ui.confirm(t("แทนที่เซฟช่องนี้?","Replace this slot?"),t("เซฟช่องนี้จะถูกแทนที่ มีไฟล์สำรองก่อนหน้าหนึ่งชุด","This slot will be replaced; one previous backup is retained"),launch)
   else:launch.call())
  var row=HBoxContainer.new();ui.body.add_child(row);row.add_child(ui.button(t("ส่งออกช่อง %d","Export slot %d")%slot,func():export_slot(slot)));row.add_child(ui.button(t("นำเข้าช่อง %d","Import slot %d")%slot,func():import_menu(slot)))
func export_slot(slot):
 if ui.game.playing and Farm.save_path==Farm.slot_path(slot):ui.game.save()
 var info=Farm.slot_info(slot)
 if info.is_empty():ui.toast(t("ช่องนี้ยังไม่มีเซฟ","This slot has no save"));return
 var text=load("res://scripts/save_store.gd").envelope(info);var name="MakeLifeSlower-slot%d.json"%slot
 if OS.has_feature("web"):
  JavaScriptBridge.eval("(()=>{const b=new Blob(["+JSON.stringify(text)+"],{type:'application/json'});const u=URL.createObjectURL(b);const a=document.createElement('a');a.href=u;a.download="+JSON.stringify(name)+";a.click();setTimeout(()=>URL.revokeObjectURL(u),1000)})()")
 else:
  var dialog=FileDialog.new();dialog.file_mode=FileDialog.FILE_MODE_SAVE_FILE;dialog.access=FileDialog.ACCESS_FILESYSTEM;dialog.current_file=name;dialog.add_filter("*.json","Save file");ui.overlay.add_child(dialog);dialog.file_selected.connect(func(path):var f=FileAccess.open(path,FileAccess.WRITE);if f:f.store_string(text));dialog.popup_centered(Vector2i(800,500))
func import_menu(slot):
 import_slot=slot;ui.window(t("นำเข้าเซฟ","Import save"),t("เลือกไฟล์ JSON หรือวางข้อความ · ตรวจข้อมูลก่อนยืนยันแทนที่","Choose JSON or paste its contents · Validated before confirming replacement"))
 var text=TextEdit.new();text.custom_minimum_size=Vector2(600,150);ui.body.add_child(text)
 ui.body.add_child(ui.button(t("เลือกไฟล์","Choose file"),func():
  if OS.has_feature("web"):
   file_callback=JavaScriptBridge.create_callback(func(args):
    if args.size()>0 and is_instance_valid(text):text.text=str(args[0]))
   JavaScriptBridge.get_interface("window").mlsImportSave=file_callback
   JavaScriptBridge.eval("(()=>{const i=document.createElement('input');i.type='file';i.accept='.json';i.onchange=()=>{const f=i.files[0];if(!f||f.size>4000000)return;const r=new FileReader();r.onload=()=>window.mlsImportSave(r.result);r.readAsText(f)};i.click()})()")
  else:
   var dialog=FileDialog.new();dialog.file_mode=FileDialog.FILE_MODE_OPEN_FILE;dialog.access=FileDialog.ACCESS_FILESYSTEM;dialog.add_filter("*.json","Save file");ui.overlay.add_child(dialog);dialog.file_selected.connect(func(path):if is_instance_valid(text):text.text=FileAccess.get_file_as_string(path));dialog.popup_centered(Vector2i(800,500))))
 ui.body.add_child(ui.button(t("ตรวจและนำเข้า","Validate & import"),func():
  var raw=text.text;var value=load("res://scripts/save_store.gd").decode(raw)
  if value.is_empty():ui.toast(t("ไฟล์ไม่ถูกต้องหรือเสียหาย เซฟเดิมยังอยู่","Invalid or damaged file. Existing save is untouched."));return
  ui.confirm(t("นำเข้าช่อง %d?","Import into slot %d?")%slot,t("แทนที่ด้วยวันที่ %d · ฿%d · ควรส่งออกเซฟเดิมก่อน","Replace with day %d · ฿%d · Export the old save first")%[value.day,value.money],func():
   if ui.game.playing and Farm.save_path==Farm.slot_path(slot):ui.game.save()
   if Farm.import_save(raw,slot):
    if ui.game.playing and Farm.save_path==Farm.slot_path(slot):ui.game.start_game(true)
    saves()
   else:ui.toast(t("นำเข้าไม่สำเร็จ","Import failed")))))
