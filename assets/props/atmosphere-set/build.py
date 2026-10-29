"""Generate original bar, wall, storm and courtyard dressing. Run with Blender --background --python build.py."""
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

import random, os
rng=random.Random(20261029)
cream=material('Ivory enamel',(228,211,171),0,.45)
enamel=material('Burgundy enamel',(52,25,33),.15,.38)
green=material('Weathered green',(53,72,61),.1,.78)
terracotta=material('Aged terracotta',(133,73,48),0,.9)
soil=material('Dry dark soil',(36,30,25),0,1)
silver=material('Tarnished pewter',(135,142,142),.75,.35)
cork=material('Coaster cork',(143,108,68),0,.9)
red=material('Dartboard oxblood',(126,43,39),0,.82)
night=material('Painting dusk',(47,59,69),0,1)
hill=material('Painting rolling hills',(63,73,62),0,1)
farhill=material('Painting distant hills',(82,89,86),0,1)
forest=material('Painting tree silhouettes',(30,42,38),0,1)
glass=material('Rain glass',(140,163,176),0,.18)
water=material('Storm water',(69,91,108),.25,.14)
for mat,alpha in [(glass,.16),(water,.65)]:
 mat.diffuse_color=(*mat.diffuse_color[:3],alpha);mat.node_tree.nodes.get('Principled BSDF').inputs['Alpha'].default_value=alpha
streak=material('Rain streaks',(170,191,201),0,.2)
streak.diffuse_color=(*streak.diffuse_color[:3],.32);streak.node_tree.nodes.get('Principled BSDF').inputs['Alpha'].default_value=.32
font=bpy.data.fonts.load('/System/Library/Fonts/Supplemental/Georgia Bold.ttf')
meta={}
def start(name,group,origin='floor centre',**extra):
 begin(name);meta[name]={'group':group,'origin':origin,**extra}
def sphere(n,loc,scale,mat):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,radius=1,location=loc);o=bpy.context.object;o.scale=scale;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);return finish(o,n,mat)
def ring(n,loc,r,minor,mat,vertical=False):
 bpy.ops.mesh.primitive_torus_add(major_segments=24,minor_segments=6,major_radius=r,minor_radius=minor,location=loc,rotation=(math.pi/2 if vertical else 0,0,0));return finish(bpy.context.object,n,mat)
def words(body,loc,size,mat=cream):
 bpy.ops.object.text_add(location=loc,rotation=(math.pi/2,0,0));o=bpy.context.object;o.data.body=body;o.data.font=font;o.data.align_x='CENTER';o.data.align_y='CENTER';o.data.size=size;o.data.extrude=.001;o.data.resolution_u=2;bpy.ops.object.convert(target='MESH');return finish(bpy.context.object,'Lettering',mat)
def mug(x,y,z):
 o=lathe('PewterMug',[(.01,z),(.20,z),(.23,z+.04),(.23,z+.52),(.20,z+.55),(.185,z+.52),(.185,z+.08),(.01,z+.08)],silver,20);o.location.x=x;o.location.y=y
 ring('MugHandle',(x+.29,y,z+.29),.16,.035,silver,True)
# BAR: regular crockery, deliberately distinct from the monster's wooden tankard.
start('TwinBeerPump','bar','countertop centre')
box('OakPumpPlinth',(0,0,.10),(2.6,.95,.2),wood[0],.06)
for x in [-.68,.68]:
 cyl('BrassCollar',(x,0,.23),.23,.20,brass)
 tube('PumpNeck',[(x,0,.25),(x,0,.85),(x,-.1,1.04),(x,-.34,1.04),(x,-.48,.90)],brass,.065)
 cyl('HandlePivot',(x,.15,.77),.12,.20,brass,'Y')
 tube('PullLever',[(x,.16,.72),(x,.30,1.36),(x,.36,1.53)],black,.045)
 sphere('BurgundyPullHandle',(x,.36,1.69),(.13,.13,.28),enamel)
 sphere('IvoryPumpBadge',(x,-.03,1.40),(.18,.055,.23),cream)
