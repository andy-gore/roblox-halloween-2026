"""Original local objective props. Blender 5.2 Python; one unit = one stud."""
import bpy, math, json
from pathlib import Path
from mathutils import Vector
OUT=Path(__file__).resolve().parent
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
def mat(n,c,metal=0,rough=.5):
 m=bpy.data.materials.new(n); m.diffuse_color=(*c,1); m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*c,1); p.inputs['Metallic'].default_value=metal; p.inputs['Roughness'].default_value=rough
 return m
brass=mat('Aged brass matching exit key',(.48,.255,.055),.75,.38)
polish=mat('Polished brass edges',(.65,.39,.095),.75,.3)
steel=mat('Painted charcoal steel',(.055,.07,.072),.35,.64)
edge=mat('Worn steel edges',(.15,.17,.16),.65,.5)
black=mat('Bakelite and black iron',(.018,.021,.02),.15,.48)
ivory=mat('Aged enamel labels',(.64,.58,.43),0,.73)
red=mat('Muted red handle',(.31,.035,.023),.1,.55)
green=mat('Green indicator glass',(.055,.29,.12),.25,.3)
oak=mat('Dark oak mounting block',(.17,.078,.035),0,.8)
assets={}; collection=None

def begin(n):
 global collection
 collection=bpy.data.collections.new(n); bpy.context.scene.collection.children.link(collection); assets[n]=collection

def finish(o,n,m):
 o.name=n
 for c in list(o.users_collection): c.objects.unlink(o)
 collection.objects.link(o)
 if m:o.data.materials.append(m)
 return o

def box(n,loc,size,m,b=.035):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc); o=bpy.context.object; o.dimensions=size; bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if b:
  mod=o.modifiers.new('Soft worn edge','BEVEL'); mod.width=b; mod.segments=2; bpy.ops.object.modifier_apply(modifier=mod.name)
 return finish(o,n,m)

def cyl(n,loc,r,d,m,axis='Z',vertices=24):
 bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=d,location=loc); o=bpy.context.object
 if axis=='Y':o.rotation_euler.x=math.pi/2
 if axis=='X':o.rotation_euler.y=math.pi/2
 return finish(o,n,m)

def screw(x,y,z,r=.045):
 cyl('SlottedScrew',(x,y,z),r,.035,edge,'Y',12)
 box('ScrewSlot',(x,y-.023,z),(r*1.4,.008,.012),black,.002)

def label(n,text,loc,size,m):
 bpy.ops.object.text_add(location=loc,rotation=(math.pi/2,0,0)); o=bpy.context.object; o.data.body=text; o.data.align_x='CENTER'; o.data.align_y='CENTER'; o.data.size=size; o.data.extrude=.001
 bpy.ops.object.convert(target='MESH'); return finish(bpy.context.object,n,m)

def lathe(n,profile,m,segments=40):
 verts=[(r*math.cos(i*math.tau/segments),r*math.sin(i*math.tau/segments),z) for r,z in profile for i in range(segments)]
 faces=[]
 for j in range(len(profile)-1):
  for i in range(segments):
   k=(i+1)%segments; faces.append((j*segments+i,j*segments+k,(j+1)*segments+k,(j+1)*segments+i))
 mesh=bpy.data.meshes.new(n); mesh.from_pydata(verts,[],faces); mesh.update(); o=bpy.data.objects.new(n,mesh); collection.objects.link(o); o.data.materials.append(m); return o
# Wall-mounted fuse box. Front is -Y; bottom at zero, back at Y=0.
begin('CellarFuseBox')
box('CabinetBody',(0,-.23,1.6),(2.5,.46,3.2),steel,.08)
box('RaisedFront',(0,-.5,1.6),(2.25,.12,2.95),edge,.045)
box('EnamelFace',(0,-.58,1.6),(2.09,.06,2.78),steel,.025)
for x in [-.93,.93]:
 for z in [.32,2.88]:screw(x,-.64,z,.06)
