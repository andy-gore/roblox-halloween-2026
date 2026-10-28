"""Generate original local pub detail props. Run with Blender --background --python build.py."""
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

# Original decorative props; no invented names, dates or narrative records.
cream=material('Stoneware cream',(179,160,122),0,.5)
bottlegreen=material('Opaque green bottle',(30,61,41),.12,.3)
bottlebrown=material('Opaque amber bottle',(91,47,23),.1,.31)
cork=material('Cork',(139,105,63),0,.9)
ink=material('Guestbook rules',(111,98,75),0,.85)

begin('OpenGuestbook')
for s in [-1,1]:
 box('LeatherCover',(s*.61,0,.065),(1.24,1.66,.13),cloth,.045)
 for y in [-.71,.71]:box('CoverBorder',(s*.61,y,.14),(1.04,.025,.012),brass,.004)
 box('PageBlock',(s*.60,0,.2),(1.13,1.5,.16),paper,.035)
 # Slightly raised inner edge suggests a bound open volume.
 o=box('OpenPage',(s*.60,0,.31),(1.13,1.49,.055),ivory,.018);o.rotation_euler.y=s*.065
 for j in range(8):
  y=-.57+j*.145
  o=box('BlankEntryRule',(s*.61,y,.339),(.89,.009,.004),ink,.001);o.rotation_euler.y=s*.065
 for x in [s*.31,s*.88]:
  o=box('PageColumn',(x,0,.339-math.sin(s*.065)*(x-s*.6)),(.008,1.25,.004),ink,.001);o.rotation_euler.y=s*.065
 # Fine paper edge layers visible around the book block.
 for z in [.16,.21,.25]:box('PageEdge',(s*.6,-.755,z),(1.04,.008,.008),linenedge,.002)
cyl('LeatherSpine',(0,0,.12),.12,1.6,cloth,'Y')
box('BookmarkRibbon',(.1,-.73,.34),(.09,.55,.018),clothlight,.004)

for name,w,h in [('PortraitFrame',1.55,2.05),('LandscapeFrame',2.2,1.45)]:
 begin(name)
 box('Backing',(0,.06,h/2),(w,.12,h),wood[0],.045)
 # Frame rails leave a real recessed opening; insert remains blank.
 for x in [-w/2+.09,w/2-.09]:
  box('OakSideRail',(x,-.065,h/2),(.18,.2,h),wood[2],.035)
  box('BrassInnerRail',(x-math.copysign(.083,x),-.16,h/2),(.025,.035,h-.25),brass,.006)
 for z in [.09,h-.09]:
  box('OakEndRail',(0,-.065,z),(w,.2,.18),wood[2],.035)
  box('BrassInnerEnd',(0,-.16,z+(.083 if z<h/2 else -.083)),(w-.27,.035,.025),brass,.006)
 box('BlankPictureInsert',(0,-.021,h/2),(w-.35,.025,h-.35),ivory,.005)
 # Two mitre accent strips give readable layered borders.
 for x in [-w/2+.04,w/2-.04]:box('OuterDarkRail',(x,-.175,h/2),(.025,.02,h-.07),trim,.005)

for name,profile,m in [
 ('GreenBottle',[(0,0),(.26,0),(.29,.07),(.29,.77),(.25,.87),(.11,1.01),(.10,1.35),(.12,1.37),(.12,1.43),(0,1.43)],bottlegreen),
 ('AmberBottle',[(0,0),(.32,0),(.35,.08),(.35,.59),(.31,.69),(.13,.85),(.12,1.12),(.145,1.14),(.145,1.21),(0,1.21)],bottlebrown)]:
 begin(name);lathe('BottleBody',profile,m,24)
 top=1.43 if name=='GreenBottle' else 1.21
 cyl('CorkStopper',(0,0,top+.035),.09,.09,cork)
 radius=.293 if name=='GreenBottle' else .353
 z=.44 if name=='GreenBottle' else .35
 lathe('BlankPaperBand',[(radius,z-.16),(radius+.005,z-.16),(radius+.005,z+.16),(radius,z+.16)],ivory,24)
 # Thin paper borders; no real brand or unsupported story text.
 for zz in [z-.13,z+.13]:lathe('LabelBorder',[(radius+.006,zz-.008),(radius+.008,zz-.008),(radius+.008,zz+.008),(radius+.006,zz+.008)],linenedge,24)

