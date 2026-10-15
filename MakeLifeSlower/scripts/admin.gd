extends RefCounted
# Client-side convenience lock, not authoritative security for online/multiplayer.
const PASSWORD_HASH="ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f"
var game
var unlocked=false
var failures=0
var retry_at=0
func _init(owner):game=owner
func authenticate(password):
 if Time.get_ticks_msec()<retry_at:return false
 if password.sha256_text()==PASSWORD_HASH:unlocked=true;failures=0;return true
 failures+=1
 if failures>=5:retry_at=Time.get_ticks_msec()+30000;failures=0
 return false
func login():
 if unlocked:panel();return
 game.ui.window(Lang.t("เข้าสู่ระบบผู้ดูแล"),Lang.t("เครื่องมือทดสอบ · ต้องใช้รหัสผ่าน"))
 var field=LineEdit.new();field.secret=true;field.placeholder_text=Lang.t("รหัสผ่าน");field.custom_minimum_size.y=48;game.ui.body.add_child(field);field.grab_focus.call_deferred()
 var status=game.ui.label("");game.ui.body.add_child(status)
 var enter=func():
  if authenticate(field.text):field.text="";panel()
  else:field.text="";status.text=Lang.t("รหัสไม่ถูกต้อง หรือยังอยู่ในช่วงพักการลองรหัส")
 game.ui.body.add_child(game.ui.button(Lang.t("เข้าสู่ระบบ"),enter));field.text_submitted.connect(func(_text):enter.call())
func choice(options):
 var box=OptionButton.new()
 for option in options:box.add_item(Lang.t(str(option)))
 box.custom_minimum_size.y=42;game.ui.body.add_child(box);return box
func count(maximum=100,value=1):
 var spin=SpinBox.new();spin.min_value=1;spin.max_value=maximum;spin.value=value;spin.step=1;game.ui.body.add_child(spin);return spin
func command(action,payload={}):
 if not unlocked:return false
 match action:
  "teleport":
   var points={"fishing":Vector3(-46.2,.355,57.3),"farm":Vector3(2,.1,10),"barn":Vector3(16,.1,8)}
   var key=str(payload.get("key",""))
   if not points.has(key):return false
   game.player.position=points[key];game.player.velocity=Vector3.ZERO
  "money":Farm.data.money=clamp(int(payload.get("amount",0)),0,9999999)
  "season":
   var season=clamp(int(payload.get("index",0)),0,3);var year=int((int(Farm.data.day)-1)/28)
   Farm.data.day=year*28+season*7+1
  "hour":Farm.data.hour=clamp(float(payload.get("hour",8)),0.0,23.99)
  "upgrade":
   for key in ["farm_level","tool_level","home_level","barn_level"]:Farm.data[key]=2
  "item":
   var key=str(payload.get("key",""));var base=key.trim_suffix("_premium")
   if not Farm.CROPS.has(base) and not Farm.GOODS.has(base):return false
   var amount=clamp(int(payload.get("amount",1)),1,200)
   if Farm.bag_count()+amount>Farm.bag_capacity():return false
   Farm.add_good(key,amount)
  "seed":
   var key=str(payload.get("key",""))
   if not Farm.CROPS.has(key):return false
   Farm.data.seeds[key]=int(Farm.data.seeds.get(key,0))+clamp(int(payload.get("amount",1)),1,999)
  "animal":
   var key=str(payload.get("key",""))
   if not Farm.SPECIES.has(key) or Farm.data.animals.size()>=100:return false
   var id=int(Farm.data.next_id);Farm.data.next_id=id+1
   Farm.data.animals.append({"id":id,"species":key,"breed":clamp(int(payload.get("breed",0)),0,1),"age":int(Farm.SPECIES[key].days) if payload.get("adult",false) else 0,"fed":false,"product":0,"bond":0,"x":15.0+float(id%5)*2.0,"z":4.0+float(id%4)*2.0})
  "grow":
   for plot in Farm.data.plots:
    if plot.crop!="":plot.growth=Farm.CROPS[plot.crop].days
  "products":
   for animal in Farm.data.animals:
    if Farm.mature(animal):animal.product+=int(Farm.SPECIES[animal.species].qty)
  "tomorrow":Farm.next_day()
  _:return false
 Farm.commit();game.world.refresh();game.world.update_daylight(Farm.data.hour,game.player.position);game.ui.update_hud();game.save();return true
