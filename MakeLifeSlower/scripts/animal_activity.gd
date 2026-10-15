extends CanvasLayer
var game
var record_id=0
var mode=""
var score=0
var required=6
var cursor=0
var goal=0
var expected=0
var phase=.5
var window_center=.5
var window_width=.24
var window_base=.5
var elapsed=0.0
var cleaned=[]
var obstacles=[7,12,17]
var finished=false
var tick=0.0
var pulse=0.0
var container
var board
var status
var instructions
var prompt_row
var prompt_mode=false
var scene
var actor
var ap
var hand
var prop
var teat
var milk_materials=[]
var fleece=[]
var actor_home=Vector3.ZERO
var bounds=AABB()
var base_hand=Vector3.ZERO
var progress
var milk_fill
var stage_eggs=[]
const NAMES={"chicken":"เก็บไข่ในรัง","duck":"พาเป็ดกลับคอก","cow":"รีดนมวัว","goat":"ป้อนอาหารแพะ","sheep":"ตัดขนแกะ","pig":"ช่วยหมูหาของในดิน","dog":"โยนบอลให้สุนัข","cat":"เล่นไม้ล่อแมว","brush":"แปรงขนวัยเด็ก","pet":"ลูบหัวและเล่นด้วยกัน"}
const HELP={"chicken":"เลือกไข่ในรังแล้วหยิบใส่ตะกร้าให้ครบ","duck":"พาเป็ดไปวงสีทองสามจุด หลีกเลี่ยงก้อนหิน","cow":"กดขึ้นและลงสลับกัน ขณะตัวชี้อยู่ในแถบสีเขียว","goat":"เลือกอาหารที่อยากกิน แล้วกดยืนยัน","sheep":"เลือกบริเวณขนแล้วตัดทีละส่วน ไม่ตัดหัวหรือขา","pig":"เลือกจุดแล้วขุด หาของสามจุดตามคำใบ้ใกล้หรือไกล","dog":"กดโยนตอนตัวชี้อยู่ในแถบสีเขียว แล้วรอเพื่อนคาบกลับมา","cat":"ขยับของเล่นไปยังจุดสีทองแล้วกดเล่น","brush":"เลือกจุดแปรงขนเบา ๆ ให้ครบหกจุด","pet":"เลือกจุดลูบเบา ๆ แล้วดูเพื่อนตอบสนอง"}
func begin(owner,id,activity=""):
 game=owner;record_id=id
 var a=Farm.animal_by_id(id)
 if a.is_empty():queue_free();return
 mode=activity if activity!="" else a.species
 if not Farm.mature(a) and mode in ["chicken","duck","cow","goat","sheep"]:mode="pet" if mode in ["chicken","duck","goat"] else "brush"
 required=3 if mode in ["duck","pig","dog"] else 6
 goal=4 if mode=="duck" else 2 if mode=="cat" else 0
 game.ui.close();game.modal=true;game.ui.hud.visible=false;game.activity=self;Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
 build(a)
func button(text,callback,parent):
 var b=game.ui.button(text,callback);b.custom_minimum_size=Vector2(105,46);b.focus_mode=Control.FOCUS_NONE;parent.add_child(b);return b
