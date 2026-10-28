"""Generate original local kitchen and cellar props. Run with Blender --background --python build.py."""
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

# Additional materials retain the same sRGB-to-linear bedroom palette.
leather=material('Worn brown leather',(97,52,32),0,.65)
strap=material('Dark leather straps',(49,30,24),0,.62)
bookgreen=material('Faded green book',(45,70,58))
bookblue=material('Faded navy book',(36,49,65))
paper=material('Aged paper',(192,177,140))
shade=material('Ivory lampshade',(197,178,137),0,.85)
black=material('Blackened iron',(31,33,34),.6,.55)
bulb=material('Warm bulb',(238,207,143),0,.4)

def lathe(n,profile,m,segments=32):
 v=[(r*math.cos(i*math.tau/segments),r*math.sin(i*math.tau/segments),z) for r,z in profile for i in range(segments)]
 f=[(j*segments+i,j*segments+(i+1)%segments,(j+1)*segments+(i+1)%segments,(j+1)*segments+i) for j in range(len(profile)-1) for i in range(segments)]
 mesh=bpy.data.meshes.new(n);mesh.from_pydata(v,[],f);mesh.update();return custom(n,mesh,m)

def tube(n,points,m,r=.045):
 curve=bpy.data.curves.new(n,'CURVE');curve.dimensions='3D';curve.bevel_depth=r;curve.bevel_resolution=1;curve.resolution_u=1
 spline=curve.splines.new('POLY');spline.points.add(len(points)-1)
 for p,co in zip(spline.points,points):p.co=(*co,1)
 o=bpy.data.objects.new(n,curve);coll.objects.link(o);bpy.context.view_layer.objects.active=o;o.select_set(True);bpy.ops.object.convert(target='MESH');o=bpy.context.object;o.data.materials.append(m);o.select_set(False);return o

def text(n,body,loc,size,m):
 bpy.ops.object.text_add(location=loc,rotation=(math.pi/2,0,0));o=bpy.context.object;o.data.body=body;o.data.align_x='CENTER';o.data.align_y='CENTER';o.data.size=size;o.data.extrude=.004;o.data.resolution_u=3
 bpy.ops.object.convert(target='MESH');return finish(bpy.context.object,n,m)

def screw(x,y,z):
 cyl('BrassScrew',(x,y,z),.045,.03,brass,'Y');box('ScrewSlot',(x,y-.018,z),(.05,.008,.012),trim,.002)

steel=material('Aged cookware steel',(94,103,106),.75,.42)
steelrim=material('Polished steel edges',(145,151,146),.8,.32)
enamel=material('Ivory enamel',(190,182,155),.15,.46)
straw=material('Broom straw',(145,116,62),0,.9)
strawlight=material('Broom straw light',(175,144,81),0,.9)

begin('CellarShelf')
for x in [-1.65,1.65]:
 for y in [-.6,.6]:box('Upright',(x,y,2.25),(.18,.18,4.5),wood[0])
for z in [.28,1.62,2.96,4.3]:
 for j in [-1,0,1]:box('ShelfPlank',(0,j*.46,z),(3.6,.43,.16),wood[(j+2)%4])
 for x in [-1.64,1.64]:box('ShelfCleat',(x,0,z-.16),(.18,1.3,.18),wood[1])
for y in [-.62,.62]:box('TopRail',(0,y,4.4),(3.5,.16,.16),wood[1])
# Braced rear frame; front stays open for placing shelf props.
for a,b in [((-1.6,.69,.35),(1.6,.69,4.22)),((1.6,.72,.35),(-1.6,.72,4.22))]:
 mid=(Vector(a)+Vector(b))/2;delta=Vector(b)-Vector(a)
 o=box('BackBrace',mid,(.12,.1,delta.length),wood[2],.015);o.rotation_euler=delta.to_track_quat('Z','Y').to_euler()