begin('StonewareMug')
lathe('HollowMug',[(0,0),(.29,0),(.34,.05),(.35,.69),(.34,.76),(.295,.76),(.29,.7),(.285,.12),(0,.12)],cream,32)
lathe('DarkRim',[(.297,.73),(.35,.73),(.35,.77),(.297,.77),(.297,.73)],cloth,32)
tube('MugHandle',[(.32,0,.59),(.53,0,.65),(.68,0,.56),(.72,0,.37),(.64,0,.18),(.45,0,.16),(.32,0,.23)],cream,.07)
# Empty mug; decorative prop, not a player drinking interaction.

for name,body,width in [('PubNameSign','THE CROOKED TANKARD',3.5),('RoomsAvailableSign','ROOMS AVAILABLE',2.6),('CellarSign','CELLAR',1.8)]:
 begin(name)
 h=.67
 box('OakSignBoard',(0,.08,h/2),(width,.16,h),wood[0],.06)
 box('InsetBoard',(0,-.02,h/2),(width-.15,.045,h-.15),trim,.025)
 for z in [.075,h-.075]:box('BrassBorder',(0,-.05,z),(width-.18,.022,.02),brass,.005)
 text('SignLettering',body,(0,-.053,h/2),.16,ivory)
 for x in [-width/2+.12,width/2-.12]:
  cyl('MountingRivet',(x,-.064,h/2),.025,.025,brass,'Y')

report={}
for name,c in assets.items():
 bpy.context.view_layer.update();points=[o.matrix_world@Vector(v) for o in c.objects for v in o.bound_box];low=[min(p[i] for p in points) for i in range(3)];high=[max(p[i] for p in points) for i in range(3)];dims=[round(b-a,4) for a,b in zip(low,high)]
 assert all(math.isfinite(v) and v>0 for v in dims)
 # Open guestbook spine has round-section geometry tangent to ground.
 assert abs(low[2])<.025,(name,low)
 bpy.ops.object.select_all(action='DESELECT')
 for o in c.objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 report[name]={'blender_xyz_studs':dims,'roblox_xyz_studs':[dims[0],dims[2],dims[1]],'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in c.objects),'mesh_objects':len(c.objects)}
assert len(report)==9
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
positions={'OpenGuestbook':(-1.9,-1,0),'PortraitFrame':(-2.7,.8,.65),'LandscapeFrame':(-.6,.8,1),'GreenBottle':(.55,-.5,0),'AmberBottle':(1.35,-.2,0),'StonewareMug':(2.2,-.95,0),'PubNameSign':(.5,1,3),'RoomsAvailableSign':(2.1,.5,2.1),'CellarSign':(2.5,.5,1.25)}
for name,c in assets.items():
 for o in c.objects:o.location+=Vector(positions[name])
scene=bpy.context.scene;scene['units']='1 Blender unit = 1 Roblox stud';scene['status']='Static scenery; blank picture inserts and guest records';bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'PubDetails.blend'))
begin('PreviewOnly');box('Ground',(0,0,-.09),(200,200,.15),material('PreviewSlate',(66,74,80)),0)
def aim(o,p):o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for pos,power,size in [((-4,-6,8),1400,6),((6,-3,6),1200,5),((0,6,8),1600,5)]:
 bpy.ops.object.light_add(type='AREA',location=pos);o=bpy.context.object;o.data.energy=power;o.data.size=size;aim(o,(0,0,1))
bpy.ops.object.camera_add(location=(5,-12,8));camera=bpy.context.object;aim(camera,(0,0,1.6));scene.camera=camera;camera.data.type='ORTHO';camera.data.ortho_scale=8.8
scene.render.engine='CYCLES';scene.cycles.samples=48;scene.world.color=(.25,.25,.25);scene.render.resolution_x=1600;scene.render.resolution_y=1100;scene.render.resolution_percentage=100;scene.render.filepath=str(OUT/'preview.png');bpy.ops.render.render(write_still=True)
print('VALIDATED',json.dumps(report))
