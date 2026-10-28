"""Generate original local pub lighting fixtures and room signs. Run with Blender --background --python build.py."""
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

# Fixtures are opaque meshes; actual lights are added by the build chat.
opal=material('Warm opal diffuser',(220,207,172),0,.46)
paint=material('Burgundy black sign enamel',(38,24,28),0,.74)
letter=material('Warm ivory sign lettering',(237,222,182),0,.7)
font_path=Path('/System/Library/Fonts/Supplemental/Georgia Bold.ttf')
serif=bpy.data.fonts.load(str(font_path)) if font_path.exists() else bpy.data.fonts.get('Bfont')
mounts={}
def shift(o,offset):o.location+=Vector(offset);return o

begin('BedroomCeilingLight')
lathe('CeilingRose',[(.015,0),(.35,0),(.39,-.06),(.39,-.13),(.27,-.2),(.10,-.24)],brass)
cyl('PendantStem',(0,0,-.43),.055,.45,brass)
lathe('OpalBowl',[(.09,-.58),(.42,-.62),(.63,-.77),(.68,-.9),(.59,-1.07),(.32,-1.19),(.06,-1.21),(.015,-1.18)],opal,32)
lathe('ShadeUpperBand',[(.4,-.61),(.45,-.62),(.45,-.67),(.41,-.69)],brass)
lathe('BowlRim',[(.655,-.85),(.69,-.87),(.69,-.92),(.655,-.94)],brass)
cyl('BottomFinial',(0,0,-1.235),.07,.1,brass)
mounts['BedroomCeilingLight']={'origin':'ceiling centre; hangs down local Blender -Z / Roblox -Y','light_blender_xyz':[0,0,-.9],'suggested_light':'one warm PointLight; start Range 14, Brightness 0.8; tune in game','attachment_blender_xyz':[0,0,0]}

begin('PubWallSconce')
box('OakBackplate',(0,.075,.9),(.62,.15,1.8),wood[0],.12)
box('BrassBackplate',(0,-.025,.9),(.45,.06,1.53),brass,.1)
box('DarkInset',(0,-.065,.9),(.31,.035,1.3),trim,.07)
for z in [.28,1.52]:screw(0,-.105,z)
tube('CurvedSconceArm',[(0,-.1,.55),(0,-.42,.46),(0,-.7,.56),(0,-.81,.83),(0,-.81,1.05)],brass,.045)
shift(lathe('LampCup',[(.02,.94),(.17,.94),(.22,1.02),(.22,1.08),(.04,1.1)],brass,24),(0,-.81,0))
shift(lathe('IvoryShade',[(.5,1.1),(.27,2.01),(.24,2.01),(.47,1.1),(.5,1.1)],shade,32),(0,-.81,0))
for z,r in [(1.12,.5),(1.99,.27)]:shift(lathe('ShadeBinding',[(r-.01,z-.025),(r+.01,z-.025),(r+.01,z+.025),(r-.01,z+.025)],linenedge,32),(0,-.81,0))
bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=6,radius=.13,location=(0,-.81,1.4));finish(bpy.context.object,'Bulb',opal)
mounts['PubWallSconce']={'origin':'bottom of backplate; back surface Blender Y=+0.15 / Roblox Z=-0.15','light_blender_xyz':[0,-.81,1.4],'suggested_light':'one warm PointLight; start Range 12, Brightness 0.6','attachment_blender_xyz':[0,.15,.9]}

begin('PubChandelier')
lathe('CeilingCanopy',[(.015,0),(.28,0),(.34,-.07),(.3,-.15),(.08,-.2)],brass,24)
cyl('UpperStem',(0,0,-.37),.045,.38,black)
for i in range(3):
 bpy.ops.mesh.primitive_torus_add(major_segments=12,minor_segments=6,major_radius=.09,minor_radius=.023,location=(0,0,-.62-i*.14),rotation=(math.pi/2,0,i%2*math.pi/2));finish(bpy.context.object,'ChainLink',brass)