box('MainLabelPlate',(0,-.64,2.65),(1.68,.045,.37),ivory,.025)
label('MAIN_LIGHTS','MAIN LIGHTS',(0,-.67,2.65),.18,black)
box('LeverRecess',(0,-.65,1.6),(.73,.08,1.28),black,.04)
for x in [-.31,.31]:cyl('LeverPivotCover',(x,-.8,1.6),.12,.12,edge,'X',16)
# Lever children share an explicit rotation pivot; default is OFF.
bpy.ops.object.empty_add(type='PLAIN_AXES',location=(0,-.8,1.6)); pivot=finish(bpy.context.object,'SwitchPivot',None); pivot['animation_axis']='local X'; pivot['off_degrees']=25; pivot['on_degrees']=-155
arm=box('SwitchArm',(0,-.87,1.25),(.15,.18,.7),edge)
grip=box('SwitchGrip',(0,-.89,.92),(.7,.32,.23),red,.07)
for o in [arm,grip]:o.parent=pivot; o.matrix_parent_inverse=pivot.matrix_world.inverted()
pivot.rotation_euler.x=math.radians(25)
label('ON_Label','ON',(-.7,-.68,2.04),.15,ivory)
label('OFF_Label','OFF',(-.7,-.68,1.14),.15,ivory)
cyl('IndicatorBezel',(.7,-.68,2.08),.14,.08,brass,'Y',20)
cyl('IndicatorLens',(.7,-.73,2.08),.1,.055,green,'Y',20)
box('WarningPlate',(0,-.66,.5),(1.45,.035,.28),ivory,.01)
label('WarningText','ISOLATE SUPPLY',(0,-.69,.5),.115,black)
for i in range(5):box('VentGroove',(.63,-.62,.9+i*.1),(.35,.025,.025),black,.006)
for x in [-.65,.65]:
 cyl('ConduitSocket',(x,-.2,3.24),.15,.1,edge)
 cyl('ConduitStub',(x,-.2,3.48),.075,.4,black)
# Classic brass counter bell with hollow lathed shell and independent plunger.
begin('ServiceBell')
cyl('BakeliteBase',(0,0,.105),.8,.21,black,vertices=40)
lathe('BrassBaseRim',[(.79,.14),(.82,.19),(.8,.25),(.68,.27)],brass)
lathe('BellShell',[(.64,.23),(.67,.28),(.65,.38),(.6,.57),(.5,.76),(.35,.89),(.13,.95),(.09,.94),(.3,.83),(.46,.7),(.55,.52),(.6,.32),(.6,.25)],brass)
lathe('PolishedLowerLip',[(.64,.27),(.675,.29),(.67,.32),(.64,.33)],polish)
cyl('PlungerShaft',(0,0,1.0),.065,.24,edge)
cyl('PressButton',(0,0,1.13),.19,.13,polish,vertices=24)
for a in [0,math.pi*.5,math.pi,math.pi*1.5]:
 cyl('BaseFoot',(.54*math.cos(a),.54*math.sin(a),.035),.12,.07,black,vertices=12)
# Brass lock on oak review mount. Actual slot is cut through the escutcheon.
begin('ExitDoorLock')
box('OakMount',(0,.1,1.25),(1.35,.2,2.5),oak,.06)
plate=box('BrassEscutcheon',(0,-.06,1.25),(.92,.12,2.16),brass,.12)
# Round keyhole head and narrow stem form a readable traditional keyway.
cut=cyl('TemporaryRoundCut',(0,-.06,1.0),.14,.5,None,'Y',24)
for cutter in [cut,box('TemporaryStemCut',(0,-.06,.78),(.135,.5,.33),None,.008)]:
 bpy.context.view_layer.objects.active=plate
 mod=plate.modifiers.new('Actual keyway','BOOLEAN'); mod.operation='DIFFERENCE'; mod.object=cutter; bpy.ops.object.modifier_apply(modifier=mod.name); bpy.data.objects.remove(cutter,do_unlink=True)
