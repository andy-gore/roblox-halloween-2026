"""Generate local first-pass bedroom props. Run with Blender --background --python build.py."""
import bpy, json, math
from pathlib import Path
from mathutils import Vector
OUT=Path(__file__).resolve().parent
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
for c in list(bpy.data.collections):
 if c.name!='Collection': bpy.data.collections.remove(c)
def linear(v): return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
def material(name,rgb,metal=0,rough=.78):
 c=[linear(x/255) for x in rgb]; m=bpy.data.materials.new(name); m.diffuse_color=(*c,1); m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*c,1); p.inputs['Roughness'].default_value=rough; p.inputs['Metallic'].default_value=metal
 return m
wood=[material('DarkOak_%02d'%i,c) for i,c in enumerate([(66,34,20),(80,43,25),(93,52,30),(72,37,23)])]
trim=material('GothicTimber',(36,26,24)); brass=material('AgedBrass',(158,113,51),.65); cloth=material('BurgundyBlanket',(90,28,45)); clothlight=material('BlanketBinding',(123,48,61)); ivory=material('AgedIvoryLinen',(180,169,139)); linenedge=material('LinenSeams',(147,133,108)); mirror=material('TarnishedMirrorProxy',(101,115,119),.8,.24)
assets={}
def begin(name):
 global coll
 coll=bpy.data.collections.new(name); bpy.context.scene.collection.children.link(coll); assets[name]=coll

def finish(o,name,m):
 o.name=name
 for c in list(o.users_collection): c.objects.unlink(o)
 coll.objects.link(o); o.data.materials.append(m); return o

def box(n,loc,size,m,b=.035):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc); o=bpy.context.object; o.dimensions=size; bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if b:
  mod=o.modifiers.new('Small worn edges','BEVEL'); mod.width=b; mod.segments=1; bpy.context.view_layer.objects.active=o; bpy.ops.object.modifier_apply(modifier=mod.name)
 return finish(o,n,m)
def cyl(n,loc,r,depth,m,axis='Z'):
 bpy.ops.mesh.primitive_cylinder_add(vertices=12,radius=r,depth=depth,location=loc); o=bpy.context.object
 if axis=='Y': o.rotation_euler.x=math.pi/2
 return finish(o,n,m)
def peak(n,x,y,z,w,h,d,m):
 v=[(x-w/2,y-d/2,z),(x+w/2,y-d/2,z),(x,y-d/2,z+h),(x-w/2,y+d/2,z),(x+w/2,y+d/2,z),(x,y+d/2,z+h)]
 mesh=bpy.data.meshes.new(n); mesh.from_pydata(v,[],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)]); mesh.update(); return custom(n,mesh,m)
def custom(n,mesh,m):
 o=bpy.data.objects.new(n,mesh); coll.objects.link(o); o.data.materials.append(m); return o

def knob(n,x,y,z):
 cyl(n+'Mount',(x,y+.025,z),.1,.07,brass,'Y'); cyl(n+'Pull',(x,y-.045,z),.067,.13,brass,'Y')

begin('InnSingleBed')
for x in [-2,2]:
 for y in [-3.25,3.25]:
  height=3.7 if y>0 else 2.6
  box('BedPost',(x,y,height/2),(.5,.5,height),wood[0],.055)
  box('PostCap',(x,y,height+.07),(.58,.58,.14),trim)
 for z in [1.04]: box('SideRail',(x,0,z),(.28,6.5,.55),wood[1])
for y,height in [(-3.25,2.15),(3.25,3.25)]:
 box('EndRail',(0,y,1.05),(4,.25,.5),wood[0])
 for i in range(5): box('HeadPlank' if y>0 else 'FootPlank',((i-2)*.73,y,(1.25+height)/2),(.7,.23,height-1.25),wood[i%4])
 box('TopRail',(0,y,height+.08),(4,.35,.19),wood[2])
 if y>0: peak('HeadboardCrest',0,y,height+.17,1.3,.38,.28,wood[1])
box('Mattress',(0,0,1.67),(3.95,6.2,.66),ivory,.13)
for y in [-2.95,2.95]: box('MattressPiping',(0,y,1.7),(3.8,.04,.045),linenedge,.015)
box('BurgundyCoverlet',(0,-.72,2.035),(3.99,4.55,.14),cloth,.06)
for x in [-1.94,1.94]: box('CoverletSideDrop',(x,-.72,1.8),(.14,4.5,.5),cloth,.035)
box('FoldedBlanketEdge',(0,1.45,2.12),(4.02,.35,.13),clothlight,.035)
box('Pillow',(0,2.15,2.14),(2.65,1.3,.4),ivory,.19)
box('PillowSeam',(0,2.15,2.345),(2.2,.025,.018),linenedge,.008)

begin('BedsideCabinet')
for x in [-.78,.78]:
 for y in [-.62,.62]: box('Foot',(x,y,.24),(.25,.25,.48),wood[0])
box('CabinetBody',(0,0,1.25),(1.85,1.5,1.85),wood[0])
box('OverhangingTop',(0,0,2.3),(2.05,1.7,.25),wood[2])
box('DrawerFront',(0,-.79,1.85),(1.62,.13,.47),wood[1]); knob('Drawer',0,-.9,1.85)
box('CupboardDoor',(0,-.79,.98),(1.62,.13,1.12),wood[1])
box('DoorInset',(0,-.87,.98),(1.2,.06,.76),wood[0]); knob('Cupboard',.48,-.96,1.1)
for z in [.66,1.38]: box('Hinge',(-.65,-.93,z),(.1,.05,.2),brass,.015)

