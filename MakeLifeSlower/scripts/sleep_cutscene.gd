extends Node
var game
var sleeping_actor
var layer
var fade
var canvas
var caption
var elapsed=0.0
var advanced=false
var ending=false
var bed_position=Vector3.ZERO
var original_position=Vector3.ZERO
var original_transform=Transform3D.IDENTITY
func begin(owner):
 game=owner;game.ui.close();game.modal=true;game.sleep_scene=self;game.ui.hud.visible=false;game.player.set_physics_process(false);game.player.visual.visible=false;game.world.lantern.visible=false;game.world.lantern_model.visible=false;Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
 if game.player.hand_tool:game.player.hand_tool.visible=false
 if game.player.body_tool:game.player.body_tool.visible=false
 original_position=game.player.position;original_transform=game.player.camera.global_transform
 # Follow the upgraded house's scale so the sleeping actor stays on the mattress.
 bed_position=game.world.house.to_global(Vector3(-1.5,1.03,.2))
 sleeping_actor=load("res://assets/models/player.glb").instantiate();game.world.add_child(sleeping_actor);sleeping_actor.position=bed_position; sleeping_actor.rotation=Vector3(-PI/2,0,0);sleeping_actor.scale=Vector3.ONE*.85
 var ap=sleeping_actor.find_child("AnimationPlayer",true,false)
 if ap:
  for anim in ap.get_animation_list():
   if "Idle" in anim:ap.play(anim);ap.seek(.1,true);ap.pause();break
 game.player.camera.global_position=bed_position+Vector3(2,2.5,1.6);game.player.camera.look_at(bed_position+Vector3(0,0,-.7))
 layer=CanvasLayer.new();layer.layer=30;add_child(layer)
 canvas=Control.new();layer.add_child(canvas);canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);canvas.theme=game.ui.theme
 fade=ColorRect.new();fade.color=Color(0,0,0,0);fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);fade.mouse_filter=Control.MOUSE_FILTER_IGNORE;canvas.add_child(fade)
 caption=game.ui.label("พักผ่อน แล้วค่อยเริ่มใหม่พรุ่งนี้",25);caption.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM);caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;canvas.add_child(caption);caption.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM);caption.offset_left=-360;caption.offset_right=360;caption.offset_top=-145;caption.offset_bottom=-85;caption.add_theme_constant_override("outline_size",6);caption.add_theme_color_override("font_outline_color",Color("182a23"))
 var skip=game.ui.button("ข้าม · Space / A",finish);skip.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT);canvas.add_child(skip);skip.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT);skip.offset_left=-250;skip.offset_right=-30;skip.offset_top=-75;skip.offset_bottom=-25
func _process(dt):
 if ending or not fade:return
 elapsed+=dt
 if elapsed<1.8:
  game.player.camera.global_position=bed_position+Vector3(2-elapsed*.10,2.5,1.6)
  game.player.camera.look_at(bed_position+Vector3(0,0,-.7))
 fade.color.a=smoothstep(1.6,2.7,elapsed)
 if elapsed>=2.7 and not advanced:
  advance();caption.text=Lang.t("เช้าวันใหม่")
 if elapsed>=3.2:fade.color.a=1-smoothstep(3.2,4.2,elapsed)
 if elapsed>=4.2:finish()
func advance():
 if advanced:return
 advanced=true;Farm.next_day();game.player.position=original_position;game.player.camera.global_transform=original_transform
 sleeping_actor.visible=false;game.world.update_daylight(Farm.data.hour,game.player.global_position);game.audio.play_sfx("save");game.save()
func _input(event):
 if event is InputEventKey and event.pressed and event.keycode in [KEY_SPACE,KEY_ENTER,KEY_ESCAPE]:finish();get_viewport().set_input_as_handled()
 elif event is InputEventJoypadButton and event.pressed and event.button_index in [JOY_BUTTON_A,JOY_BUTTON_B,JOY_BUTTON_START]:finish();get_viewport().set_input_as_handled()
func finish():
 if ending:return
 ending=true;advance();sleeping_actor.queue_free();game.player.set_physics_process(true);game.player.visual.visible=not game.player.first_person;game.ui.hud.visible=true;game.modal=false;game.sleep_scene=null;game.player.reset_mouse_capture();Input.mouse_mode=Input.MOUSE_MODE_CAPTURED;queue_free()