func build(a):
 layer=20
 container=Control.new();container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);container.theme=game.ui.theme;add_child(container)
 var veil=ColorRect.new();veil.color=Color("15291d");veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);container.add_child(veil)
 var margin=MarginContainer.new();margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);container.add_child(margin)
 for side in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+side,32)
 var column=VBoxContainer.new();column.add_theme_constant_override("separation",12);margin.add_child(column)
 var heading=HBoxContainer.new();column.add_child(heading);heading.add_child(game.ui.label(NAMES[mode],30));button("กลับไปฟาร์ม",cancel,heading)
 instructions=game.ui.label(HELP[mode],17);column.add_child(instructions)
 var middle=HBoxContainer.new();middle.size_flags_vertical=Control.SIZE_EXPAND_FILL;middle.add_theme_constant_override("separation",24);column.add_child(middle)
 var left=VBoxContainer.new();left.size_flags_horizontal=Control.SIZE_EXPAND_FILL;middle.add_child(left)
 var viewport_container=SubViewportContainer.new();viewport_container.stretch=true;viewport_container.custom_minimum_size=Vector2(440,315);viewport_container.size_flags_vertical=Control.SIZE_EXPAND_FILL;viewport_container.mouse_filter=Control.MOUSE_FILTER_IGNORE;left.add_child(viewport_container)
 var viewport=SubViewport.new();viewport.size=Vector2i(440,315);viewport.own_world_3d=true;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;viewport_container.add_child(viewport)
 make_stage(viewport,a)
 left.add_child(game.ui.label(Farm.SPECIES[a.species].title+" · "+("โตเต็มวัย" if Farm.mature(a) else "วัยเด็ก"),20))
 var right=VBoxContainer.new();right.custom_minimum_size.x=520;right.size_flags_horizontal=Control.SIZE_EXPAND_FILL;middle.add_child(right)
 board=load("res://scripts/activity_board.gd").new();board.session=self;board.size_flags_vertical=Control.SIZE_EXPAND_FILL;right.add_child(board)
 progress=ProgressBar.new();progress.max_value=required;progress.custom_minimum_size.y=14;progress.show_percentage=false;right.add_child(progress)
 status=game.ui.label("อยากกิน ใบไม้" if mode=="goat" else "ค่อย ๆ เล่นได้ ไม่จำกัดเวลา",18);right.add_child(status)
 var controls=HBoxContainer.new();controls.alignment=BoxContainer.ALIGNMENT_CENTER;right.add_child(controls)
 var directions=[["↑",1],["↓",2]] if mode=="cow" else [["←",0],["↑",1],["↓",2],["→",3]]
 for pair in directions:button(pair[0],func():direction(pair[1]),controls)
 button("ยืนยัน / เล่น",confirm_action,right)
 prompt_row=HBoxContainer.new();prompt_row.alignment=BoxContainer.ALIGNMENT_CENTER;prompt_row.add_theme_constant_override("separation",14);column.add_child(prompt_row);refresh_prompts()
func primitive(parent,type,p,scale_v,color):
 var node=MeshInstance3D.new();node.mesh=SphereMesh.new() if type=="ball" else CylinderMesh.new() if type=="cylinder" else BoxMesh.new();node.position=p;node.scale=scale_v
 var mat=StandardMaterial3D.new();mat.albedo_color=Color(color);mat.roughness=.8;node.material_override=mat;parent.add_child(node);return node
