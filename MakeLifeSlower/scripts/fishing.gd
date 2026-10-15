extends CanvasLayer
var game
var state="cast"
var elapsed=0.0
var state_time=0.0
var bite_wait=3.0
var marker=.5
var fish_position=.5
var tension=.12
var catch_progress=0.0
var holding=false
var landed=false
var board
var status
var progress
var prompt_row
var prompt_mode=false
var scene
var bobber
var fishing_line
var tip=Vector3(-49.4,2.4,57)
var float_position=Vector3(-51,-.05,57)
var old_camera
var old_position
var caught_fish=""
var fish_kind="perch"
var band_width=.20
var fish_phase=0.0
var surging=false
var misses=0.0
func begin(owner):
 game=owner;game.ui.close();game.modal=true;game.activity=self;game.ui.hud.visible=false;game.player.set_physics_process(false)
 old_camera=game.player.camera.global_transform;old_position=game.player.position
 game.player.position=Vector3(-46.2,.355,57.3);game.player.visual.visible=true;game.player.visual.rotation.y=-PI/2
 if game.player.hand_tool:game.player.hand_tool.visible=false
 game.player.camera.global_position=Vector3(-41.2,3.2,61.5);game.player.camera.look_at(Vector3(-49,.6,57))
 Input.mouse_mode=Input.MOUSE_MODE_VISIBLE;layer=20
 build();make_props()
func build():
 var root=Control.new();root.theme=game.ui.theme;root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(root)
 var panel=PanelContainer.new();root.add_child(panel);panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);panel.offset_left=180;panel.offset_right=-180;panel.offset_top=-420;panel.offset_bottom=-16;panel.add_theme_stylebox_override("panel",game.ui.style("20382fe8",18))
 var column=VBoxContainer.new();panel.add_child(column);column.add_theme_constant_override("separation",8)
 var heading=HBoxContainer.new();column.add_child(heading);heading.add_child(game.ui.label("ตกปลาที่ทะเลสาบ",25));var exit=game.ui.button("กลับไปฟาร์ม",cancel);heading.add_child(exit)
 status=game.ui.label("กดเพื่อเหวี่ยงเบ็ด",18);status.autowrap_mode=TextServer.AUTOWRAP_OFF;column.add_child(status)
 board=load("res://scripts/fishing_board.gd").new();board.session=self;column.add_child(board)
 progress=ProgressBar.new();progress.max_value=1;progress.show_percentage=false;progress.custom_minimum_size.y=12;column.add_child(progress)
 var action=Button.new();action.text=Lang.t("กด / กดค้าง เพื่อเล่น");action.custom_minimum_size.y=43;action.focus_mode=Control.FOCUS_NONE;action.button_down.connect(press);action.button_up.connect(release);column.add_child(action)
 prompt_row=HBoxContainer.new();prompt_row.alignment=BoxContainer.ALIGNMENT_CENTER;column.add_child(prompt_row);refresh_prompts()
func refresh_prompts():
 prompt_mode=game.using_controller
 for child in prompt_row.get_children():child.visible=false;child.queue_free()
 for pair in [["M1","A","ดึงสาย"],["Space","A","ยืนยัน / เล่น"],["Esc","B","กลับ"]]:
  var glyph=load("res://scripts/input_glyph.gd").new(pair[1] if prompt_mode else pair[0],prompt_mode);glyph.custom_minimum_size.y=34;prompt_row.add_child(glyph)
  var label=game.ui.label(pair[2],15);label.autowrap_mode=TextServer.AUTOWRAP_OFF;prompt_row.add_child(label)
func make_props():
 scene=Node3D.new();game.world.add_child(scene)
 var start=Vector3(-46.5,1.5,57)
 var rod=load("res://scripts/equipment_assets.gd").make("fishing_rod",start.distance_to(tip));scene.add_child(rod);rod.position=(start+tip)*.5;rod.quaternion=Quaternion(Vector3.UP,(tip-start).normalized())
 bobber=Node3D.new();scene.add_child(bobber)
 game.world.sphere(bobber,Vector3.ZERO,Vector3(.12,.16,.12),"dd876b");game.world.sphere(bobber,Vector3(0,-.045,0),Vector3(.12,.075,.12),"f0e7ce")
 fishing_line=MeshInstance3D.new();var mat=StandardMaterial3D.new();mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;mat.albedo_color=Color("e5e2c6");fishing_line.material_override=mat;scene.add_child(fishing_line)
func _process(dt):
 if not game:return
 advance(dt)
 if game.using_controller!=prompt_mode:refresh_prompts()
 bobber.position=float_position+Vector3(0,sin(elapsed*3.7)*.014,0)
 if state=="bite":bobber.position.y-=.07
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_LINES);st.add_vertex(tip);st.add_vertex(bobber.position);fishing_line.mesh=st.commit()
 board.queue_redraw();progress.value=catch_progress