cyl('LowerStem',(0,0,-1.14),.055,.56,brass)
lathe('CentralBowl',[(.04,-1.29),(.27,-1.35),(.34,-1.49),(.25,-1.62),(.08,-1.69)],brass,24)
for i in range(6):
 a=i*math.tau/6;ux,uy=math.cos(a),math.sin(a)
 tube('ScrollArm',[(.15*ux,.15*uy,-1.48),(.62*ux,.62*uy,-1.74),(1.13*ux,1.13*uy,-1.68),(1.39*ux,1.39*uy,-1.46),(1.39*ux,1.39*uy,-1.29)],brass,.045)
 x,y=1.39*ux,1.39*uy
 shift(lathe('LampCup',[(.03,-1.37),(.18,-1.37),(.23,-1.29),(.23,-1.24),(.08,-1.21)],brass,20),(x,y,0))
 cyl('IvoryCandleSleeve',(x,y,-1.03),.105,.39,ivory)
 bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=6,radius=1,location=(x,y,-.76));o=bpy.context.object;o.scale=(.10,.10,.17);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);finish(o,'OpalCandleBulb',opal)
lathe('LowerFinial',[(.09,-1.63),(.14,-1.76),(.1,-1.86),(.02,-1.94)],brass,20)
mounts['PubChandelier']={'origin':'ceiling centre; rigid hanging fixture; no chain physics','light_blender_xyz':[0,0,-1.25],'suggested_light':'prefer one warm PointLight at centre; start Range 22, Brightness 1.2, rather than six shadowed lights','attachment_blender_xyz':[0,0,0],'bulb_centres_blender_xyz':[[round(1.39*math.cos(i*math.tau/6),4),round(1.39*math.sin(i*math.tau/6),4),-.76] for i in range(6)]}

begin('CellarBulkheadLight')
box('CastIronBack',(0,.06,.84),(.98,.12,1.68),black,.18)
box('HousingRim',(0,-.035,.84),(.83,.12,1.48),brass,.18)
bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,radius=1,location=(0,-.19,.84));o=bpy.context.object;o.scale=(.35,.21,.64);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);finish(o,'FrostedDiffuser',opal)
tube('ProtectiveOval',[(.43*math.cos(i*math.tau/24),-.32,.84+.73*math.sin(i*math.tau/24)) for i in range(25)],black,.033)
for z,w in [(.37,.31),(.84,.43),(1.31,.31)]:tube('CageCrossbar',[(-w,-.31,z),(-w*.6,-.44,z),(0,-.47,z),(w*.6,-.44,z),(w,-.31,z)],black,.029)
tube('CageCentreRib',[(0,-.33,.15),(0,-.44,.4),(0,-.48,.84),(0,-.44,1.28),(0,-.33,1.53)],black,.028)
for x in [-.42,.42]:
 for z in [.17,1.51]:screw(x,-.09,z)
mounts['CellarBulkheadLight']={'origin':'bottom of housing; back surface Blender Y=+0.12 / Roblox Z=-0.12','light_blender_xyz':[0,-.35,.84],'suggested_light':'one warm-neutral PointLight; start Range 14, Brightness 0.8; retain existing cellar safety-light rules','attachment_blender_xyz':[0,.12,.84]}