func make_stage(viewport,a):
 scene=Node3D.new();viewport.add_child(scene)
 var env=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("b4c5aa");env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.environment.ambient_light_color=Color("e8edd7");env.environment.ambient_light_energy=.65;scene.add_child(env)
 var light=DirectionalLight3D.new();light.rotation_degrees=Vector3(-45,-35,0);light.light_energy=.9;scene.add_child(light)
 actor=load("res://assets/models/"+a.species+"_"+("adult" if Farm.mature(a) else "young")+".glb").instantiate();scene.add_child(actor);actor.rotation.y=-.4
 var first=true
 for mesh in actor.find_children("*","MeshInstance3D",true,false):
  var box=(actor.global_transform.affine_inverse()*mesh.global_transform)*mesh.get_aabb()
  bounds=box if first else bounds.merge(box);first=false
 var h=max(.3,bounds.size.y);var extent=max(h,max(bounds.size.x,bounds.size.z));actor.position.y=-bounds.position.y;actor_home=actor.position
 ap=actor.find_child("AnimationPlayer",true,false);play_anim("Idle")
 primitive(scene,"cylinder",Vector3(0,-.08,0),Vector3.ONE*extent*1.15,"8da17c").scale.y=.06
 var camera=Camera3D.new();scene.add_child(camera);var focus=actor.to_global(bounds.get_center());camera.position=focus+Vector3(-extent*.95,extent*.32,extent*1.10);camera.look_at(focus);camera.fov=40
 hand=Node3D.new();scene.add_child(hand);base_hand=actor.to_global(Vector3(bounds.get_center().x,bounds.end.y*.83,bounds.get_center().z+bounds.size.z*.34));hand.position=base_hand
 if mode=="pet":
  var skeletons=actor.find_children("*","Skeleton3D",true,false)
  if not skeletons.is_empty():
   var bone=skeletons[0].find_bone("Head")
   if bone>=0:base_hand=skeletons[0].to_global(skeletons[0].get_bone_global_pose(bone).origin)+Vector3(0,h*.08,.06);hand.position=base_hand
 primitive(hand,"ball",Vector3.ZERO,Vector3(.12,.055,.15)*extent,"e7ba94")
 for i in range(4):primitive(hand,"ball",Vector3(-.055+i*.037,0,-.08)*extent,Vector3(.033,.03,.115)*extent,"e7ba94")
 if mode=="cow":
  hand.visible=false
  base_hand=actor.to_global(Vector3(.48,.32,.23));hand.position=base_hand
  for mesh in actor.find_children("*","MeshInstance3D",true,false):
   for surface in mesh.mesh.get_surface_count():
    var source=mesh.mesh.surface_get_material(surface)
    var material=ShaderMaterial.new();material.shader=load("res://assets/animal_milk.gdshader")
    if source is StandardMaterial3D:
     material.set_shader_parameter("albedo_tint",source.albedo_color);material.set_shader_parameter("vertex_colored",source.vertex_color_use_as_albedo)
     if source.albedo_texture:material.set_shader_parameter("albedo_texture",source.albedo_texture);material.set_shader_parameter("textured",true)
    mesh.set_surface_override_material(surface,material);milk_materials.append(material)
  prop=Node3D.new();scene.add_child(prop);prop.position=actor.to_global(Vector3(.47,.03,.20))
  var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
  for i in range(32):
   var angle_a=float(i)*TAU/32;var angle_b=float(i+1)*TAU/32
   var low=Vector3(cos(angle_a)*.15,0,sin(angle_a)*.15);var high=Vector3(cos(angle_a)*.19,.28,sin(angle_a)*.19);var low2=Vector3(cos(angle_b)*.15,0,sin(angle_b)*.15);var high2=Vector3(cos(angle_b)*.19,.28,sin(angle_b)*.19)
   for v in [low,high,low2,low2,high,high2]:st.add_vertex(v)
  st.generate_normals();var bucket=MeshInstance3D.new();bucket.mesh=st.commit();bucket.material_override=StandardMaterial3D.new();bucket.material_override.albedo_color=Color("a1b4b0");bucket.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED;prop.add_child(bucket)
  milk_fill=primitive(prop,"cylinder",Vector3(0,.035,0),Vector3(.33,.008,.33),"efe7d0")
 elif mode=="chicken":
  base_hand=Vector3(-extent*.45,.18,extent*.28);hand.position=base_hand
  prop=primitive(scene,"cylinder",Vector3(-extent*.45,.02,extent*.28),Vector3(.48,.022,.38),"b29568")
  for i in range(6):stage_eggs.append(primitive(scene,"ball",prop.position+Vector3((i%3-1)*.10,.07,(float(i/3)-.5)*.12),Vector3(.07,.09,.07),"f6e8c9"))
 elif mode in ["dog","cat"]:hand.visible=false;prop=primitive(scene,"ball",Vector3(extent*.7,.15,0),Vector3.ONE*.13*extent,"dcac67")
 elif mode=="sheep":
  for i in range(6):
   var tuft=primitive(actor,"ball",Vector3(bounds.get_center().x+(i%3-1)*bounds.size.x*.20,bounds.get_center().y+float(i/3)*bounds.size.y*.13,bounds.get_center().z+bounds.size.z*.34),Vector3.ONE*extent*.12,"eee4ca");fleece.append(tuft)
  prop=primitive(hand,"box",Vector3(0,0,-.14)*extent,Vector3(.09,.05,.16)*extent,"728b87")
 else:prop=primitive(scene,"ball",Vector3(extent*.55,.12,0),Vector3(.18,.10,.18)*extent,"ceaa78")
func play_anim(which):
 if ap:
  for name in ap.get_animation_list():
   if which in name:
    if ap.current_animation!=name:ap.get_animation(name).loop_mode=Animation.LOOP_LINEAR;ap.play(name,.15)
    break
func refresh_prompts():
 prompt_mode=game.using_controller
 for child in prompt_row.get_children():child.visible=false;child.queue_free()
 var prompts=[["UP","UP","ขึ้น"],["DOWN","DOWN","ลง"],["Esc","B","กลับ"]] if mode=="cow" else [["LEFT","LEFT","เลือก"],["RIGHT","RIGHT","เลือก"],["Space","A","ยืนยัน / เล่น"],["Esc","B","กลับ"]]
 for pair in prompts:
  prompt_row.add_child(load("res://scripts/input_glyph.gd").new(pair[1] if prompt_mode else pair[0],prompt_mode));prompt_row.add_child(game.ui.label(pair[2],16))
