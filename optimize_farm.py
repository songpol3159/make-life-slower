from pathlib import Path
p=Path('MakeLifeSlower/scripts/world.gd');s=p.read_text(encoding='utf-8')
s=s.replace('var plot_signatures={}','var plot_signatures={}\nvar plot_visuals')
s=s.replace('var o=MeshInstance3D.new();o.mesh=mesh;o.material_override=m;add_child(o)','var o=MeshInstance3D.new();o.mesh=mesh;o.material_override=m;o.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(o)',1)
s=s.replace(' var ap=model.find_child("AnimationPlayer",true,false)',' for mesh in model.find_children("*","MeshInstance3D",true,false):mesh.visibility_range_end=45;mesh.visibility_range_end_margin=3\n var ap=model.find_child("AnimationPlayer",true,false)',1)
s=s.replace(' for i in range(plots.size()):',' var plot_changed=false\n for i in range(plots.size()):',1)
s=s.replace('  plot_signatures[i]=signature','  plot_signatures[i]=signature;plot_changed=true')
s=s.replace('  rounded_plot(n,"b5aa7c" if not p.tilled else "66523a" if p.water else "947049",i<Farm.max_plots())\n  if i>=Farm.max_plots():\n   if i%6==0:label3(n,"ขยายพื้นที่",Vector3(0,.25,0),18)\n   continue','  if i>=Farm.max_plots():continue\n  rounded_plot(n,"b5aa7c" if not p.tilled else "66523a" if p.water else "947049",true)')
s=s.replace(' var crops_key=',' if plot_changed:batch_plot_visuals()\n var crops_key=',1)
s += '''
func batch_plot_visuals():
 if plot_visuals:plot_visuals.queue_free()
 plot_visuals=Node3D.new();plot_visuals.set_meta("dynamic",true);add_child(plot_visuals)
 var groups={}
 for n in plots:
  for o in n.find_children("*","MeshInstance3D",true,false):
   if o.is_queued_for_deletion():continue
   var material=o.material_override;var key=str(material.get_instance_id())
   if not groups.has(key):
    var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);groups[key]={"st":st,"material":material}
   for surface in range(o.mesh.get_surface_count()):groups[key].st.append_from(o.mesh,surface,o.global_transform)
   o.visible=false
 for group in groups.values():
  var mesh=MeshInstance3D.new();mesh.mesh=group.st.commit();mesh.material_override=group.material;plot_visuals.add_child(mesh)
'''
# More recognizable foliage while sharing the existing crop batches.
s=s.replace('for side in [-1,1]:crop_part(groups,"leaf",ball,p+Vector3(side*.06,.13*grow,0),Vector3(.13,.48,.16)*grow,"6c994f",side*.45)','for j in range(5):crop_part(groups,"leaf",ball,p+Vector3((j-2)*.03,.19*grow,(j%2)*.04),Vector3(.075,.48,.10)*grow,"6c994f",(j-2)*.36)')
s=s.replace('for side in [-1,1]:crop_part(groups,"leaf",ball,p+Vector3(side*.13,h*.72,0),Vector3(.44,.16,.34)*grow,"6c994f",side*.2)','for level in range(3):\n      for side in [-1,1]:crop_part(groups,"leaf",ball,p+Vector3(side*.16,h*(.3+level*.23),(.06 if level%2==0 else -.06)),Vector3(.43,.10,.26)*grow,"6c994f",side*.2)')
p.write_text(s,encoding='utf-8')
p=Path('MakeLifeSlower/scripts/main.gd');s=p.read_text(encoding='utf-8').replace('  var reach=4.2','  if kind=="plot" and int(n.get_meta("id"))>=Farm.max_plots():continue\n  var reach=4.2')
p.write_text(s,encoding='utf-8')
