"""Make lightweight animated game copies; original Blender files stay intact."""
import bpy, os, math, json
from mathutils import Vector, Quaternion
BASE=r'C:\Users\pubet\Downloads\gamedev model\output'
OUT=os.path.join(os.path.dirname(__file__),'MakeLifeSlower','assets','models')
BLENDS=os.path.join(os.path.dirname(__file__),'Rigged_Game_Models')
os.makedirs(OUT,exist_ok=True)
os.makedirs(BLENDS,exist_ok=True)
items=[]
for name,path,sx,sz in [('player','characters/player/Player_Farmer.glb',1,1),('seed','characters/seed_merchant/Seed_Merchant.glb',.94,.965),('livestock','characters/livestock_merchant/Livestock_Merchant.glb',1.08,1.035),('carpenter','characters/carpenter/Farm_Carpenter.glb',1.02,1.015)]:
    items.append((name,path,True,sx,sz))
for sp in ['cow','chicken','duck','sheep','goat','pig','dog','cat']:
    for age in ['young','adult']:
        title=sp.title()+'_'+age.title()
        if age=='young': path=f'friendly/{sp}/{age}/{title}_Friendly.glb'
        elif sp=='cow': path='cow/Cow_Adult_Holstein_v02.glb'
        else:path=f'{sp}/{age}/{title}.glb'
        items.append((sp+'_'+age,path,False,1,1))
report=[]
def smooth(a,b,x):
    t=max(0,min(1,(x-a)/(b-a)));return t*t*(3-2*t)