func _process(dt):
 if not game:return
 elapsed+=dt;tick=max(0,tick-dt);pulse=max(0,pulse-dt);phase=(sin(elapsed*(2.7+score*.08))+1)*.5
 window_center=clamp(window_base+sin(elapsed*.9+score)*.035,.15,.85)
 if game.using_controller!=prompt_mode:refresh_prompts()
 if not finished:
  var devices=Input.get_connected_joypads()
  if game.using_controller and not devices.is_empty() and tick<=0:
   var v=Vector2(Input.get_joy_axis(devices[0],JOY_AXIS_LEFT_X),Input.get_joy_axis(devices[0],JOY_AXIS_LEFT_Y))
   if v.length()>.65:direction(0 if v.x<-.5 else 3 if v.x>.5 else 1 if v.y<0 else 2);tick=.22
  if hand:
   hand.visible=pulse>0 and not mode in ["cow","dog","cat"]
   if milk_fill:milk_fill.position.y=.035+.19*float(score)/required
   if mode in ["pet","brush","goat"]:actor.rotation.z=sin(pulse*PI/.7)*.04 if pulse>0 else 0.0
   hand.position=base_hand+Vector3(0,-sin(pulse*PI/.7)*bounds.size.y*.08 if pulse>0 else 0,0)
   for material in milk_materials:material.set_shader_parameter("milk_pull",sin(pulse*PI/.7) if pulse>0 else 0.0)
   if mode=="cat" and prop:prop.position=Vector3(cos(cursor*TAU/6)*bounds.size.x*.6,.16+sin(elapsed*3)*.03,sin(cursor*TAU/6)*bounds.size.x*.5)
  if pulse<=0:play_anim("Idle")
 board.queue_redraw();progress.value=score
func _input(event):
 if not game:return
 if event is InputEventKey or event is InputEventMouseButton:game.using_controller=false
 elif event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value)>.22):game.using_controller=true
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_ESCAPE:cancel()
  elif not finished:
   match event.keycode:
    KEY_LEFT,KEY_A:direction(0)
    KEY_UP,KEY_W:direction(1)
    KEY_DOWN,KEY_S:direction(2)
    KEY_RIGHT,KEY_D:direction(3)
    KEY_SPACE,KEY_ENTER:confirm_action()
    KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6:cursor=int(event.keycode-KEY_1);confirm_action()
  get_viewport().set_input_as_handled()
 if event is InputEventJoypadButton and event.pressed:
  if event.button_index in [JOY_BUTTON_B,JOY_BUTTON_START]:cancel()
  elif not finished:
   match event.button_index:
    JOY_BUTTON_A,JOY_BUTTON_X:confirm_action()
    JOY_BUTTON_DPAD_LEFT:direction(0)
    JOY_BUTTON_DPAD_UP:direction(1)
    JOY_BUTTON_DPAD_DOWN:direction(2)
    JOY_BUTTON_DPAD_RIGHT:direction(3)
  get_viewport().set_input_as_handled()
func direction(dir):
 if finished:return
 if mode=="cow":
  if dir in [1,2]:milk(0 if dir==1 else 1)
  return
 var columns=5 if mode in ["pig","duck"] else 3
 var count=20 if mode in ["pig","duck"] else 3 if mode=="goat" else 6
 var next=cursor
 if dir==0:next=posmod(cursor-1,count)
 elif dir==3:next=posmod(cursor+1,count)
 elif dir==1:next=posmod(cursor-columns,count)
 else:next=posmod(cursor+columns,count)
 if mode=="duck":
  if abs(next%5-cursor%5)+abs(int(next/5)-int(cursor/5))!=1 or next in obstacles:return
 cursor=next
 if mode=="duck":
  actor.position=actor_home+Vector3((cursor%5-2)*bounds.size.y*.16,0,(float(int(cursor/5))-1.5)*bounds.size.y*.16);play_anim("Walk");pulse=.7
 if mode=="duck" and cursor==goal:hit();goal=[19,15,0][min(score,2)]
