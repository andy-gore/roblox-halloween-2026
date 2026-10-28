"""Generate original local bedroom detail props. Run with Blender --background --python build.py."""
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

begin('BedsideLamp')
cyl('DarkBase',(0,0,.09),.48,.18,trim)
lathe('BrassBase',[(0,.16),(.43,.16),(.43,.21),(.34,.27),(.17,.3)],brass)
cyl('LampStem',(0,0,.81),.055,1.06,brass)
lathe('StemCollar',[(.07,1.12),(.14,1.17),(.14,1.23),(.07,1.27)],brass)
# Open tapered shade: paired inner and outer skins, closed rims.
lathe('FabricShade',[(.63,.97),(.31,1.82),(.28,1.82),(.60,.97),(.63,.97)],shade)
for z,r in [(.99,.63),(1.8,.315)]:lathe('ShadeBinding',[(r-.015,z-.025),(r+.012,z-.025),(r+.012,z+.025),(r-.015,z+.025)],linenedge)
for a in [0,math.tau/3,math.tau*2/3]:tube('ShadeSupport',[(0,0,1.27),(.46*math.cos(a),.46*math.sin(a),1.29)],brass,.013)
bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=6,radius=.14,location=(0,0,1.36));finish(bpy.context.object,'Bulb',bulb)
tube('PullChain',[(.15,-.05,1.26),(.15,-.05,.78)],brass,.013)
cyl('PullWeight',(.15,-.05,.74),.032,.1,brass)

begin('TravellerSuitcase')
box('LeatherBody',(0,0,.7),(2.6,.86,1.4),leather,.12)
box('LidFront',(0,-.455,.7),(2.5,.12,1.28),leather,.09)
for x in [-.8,.8]:
 box('FrontStrap',(x,-.532,.7),(.18,.055,1.29),strap,.018)
 box('TopStrap',(x,0,1.385),(.18,.85,.045),strap,.014)
 box('BottomStrap',(x,0,.028),(.18,.8,.045),strap,.014)
 box('Buckle',(x,-.577,1.07),(.27,.065,.26),brass,.02)
 box('BuckleInset',(x,-.617,1.07),(.14,.018,.13),strap,.008)
for x in [-1.13,1.13]:
 for z in [.17,1.23]:box('CornerGuard',(x,-.53,z),(.25,.055,.23),strap,.035)
for x in [-.36,.36]:box('HandleMount',(x,0,1.435),(.18,.26,.08),brass,.025)
tube('CarryHandle',[(-.36,0,1.46),(-.34,0,1.69),(-.23,0,1.76),(.23,0,1.76),(.34,0,1.69),(.36,0,1.46)],strap,.065)
box('LuggageTag',(.37,-.57,.62),(.37,.025,.49),ivory,.02)
# Deliberately blank tag: no invented guest identity or story clue.
box('TagBorder',(.37,-.59,.62),(.28,.012,.38),linenedge,.018)
box('TagPaper',(.37,-.603,.62),(.23,.012,.33),paper,.015)

begin('BedsideBooks')
from mathutils import Matrix
for index,(width,depth,height,angle,m) in enumerate([(1.22,.86,.2,0,bookgreen),(1.1,.79,.18,-.13,cloth),(1.03,.73,.18,.08,bookblue)]):
 bottom=sum([.2,.18,.18][:index]);before=set(coll.objects)
 box('Pages',(0,0,bottom+height/2),(width-.06,depth-.07,height-.055),paper,.018)
 for z in [bottom+.02,bottom+height-.02]:box('BookCover',(0,0,z),(width,depth,.04),m,.015)
 box('BookSpine',(0,depth/2-.015,bottom+height/2),(width,.06,height),m,.018)
 for x in [-width*.36,width*.36]:box('SpineGoldBand',(x,depth/2+.018,bottom+height/2),(.025,.012,height-.045),brass,.004)
 for z in [bottom+height*.4,bottom+height*.65]:box('PageLines',(0,-depth/2+.025,z),(width-.1,.009,.008),linenedge,.002)
 for o in set(coll.objects)-before:o.matrix_world=Matrix.Rotation(angle,4,'Z')@o.matrix_world
