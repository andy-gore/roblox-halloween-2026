"""Run with Blender --background --python build.py. All dimensions are studs."""
import bpy, math, json
from pathlib import Path
from mathutils import Vector
OUT=Path(__file__).resolve().parent
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
for c in list(bpy.data.collections):
    if c.name != 'Collection': bpy.data.collections.remove(c)
def material(name, color, metal=0):
    m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*color,1); p.inputs['Roughness'].default_value=.8; p.inputs['Metallic'].default_value=metal
    return m
woods=[material('Oak_%02d'%i,c) for i,c in enumerate([(.22,.105,.045),(.28,.14,.065),(.32,.17,.08),(.25,.12,.05)])]
iron=material('Blackened_Iron',(.07,.08,.085),.65)
assets={}
def begin(name):
    global coll
    coll=bpy.data.collections.new(name); bpy.context.scene.collection.children.link(coll); assets[name]=coll

def finish(o,name,mat):
    o.name=name
    for c in list(o.users_collection): c.objects.unlink(o)
    coll.objects.link(o); o.data.materials.append(mat)
    return o

def box(name,loc,size,mat,bevel=.035):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc); o=bpy.context.object; o.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        mod=o.modifiers.new('Small worn edges','BEVEL'); mod.width=bevel; mod.segments=1
        bpy.context.view_layer.objects.active=o; bpy.ops.object.modifier_apply(modifier=mod.name)
    return finish(o,name,mat)

begin('PubTable')
for i in range(5): box('TopPlank_%02d'%i,(0,(i-2)*1.2,2.8),(7,1.17,.4),woods[i%4])
for x in [-2.65,2.65]:
    for y in [-2.2,2.2]: box('Leg',(x,y,1.3),(.48,.48,2.6),woods[0])
    box('EndApron',(x,0,2.35),(.24,4.5,.6),woods[1])
for y in [-2.2,2.2]: box('SideApron',(0,y,2.35),(5.4,.24,.6),woods[0])
box('LowStretcher',(0,0,.7),(5.5,.32,.35),woods[1])
for x in [-2.65,2.65]: box('CrossStretcher',(x,0,.7),(.32,4.5,.35),woods[1])

begin('PubChair')
for i in range(3): box('SeatPlank',(0,(i-1)*.8,1.85),(2.5,.77,.3),woods[i])
for x in [-.96,.96]:
    box('RearPost',(x,.93,2.2),(.3,.3,4.4),woods[0])
    box('FrontLeg',(x,-.93,.85),(.34,.34,1.7),woods[0])
    box('SideRail',(x,0,.65),(.18,1.9,.2),woods[1])
for z in [2.65,3.75]: box('BackRail',(0,.93,z),(2.2,.26,.45),woods[2])
for x in [-.55,0,.55]: box('BackSlat',(x,.93,3.2),(.2,.18,.7),woods[1])
for y in [-.93,.93]: box('SeatApron',(0,y,1.5),(2,.22,.4),woods[0])

begin('CellarBarrel')
# Sixteen individually editable curved staves; narrow gaps make the silhouette readable.
levels=[(0,1.6),(.25,1.7),(1.2,1.94),(2,2),(2.8,1.94),(3.75,1.7),(4,1.6)]
for i in range(16):
    a0=2*math.pi*(i+.025)/16; a1=2*math.pi*(i+.975)/16
    verts=[(r*math.cos(a),r*math.sin(a),z) for z,r in levels for a in (a0,a1)]
    faces=[(j*2,j*2+1,j*2+3,j*2+2) for j in range(len(levels)-1)]
    mesh=bpy.data.meshes.new('Stave'); mesh.from_pydata(verts,[],faces); mesh.update()
    o=bpy.data.objects.new('Stave_%02d'%i,mesh); coll.objects.link(o); o.data.materials.append(woods[i%4])
    mod=o.modifiers.new('Stave thickness','SOLIDIFY'); mod.thickness=.13
    bpy.context.view_layer.objects.active=o; bpy.ops.object.modifier_apply(modifier=mod.name)
for z,r in [(.45,1.78),(1.2,1.98),(2.8,1.98),(3.55,1.78)]:
    verts=[]
    for zz,rr in [(z-.12,r),(z+.12,r),(z-.12,r-.08),(z+.12,r-.08)]:
        verts.extend([(rr*math.cos(i*math.tau/16),rr*math.sin(i*math.tau/16),zz) for i in range(16)])
    faces=[]
    for i in range(16):
        j=(i+1)%16
        faces.extend([(i,j,16+j,16+i),(i,32+i,32+j,j),(16+i,16+j,48+j,48+i),(32+i,48+i,48+j,32+j)])
    mesh=bpy.data.meshes.new('Hoop'); mesh.from_pydata(verts,[],faces); mesh.update(); o=bpy.data.objects.new('IronHoop',mesh); coll.objects.link(o); o.data.materials.append(iron)
for z in [.08,3.92]:
    bpy.ops.mesh.primitive_cylinder_add(vertices=16,radius=1.58,depth=.16,location=(0,0,z)); finish(bpy.context.object,'BarrelHead',woods[1])
# Export each prop around a floor-centred origin before staging the preview.
report={}
for name,c in assets.items():
    bpy.ops.object.select_all(action='DESELECT')
    for o in c.objects: o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
    points=[o.matrix_world@Vector(v) for o in c.objects for v in o.bound_box]
    dims=[round(max(p[i] for p in points)-min(p[i] for p in points),3) for i in range(3)]
    tris=sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in c.objects)
    assert all(abs(a-b)<.04 for a,b in zip(dims,{'PubTable':[7,6,3],'PubChair':[2.5,2.4,4.4],'CellarBarrel':[4,4,4]}[name])), (name,dims)
    report[name]={'blender_xyz_studs':dims,'triangles':tris,'mesh_objects':len(c.objects)}
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
# Stage assets without altering exported origins.
for name,offset in [('PubTable',(-3,1,0)),('PubChair',(-3,-3.2,0)),('CellarBarrel',(3.3,1,0))]:
    for o in assets[name].objects: o.location+=Vector(offset)
scene=bpy.context.scene; scene.unit_settings.system='NONE'
scene['asset_units']='1 Blender unit = 1 Roblox stud. GLB export uses Y up.'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'PubProps.blend'))
begin('PreviewOnly')
box('Ground',(0,0,-.15),(200,200,.2),material('PreviewGround',(.065,.085,.09)),0)
def aim(o,p): o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for loc,power,size in [((-6,-8,12),2200,8),((7,-2,9),1600,7),((0,7,10),2400,6)]:
    bpy.ops.object.light_add(type='AREA',location=loc); o=bpy.context.object; o.data.energy=power; o.data.shape='DISK'; o.data.size=size; aim(o,(0,0,1))
bpy.ops.object.camera_add(location=(12,-17,12)); aim(bpy.context.object,(-.8,0,1.7)); scene.camera=bpy.context.object; scene.camera.data.type='ORTHO'; scene.camera.data.ortho_scale=18
scene.render.engine='CYCLES'; scene.cycles.samples=32
scene.world.color=(.25,.25,.25); scene.render.resolution_x=1500; scene.render.resolution_y=1000; scene.render.resolution_percentage=100
scene.render.filepath=str(OUT/'preview.png'); bpy.ops.render.render(write_still=True)
print('ASSET_VALIDATION',json.dumps(report))