for name,closed in [('OpenCellarCrate',False),('ClosedCellarCrate',True)]:
 begin(name)
 for i in range(4):box('FloorPlank',((i-1.5)*.49,0,.08),(.47,1.46,.16),wood[i%4])
 for x in [-.94,.94]:
  for y in [-.65,.65]:box('CornerPost',(x,y,.69),(.16,.16,1.38),wood[0])
 for z in [.31,.65,.99]:
  for y in [-.73,.73]:box('LongSidePlank',(0,y,z),(2.02,.14,.27),wood[int(z*10)%4])
  for x in [-1.02,1.02]:box('EndPlank',(x,0,z),(.14,1.33,.27),wood[1])
 for y in [-.73,.73]:box('LongTopRail',(0,y,1.3),(2.06,.16,.17),wood[2])
 # End top rails have a central open handhold above the third board.
 for x in [-1.02,1.02]:
  for y in [-.49,.49]:box('HandholdSide',(x,y,1.245),(.14,.36,.29),wood[2])
  box('HandleBridge',(x,0,1.385),(.14,1.32,.1),wood[2])
 for x in [-.9,.9]:
  for z in [.3,.98]:
   for y in [-.817,.817]:cyl('IronNail',(x,y,z),.026,.015,black,'Y')
 if closed:
  for i in range(4):box('LidPlank',((i-1.5)*.5,0,1.48),(.48,1.57,.14),wood[i%4])
  for x in [-.66,.66]:box('LidBatten',(x,0,1.59),(.16,1.57,.09),wood[0])

begin('KitchenStockpot')
lathe('HollowStockpot',[(0,0),(.58,0),(.64,.07),(.65,.97),(.67,1.01),(.67,1.06),(.61,1.06),(.59,.98),(.58,.12),(0,.12)],steel,32)
lathe('RolledRim',[(.61,1.015),(.69,1.015),(.69,1.07),(.61,1.07),(.61,1.015)],steelrim,32)
for s in [-1,1]:
 tube('PotHandle',[(s*.62,0,.76),(s*.86,0,.78),(s*1,0,.68),(s*1,0,.52),(s*.84,0,.48),(s*.63,0,.5)],black,.065)
 for z in [.55,.72]:cyl('HandleRivet',(s*.635,-.02,z),.04,.035,steelrim,'Y')

begin('KitchenFryingPan')
lathe('HollowPan',[(0,0),(.56,0),(.65,.04),(.76,.25),(.77,.3),(.72,.32),(.66,.23),(.57,.095),(0,.095)],black,32)
lathe('PanLip',[(.72,.28),(.78,.28),(.78,.32),(.72,.32),(.72,.28)],steelrim,32)
box('HandleNeck',(.88,0,.22),(.38,.18,.12),steel,.025)
box('WoodenPanHandle',(1.4,0,.23),(.9,.23,.18),wood[0],.075)
for x in [1.1,1.65]:cyl('HandleStud',(x,0,.332),.035,.025,steelrim)

begin('KitchenPlateStack')
for j in range(4):
 z=j*.11
 profile=[(0,z),(.35,z),(.4,z+.035),(.6,z+.05),(.78,z+.14),(.8,z+.19),(.76,z+.205),(.59,z+.105),(.35,z+.08),(0,z+.08)]
 lathe('CeramicPlate',profile,enamel,32)
 lathe('BurgundyPlateRim',[(.77,z+.16),(.8,z+.18),(.8,z+.195),(.77,z+.195)],cloth,32)

begin('CellarBucket')
lathe('HollowBucket',[(0,0),(.37,0),(.42,.06),(.54,.88),(.55,.94),(.50,.95),(.48,.88),(.36,.12),(0,.12)],steel,24)
lathe('RolledBucketRim',[(.5,.9),(.565,.9),(.565,.96),(.5,.96),(.5,.9)],steelrim,24)
for s in [-1,1]:
 o=cyl('HandleHinge',(s*.535,0,.76),.075,.07,steelrim)
 o.rotation_euler.y=math.pi/2