sign_specs=[('SnugRoomSign','THE SNUG',4.5),('BarRoomSign','MAIN BAR',4.5),('KitchenRoomSign','KITCHEN',4.2),('OfficeRoomSign',"LANDLORD'S OFFICE",5.8),('GuestRoomsSign','GUEST ROOMS',5.1),('CellarRoomSign','CELLAR',4.2),('StaffStairsSign','STAFF STAIRS',5.1)]
for name,wording,w in sign_specs:
 begin(name);h=1.35
 box('CarvedOakPlaque',(0,.10,h/2),(w,.2,h),wood[0],.14)
 box('RaisedOakBorder',(0,-.022,h/2),(w-.13,.095,h-.13),wood[2],.12)
 box('DarkEnamelInset',(0,-.08,h/2),(w-.31,.055,h-.31),paint,.095)
 # Slim brass edging follows a chamfered cartouche silhouette.
 pts=[(-w/2+.26,-.121,.17),(w/2-.26,-.121,.17),(w/2-.17,-.121,.26),(w/2-.17,-.121,h-.26),(w/2-.26,-.121,h-.17),(-w/2+.26,-.121,h-.17),(-w/2+.17,-.121,h-.26),(-w/2+.17,-.121,.26),(-w/2+.26,-.121,.17)]
 tube('BrassOutline',pts,brass,.015)
 for x in [-w/2+.32,w/2-.32]:
  screw(x,-.124,h/2)
 for z in [.28,1.07]:
  o=box('SmallBrassDiamond',(0,-.129,z),(.095,.024,.095),brass,.008);o.rotation_euler.y=math.pi/4
 bpy.ops.object.text_add(location=(0,-.134,.675),rotation=(math.pi/2,0,0));o=bpy.context.object;o.data.body=wording;o.data.font=serif;o.data.align_x='CENTER';o.data.align_y='CENTER';o.data.size=.37;o.data.extrude=.004;o.data.resolution_u=3
 bpy.context.view_layer.update()
 if o.dimensions.x>w-1.05:o.data.size*=(w-1.05)/o.dimensions.x
 bpy.ops.object.convert(target='MESH');finish(bpy.context.object,'IvorySerifLettering',letter)
 mounts[name]={'origin':'bottom centre of plaque; back surface Blender Y=+0.2 / Roblox Z=-0.2; front -Y / Roblox +Z','wording':wording,'attachment_blender_xyz':[0,.2,h/2],'readability':'mesh lettering is supplied; native SurfaceGui text can replace it for distance/touch readability; keep dark enamel and ivory contrast','text_area_width':w-1.05,'text_area_height':.5}
# Each export retains its mounting origin, including negative-height ceiling fixtures.
report={}
for name,c in assets.items():
 bpy.context.view_layer.update();points=[o.matrix_world@Vector(v) for o in c.objects for v in o.bound_box];lo=[min(p[i] for p in points) for i in range(3)];hi=[max(p[i] for p in points) for i in range(3)];dims=[round(b-a,4) for a,b in zip(lo,hi)];triangles=sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in c.objects)
 assert all(math.isfinite(v) and v>0 for v in dims);assert triangles<18000
 bpy.ops.object.select_all(action='DESELECT')
 for o in c.objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 report[name]={'blender_xyz_studs':dims,'roblox_xyz_studs':[dims[0],dims[2],dims[1]],'bounds_min_xyz':lo,'bounds_max_xyz':hi,'triangles':triangles,'mesh_objects':len(c.objects),**mounts[name]}
assert len(report)==11
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
positions={'BedroomCeilingLight':(-4.5,0,3.2),'PubWallSconce':(-1.5,0,.6),'PubChandelier':(2,0,3.4),'CellarBulkheadLight':(5,0,.9)}
for i,(name,_,_) in enumerate(sign_specs):positions[name]=((i%2)*6.8-3.4,0,-2.0-(i//2)*1.65)
for name,c in assets.items():
 for o in c.objects:o.location+=Vector(positions[name])
scene=bpy.context.scene;scene['units']='1 Blender unit = 1 Roblox stud';scene['status']='Static art only. Actual lights/text integration remain in build chat.';bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'LightingAndRoomSigns.blend'))
# Render staging, excluded from source and exports.
begin('PreviewOnly');back=material('PreviewSlate',(52,59,65))
box('Backdrop',(0,3.5,0),(40,.15,40),back,.0)
def aim(o,p):o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for loc,power,size in [((-6,-8,10),2000,8),((8,-4,7),1700,7),((0,4,8),1700,6)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.size=size;aim(o,(0,0,1))
bpy.ops.object.camera_add();cam=bpy.context.object;scene.camera=cam;cam.data.type='ORTHO';scene.render.engine='CYCLES';scene.cycles.samples=48;scene.world.color=(.23,.23,.23);scene.render.resolution_x=1800;scene.render.resolution_y=1100;scene.render.resolution_percentage=100
for filename,pos,look,scale in [('lighting-preview.png',(4,-16,8),(.3,0,1.8),13.5),('signs-preview.png',(.5,-18,-1.9),(0,0,-3.9),14.3)]:
 for name,c in assets.items():c.hide_render=(name in [row[0] for row in sign_specs])!=(filename=='signs-preview.png')
 cam.location=pos;aim(cam,look);cam.data.ortho_scale=scale;scene.render.filepath=str(OUT/filename);bpy.ops.render.render(write_still=True)
print('VALIDATED',json.dumps(report))
