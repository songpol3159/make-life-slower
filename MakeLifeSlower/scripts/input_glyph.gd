extends Control
# Original vector prompts: crisp at any resolution, no external font glyphs needed.
var symbol="E"
var controller=false
var active=false
func _init(text="E",pad=false):
 symbol=text;controller=pad;custom_minimum_size=Vector2(46 if pad else max(46,text.length()*10+20),46);mouse_filter=MOUSE_FILTER_IGNORE
func _ready():resized.connect(queue_redraw)
func _draw():
 var font=load("res://scripts/ui_font.gd").get_font()
 var r=Rect2(Vector2(2,2),size-Vector2(4,7))
 var colors={"A":Color("92c977"),"B":Color("e59487"),"X":Color("80b4dc"),"Y":Color("e5cb79")}
 var ink=colors.get(symbol,Color("f3ebd6")) if controller else Color("2b4036")
 if controller:
  draw_circle(size*.5+Vector2(0,3),min(size.x,size.y)*.44,Color("111f1b"))
  draw_circle(size*.5,min(size.x,size.y)*.44,Color("344f43"))
  draw_arc(size*.5,min(size.x,size.y)*.43,0,TAU,40,ink*.8,1.5,true)
 else:
  var shadow=StyleBoxFlat.new();shadow.bg_color=Color("a9b8ae");shadow.set_corner_radius_all(8);draw_style_box(shadow,Rect2(r.position+Vector2(0,5),r.size))
  var cap=StyleBoxFlat.new();cap.bg_color=Color("f0f1e7");cap.set_corner_radius_all(8);cap.set_border_width_all(1);cap.border_color=Color("bdcabe");draw_style_box(cap,r)
 var center=size*.5
 if symbol in ["UP","DOWN","LEFT","RIGHT"]:
  var angle={"UP":-PI/2,"DOWN":PI/2,"LEFT":PI,"RIGHT":0.0}[symbol]
  var points=PackedVector2Array()
  for p in [Vector2(-8,-3),Vector2(1,-3),Vector2(1,-8),Vector2(10,0),Vector2(1,8),Vector2(1,3),Vector2(-8,3)]:points.append(center+p.rotated(angle))
  draw_colored_polygon(points,ink)
 elif symbol=="M1":
  draw_arc(center,10,PI,TAU,20,ink,2,true);draw_line(center+Vector2(-10,0),center+Vector2(-10,10),ink,2);draw_line(center+Vector2(10,0),center+Vector2(10,10),ink,2);draw_arc(center+Vector2(0,10),10,0,PI,20,ink,2,true);draw_line(center+Vector2(0,-9),center+Vector2(0,0),ink,2)
 else:draw_string(font,center-Vector2(font.get_string_size(symbol,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x*.5,-6),symbol,HORIZONTAL_ALIGNMENT_LEFT,-1,18,ink)
