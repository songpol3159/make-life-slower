from pathlib import Path
P=Path('MakeLifeSlower/scripts')
def edit(name, fn):
 p=P/name; p.write_text(fn(p.read_text(encoding='utf-8')),encoding='utf-8')
def function(s,name,new):
 start=s.index('func '+name+'('); end=s.find('\nfunc ',start+5)
 return s[:start]+new.rstrip()+'\n'+(s[end+1:] if end!=-1 else '')

def farm(s):
 s=function(s,'sell_good','''func sale_value(k,amount):
 if not data.bag.has(k) or k=="feed":return 0
 var freshness=clamp(1.0-(int(data.day)-int(data.bag[k].day))*.04,.7,1.0) if k.trim_suffix("_premium") in CROPS else 1.0
 return int(clamp(int(amount),0,qty(k))*price(k)*freshness)
func sell_good(k,amount=-1):
 if not data.bag.has(k) or k=="feed":return 0
 var count=qty(k) if amount<0 else clamp(int(amount),0,qty(k))
 if count==0:return 0
 var n=sale_value(k,count)
 data.money+=n;data.stats.sold+=n;data.bag[k].qty-=count
 if qty(k)==0:data.bag.erase(k)
 commit("ขาย %d ชิ้น ได้ ฿%d"%[count,n])
 return n''')
 return s
edit('farm.gd',farm)

def player(s):
 s=s.replace('var look_drag=false','var look_drag=false\nvar car_speed=0.0\nvar camera_distance=4.5')
 s=s.replace('(Input.mouse_mode==Input.MOUSE_MODE_CAPTURED or look_drag)','(Input.mouse_mode==Input.MOUSE_MODE_CAPTURED or look_drag or OS.has_feature("web"))')
 s=s.replace('yaw-=Input.get_axis("look_left","look_right")*dt*1.8','yaw-=(Input.get_axis("look_left","look_right")+game.controller_look.x)*dt*1.8')
 s=s.replace('pitch+Input.get_axis("look_down","look_up")*dt*1.3','pitch+(Input.get_axis("look_down","look_up")-game.controller_look.y)*dt*1.3')
 s=s.replace('input=Input.get_vector("left","right","back","forward")','input=Input.get_vector("left","right","back","forward")\n if not game.modal and game.controller_move.length()>.12:input=Vector2(game.controller_move.x,-game.controller_move.y)')
 s=s.replace('car.rotation.y-=input.x*dt*1.1\n   var dir=Vector3(-sin(car.rotation.y),0,-cos(car.rotation.y));car.velocity.x=dir.x*input.y*11.0;car.velocity.z=dir.z*input.y*11.0','car_speed=move_toward(car_speed,input.y*(16.0 if input.y>=0 else 7.0),dt*(10.0 if abs(input.y)>.05 else 14.0))\n   car.rotation.y-=input.x*dt*1.35*clamp(abs(car_speed)/4.0,0,1)*sign(car_speed)\n   var dir=Vector3(-sin(car.rotation.y),0,-cos(car.rotation.y));car.velocity.x=dir.x*car_speed;car.velocity.z=dir.z*car_speed')
 s=s.replace('camera.position=Vector3(0,2.7,0)-front*5.0','camera.position=Vector3(0,3.6,0)-front*6.5')
 s=s.replace('*3.5+right*.6','*camera_distance+right*.6')
 return s
edit('player.gd',player)