func pointer_action(point,board_size):
 if finished:return
 if mode=="cow":milk(expected);return
 if mode=="dog":confirm_action();return
 if mode=="cat":
  var nearest=INF
  for i in range(6):
   var p=board_size*.5+Vector2(cos(i*TAU/6),sin(i*TAU/6))*board_size.y*.32
   if point.distance_to(p)<nearest:nearest=point.distance_to(p);cursor=i
  confirm_action();return
 var cols=5 if mode in ["pig","duck"] else 3;var rows=4 if cols==5 else 1 if mode=="goat" else 2
 for i in range(cols*rows):
  if board.cell_rect(i,cols,rows).has_point(point):
   if mode=="duck":
    if abs(i%5-cursor%5)+abs(int(i/5)-int(cursor/5))==1 and not i in obstacles:cursor=i;if cursor==goal:hit();goal=[19,15,0][min(score,2)]
   else:cursor=i;confirm_action()
   return
func milk(dir):
 if dir==expected and abs(phase-window_center)<=window_width*.5:expected=1-expected;hit();window_base=.2+fmod(float(score)*.371,.6);window_width=max(.12,.24-score*.018)
 else:status.text=Lang.t("ลองใหม่ได้ รอแถบสีเขียวแล้วสลับขึ้นลง")
func confirm_action():
 if finished:return
 match mode:
  "chicken","sheep","brush","pet":
   if cursor<6 and not cursor in cleaned:
    cleaned.append(cursor)
    if mode=="chicken" and cursor<stage_eggs.size():base_hand=stage_eggs[cursor].global_position+Vector3(0,.08,.03);stage_eggs[cursor].visible=false
    if mode=="sheep" and cursor<fleece.size():base_hand=fleece[cursor].global_position+Vector3(0,.07,.06);fleece[cursor].visible=false
    hit();cursor=posmod(cursor+1,6)
  "cow":milk(expected)
  "goat":
   if cursor==goal:hit();goal=posmod(score*2,3)
   else:status.text=Lang.t("วันนี้อยากกิน ")+Lang.t(["ใบไม้","อาหาร","แครอต"][goal])
  "pig":
   if cursor in [3,11,18] and not cursor in cleaned:cleaned.append(cursor);hit()
   else:
    var distance=20
    for cell in [3,11,18]:
     if not cell in cleaned:distance=min(distance,abs(cursor%5-cell%5)+abs(int(cursor/5)-int(cell/5)))
    status.text=Lang.t("กลิ่นอยู่ใกล้แล้ว") if distance<=2 else Lang.t("ลองเดินหาอีกหน่อย")
  "dog":
   if pulse>0:return
   if phase>=.25 and phase<=.75:fetch()
   else:status.text=Lang.t("ลองโยนในแถบสีเขียว")
  "cat":
   if cursor==goal:hit();goal=posmod(goal+2+(score%2),6)
func fetch():
 pulse=2.3;play_anim("Walk");var tw=create_tween();var target=actor_home+actor.basis*Vector3(-bounds.size.x*.5,0,0)
 prop.position=target+Vector3(0,.12,0)
 tw.tween_property(actor,"position",target,.8);tw.tween_interval(.25);tw.tween_property(actor,"position",actor_home,.8);tw.tween_callback(hit)
func hit():
 if finished:return
 score+=1;pulse=.7;play_anim("Eat" if mode=="goat" else "Idle");game.audio.play_sfx("harvest",-12)
 status.text=Lang.t("ทำได้ดี! ค่อย ๆ ทำต่อได้เลย")
 if mode=="goat":status.text=Lang.t("อยากกิน ")+Lang.t(["ใบไม้","อาหาร","แครอต"][posmod(score*2,3)])
 if score>=required:complete()
func complete():
 if finished:return
 finished=true
 var result=Farm.finish_activity(record_id,mode)
 game.world.refresh();game.save();status.text=Lang.t(result)
 var row=HBoxContainer.new();container.add_child(row);row.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM);row.position=Vector2(-110,-90);button("กลับไปฟาร์ม",cancel,row)
func cancel():
 if not game:return
 game.activity=null;game.ui.hud.visible=true;game.modal=false;game.player.reset_mouse_capture();Input.mouse_mode=Input.MOUSE_MODE_CAPTURED;queue_free()