box('RibbonBookmark',(.26,-.38,.56),(.07,.36,.012),clothlight,.003)

begin('BedroomCoatRail')
box('OakRail',(0,.1,.58),(2.8,.2,1.16),wood[0],.075)
box('RailInset',(0,-.015,.58),(2.55,.035,.91),wood[1],.04)
for x in [-1.2,1.2]:screw(x,-.052,.58)
for x in [-.8,0,.8]:
 cyl('HookRose',(x,-.08,.64),.13,.07,brass,'Y')
 tube('BrassCoatHook',[(x,-.1,.7),(x,-.23,.46),(x,-.39,.33),(x,-.51,.36),(x,-.55,.52)],brass,.048)
 bpy.ops.mesh.primitive_uv_sphere_add(segments=10,ring_count=5,radius=.075,location=(x,-.55,.54));finish(bpy.context.object,'RoundedHookTip',brass)

for number in range(1,9):
 begin('RoomPlaque_%02d'%number)
 box('OakPlaque',(0,.065,.35),(1.04,.13,.7),wood[0],.1)
 box('BrassInset',(0,-.012,.35),(.9,.035,.56),brass,.08)
 box('DarkEnamel',(0,-.04,.35),(.78,.025,.45),trim,.065)
 text('RoomNumber',str(number),(0,-.06,.35),.34,ivory)
 for x in [-.435,.435]:screw(x,-.045,.35)
# Validate and export before staging.
report={}
for name,c in assets.items():
 bpy.context.view_layer.update();points=[o.matrix_world@Vector(v) for o in c.objects for v in o.bound_box];low=[min(p[i] for p in points) for i in range(3)];high=[max(p[i] for p in points) for i in range(3)];dims=[round(b-a,4) for a,b in zip(low,high)]
 assert all(math.isfinite(v) and v>0 for v in dims)
 assert abs(low[2])<.025,(name,low)
 bpy.ops.object.select_all(action='DESELECT')
 for o in c.objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 report[name]={'blender_xyz_studs':dims,'roblox_xyz_studs':[dims[0],dims[2],dims[1]],'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in c.objects),'mesh_objects':len(c.objects)}
assert report['BedsideLamp']['blender_xyz_studs'][0]<2.05
assert len(report)==12
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
positions={'BedsideLamp':(-2.4,.1,0),'TravellerSuitcase':(0,.15,0),'BedsideBooks':(-.1,-1.2,0),'BedroomCoatRail':(0,.7,2.25)}
for number in range(1,9):positions['RoomPlaque_%02d'%number]=(1.95+(number-1)%2*1.2,-.6,(number-1)//2*.78)
for name,c in assets.items():
 for o in c.objects:o.location+=Vector(positions[name])
scene=bpy.context.scene;scene['asset_units']='1 Blender unit = 1 Roblox stud';scene['status']='Static decorative props; no gameplay or lights'
bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'BedroomDetails.blend'))
begin('PreviewOnly')
box('Ground',(0,0,-.09),(200,200,.15),material('PreviewSlate',(66,74,80)),0)
def aim(o,p):o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for pos,power,size in [((-4,-6,8),1400,6),((6,-3,6),1200,5),((0,6,8),1600,5)]:
 bpy.ops.object.light_add(type='AREA',location=pos);o=bpy.context.object;o.data.energy=power;o.data.size=size;aim(o,(0,0,.8))
bpy.ops.object.camera_add(location=(5,-12,7));camera=bpy.context.object;aim(camera,(.3,0,1.15));scene.camera=camera;camera.data.type='ORTHO';camera.data.ortho_scale=8.7
scene.render.engine='CYCLES';scene.cycles.samples=48;scene.world.color=(.25,.25,.25);scene.render.resolution_x=1600;scene.render.resolution_y=1100;scene.render.resolution_percentage=100
scene.render.filepath=str(OUT/'preview.png');bpy.ops.render.render(write_still=True)
print('VALIDATED',json.dumps(report))