start('BarDripTray','bar','countertop centre')
box('TrayPan',(0,0,.045),(2.8,1.15,.09),black,.04)
for y in [-.55,.55]:box('RaisedTrayLip',(0,y,.12),(2.8,.07,.15),silver,.025)
for x in [-1.36,1.36]:box('RaisedTrayEnd',(x,0,.12),(.07,1.15,.15),silver,.025)
for i in range(15):box('DrainGrille',(-1.22+i*.174,0,.105),(.055,.98,.055),silver,.01)
start('PewterTankardRack','bar','bottom centre; wall back Blender Y=0.12')
box('OakRackBack',(0,.06,1.08),(3.2,.12,2.16),wood[0],.06)
for z in [.14,1.05]:box('RackShelf',(0,-.35,z),(3.4,.92,.13),wood[2],.03)
for x in [-1.48,1.48]:box('RackUpright',(x,-.32,.67),(.13,.88,1.25),wood[0],.03)
for x in [-.94,0,.94]:mug(x,-.35,.21);mug(x,-.35,1.12)
start('CoasterStack','bar','countertop centre')
for i in range(5):
 o=cyl('CorkCoaster',(0,0,.025+i*.055),.34,.05,cork);o.rotation_euler.z=i*.15
cyl('IvoryTop',(0,0,.277),.30,.012,cream)
ring('CoasterRim',(0,0,.286),.26,.009,enamel)
start('SinglePewterMug','bar','countertop centre');mug(0,0,0)
# WALL: original geometric landscape reliefs; no purported historical artwork.
start('StoppedPubClock','wall','bottom centre; wall back Blender Y=0.16',clock_note='Decorative stopped hands; no narrative time claim')
cyl('OakClockCase',(0,.055,1.15),1.15,.21,wood[0],'Y')
cyl('BrassClockRim',(0,-.064,1.15),1.035,.07,brass,'Y')
cyl('IvoryClockFace',(0,-.108,1.15),.965,.025,cream,'Y')
for i in range(60):
 a=i*math.tau/60;r=.86
 o=box('MinuteMark',(-math.sin(a)*r,-.129,1.15+math.cos(a)*r),(.013 if i%5 else .027,.01,.04 if i%5 else .085),trim,.002);o.rotation_euler.y=-a
for n in [12,3,6,9]:
 a=n*math.tau/12;words(str(n),(math.sin(a)*.69,-.143,1.15+math.cos(a)*.69),.19,trim)
for a,length,width in [(math.radians(250),.47,.05),(math.radians(120),.69,.035)]:
 tube('StoppedClockHand',[(0,-.17,1.15),(math.sin(a)*length,-.17,1.15+math.cos(a)*length)],black,width/2)
cyl('ClockHandPin',(0,-.18,1.15),.065,.04,brass,'Y')
def painting(name,w,h,variant):
 start(name,'wall','bottom centre; wall back Blender Y=0.10',art_note='Original geometric countryside study; proposed dressing, not canonical artwork')
 box('OakPictureFrame',(0,0,h/2),(w,.2,h),wood[0],.06)
 box('BrassLiner',(0,-.115,h/2),(w-.16,.04,h-.16),brass,.02)
 box('DuskCanvas',(0,-.145,h/2),(w-.29,.025,h-.29),night,.015)
 # Flat relief layers confined inside the frame opening.
 for label,mat,basey,points in [('DistantHills',farhill,-.162,[(-.5,.35),(-.28,.58),(0,.4),(.22,.56),(.5,.38)]),('NearHills',hill,-.172,[(-.5,.25),(-.21,.37),(.07,.29),(.32,.40),(.5,.27)])]:
  left=-w/2+.16;right=w/2-.16;bottom=.16
  pts=[(left,basey,bottom)]+[(x*(w-.32),basey,.18+y*(h-.36)) for x,y in points]+[(right,basey,bottom)]
  mesh=bpy.data.meshes.new(label);mesh.from_pydata(pts,[],[tuple(range(len(pts)))]);mesh.update();custom(label,mesh,mat)
 for i in range(5):
  x=(-.33+i*.16)*(w-.4);z=.2+(i%2)*.04
  peak('TreeSilhouette',x,-.19,z,.18,h*(.23 if variant==0 else .3),.012,forest)
