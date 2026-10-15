extends Control
signal picked(point)
var point=Vector2(-18,20)
var angle=0.0
var edit_id=-1
var selected_kind="pot"
func _ready():custom_minimum_size=Vector2(600,180);mouse_filter=Control.MOUSE_FILTER_STOP
func project(p):return Vector2(20+(p.x+21)/19*(size.x-40),20+(p.y-18)/18*(size.y-40))
func _gui_input(event):
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
  picked.emit(Vector2(snapped(-21+(event.position.x-20)/(size.x-40)*19,.5),snapped(18+(event.position.y-20)/(size.y-40)*18,.5)));accept_event()
func _draw():
 var background=StyleBoxFlat.new();background.bg_color=Color("46644c");background.set_corner_radius_all(12);draw_style_box(background,Rect2(Vector2.ZERO,size))
 for x in range(1,10):draw_line(Vector2(20+x*(size.x-40)/10,20),Vector2(20+x*(size.x-40)/10,size.y-20),Color(1,1,1,.06))
 for y in range(1,5):draw_line(Vector2(20,20+y*(size.y-40)/5),Vector2(size.x-20,20+y*(size.y-40)/5),Color(1,1,1,.06))
 for record in Farm.data.get("decorations",[]):
  if int(record.id)!=edit_id:icon(project(Vector2(record.x,record.z)),record.kind,record.rotation,Color("e5cc94"))
 var center=project(point);var color=Color("b9dfa4") if Life.valid_decoration(point,edit_id) else Color("e0806e")
 draw_circle(center,15,Color(color,.2));icon(center,selected_kind,angle,color)
 var font=load("res://scripts/ui_font.gd").get_font();draw_string(font,Vector2(22,19),Life.t("สวนข้างบ้าน · ด้านบนไปบ้าน","Home garden · House to the north"),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f1ebd3"))
func icon(center,kind,rotation,color):
 match kind:
  "fence":
   var end=Vector2(cos(rotation),sin(rotation))*15;draw_line(center-end,center+end,color,4);draw_circle(center-end,3,color);draw_circle(center+end,3,color)
  "lamp":draw_circle(center,7,Color(color,.3));draw_circle(center,3,color)
  "pot":
   for i in range(5):draw_circle(center+Vector2(cos(i*TAU/5),sin(i*TAU/5))*5,3,Color("edb1a4"))
   draw_circle(center,3,color)
  "path":draw_path_marker(center,Vector2(10,6),color)
func draw_path_marker(center,extent,color):
 var points=PackedVector2Array()
 for i in range(16):points.append(center+Vector2(cos(i*TAU/16)*extent.x,sin(i*TAU/16)*extent.y))
 draw_colored_polygon(points,color)