points=[(.53*math.cos(a),0,.77+.69*math.sin(a)) for a in [i*math.pi/16 for i in range(17)]]
tube('BucketHandle',points,black,.025)
box('BucketGrip',(0,0,1.445),(.37,.11,.11),wood[0],.035)

begin('CellarBroom')
# Geometry straw gives a readable brush silhouette without alpha textures.
for i in range(9):
 x=(i-4)*.085
 o=box('StrawBundle',(x,-.005,.26),(.095,.3,.5),straw if i%2 else strawlight,.015)
 o.rotation_euler.y=-x*.2
box('StrawBinding',(0,0,.48),(.75,.33,.12),strap,.025)
box('HeadSocket',(0,0,.62),(.3,.25,.24),wood[0],.04)
cyl('BroomHandle',(0,0,2.05),.052,2.76,wood[2])
cyl('GripCap',(0,0,3.45),.065,.12,wood[0])
for z in [.46,.51]:box('BindingCord',(0,-.175,z),(.72,.018,.018),cloth,.005)

# Normalise each export to its main horizontal centre and exact floor height.
report={}
for name,c in assets.items():
 bpy.context.view_layer.update();points=[o.matrix_world@Vector(v) for o in c.objects for v in o.bound_box];low=Vector(tuple(min(p[i] for p in points) for i in range(3)));high=Vector(tuple(max(p[i] for p in points) for i in range(3)))
 # Preserve main-body centres for cookware with handles; shift only height.
 for o in c.objects:o.location.z-=low.z
 dims=[round(v,4) for v in high-low];assert all(math.isfinite(v) and v>0 for v in dims)
 bpy.context.view_layer.update();assert min((o.matrix_world@Vector(v)).z for o in c.objects for v in o.bound_box)>-.0001
 bpy.ops.object.select_all(action='DESELECT')
 for o in c.objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 report[name]={'blender_xyz_studs':dims,'roblox_xyz_studs':[dims[0],dims[2],dims[1]],'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in c.objects),'mesh_objects':len(c.objects)}
assert len(report)==8
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
positions={'CellarShelf':(-3.3,.65,0),'OpenCellarCrate':(-.8,-1.05,0),'ClosedCellarCrate':(-.2,1,0),'KitchenStockpot':(1.6,-.9,0),'KitchenFryingPan':(1.8,-2.5,0),'KitchenPlateStack':(-3.3,.65,1.72),'CellarBucket':(3.7,-.3,0),'CellarBroom':(3.3,1.1,0)}
for name,c in assets.items():
 for o in c.objects:o.location+=Vector(positions[name])
scene=bpy.context.scene;scene['units']='1 Blender unit = 1 Roblox stud';scene['status']='Static scenery; no gameplay';bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'KitchenCellarProps.blend'))
begin('PreviewOnly');box('Ground',(0,0,-.09),(200,200,.15),material('PreviewSlate',(66,74,80)),0)
def aim(o,p):o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for pos,power,size in [((-5,-8,11),2200,7),((7,-3,9),1800,6),((0,7,10),2400,6)]:
 bpy.ops.object.light_add(type='AREA',location=pos);o=bpy.context.object;o.data.energy=power;o.data.size=size;aim(o,(0,0,1.5))
bpy.ops.object.camera_add(location=(8,-15,10));camera=bpy.context.object;aim(camera,(-.4,0,1.6));scene.camera=camera;camera.data.type='ORTHO';camera.data.ortho_scale=12.3
scene.render.engine='CYCLES';scene.cycles.samples=48;scene.world.color=(.25,.25,.25);scene.render.resolution_x=1700;scene.render.resolution_y=1200;scene.render.resolution_percentage=100;scene.render.filepath=str(OUT/'preview.png');bpy.ops.render.render(write_still=True)
print('VALIDATED',json.dumps(report))
