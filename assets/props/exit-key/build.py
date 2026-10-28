"""Generate an original brass key, GLB and transparent inventory render in Blender."""
import bpy, math, json
from pathlib import Path
from mathutils import Vector
OUT=Path(__file__).resolve().parent
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
def material(name,color,metal=0,rough=.4):
 m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*color,1); p.inputs['Metallic'].default_value=metal; p.inputs['Roughness'].default_value=rough
 return m
brass=material('Aged brass',(.48,.255,.055),.75,.38)
bright=material('Polished edge brass',(.65,.39,.095),.75,.3)
dark=material('Recessed brass',(.19,.085,.018),.65,.6)
parts=[]
def cube(n,loc,size,mat):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc); o=bpy.context.object; o.name=n; o.dimensions=size; bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 b=o.modifiers.new('Soft worn edges','BEVEL'); b.width=.025; b.segments=2; bpy.ops.object.modifier_apply(modifier=b.name); o.data.materials.append(mat); parts.append(o); return o
# Flat key, positive X points to the teeth. Open bow is real geometry.
bpy.ops.mesh.primitive_torus_add(major_segments=24,minor_segments=8,location=(-.6,0,.105),major_radius=.325,minor_radius=.09)
o=bpy.context.object; o.name='Open_Bow'; o.data.materials.append(brass); parts.append(o)
cube('Bow_Collar',(-.22,0,.105),(.27,.25,.18),bright)
cube('Shaft',(.35,0,.105),(1.03,.16,.18),brass)
cube('Tip',(.9,0,.105),(.16,.2,.2),bright)
cube('Bit_Spine',(.66,-.22,.105),(.55,.35,.18),brass)
# Two asymmetric teeth and open notch, readable at small scale.
cube('Tooth_Long',(.84,-.45,.105),(.17,.2,.18),bright)
cube('Tooth_Short',(.49,-.41,.105),(.15,.12,.18),bright)
for x in [-.25,-.14]: cube('Collar_Ridge',(x,0,.105),(.035,.28,.21),dark)
# Move the geometry to a floor-centred bounding-box origin.
pts=[o.matrix_world@Vector(v) for o in parts for v in o.bound_box]
minimum=Vector(tuple(min(v[i] for v in pts) for i in range(3))); maximum=Vector(tuple(max(v[i] for v in pts) for i in range(3)))
offset=Vector(((minimum.x+maximum.x)/2,(minimum.y+maximum.y)/2,minimum.z))
for o in parts: o.location-=offset
bpy.context.view_layer.update()
size=maximum-minimum
report={'blender_xyz_studs':[round(v,4) for v in size],'roblox_xyz_studs':[round(size.x,4),round(size.z,4),round(size.y,4)],'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in parts),'mesh_objects':len(parts),'units':'1 Blender unit = 1 Roblox stud'}
assert 1.9<size.x<2.1 and size.z<.25
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
bpy.ops.object.select_all(action='DESELECT')
for o in parts: o.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(OUT/'ExitKey.glb'),export_format='GLB',use_selection=True)
scene=bpy.context.scene; scene['asset_units']='1 Blender unit = 1 Roblox stud'; scene['status']='Static visual asset, no objective logic'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'ExitKey.blend'))
def aim(o,at): o.rotation_euler=(Vector(at)-o.location).to_track_quat('-Z','Y').to_euler()
for loc,power,size in [((-2,-3,5),250,4),((2,1,4),180,3),((0,3,3),200,2)]:
 bpy.ops.object.light_add(type='AREA',location=loc); o=bpy.context.object; o.data.energy=power; o.data.size=size; aim(o,(0,0,0))
bpy.ops.object.camera_add(location=(0,-1.1,4)); cam=bpy.context.object; aim(cam,(0,0,.08)); scene.camera=cam; cam.data.type='ORTHO'; cam.data.ortho_scale=2.65
scene.render.engine='CYCLES'; scene.cycles.samples=48; scene.world.color=(.3,.3,.3)
scene.render.resolution_x=1024; scene.render.resolution_y=1024; scene.render.resolution_percentage=100
scene.render.film_transparent=True; scene.render.image_settings.file_format='PNG'; scene.render.image_settings.color_mode='RGBA'
scene.render.filepath=str(OUT/'inventory-icon.png'); bpy.ops.render.render(write_still=True)
scene.render.film_transparent=False
floor=material('Preview slate',(.04,.055,.07),0,.85)
cube('PreviewGround',(0,0,-.08),(200,200,.1),floor)
cam.location=(1.5,-2.6,4); aim(cam,(0,0,.08)); scene.render.filepath=str(OUT/'preview.png'); bpy.ops.render.render(write_still=True)
print('VALIDATED',json.dumps(report))