func advance(dt):
 elapsed+=dt;state_time+=dt
 if state=="wait" and state_time>=bite_wait:
  state="bite";state_time=0;status.text=Lang.t("ปลากินเหยื่อแล้ว! กดเพื่อตวัดเบ็ด");game.audio.play_sfx("water",-9)
 elif state=="bite" and state_time>2.2:
  reset_cast("ปลาหลุดไปแล้ว ลองเหวี่ยงใหม่ได้")
 elif state=="reel":
  marker=clamp(marker+dt*(.55 if holding else -.42),0.0,1.0)
  var difficulty=1.0 if fish_kind=="perch" else 1.18
  surging=fmod(state_time+fish_phase,6.0)>4.7
  fish_position=clamp(.5+sin(state_time*1.55*difficulty+fish_phase)*.25+sin(state_time*3.25+fish_phase)*.085,.12,.88)
  band_width=(.20 if fish_kind=="perch" else .18)-catch_progress*.035
  var aligned=abs(marker-fish_position)<=band_width*.5
  misses=max(0.0,misses+dt*(-1.2 if aligned else 1.0))
  catch_progress=clamp(catch_progress+dt*(.20 if aligned else -.045),0.0,1.0)
  tension=clamp(tension+dt*(.35 if holding and surging else .28 if holding and not aligned else -.20),0.0,1.0)
  status.text=Life.t("ปลากระชาก! ผ่อนสายสักนิด","Fish is surging! Ease off briefly") if surging else Lang.t("กดค้างเพื่อดึง ปล่อยเพื่อผ่อน อย่าให้สายตึงเกินไป")
  if catch_progress>=1:land_fish()
  elif tension>=1:reset_cast("สายตึงเกินไป ปลาหลุดแล้ว ลองใหม่ได้")
  elif misses>12:reset_cast(Life.t("ปลาว่ายหนีไปแล้ว ลองใหม่ได้","The fish swam away. Try again."))
func press():
 if state=="cast":
  if not Farm.room_for(1):return
  state="wait";state_time=0;bite_wait=randf_range(2,4);status.text=Lang.t("รอทุ่นขยับ อย่าเพิ่งตวัดเบ็ด");game.audio.play_sfx("water")
 elif state=="bite":
  state="reel";state_time=0;holding=true;marker=.5;tension=.12;catch_progress=0;misses=0;fish_phase=randf()*TAU;fish_kind="carp" if Farm.data.hour>=19 or Farm.data.hour<5 else "trout" if Farm.season_index()==3 else ["perch","perch","trout","carp"][randi()%4];status.text=Lang.t("กดค้างเพื่อดึง ปล่อยเพื่อผ่อน อย่าให้สายตึงเกินไป")
 elif state=="wait":reset_cast(Life.t("ตวัดเร็วไป รอให้ทุ่นจมก่อนนะ","Too early! Wait until the float dips."))
 elif state=="reel":holding=true
 elif state=="landed":reset_cast("กดเพื่อเหวี่ยงเบ็ดอีกครั้ง")
func release():holding=false
func reset_cast(message):
 state="cast";state_time=0;holding=false;landed=false;catch_progress=0;tension=.12;status.text=Lang.t(message)
func land_fish():
 if landed or state!="reel":return
 caught_fish=fish_kind
 if not Farm.add_good(caught_fish,1):reset_cast("กระเป๋าเต็ม กลับไปขายของก่อน");return
 landed=true;state="landed";holding=false;Farm.data.stats.fish=int(Farm.data.stats.get("fish",0))+1
 if int(Farm.data.stats.get("festival_day",0))!=int(Farm.data.day):Farm.data.stats.festival_day=int(Farm.data.day);Farm.data.stats.festival_fish_day=0
 Farm.data.stats.festival_fish_day=int(Farm.data.stats.get("festival_fish_day",0))+1;Farm.commit();game.save();game.audio.play_sfx("harvest")
 status.text=Lang.t("จับได้ ")+Farm.good_title(caught_fish)+Lang.t(" · เก็บเข้ากระเป๋าแล้ว ขายที่ตลาดได้")
func _input(event):
 if event is InputEventKey and not event.echo:
  game.using_controller=false
  if event.keycode in [KEY_SPACE,KEY_ENTER]:
   if event.pressed:press()
   else:release()
   get_viewport().set_input_as_handled()
  elif event.keycode==KEY_ESCAPE and event.pressed:cancel();get_viewport().set_input_as_handled()
 elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
  game.using_controller=false
  if not event.pressed:release()
 elif event is InputEventJoypadButton:
  game.using_controller=true
  if event.button_index in [JOY_BUTTON_A,JOY_BUTTON_X]:
   if event.pressed:press()
   else:release()
   get_viewport().set_input_as_handled()
  elif event.button_index in [JOY_BUTTON_B,JOY_BUTTON_START] and event.pressed:cancel();get_viewport().set_input_as_handled()
func cancel():
 if not game:return
 scene.queue_free();game.player.position=old_position;game.player.camera.global_transform=old_camera;game.player.set_physics_process(true);game.activity=null;game.modal=false;game.ui.hud.visible=true;game.player.reset_mouse_capture();Input.mouse_mode=Input.MOUSE_MODE_CAPTURED;queue_free()
