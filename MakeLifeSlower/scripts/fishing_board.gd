extends Control
var session
func _ready():custom_minimum_size=Vector2(500,140);mouse_filter=MOUSE_FILTER_STOP
func _gui_input(event):
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:session.press();accept_event()
func _draw():
 if not session:return
 var rect=Rect2(24,55,size.x-48,34)
 draw_style_box(session.game.ui.style("243d34",10),rect)
 if session.state=="reel":
  var width=session.band_width;var center=session.fish_position
  draw_style_box(session.game.ui.style("d28b6b" if session.surging else "8ba36d",8),Rect2(rect.position+Vector2(rect.size.x*(center-width*.5),3),Vector2(rect.size.x*width,28)))
  var x=rect.position.x+session.marker*rect.size.x
  draw_line(Vector2(x,rect.position.y-9),Vector2(x,rect.end.y+9),Color("f6df9b"),4,true)
 else:
  var point=rect.get_center();var radius=9+sin(session.elapsed*3)*3
  draw_circle(point,radius,Color("f2d7a0"))
 var font=load("res://scripts/ui_font.gd").get_font()
 draw_string(font,Vector2(24,35),Lang.t("คุมตัวชี้ให้อยู่ในแถบปลา · กดค้างเพื่อดึง ปล่อยเพื่อผ่อน"),HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("f3ebd6"))
 draw_string(font,Vector2(24,135),Lang.t("แรงตึงสาย"),HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("f3ebd6"))
 var tension=Rect2(145,119,size.x-169,13)
 draw_style_box(session.game.ui.style("243d34",4),tension)
 draw_style_box(session.game.ui.style("d38a6d" if session.tension>.75 else "92ad83",4),Rect2(tension.position,Vector2(tension.size.x*session.tension,13)))
