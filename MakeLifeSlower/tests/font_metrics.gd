extends SceneTree
func _initialize():
 for path in ["NotoSansThai.ttf","NotoSans.ttf","NotoSansSymbols.ttf","NotoSansSymbols2.ttf"]:
  var font=load("res://assets/fonts/"+path);print(path," ",font.get_height(17))
 print("Combined ",load("res://scripts/ui_font.gd").get_font().get_height(17))
 quit()