func panel():
 if not unlocked:login();return
 game.ui.window(Lang.t("เครื่องมือผู้ดูแล"),Lang.t("เปลี่ยนข้อมูลเซฟบนเครื่องนี้เท่านั้น · ไม่ใช่ระบบสิทธิ์ออนไลน์"))
 var ui=game.ui
 ui.body.add_child(ui.button("ไปจุดตกปลา",func():command("teleport",{"key":"fishing"});ui.close()))
 ui.body.add_child(ui.label("เงิน"));var money=count(9999999,max(1,int(Farm.data.money)));ui.body.add_child(ui.button("ตั้งค่าเงิน",func():show_result(command("money",{"amount":money.value}))))
 ui.body.add_child(ui.label("ฤดูกาล"));var season=choice(["ใบไม้ผลิ","ฤดูร้อน","ใบไม้ร่วง","ฤดูหนาว"]);season.select(int((int(Farm.data.day)-1)/7)%4);ui.body.add_child(ui.button("เปลี่ยนฤดูกาล",func():show_result(command("season",{"index":season.selected}))))
 ui.body.add_child(ui.label("เวลา"));var hour=HSlider.new();hour.min_value=0;hour.max_value=23.9;hour.step=.1;hour.value=Farm.data.hour;ui.body.add_child(hour);hour.value_changed.connect(func(value):command("hour",{"hour":value}))
 var items=Farm.CROPS.keys()+Farm.GOODS.keys()
 for key in Farm.CROPS.keys()+["egg","duck_egg","milk","goat_milk","wool","meat"]:items.append(key+"_premium")
 ui.body.add_child(ui.label("เสกสิ่งของ"));var item_titles=[]
 for key in items:item_titles.append(Farm.good_title(key))
 var item=choice(item_titles);var amount=count(200)
 ui.body.add_child(ui.button("เสกเข้ากระเป๋า",func():show_result(command("item",{"key":items[item.selected],"amount":amount.value}))))
 var crops=Farm.CROPS.keys();var crop_titles=[]
 for key in crops:crop_titles.append(Farm.CROPS[key].title)
 var seed=choice(crop_titles);ui.body.add_child(ui.button("เสกเมล็ด 20 ถุง",func():show_result(command("seed",{"key":crops[seed.selected],"amount":20}))))
 ui.body.add_child(ui.label("เสกสัตว์"));var species=Farm.SPECIES.keys();var species_titles=[]
 for key in species:species_titles.append(Farm.SPECIES[key].title)
 var animal=choice(species_titles);var age=choice(["วัยเด็ก","โตเต็มวัย"]);var breed=choice(["สายพันธุ์พื้นฐาน","สายพันธุ์พิเศษ"])
 ui.body.add_child(ui.button("เสกสัตว์ที่เลือก",func():show_result(command("animal",{"key":species[animal.selected],"adult":age.selected==1,"breed":breed.selected}))))
 for pair in [["อัปเกรดทุกอย่าง","upgrade"],["ทำพืชให้โตเต็มที่","grow"],["เพิ่มผลผลิตสัตว์","products"],["ข้ามไปวันถัดไป","tomorrow"]]:ui.body.add_child(ui.button(pair[0],func():show_result(command(pair[1]))))
 ui.body.add_child(ui.button("ออกจากระบบผู้ดูแล",func():unlocked=false;ui.pause_screen()))
func show_result(ok):game.ui.toast(Lang.t("เรียบร้อย") if ok else Lang.t("ทำไม่ได้ ตรวจพื้นที่กระเป๋าหรือจำนวนสัตว์"))