painting('FramedCountryside',3.5,2.25,0)
painting('FramedWoodland',2.0,2.8,1)
start('PubDartboard','wall','bottom centre; wall back Blender Y=0.20',gameplay='Static decorative board; no playable darts')
cyl('OakDartboardSurround',(0,.09,1.3),1.3,.22,wood[0],'Y')
cyl('DarkSisalBase',(0,-.06,1.3),1.15,.12,black,'Y')
# Proper twenty-segment numbering order; alternating beds and scoring rings.
order=[20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
def wedge(name,r1,r2,a1,a2,mat):
 pts=[(r*math.sin(a),-.131,1.3+r*math.cos(a)) for r,a in [(r1,a1),(r2,a1),(r2,a2),(r1,a2)]]
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(pts,[],[(0,1,2,3)]);mesh.update();custom(name,mesh,mat)
for i,n in enumerate(order):
 a=i*math.tau/20;lo=a-math.pi/20;hi=a+math.pi/20
 for j,(r1,r2) in enumerate([(.10,.51),(.51,.56),(.56,.88),(.88,.93)]):wedge('DartScoringBed',r1,r2,lo,hi,(red if i%2==0 else green) if j%2 else (cream if i%2==0 else black))
 tube('RadialWire',[(.1*math.sin(lo),-.145,1.3+.1*math.cos(lo)),(.93*math.sin(lo),-.145,1.3+.93*math.cos(lo))],silver,.005)
 words(str(n),(1.04*math.sin(a),-.15,1.3+1.04*math.cos(a)),.12)
for r in [.10,.51,.56,.88,.93]:ring('ScoringWire',(0,-.146,1.3),r,.005,silver,True)
cyl('OuterBull',(0,-.145,1.3),.10,.018,green,'Y');cyl('Bullseye',(0,-.16,1.3),.045,.015,red,'Y')
# STORM: optional translucent sheets; never used as navigation/collision surfaces.
for variant in range(2):
 name=['RainStreakPaneNarrow','RainStreakPaneWide'][variant];w,h=[(2.4,4.4),(4.8,4.4)][variant]
 start(name,'storm','bottom centre; front -Y',runtime='Translucent GLB reference only; use native glass and thin transparent streak strips for current upload-free renderer')
 box('ClearRainSheet',(0,0,h/2),(w,.012,h),glass,.0)
 for i in range(18 if variant==0 else 32):
  x=rng.uniform(-w/2+.12,w/2-.12);z=rng.uniform(.3,h-.3);length=min(rng.uniform(.15,.7),z-.08)
  tube('RainTrail',[(x,-.016,z),(x+.015,-.016,z-length*.65),(x+.008,-.016,z-length)],streak,.006)
  sphere('RainBead',(x+.008,-.023,z-length),(.014,.009,.025),streak)
for name,rx,ry in [('SmallPuddle',1.1,.65),('DoorwayPuddle',2.1,.8),('CourtyardPuddle',2.8,1.6)]:
 start(name,'storm','ground centre; place slightly above ground',runtime='Transparent low-profile mesh; non-colliding and non-queryable; native material/reflection tuning required')
 pts=[(0,0,.012)]
 for i in range(32):
  a=i*math.tau/32;f=1+.08*math.sin(3*a)+.05*math.cos(7*a);pts.append((rx*f*math.cos(a),ry*f*math.sin(a),.012))
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(pts,[],[(0,1+i,1+(i+1)%32) for i in range(32)]);mesh.update();custom('IrregularWaterSurface',mesh,water)
 # Sparse ripple arcs, with no duplicate opaque ground slab.
 for radius in [.18,.31]:tube('RainRipple',[(radius*math.cos(i*math.tau/24),radius*.7*math.sin(i*math.tau/24),.018) for i in range(25)],streak,.007)
# COURTYARD: modular wall dressing, outside the chase/navigation route.
for name,points in [('DrainpipeStraight',[(0,-.18,0),(0,-.18,5)]),('DrainpipeOffset',[(0,-.18,0),(0,-.18,.4),(0,-.55,.8),(0,-.55,1.3)]),('DrainpipeShoe',[(0,-.18,1),(0,-.18,.35),(0,-.48,.12),(0,-.73,.12)])]:
 start(name,'courtyard','bottom wall centre; front -Y',mount='Pipe radius 0.10; wall brackets extend to Blender Y=0.08')
 tube('BlackIronDrainpipe',points,black,.10)
 for z in ([.5,4.5] if name.endswith('Straight') else [.35]):
  box('PipeWallBracket',(0,.025,z),(.33,.11,.18),black,.025)
  ring('PipeCollar',(0,-.18,z),.12,.022,brass)
start('GalvanisedBin','courtyard','ground centre')
lathe('BinBody',[(.01,0),(.54,0),(.63,.14),(.69,1.8),(.64,1.85),(.58,.18),(.01,.18)],silver,24)
for i in range(16):
 a=i*math.tau/16;tube('PressedBinRib',[(.56*math.cos(a),.56*math.sin(a),.17),(.67*math.cos(a),.67*math.sin(a),1.7)],silver,.018)
lathe('LiddedBin',[(.01,1.98),(.28,1.98),(.68,1.87),(.73,1.82),(.72,1.76),(.65,1.76)],silver,24)
tube('LidHandle',[(-.16,0,1.99),(-.16,0,2.13),(.16,0,2.13),(.16,0,1.99)],black,.035)
for x in [-.7,.7]:ring('SideBinHandle',(x,0,1.4),.15,.025,black,True)
start('BrokenCourtyardPlanter','courtyard','ground centre')
# Open pot sectors create an actual broken gap; jagged rim rather than a complete pot.
segments=24
for i in range(segments):
 if i in [2,3,4,5]:continue
 a1=i*math.tau/segments;a2=(i+1)*math.tau/segments
 h=1.18 if i not in [1,6] else .75
 v=[(r*math.cos(a),r*math.sin(a),z) for r,z in [(.43,0),(.68,h),(.58,h),(.34,.10)] for a in [a1,a2]]
 mesh=bpy.data.meshes.new('PotShard');mesh.from_pydata(v,[],[(0,1,3,2),(2,3,5,4),(4,5,7,6),(6,7,1,0),(0,2,4,6),(1,7,5,3)]);mesh.update();custom('BrokenPotWall',mesh,terracotta)
cyl('PlanterSoil',(0,0,.35),.38,.20,soil)
for i in range(3):
 o=box('FallenTerracottaShard',(.8+i*.18,-.42+i*.22,.06),(.35,.22,.07),terracotta,.02);o.rotation_euler.z=i*.9
for i in range(5):
 a=i*2.4;tube('DeadPlantStem',[(0,0,.46),(.10*math.cos(a),.10*math.sin(a),.90),(.26*math.cos(a),.26*math.sin(a),1.36)],wood[1],.012)
start('CourtyardWallLantern','courtyard','bottom centre; wall back Blender Y=0.12',light_blender_xyz=[0,-.60,1.12],runtime='One native warm PointLight; no light or switching behaviour baked in')
box('LanternBackplate',(0,.055,1.5),(.38,.13,1.5),black,.05)
tube('LanternScrollArm',[(0,-.04,2.02),(0,-.22,2.27),(0,-.60,2.27),(0,-.60,2.06)],black,.04)
for x in [-.34,.34]:
 for y in [-.94,-.26]:box('LanternCorner',(x,y,1.10),(.045,.045,1.1),black,.008)
for z in [.54,1.66]:box('LanternRim',(0,-.60,z),(.79,.79,.09),black,.025)
for y in [-.95,-.25]:box('GlassPane',(0,y,1.10),(.60,.012,.96),glass,0)
for x in [-.35,.35]:box('GlassPane',(x,-.60,1.10),(.012,.60,.96),glass,0)
o=lathe('LanternHood',[(.01,2.03),(.18,1.95),(.53,1.72),(.53,1.65)],black,4);o.location.y=-.60;o.rotation_euler.z=math.pi/4
cyl('CandleSleeve',(0,-.60,.83),.09,.45,cream)
sphere('WarmBulb',(0,-.60,1.12),(.085,.085,.16),bulb)
# Export mounting-space geometry before staging. Each pack has a manifest and preview.
for name,c in assets.items():
 bpy.context.view_layer.update();points=[o.matrix_world@Vector(v) for o in c.objects for v in o.bound_box]
 lo=[min(p[i] for p in points) for i in range(3)];hi=[max(p[i] for p in points) for i in range(3)];dims=[round(b-a,4) for a,b in zip(lo,hi)]
 tris=sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in c.objects)
 assert all(math.isfinite(v) and v>0 for v in dims) and tris<12000,(name,tris,dims)
 folder=OUT/meta[name]['group'];folder.mkdir(exist_ok=True)
 bpy.ops.object.select_all(action='DESELECT')
 for o in c.objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(folder/(name+'.glb')),export_format='GLB',use_selection=True)
 meta[name].update({'roblox_xyz_studs':[dims[0],dims[2],dims[1]],'bounds_min_blender_xyz':lo,'bounds_max_blender_xyz':hi,'triangles':tris,'mesh_objects':len(c.objects)})