begin('InnWardrobe')
for x in [-1.6,1.6]:
 for y in [-.77,.77]: box('WardrobeFoot',(x,y,.25),(.35,.35,.5),trim)
box('WardrobeBody',(0,0,3.25),(3.8,2.05,5.8),wood[0])
box('BaseMoulding',(0,0,.55),(4.05,2.2,.3),wood[2]); box('Cornice',(0,0,6.2),(4.15,2.3,.3),wood[2]); box('CrownLip',(0,0,6.4),(4.3,2.4,.16),trim)
for x in [-.91,.91]:
 box('Door_L' if x<0 else 'Door_R',(x,-1.09,3.3),(1.72,.16,5.12),wood[1])
 box('LowerDoorPanel',(x,-1.19,1.8),(1.3,.07,1.6),wood[0])
 box('UpperDoorPanel',(x,-1.19,4.25),(1.3,.07,2.3),wood[0])
 peak('PointedPanelCrest',x,-1.19,5.4,1.3,.45,.07,wood[0])
 for xx in [-.7,.7]: box('DoorStile',(x+xx,-1.22,3.3),(.09,.08,4.86),wood[2],.015)
 knob('DoorHandle',-.12 if x<0 else .12,-1.35,3.05)
 for z in [1.3,5.3]: box('WardrobeHinge',(x+(-.73 if x<0 else .73),-1.24,z),(.13,.08,.3),brass,.02)
peak('WardrobePediment',0,0,6.48,2.5,.55,.6,wood[1])

begin('DresserMirror')
for x in [-1.55,1.55]:
 for y in [-.65,.65]: box('DresserFoot',(x,y,.23),(.3,.3,.46),trim)
box('DresserBody',(0,0,1.45),(3.6,1.65,2.25),wood[0])
box('DresserTop',(0,0,2.68),(3.9,1.9,.22),wood[2])
for i,z in enumerate([.83,1.48,2.13]):
 box('Drawer_%02d'%i,(0,-.88,z),(3.3,.15,.54),wood[1]); box('DrawerInset',(0,-.97,z),(2.98,.06,.32),wood[0],.02)
 for x in [-.85,.85]: knob('DrawerPull',x,-1.08,z)
for x in [-1.18,1.18]: box('MirrorUpright',(x,.58,3.9),(.22,.23,2.5),wood[1])
box('MirrorBacking',(0,.6,4.04),(2.5,.18,2.35),wood[0])
box('MirrorFace',(0,.478,4.04),(2.08,.035,1.95),mirror,.03)
for z in [2.9,5.18]: box('MirrorRail',(0,.46,z),(2.7,.27,.2),wood[2])
peak('MirrorCrest',0,.6,5.28,1.4,.32,.2,wood[1])

# Per-prop origin and export inspection before staging.
report={}
for name,c in assets.items():
 bpy.ops.object.select_all(action='DESELECT')
 for o in c.objects: o.select_set(True)
 bpy.context.view_layer.update()
 points=[o.matrix_world@Vector(v) for o in c.objects for v in o.bound_box]
 dims=[round(max(p[i] for p in points)-min(p[i] for p in points),3) for i in range(3)]
 assert abs(min(p.z for p in points))<.001,(name,'not floor aligned')
 assert all(d>0 for d in dims)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 report[name]={'blender_xyz_studs':dims,'roblox_xyz_studs':[dims[0],dims[2],dims[1]],'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in c.objects),'mesh_objects':len(c.objects)}
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
# Display arrangement only; exports retain their local origins.
for name,offset in [('InnSingleBed',(-3.5,-1,0)),('BedsideCabinet',(-.3,1.4,0)),('InnWardrobe',(3.8,3.3,0)),('DresserMirror',(4,-1.5,0))]:
 for o in assets[name].objects: o.location+=Vector(offset)
scene=bpy.context.scene; scene.unit_settings.system='NONE'; scene['asset_units']='1 Blender unit = 1 Roblox stud; GLB Y up'; scene['status']='Static first art pass; not integrated. Closed drawers/doors and decorative mirror.'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'BedroomProps.blend'))
begin('PreviewOnly')
box('Ground',(0,0,-.15),(200,200,.3),material('PreviewGround',(77,84,89)),0)
def aim(o,p): o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for loc,power,size in [((-7,-8,13),2600,8),((8,-2,11),2200,7),((0,9,12),2800,7)]:
 bpy.ops.object.light_add(type='AREA',location=loc); o=bpy.context.object; o.data.energy=power; o.data.shape='DISK'; o.data.size=size; aim(o,(0,0,2))
bpy.ops.object.camera_add(location=(14,-21,15)); aim(bpy.context.object,(.1,.2,2.3)); scene.camera=bpy.context.object; scene.camera.data.type='ORTHO'; scene.camera.data.ortho_scale=20
scene.render.engine='CYCLES'; scene.cycles.samples=40; scene.world.color=(.28,.28,.28); scene.render.resolution_x=1600; scene.render.resolution_y=1200; scene.render.resolution_percentage=100
scene.render.filepath=str(OUT/'preview.png'); bpy.ops.render.render(write_still=True)
print('ASSET_VALIDATION',json.dumps(report))