box('KeywayShadow',(0,.013,.95),(.4,.018,.65),black,.015)
for z in [.42,2.08]:screw(0,-.145,z,.065)
cyl('TurnKnobBezel',(0,-.17,1.65),.22,.1,polish,'Y')
cyl('TurnKnobStem',(0,-.27,1.65),.09,.17,edge,'Y')
knob=box('TurnKnob',(0,-.39,1.65),(.49,.16,.18),brass,.055)
# Set knob origin at the rotational centre for future local Y rotation.
bpy.context.scene.cursor.location=(0,-.39,1.65); bpy.context.view_layer.objects.active=knob; bpy.ops.object.select_all(action='DESELECT'); knob.select_set(True); bpy.ops.object.origin_set(type='ORIGIN_CURSOR'); knob['animation_axis']='local Y'; knob['unlock_degrees']=90
box('LockLabel',(0,-.14,2.38),(.82,.04,.16),ivory,.01)
label('EXIT_Text','EXIT',(0,-.167,2.38),.11,black)
# Local bounds, counts and individual GLBs before preview staging.
report={}
for name,c in assets.items():
 bpy.context.view_layer.update(); objects=[o for o in c.objects if o.type=='MESH']; pts=[o.matrix_world@Vector(v) for o in objects for v in o.bound_box]
 mins=[min(p[i] for p in pts) for i in range(3)]; maxs=[max(p[i] for p in pts) for i in range(3)]; dims=[round(b-a,4) for a,b in zip(mins,maxs)]
 assert all(math.isfinite(v) and v>0 for v in dims)
 bpy.ops.object.select_all(action='DESELECT')
 for o in c.objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 report[name]={'blender_xyz_studs':dims,'roblox_xyz_studs':[dims[0],dims[2],dims[1]],'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in objects),'mesh_objects':len(objects),'bounds_min_xyz':mins,'bounds_max_xyz':maxs}
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
# Stage at separated origins for editable overview.
for name,offset in [('CellarFuseBox',(-2.5,.4,0)),('ServiceBell',(0,-.45,0)),('ExitDoorLock',(2.2,.35,0))]:
 for o in assets[name].objects:
  if o.parent is None:o.location+=Vector(offset)
scene=bpy.context.scene; scene['units']='1 Blender unit = 1 Roblox stud'; scene['front']='-Y in Blender, +Z in glTF'; scene['status']='Local art assets; no gameplay or upload'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'ObjectiveProps.blend'))
# Preview stage is created after saving, and excluded from asset exports.
collection=bpy.data.collections.new('PreviewOnly'); scene.collection.children.link(collection)
box('Floor',(0,0,-.07),(200,200,.1),mat('Backdrop',(.045,.055,.065)),0)
def aim(o,at):o.rotation_euler=(Vector(at)-o.location).to_track_quat('-Z','Y').to_euler()
for loc,power,size in [((-4,-6,8),1000,5),((5,-2,6),750,4),((0,5,7),1100,4)]:
 bpy.ops.object.light_add(type='AREA',location=loc); o=bpy.context.object; o.data.energy=power; o.data.size=size; aim(o,(0,0,1.4))
bpy.ops.object.camera_add(location=(6,-13,7)); camera=bpy.context.object; aim(camera,(-.2,0,1.6)); scene.camera=camera; camera.data.type='ORTHO'; camera.data.ortho_scale=8.9
scene.render.engine='CYCLES'; scene.cycles.samples=48; scene.world.color=(.25,.25,.25); scene.render.resolution_x=1600; scene.render.resolution_y=1100; scene.render.resolution_percentage=100; scene.render.filepath=str(OUT/'preview.png'); bpy.ops.render.render(write_still=True)
print('VALIDATED',json.dumps(report))