(OUT/'manifest.json').write_text(json.dumps(meta,indent=2)+'\n')
for group in ['bar','wall','storm','courtyard']:(OUT/group/'manifest.json').write_text(json.dumps({n:d for n,d in meta.items() if d['group']==group},indent=2)+'\n')
assert len(meta)==20,len(meta)
# Review staging keeps each object separate in the source collections.
positions={
'TwinBeerPump':(-3,0,0),'BarDripTray':(0,0,0),'PewterTankardRack':(3.8,0,0),'CoasterStack':(-.8,-2,0),'SinglePewterMug':(1.3,-2,0),
'StoppedPubClock':(-4,0,0),'FramedCountryside':(-.7,0,0),'FramedWoodland':(2.4,0,0),'PubDartboard':(5.3,0,0),
'RainStreakPaneNarrow':(-4,0,0),'RainStreakPaneWide':(.5,0,0),'SmallPuddle':(-5.4,-2,0),'DoorwayPuddle':(-1.8,-2,0),'CourtyardPuddle':(4.5,-2,0),
'DrainpipeStraight':(-5,0,0),'DrainpipeOffset':(-3.8,0,0),'DrainpipeShoe':(-2.8,0,0),'GalvanisedBin':(-.9,0,0),'BrokenCourtyardPlanter':(1.4,0,0),'CourtyardWallLantern':(4,0,1)}
for name,c in assets.items():
 for o in c.objects:o.location+=Vector(positions[name])
