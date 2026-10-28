"""Generate refined local Tavern signage. Run with Blender --background --python build.py."""
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

# A coordinated sign family; preserves original room wording and mounting orientation.
enamel=material('Midnight burgundy enamel',(31,25,29),0,.36)
ivory=material('Warm ivory lettering',(240,223,188),0,.55)
edge=material('Muted gold inlay',(188,161,106),.65,.4)
font=bpy.data.fonts.load('/System/Library/Fonts/Supplemental/Georgia.ttf')
bold=bpy.data.fonts.load('/System/Library/Fonts/Supplemental/Georgia Bold.ttf')
report={}
def lettering(body,x,z,maxwidth,size=.34,boldface=False):
 bpy.ops.object.text_add(location=(x,-.175,z),rotation=(math.pi/2,0,0));o=bpy.context.object
 o.data.body=body;o.data.font=bold if boldface else font;o.data.align_x='CENTER';o.data.align_y='CENTER';o.data.size=size;o.data.space_character=1.12;o.data.extrude=.002;o.data.resolution_u=3
 bpy.context.view_layer.update()
 if o.dimensions.x>maxwidth:o.data.size*=maxwidth/o.dimensions.x
 bpy.ops.object.convert(target='MESH');return finish(bpy.context.object,'Lettering_'+body,ivory)
def border(w,h,margin,y,r):
 x=w/2-margin;lo=margin;hi=h-margin;c=.11
 tube('GoldCartouche',[(-x+c,y,lo),(x-c,y,lo),(x,y,lo+c),(x,y,hi-c),(x-c,y,hi),(-x+c,y,hi),(-x,y,hi-c),(-x,y,lo+c),(-x+c,y,lo)],edge,r)
def plaque(name,w,h):
 begin(name)
 box('BevelledOak',(0,.08,h/2),(w,.24,h),wood[0],.09)
 box('OakMoulding',(0,-.055,h/2),(w-.12,.09,h-.12),wood[2],.07)
 box('EnamelFace',(0,-.12,h/2),(w-.28,.06,h-.28),enamel,.055)
 border(w,h,.20,-.158,.012)
 for x in [-w/2+.30,w/2-.30]:
  cyl('FlushBrassFixing',(x,-.166,h/2),.032,.018,edge,'Y')
  box('FixingSlot',(x,-.178,h/2),(.034,.006,.007),trim,.001)
def rule(z,width):
 for s in [-1,1]:box('GoldHairline',(s*(width/4+.13),-.17,z),(width/2-.13,.012,.012),edge,.002)
 o=box('DiamondInlay',(0,-.172,z),(.055,.016,.055),edge,.003);o.rotation_euler.y=math.pi/4
specs=[('SnugRoomSign','THE SNUG',4.5),('BarRoomSign','MAIN BAR',4.5),('KitchenRoomSign','KITCHEN',4.2),('OfficeRoomSign',"LANDLORD’S OFFICE",5.8),('GuestRoomsSign','GUEST ROOMS',5.1),('CellarRoomSign','CELLAR',4.2),('StaffStairsSign','STAFF STAIRS',5.1)]
for name,wording,w in specs:
 plaque(name,w,1.35)
 lettering(wording,0,.69,w-1.0,.36)
 rule(.34,w-1.4);rule(1.03,w-1.4)
 report[name]={'wording':wording,'family':'room','text_blender_xyz':[0,-.175,.69],'text_area_width':w-1.0}
for number in range(1,9):
 name=f'BedroomNumber{number:02}';plaque(name,1.05,1.35)
 lettering(str(number),0,.70,.49,.62,True)
 report[name]={'wording':str(number),'family':'bedroom number'}
