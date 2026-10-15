from pathlib import Path
p=Path('MakeLifeSlower/tests/icons.gd');s=p.read_text(encoding='utf-8')
s=s.replace('  await create_timer(.2).timeout','''  var bounds=AABB();var first=true
  for mesh in animal.find_children("*","MeshInstance3D",true,false):
   var b=mesh.global_transform*mesh.get_aabb()
   if first:bounds=b;first=false
   else:bounds=bounds.merge(b)
  var center=bounds.get_center();camera.size=max(bounds.size.y*1.35,(bounds.size.x+bounds.size.z)*.85)*1.18
  camera.position=center+Vector3(-3,1.8,4);camera.look_at(center)
  await create_timer(.2).timeout''')
p.write_text(s,encoding='utf-8')
p=Path('MakeLifeSlower/scripts/world.gd');s=p.read_text(encoding='utf-8').replace('var lantern\n','var lantern\nvar lantern_model\n',1)
s=s.replace(' for p in [Vector3(-7,2.2,7.4)', ''' lantern_model=Node3D.new();lantern_model.set_meta("dynamic",true);add_child(lantern_model)
 cylinder(lantern_model,Vector3.ZERO,.09,.19,"dfc38a")
 for y in [-.12,.12]:cylinder(lantern_model,Vector3(0,y,0),.11,.035,"79664d")
 for x in [-.075,.075]:box(lantern_model,Vector3(x,0,0),Vector3(.015,.23,.015),"79664d")
 var glass=sphere(lantern_model,Vector3.ZERO,Vector3(.14,.19,.14),"ffe3a7");glass.material_override=glow
 for p in [Vector3(-7,2.2,7.4)''')
s=s.replace('lantern.visible=daylight<.15;lantern.position=player_position+Vector3(0,1.5,-.4)','lantern.visible=daylight<.15 and game.lantern_enabled;lantern.position=player_position+Vector3(0,1.5,-.4)\n lantern_model.visible=lantern.visible')
p.write_text(s,encoding='utf-8')
p=Path('MakeLifeSlower/scripts/main.gd');s=p.read_text(encoding='utf-8').replace('var trigger_held=false','var trigger_held=false\nvar lantern_enabled=true')
s=s.replace('JOY_BUTTON_RIGHT_STICK:player.first_person=not player.first_person','JOY_BUTTON_RIGHT_STICK:player.first_person=not player.first_person\n   JOY_BUTTON_DPAD_UP:lantern_enabled=not lantern_enabled')
s=s.replace('   KEY_F3:','   KEY_L:lantern_enabled=not lantern_enabled\n   KEY_F3:')
s=s.replace('  world.lantern.position=player.global_position+Vector3(0,1.5,-.4)','  world.lantern.position=player.global_position+Vector3(0,1.5,-.4)\n  world.lantern_model.global_position=player.camera.global_position+player.camera.global_basis*Vector3(-.35,-.36,-.60) if player.first_person else player.global_position+Vector3(-.30,.9,0)')
p.write_text(s,encoding='utf-8')
p=Path('MakeLifeSlower/scripts/ui.gd');s=p.read_text(encoding='utf-8')
s=s.replace('game.player.visual.visible=false;game.world.update_daylight','game.player.visual.visible=false;game.player.position=Vector3(9,8,24);game.player.camera.global_position=Vector3(12,10,26);game.player.camera.look_at(Vector3(0,0,-8));game.world.update_daylight')
s=s.replace('Y กระเป๋า · Start พัก','Y กระเป๋า · ↑ ตะเกียง · Start พัก').replace('M แผนที่ · Esc พัก','M แผนที่ · L ตะเกียง · Esc พัก')
s=s.replace('Esc พัก / ตั้งค่า','L เปิด / ปิดตะเกียง · Esc พัก / ตั้งค่า')
p.write_text(s,encoding='utf-8')
p=Path('MakeLifeSlower/tests/integration.gd');s=p.read_text(encoding='utf-8')
s=s.replace(' var joy=InputEventJoypadButton.new()', ''' var route=[Vector3(0,.8,12),Vector3(7,.8,2),Vector3(8,.8,-12),Vector3(22,.8,-28),Vector3(55,.8,-58)]
 var clear_route=true
 for i in range(route.size()-1):
  var ray=PhysicsRayQueryParameters3D.create(route[i],route[i+1]);ray.exclude=[g.player.get_rid(),g.world.truck.get_rid()]
  if not g.world.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():clear_route=false
 verify(clear_route,"farm to market road has no walls, fences, benches or trees across it")
 var joy=InputEventJoypadButton.new()''')
p.write_text(s,encoding='utf-8')