scene=bpy.context.scene;scene['units']='1 Blender unit = 1 Roblox stud';scene['status']='Original static art; no game integration or upload';bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'TavernAtmosphere.blend'))
begin('PreviewOnly');back=material('Review slate',(48,54,58));box('ReviewFloor',(0,0,-.10),(35,30,.15),back,0)
def aim(o,p):o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for loc,power,size in [((-6,-8,10),2200,9),((8,-2,8),1800,7),((0,5,6),1800,6)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.size=size;aim(o,(0,0,1))
bpy.ops.object.camera_add();cam=bpy.context.object;cam.data.type='ORTHO';scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.samples=48;scene.world.color=(.23,.23,.23);scene.render.resolution_x=1800;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
for group,location,look,scale in [('bar',(5,-14,9),(0,-.2,.8),12),('wall',(.5,-16,6),(.5,0,1.5),13),('storm',(8,-14,10),(0,0,1.5),16.5),('courtyard',(6,-17,10),(0,0,2.1),16)]:
 if os.environ.get('TAVERN_REVIEW_GROUPS') and group not in os.environ['TAVERN_REVIEW_GROUPS'].split(','):continue
 for name,c in assets.items():c.hide_render=name!='PreviewOnly' and meta[name]['group']!=group
 cam.location=location;aim(cam,look);cam.data.ortho_scale=scale;scene.render.filepath=str(OUT/group/'preview.png');bpy.ops.render.render(write_still=True)
print('VALIDATED',len(meta),'assets',sum(m['triangles'] for m in meta.values()),'triangles')
