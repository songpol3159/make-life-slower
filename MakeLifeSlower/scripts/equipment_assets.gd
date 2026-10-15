extends RefCounted
static func bounds(scene):
 var result=AABB();var first=true
 for mesh in scene.find_children("*","MeshInstance3D",true,false):
  var transform=mesh.transform;var parent=mesh.get_parent()
  while parent and parent!=scene:transform=parent.transform*transform;parent=parent.get_parent()
  var aabb=transform*mesh.get_aabb();result=aabb if first else result.merge(aabb);first=false
 return result
static func make(key,span):
 var root=Node3D.new();var model=load("res://assets/equipment/"+key+".glb").instantiate();root.add_child(model)
 var box=bounds(model);var factor=span/max(box.size.x,max(box.size.y,box.size.z));model.scale*=factor;model.position=-box.get_center()*factor
 for mesh in model.find_children("*","MeshInstance3D",true,false):
  mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  for surface in mesh.mesh.get_surface_count():
   var material=mesh.mesh.surface_get_material(surface)
   if not material is StandardMaterial3D:continue
   material=material.duplicate()
   if key.begins_with("tool-hoe"):material.albedo_texture=load("res://assets/equipment/Textures/colormap.png")
   if key=="watering_can":material.albedo_color=Color("719f98");material.metallic=.12;material.roughness=.55
   mesh.set_surface_override_material(surface,material)
 return root