for name,path,human,sx,sz in items:
    bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=os.path.join(BASE,path))
    meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
    for o in meshes:
        world=o.matrix_world.copy();o.parent=None;o.matrix_world=world
        bpy.context.view_layer.objects.active=o;o.select_set(True)
        bpy.ops.object.transform_apply(location=True,rotation=True,scale=True);o.select_set(False)
    for o in list(bpy.context.scene.objects):
        if o.type!='MESH':bpy.data.objects.remove(o,do_unlink=True)
    tris=sum(len(o.data.polygons)*2 for o in meshes); target=13000 if human else 8000
    ratio=min(1,target/max(1,tris))
    for o in meshes:
        if len(o.data.polygons)>48:
            m=o.modifiers.new('Web geometry','DECIMATE');m.ratio=ratio
            bpy.context.view_layer.objects.active=o;bpy.ops.object.modifier_apply(modifier=m.name)
    # One skinned mesh per character, retaining distinct material surfaces.
    # This avoids a separate draw and skin update for every small eye/clothing part.
    bpy.ops.object.select_all(action='DESELECT')
    for o in meshes:o.select_set(True)
    bpy.context.view_layer.objects.active=meshes[0];bpy.ops.object.join()
    meshes=[bpy.context.object];meshes[0].name=name+' | Game mesh'
    for image in bpy.data.images:
        if image.type=='IMAGE' and image.size[0]>512:
            image.scale(512,512);image.pack()
    coords=[v.co for o in meshes for v in o.data.vertices]
    lo=Vector([min(p[i] for p in coords) for i in range(3)]);hi=Vector([max(p[i] for p in coords) for i in range(3)]);h=hi.z-lo.z
    arm=bpy.data.armatures.new('Rig'); rig=bpy.data.objects.new('Rig',arm);bpy.context.collection.objects.link(rig)
    bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
    defs={'Root':((0,0,0),(0,0,.1),None)}
    if human:
        defs.update({'Hips':((0,0,.82*sz),(0,0,1.02*sz),'Root'),'Spine':((0,0,1.02*sz),(0,0,1.33*sz),'Hips'),'Head':((0,0,1.38*sz),(0,0,1.70*sz),'Spine')})
        for s,side in [(-1,'R'),(1,'L')]:
            defs['Arm'+side]=((s*.184*sx,0,1.26*sz),(s*.402*sx,0,1.26*sz),'Spine')
            defs['Fore'+side]=((s*.402*sx,0,1.26*sz),(s*.625*sx,0,1.26*sz),'Arm'+side)
            defs['Hand'+side]=((s*.625*sx,0,1.26*sz),(s*.745*sx,0,1.26*sz),'Fore'+side)
            defs['Thigh'+side]=((s*.08*sx,0,.86*sz),(s*.08*sx,0,.50*sz),'Hips')
            defs['Shin'+side]=((s*.08*sx,0,.50*sz),(s*.08*sx,0,.19*sz),'Thigh'+side)
            defs['Foot'+side]=((s*.08*sx,0,.19*sz),(s*.08*sx,-.12,.07*sz),'Shin'+side)
    else:
        # Four short deforming leg regions; birds use a pair below their body.
        width=hi.y-lo.y;length=hi.x-lo.x
        defs['Head']=((lo.x+length*.33,0,h*.59),(lo.x+length*.13,0,h*.82),'Root')
        for idx,(x,y) in enumerate([(lo.x+length*.29,-width*.22),(lo.x+length*.29,width*.22),(lo.x+length*.70,-width*.22),(lo.x+length*.70,width*.22)]):
            defs['Leg'+str(idx)]=((x,y,h*.43),(x,y,.02),'Root')
    for bn,(a,b,parent) in defs.items():
        bone=arm.edit_bones.new(bn);bone.head=a;bone.tail=b
        if parent:bone.parent=arm.edit_bones[parent]
    bpy.ops.object.mode_set(mode='OBJECT')
    for o in meshes:
        groups={bn:o.vertex_groups.new(name=bn) for bn in defs}
        for v in o.data.vertices:
            x,y,z=v.co
            bn='Root'
            if human:
                xx=abs(x)/sx;zz=z/sz;side='L' if x>0 else 'R'
                if xx>.19 and 1.10<zz<1.40:bn=('Arm' if xx<.402 else 'Fore' if xx<.625 else 'Hand')+side
                elif zz<.88:bn=('Foot' if zz<.19 else 'Shin' if zz<.50 else 'Thigh')+side
                elif zz>1.39:bn='Head'
                elif zz>1.02:bn='Spine'
                else:bn='Hips'
            elif z<h*.38:
                bn=min([k for k in defs if k.startswith('Leg')],key=lambda k:(Vector(defs[k][0])-Vector((x,y,h*.43))).length)
            elif x<lo.x+(hi.x-lo.x)*.30:bn='Head'
            weights={bn:1.0}
            if human:
                xx=abs(x)/sx;zz=z/sz;side='L' if x>0 else 'R'
                if xx>.14 and 1.09<zz<1.40:
                    shoulder=smooth(.14,.25,xx)
                    fore=smooth(.35,.45,xx);hand=smooth(.595,.65,xx)
                    weights={'Spine':1-shoulder,'Arm'+side:shoulder*(1-fore),'Fore'+side:shoulder*fore*(1-hand),'Hand'+side:shoulder*fore*hand}
                elif zz<.94:
                    hips=smooth(.82,.94,zz);thigh=smooth(.44,.56,zz);shin=smooth(.14,.24,zz)
                    weights={'Hips':hips,'Thigh'+side:(1-hips)*thigh,'Shin'+side:(1-hips)*(1-thigh)*shin,'Foot'+side:(1-hips)*(1-thigh)*(1-shin)}
                elif zz>1.33:
                    head_w=smooth(1.33,1.43,zz);weights={'Head':head_w,'Spine':1-head_w}
            else:
                if z<h*.48:
                    leg=min([k for k in defs if k.startswith('Leg')],key=lambda k:(Vector(defs[k][0])-Vector((x,y,h*.43))).length)
                    w=1-smooth(h*.23,h*.48,z);weights={'Root':1-w,leg:w}
                elif x<lo.x+(hi.x-lo.x)*.38:
                    w=1-smooth(lo.x+(hi.x-lo.x)*.24,lo.x+(hi.x-lo.x)*.38,x);weights={'Root':1-w,'Head':w}
            for group,w in weights.items():
                if w>.001:groups[group].add([v.index],w,'REPLACE')
        mod=o.modifiers.new('Game rig','ARMATURE');mod.object=rig;o.parent=rig
    rig.animation_data_create()
    for anim,frames in [('Idle',48),('Walk',32),('Use' if human else 'Eat',48)]:
        action=bpy.data.actions.new(anim);rig.animation_data.action=action
        for frame in range(1,frames+2,4):
            phase=(frame-1)/frames*math.tau
            for bn,pb in rig.pose.bones.items():
                angle=0;axis=(1,0,0)
                if human:
                    if bn.startswith('Arm'):
                        axis=(0,1,0);angle=(1 if bn.endswith('L') else -1)*1.35
                        if anim=='Walk':angle+=.06*math.sin(phase)
                        if anim=='Use' and bn.endswith('R'):angle-=.65*math.sin(math.pi*(frame-1)/frames)
                    elif bn.startswith('Thigh') and anim=='Walk':angle=.32*math.sin(phase+(0 if bn.endswith('L') else math.pi))
                    elif bn.startswith('Shin') and anim=='Walk':angle=max(0,.20*math.sin(phase+(0 if bn.endswith('L') else math.pi)))
                    elif bn=='Head' and anim=='Use':angle=.10*math.sin(phase)
                elif bn.startswith('Leg') and anim=='Walk':
                    axis=(0,1,0);idx=int(bn[-1]);angle=.25*math.sin(phase+(0 if idx in [0,3] else math.pi))
                elif bn=='Head' and not human:
                    axis=(0,1,0);angle=-.16-.12*math.sin(phase) if anim=='Eat' else .018*math.sin(phase)
                q=pb.bone.matrix_local.to_quaternion();pb.rotation_mode='QUATERNION';pb.rotation_quaternion=q.inverted()@Quaternion(axis,angle)@q
                pb.keyframe_insert(data_path='rotation_quaternion',frame=frame)
            rig.pose.bones['Root'].location.z=(.008 if human else h*.015)*math.sin(phase*2) if anim=='Walk' else 0
            rig.pose.bones['Root'].keyframe_insert(data_path='location',frame=frame)
        rig.animation_data.action=None
        tr=rig.animation_data.nla_tracks.new();tr.name=anim;strip=tr.strips.new(anim,1,action)
    bpy.context.scene.frame_start=1;bpy.context.scene.frame_end=49;bpy.context.scene.render.fps=24
    bpy.context.scene.unit_settings.system='METRIC'
    rig.show_in_front=True
    bpy.data.orphans_purge(do_recursive=True)
    for screen in bpy.data.screens:
        for area in screen.areas:
            if area.type=='VIEW_3D':
                area.spaces.active.region_3d.view_location=(lo+hi)*.5
                area.spaces.active.region_3d.view_distance=max(h*2.5,(hi.x-lo.x)*1.8)
                area.spaces.active.shading.type='MATERIAL'
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(BLENDS,name+'.blend'))
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=os.path.join(OUT,name+'.glb'),export_format='GLB',use_selection=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_anim_single_armature=True)
    triangles=0
    for o in meshes:o.data.calc_loop_triangles();triangles+=len(o.data.loop_triangles)
    report.append({'asset':name,'triangles':triangles,'bytes':os.path.getsize(os.path.join(OUT,name+'.glb'))})
    print('GAME_ASSET',name,triangles,flush=True)
with open(os.path.join(OUT,'manifest.json'),'w') as f:json.dump(report,f,indent=2)
