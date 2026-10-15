extends RefCounted
static var cached:Font
static func get_font():
 if cached==null:
  var thai=load("res://assets/fonts/NotoSansThai.ttf").duplicate()
  thai.allow_system_fallback=false
  var fallbacks=[]
  for path in ["NotoSans.ttf","NotoSansSymbols.ttf","NotoSansSymbols2.ttf"]:
   var font=load("res://assets/fonts/"+path).duplicate();font.allow_system_fallback=false
   # Symbol fonts include very tall glyphs. Keep ordinary UI line height unchanged.
   for size in range(10,97):
    font.get_height(size)
    font.set_cache_ascent(0,size,thai.get_ascent(size));font.set_cache_descent(0,size,thai.get_descent(size))
   fallbacks.append(font)
  thai.fallbacks=fallbacks
  cached=thai
 return cached
