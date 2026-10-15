extends SceneTree
func _initialize():call_deferred("run")
func run():
 for key in ["watering_can","fishing_rod","tool-hoe"]:
  var model=load("res://assets/equipment/"+key+".glb").instantiate();root.add_child(model);print(key," ",load("res://scripts/equipment_assets.gd").bounds(model))
  for part in model.find_children("*","MeshInstance3D",true,false):
   for i in part.mesh.get_surface_count():
    var m=part.mesh.surface_get_material(i);print(" MATERIAL ",m.resource_name," ",m.albedo_color," ",m.albedo_texture.resource_path if m.albedo_texture else "none")
  model.queue_free()
 quit()
