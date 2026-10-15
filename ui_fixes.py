from pathlib import Path
P=Path(__file__).parent/'MakeLifeSlower/scripts'
p=P/'ui.gd';s=p.read_text(encoding='utf-8')
s=s.replace('var theme\n','var theme\nvar menu_repeat=0.0\n')
s=s.replace('theme.set_stylebox("panel","PanelContainer",style("20362eec",18))','theme.set_stylebox("panel","PanelContainer",style("20362e45",22))')
s=s.replace('hud.add_child(stat_panel)\n','hud.add_child(stat_panel);glass(stat_panel)\n')
s=s.replace('hud.add_child(npc_dialog);npc_text','hud.add_child(npc_dialog);glass(npc_dialog);npc_text')
s=s.replace('s.content_margin_left=18;', 's.border_width_left=1;s.border_width_right=1;s.border_width_top=1;s.border_width_bottom=1;s.border_color=Color(1,1,.92,.18);s.shadow_color=Color(0,.025,.015,.2);s.shadow_size=5;s.content_margin_left=18;')
start=s.index(' if game.using_controller and overlay and not get_viewport().gui_get_focus_owner():');end=s.index('func update_hud():',start)
s=s[:start]+''' menu_repeat=max(0.0,menu_repeat-dt)
 if game.using_controller and overlay and not overlay.is_queued_for_deletion():
  ensure_focus()
  var sticks=Input.get_connected_joypads()
  if not sticks.is_empty() and menu_repeat<=0:
   var v=Vector2(Input.get_joy_axis(sticks[0],JOY_AXIS_LEFT_X),Input.get_joy_axis(sticks[0],JOY_AXIS_LEFT_Y))
   if abs(v.y)>.55:navigate_menu(1 if v.y>0 else -1);menu_repeat=.20
   elif abs(v.x)>.55:adjust_control(1 if v.x>0 else -1);menu_repeat=.16
func glass(panel):
 var bg=ColorRect.new();bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;bg.show_behind_parent=true
 var material=ShaderMaterial.new();material.shader=load("res://assets/glass.gdshader");bg.material=material;panel.add_child(bg)
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 bg.resized.connect(func():material.set_shader_parameter("panel_size",bg.size))
 material.set_shader_parameter("blur_pixels",1.8 if int(Farm.settings.quality)>0 else 0.0)
 bg.set_meta("glass",true)
func update_glass():
 for bg in root.find_children("*","ColorRect",true,false):
  if bg.get_meta("glass",false):bg.material.set_shader_parameter("blur_pixels",1.8 if int(Farm.settings.quality)>0 else 0.0)
func menu_controls():
 var controls=[]
 if not overlay:return controls
 for c in overlay.find_children("*","Control",true,false):
  if not c.is_visible_in_tree() or c.is_queued_for_deletion():continue
  if c is BaseButton and not c.disabled:controls.append(c)
  elif c is HSlider or c is SpinBox:controls.append(c)
 return controls
func focused_control():
 var c=get_viewport().gui_get_focus_owner()
 while c and not (c is BaseButton or c is HSlider or c is SpinBox):c=c.get_parent()
 return c if c and overlay and overlay.is_ancestor_of(c) else null
func ensure_focus():
 if focused_control():return
 var controls=menu_controls()
 if not controls.is_empty():controls[0].grab_focus()
func navigate_menu(direction):
 var controls=menu_controls()
 if controls.is_empty():return
 var index=controls.find(focused_control());controls[posmod(index+direction,controls.size())].grab_focus()
func adjust_control(direction):
 var c=focused_control()
 if c is OptionButton:
  c.select(posmod(c.selected+direction,c.item_count));c.item_selected.emit(c.selected)
 elif c is Range:c.value=clamp(c.value+direction*(c.step if c is SpinBox else (c.max_value-c.min_value)/20.0),c.min_value,c.max_value)
func activate_control():
 var c=focused_control()
 if c is OptionButton:adjust_control(1)
 elif c is BaseButton:
  if c.toggle_mode:c.button_pressed=not c.button_pressed
  c.pressed.emit()
func _input(event):
 if not overlay or overlay.is_queued_for_deletion() or not game.modal:return
 if event is InputEventJoypadMotion and abs(event.axis_value)>.22:game.using_controller=true;ensure_focus()
 if event is InputEventKey or event is InputEventMouseButton:game.using_controller=false
 if not event is InputEventJoypadButton or not event.pressed:return
 game.using_controller=true;ensure_focus()
 match event.button_index:
  JOY_BUTTON_DPAD_DOWN:navigate_menu(1)
  JOY_BUTTON_DPAD_UP:navigate_menu(-1)
  JOY_BUTTON_DPAD_LEFT:adjust_control(-1)
  JOY_BUTTON_DPAD_RIGHT:adjust_control(1)
  JOY_BUTTON_A:activate_control()
  JOY_BUTTON_B,JOY_BUTTON_START:
   if game.playing:close()
  _:return
 menu_repeat=.22;get_viewport().set_input_as_handled()
'''+s[end:]
s=s.replace('if overlay:overlay.queue_free()','if overlay:overlay.visible=false;overlay.queue_free()')
s=s.replace('overlay.add_child(panel)\n','overlay.add_child(panel);glass(panel);menu_repeat=.25\n')
s=s.replace('var sc=ScrollContainer.new();','var sc=ScrollContainer.new();sc.follow_focus=true;')
s=s.replace('body.add_theme_constant_override("separation",10);sc.add_child(body)','body.add_theme_constant_override("separation",10);sc.add_child(body)\n column.add_child(label("จอย: D-pad / ก้าน เลือก · ← → ปรับค่า · A ยืนยัน · B กลับ",13))')
s=s.replace('style("31493b",10)','style("31493b7a",14)')
p.write_text(s,encoding='utf-8')
p=P/'main.gd';s=p.read_text(encoding='utf-8').replace(' update_render_scale()\n Farm.save_settings()',' update_render_scale()\n if ui:ui.update_glass()\n Farm.save_settings()');p.write_text(s,encoding='utf-8')
