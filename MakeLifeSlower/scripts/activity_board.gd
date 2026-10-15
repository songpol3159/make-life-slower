extends Control
var session
func _ready():mouse_filter=MOUSE_FILTER_STOP;custom_minimum_size=Vector2(500,265)
func cell_rect(i,cols=3,rows=2):
 var gap=14.0;var cell=Vector2((size.x-gap*(cols+1))/cols,(size.y-gap*(rows+1))/rows)
 return Rect2(Vector2(gap+(i%cols)*(cell.x+gap),gap+int(i/cols)*(cell.y+gap)),cell)
func _gui_input(event):
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
  session.pointer_action(event.position,size);accept_event()
func text_at(text,p,sz=19,color=Color("f1ead6")):
 draw_string(load("res://scripts/ui_font.gd").get_font(),p,Lang.t(text),HORIZONTAL_ALIGNMENT_LEFT,-1,sz,color)
func tile(i,cols,rows,selected=false):
 var rect=cell_rect(i,cols,rows);var box=StyleBoxFlat.new();box.bg_color=Color("496650") if selected else Color("293f34");box.set_corner_radius_all(14);box.set_border_width_all(2 if selected else 1);box.border_color=Color("eed79a") if selected else Color("6a816c");draw_style_box(box,rect);return rect
func _draw():
 if not session:return
 var mode=session.mode;var cursor=session.cursor
 if mode in ["cow","dog"]:
  var rect=Rect2(20,size.y*.42,size.x-40,42)
  draw_style_box(session.game.ui.style("293f34",12),rect)
  var center=session.window_center if mode=="cow" else .5
  var width=session.window_width if mode=="cow" else .5
  draw_style_box(session.game.ui.style("67835d",6),Rect2(rect.position+Vector2(rect.size.x*(center-width*.5),4),Vector2(rect.size.x*width,34)))
  draw_line(Vector2(20+session.phase*(size.x-40),rect.position.y-12),Vector2(20+session.phase*(size.x-40),rect.end.y+12),Color("f5df9d"),4,true)
  text_at("จังหวะสบาย ๆ · กดในแถบสีเขียว",Vector2(20,rect.position.y-28),19)
  text_at("ขึ้น" if session.expected==0 else "ลง",Vector2(20,rect.end.y+45),24)
 elif mode=="chicken":
  for i in range(6):
   var r=tile(i,3,2,i==cursor);var center=r.get_center()
   if not i in session.cleaned:
    draw_arc(center,30,0,TAU,32,Color("be9e69"),10,true)
    draw_set_transform(center,0,Vector2(.74,1));draw_circle(Vector2.ZERO,22,Color("f6e8c9"));draw_set_transform(Vector2.ZERO)
   else:text_at("เก็บแล้ว",center-Vector2(30,-5),16)
 elif mode in ["sheep","brush","pet"]:
  for i in range(6):
   var r=tile(i,3,2,i==cursor)
   for j in range(5):draw_circle(r.get_center()+Vector2(sin(j*1.7)*22,cos(j*1.7)*15),17,Color("80966c") if i in session.cleaned else Color("e8dfc9"))
   text_at(str(i+1),r.position+Vector2(10,23),16,Color("273e32"))
 elif mode=="goat":
  for i in range(3):
   var r=tile(i,3,1,i==cursor);var center=r.get_center()
   draw_circle(center,28,[Color("70a457"),Color("e2b454"),Color("d87d57")][i])
   text_at(["ใบไม้","อาหาร","แครอต"][i],r.position+Vector2(12,r.size.y-20),19)
 elif mode in ["duck","pig"]:
  for i in range(20):
   var r=tile(i,5,4,i==cursor)
   if mode=="duck":
    if i in session.obstacles:draw_circle(r.get_center(),16,Color("738782"))
    elif i==session.goal:draw_arc(r.get_center(),18,0,TAU,24,Color("edd27c"),3,true)
    if i==cursor:draw_circle(r.get_center(),11,Color("ead99f"))
   elif i in session.cleaned:draw_circle(r.get_center(),12,Color("b9a281"))
   else:draw_circle(r.get_center(),6,Color("78835a"))
 elif mode=="cat":
  draw_circle(Vector2(size.x*.5,size.y*.5),size.y*.4,Color("293f34"))
  for i in range(6):
   var p=Vector2(size.x*.5,size.y*.5)+Vector2(cos(i*TAU/6),sin(i*TAU/6))*size.y*.32
   draw_circle(p,21,Color("edca84") if i==session.goal else Color("557461"))
   if i==cursor:draw_arc(p,27,0,TAU,28,Color("f6efde"),2,true)
  text_at("ขยับของเล่นไปหาจุดสีทอง",Vector2(18,28),18)
 text_at("%d / %d"%[session.score,session.required],Vector2(size.x-80,size.y-8),16)