def main(s):
 s=s.replace('var gpu_info=""','var gpu_info=""\nvar controller_move=Vector2.ZERO\nvar controller_look=Vector2.ZERO\nvar using_controller=false\nvar npc_near\nvar pointer_poll=0.0')
 start=s.index('  if OS.has_feature("web"):',s.index('func _process'))
 end=s.index('  Farm.data.hour+=',start)
 s=s[:start]+'''  pointer_poll+=dt
  if OS.has_feature("web") and pointer_poll>.2:
   pointer_poll=0
   var bridge=Engine.get_singleton("JavaScriptBridge")
   var locked=bool(bridge.eval("document.pointerLockElement !== null")) if bridge else false
   if locked:had_pointer_lock=true
   elif had_pointer_lock:ui.pause_screen();had_pointer_lock=false
'''+s[end:]
 start=s.index('  var daylight=');end=s.index('  footsteps-=dt',start)
 s=s[:start]+'''  world.update_daylight(float(Farm.data.hour),player.global_position)
  update_npc()
'''+s[end:]
 s=s.replace(' render_check+=dt',' poll_controller()\n render_check+=dt',1)
 s=s.replace('func _unhandled_input(event):','''func _input(event):
 if event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value)>.22):using_controller=true
 elif event is InputEventKey or event is InputEventMouseButton or (event is InputEventMouseMotion and event.relative.length()>2):using_controller=false
 if event is InputEventJoypadButton and event.pressed:
  if event.button_index==JOY_BUTTON_START:
   if playing:
    if modal:ui.close()
    else:ui.pause_screen()
   return
  if not playing or modal:return
  match event.button_index:
   JOY_BUTTON_A:interact()
   JOY_BUTTON_X:use_tool()
   JOY_BUTTON_Y:ui.inventory()
   JOY_BUTTON_BACK:ui.map_screen()
   JOY_BUTTON_RIGHT_SHOULDER:tool=(tool+1)%4
   JOY_BUTTON_LEFT_SHOULDER:tool=(tool+3)%4
   JOY_BUTTON_RIGHT_STICK:player.first_person=not player.first_person
func poll_controller():
 controller_move=Vector2.ZERO;controller_look=Vector2.ZERO
 var devices=Input.get_connected_joypads()
 if devices.is_empty():return
 var id=devices[0]
 controller_move=Vector2(Input.get_joy_axis(id,JOY_AXIS_LEFT_X),Input.get_joy_axis(id,JOY_AXIS_LEFT_Y))
 controller_look=Vector2(Input.get_joy_axis(id,JOY_AXIS_RIGHT_X),Input.get_joy_axis(id,JOY_AXIS_RIGHT_Y))
 if controller_move.length()<.18:controller_move=Vector2.ZERO
 else:controller_move=controller_move.limit_length()
 if controller_look.length()<.18:controller_look=Vector2.ZERO
func update_npc():
 npc_near=null
 var distance=4.5
 for n in world.targets:
  if not is_instance_valid(n) or not n.get_meta("kind","") in ["market","livestock","upgrade"]:continue
  var d=n.global_position.distance_to(player.global_position)
  if d<distance:distance=d;npc_near=n
 ui.npc_dialog.visible=npc_near!=null and not modal and not player.driving
 if npc_near:
  var greetings={"market":"เมล็ดพร้อมแล้ว แวะเลือกของหรือขายผลผลิตได้เลยนะ", "livestock":"วันนี้จะพาเพื่อนตัวใหม่กลับฟาร์มไหม?", "upgrade":"ค่อย ๆ แต่งฟาร์มให้น่าอยู่กันเถอะ"}
  ui.npc_text.text=greetings[npc_near.get_meta("kind")]+("\\nA · เปิดร้าน" if using_controller else "\\nE · เปิดร้าน")
func _unhandled_input(event):''')
 s=s.replace('if not target:ui.toast','if not target and npc_near:target=npc_near\n if not target:ui.toast')
 s=s.replace('player.driving=false;player.collision_layer','player.driving=false;player.car_speed=0;player.collision_layer')
 s=s.replace('player.driving=true;player.collision_layer','player.driving=true;player.car_speed=0;player.collision_layer')
 return s
edit('main.gd',main)