plaque('BedroomNumberBlank',1.05,1.35)
report['BedroomNumberBlank']={'family':'shared number plaque','native_text':'Use native numerals to share one mesh across all eight bedrooms'}
# Export both arrows, but only mount the direction matching the actual route.
for direction in ['Left','Right']:
 name='Direction'+direction;plaque(name,5.1,1.35)
 lettering('GUEST ROOMS',0,.82,3.95,.31)
 sx=-1 if direction=='Left' else 1
 tube('DirectionalArrow',[(-sx*.46,-.18,.43),(sx*.46,-.18,.43)],edge,.022)
 tube('ArrowHead',[(sx*.28,-.18,.58),(sx*.46,-.18,.43),(sx*.28,-.18,.28)],edge,.022)
 report[name]={'wording':'GUEST ROOMS','family':'direction','direction':direction,'mounting_warning':'Choose only the arrow matching the actual route; do not infer placement.'}
# A blank shared cartouche supports native editable SurfaceGui text.
plaque('SharedBlankPlaque',5.1,1.35)
report['SharedBlankPlaque']={'family':'editable blank','text_area_width':4.1,'text_area_height':.65,'native_font':'Fondamento for room names; Nunito for multi-line directions'}
for name,c in assets.items():
 bpy.context.view_layer.update();points=[o.matrix_world@Vector(v) for o in c.objects for v in o.bound_box]
 lo=[min(p[i] for p in points) for i in range(3)];hi=[max(p[i] for p in points) for i in range(3)];dims=[round(b-a,4) for a,b in zip(lo,hi)]
 tris=sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in c.objects)
 assert all(math.isfinite(v) and v>0 for v in dims) and tris<18000
 bpy.ops.object.select_all(action='DESELECT')
 for o in c.objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 report[name].update({'roblox_xyz_studs':[dims[0],dims[2],dims[1]],'triangles':tris,'mesh_objects':len(c.objects),'origin':'bottom centre; front Blender -Y / Roblox +Z; back Blender Y=0.20','bounds_min_xyz':lo,'bounds_max_xyz':hi})
assert len(report)==19
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
# Arrange two readable boards. Numbers form their own uniform row.
positions={}
for i,(name,_,_) in enumerate(specs):positions[name]=(-3.3+(i%2)*6.6,0,-(i//2)*1.75)
for i in range(8):positions[f'BedroomNumber{i+1:02}']=(-5.25+i*1.5,0,-7.1)
positions['BedroomNumberBlank']=(6.2,0,-10.65)
positions.update({'DirectionLeft':(-3.3,0,-8.9),'DirectionRight':(3.3,0,-8.9),'SharedBlankPlaque':(0,0,-10.65)})
for name,c in assets.items():
 for o in c.objects:o.location+=Vector(positions[name])
scene=bpy.context.scene;scene['units']='1 Blender unit = 1 Roblox stud';scene['status']='Refined sign assets; not integrated or published';bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'TavernSignage.blend'))
begin('PreviewOnly');back=material('Review backdrop',(43,48,52));box('Backdrop',(0,.75,-4),(30,.10,24),back,0)
def aim(o,p):o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for loc,power,size in [((-6,-8,6),1700,9),((7,-5,-4),1100,8)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.size=size;aim(o,(0,0,-3))
bpy.ops.object.camera_add(location=(0,-25,-4.6));cam=bpy.context.object;aim(cam,(0,0,-4.6));cam.data.type='ORTHO';cam.data.ortho_scale=14.6;scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.samples=48;scene.world.color=(.23,.23,.23)
scene.render.resolution_x=1800;scene.render.resolution_y=1660;scene.render.resolution_percentage=100
scene.render.filepath=str(OUT/'signage-preview.png');bpy.ops.render.render(write_still=True)
# Close-up proves letter spacing and bevels at a slightly oblique angle.
for name,c in assets.items():c.hide_render=name not in ['SnugRoomSign','PreviewOnly']
cam.location=(-5.4,-9,2.5);aim(cam,(-3.3,0,.68));cam.data.ortho_scale=5.5
scene.render.resolution_x=1400;scene.render.resolution_y=650;scene.render.filepath=str(OUT/'snug-detail.png');bpy.ops.render.render(write_still=True)
print('VALIDATED',len(report),'signs',sum(v['triangles'] for v in report.values()),'triangles')