def ui(s):
 s=s.replace('var theme','var npc_dialog\nvar npc_text\nvar help\nvar theme',1)
 s=s.replace('var help=Label.new()','help=Label.new()')
 s=s.replace('root.add_child(toast_label)','root.add_child(toast_label);toast_label.z_index=10\n npc_dialog=PanelContainer.new();npc_dialog.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM);npc_dialog.position=Vector2(-280,-255);npc_dialog.size=Vector2(560,95);npc_dialog.mouse_filter=Control.MOUSE_FILTER_IGNORE;hud.add_child(npc_dialog);npc_text=label("",18);npc_text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;npc_dialog.add_child(npc_text);npc_dialog.visible=false')
 s=s.replace('if game.target and is_instance_valid(game.target):','help.text="L เดิน · R มอง · A คุย · X ใช้ · LB/RB เครื่องมือ · Y กระเป๋า · Start พัก" if game.using_controller else "WASD เดิน · Shift วิ่ง · V FPS/TPS · I กระเป๋า · M แผนที่ · Esc พัก"\n if game.target and is_instance_valid(game.target):')
 s=s.replace('" %d/%d วัน · "%[p.growth,Farm.CROPS[p.crop].days]','" · "+("พร้อมเก็บ" if p.growth>=Farm.CROPS[p.crop].days else "กำลังเติบโต")+" · "')
 s=s.replace('prompt.text=("คลิก / E · "','prompt.text=(("X / A · " if game.using_controller else "คลิก / E · ")')
 s=s.replace('else "E · "+str','else ("A · " if game.using_controller else "E · ")+str')
 s=s.replace('"โตใน %d วันที่รดน้ำ"%Farm.CROPS[k].days','{"carrot":"โตไว · เก็บเกี่ยวได้บ่อย","tomato":"เติบโตปานกลาง · ผลสดราคาดี","pumpkin":"โตช้า · ผลใหญ่ มูลค่าสูง"}[k]')
 s=s.replace('"5 เมล็ด · โต %d วัน · ขายฐาน ฿%d"%[Farm.CROPS[k].days,Farm.CROPS[k].price]','"5 เมล็ด · "+{"carrot":"โตไว","tomato":"โตปานกลาง","pumpkin":"โตช้า"}[k]+" · ขายฐาน ฿%d"%Farm.CROPS[k].price')
 s=s.replace('"ขายทั้งหมด",func():Farm.sell_good(k);game.audio.play_sfx("buy");market()','"เลือกจำนวน",func():sale_picker(k)')
 s=s.replace('if action!="":var b=button(action,callback);b.custom_minimum_size.x=155;h.add_child(b)','''var icon_key=""
 for key in Farm.SPECIES:
  if title.begins_with(Farm.SPECIES[key].title):icon_key=key;break
 for key in Farm.CROPS:
  if title.begins_with(Farm.CROPS[key].title):icon_key=key;break
 if icon_key=="":
  for pair in [["พื้นที่เพาะปลูก","farm"],["อุปกรณ์รดน้ำ","tool"],["บ้านสวน","home"],["คอกสัตว์","barn"],["อาหารสัตว์","feed"]]:
   if title.begins_with(pair[0]):icon_key=pair[1]
 if icon_key!="" and ResourceLoader.exists("res://assets/icons/"+icon_key+".png"):
  var picture=TextureRect.new();picture.texture=load("res://assets/icons/"+icon_key+".png");picture.custom_minimum_size=Vector2(76,76);picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;h.add_child(picture);h.move_child(picture,0)
 if action!="":var b=button(action,callback);b.custom_minimum_size.x=155;h.add_child(b);b.grab_focus.call_deferred()''')
 s=function(s,'title_screen','''func title_screen():
 game.playing=false;hud.visible=false;game.modal=true;Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
 if overlay:overlay.queue_free()
 overlay=Control.new();overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);root.add_child(overlay)
 var wash=ColorRect.new();wash.color=Color(.06,.15,.12,.35);wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);overlay.add_child(wash)
 var column=VBoxContainer.new();column.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT);column.position=Vector2(80,-245);column.size=Vector2(460,490);column.add_theme_constant_override("separation",18);overlay.add_child(column)
 var mark=label("✦  ALPINE FARM",18);mark.add_theme_color_override("font_color",Color("f3dfa6"));column.add_child(mark)
 var logo=label("Make Life\\nSlower",70);logo.add_theme_color_override("font_color",Color("fff4d9"));logo.add_theme_color_override("font_outline_color",Color("294537"));logo.add_theme_constant_override("outline_size",3);column.add_child(logo)
 column.add_child(label("ชีวิตเล็ก ๆ ในหุบเขาแห่งนี้",20))
 var b=button("เล่นต่อ",func():game.start_game(true));b.disabled=not Farm.has_save();column.add_child(b)
 column.add_child(button("เริ่มชีวิตใหม่",func():
  if Farm.has_save():confirm("เริ่มเกมใหม่?","เซฟเดิมจะถูกแทนที่เมื่อเล่นและบันทึก",func():game.start_game(false))
  else:game.start_game(false)))
 column.add_child(button("ตั้งค่า",settings_screen))
 var links=HBoxContainer.new();column.add_child(links);links.add_child(button("วิธีเล่น",controls));links.add_child(button("เครดิต",credits))
 b.grab_focus.call_deferred()
 var foot=label("ปลูก • เลี้ยง • เก็บเกี่ยว • เติบโตไปทีละนิด",15);foot.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT);foot.position=Vector2(-430,-55);foot.size=Vector2(400,30);overlay.add_child(foot)''')
 s += '''
func sale_picker(k):
 window("ขาย "+Farm.good_title(k),"เลือกจำนวนที่จะขาย · เก็บส่วนที่เหลือไว้ในกระเป๋า")
 var amount=SpinBox.new();amount.min_value=1;amount.max_value=Farm.qty(k);amount.step=1;amount.value=1;amount.custom_minimum_size=Vector2(240,55);body.add_child(amount)
 var total=label("รับเงิน ฿%d"%Farm.sale_value(k,1),28);body.add_child(total)
 amount.value_changed.connect(func(v):total.text="รับเงิน ฿%d"%Farm.sale_value(k,int(v)))
 body.add_child(button("ขายจำนวนที่เลือก",func():Farm.sell_good(k,int(amount.value));game.audio.play_sfx("buy");market()))
 body.add_child(button("กลับตลาด",market))
'''
 s=s.replace('ถ้าเมาส์ไม่ล็อก: กดปุ่มขวาค้างแล้วลาก หรือใช้ปุ่มลูกศรเพื่อมอง','Esc ปล่อยเมาส์ / พักเกม · จอย Xbox: L เดิน R มอง A คุย X ใช้ Y กระเป๋า')
 return s
edit('ui.gd',ui)
