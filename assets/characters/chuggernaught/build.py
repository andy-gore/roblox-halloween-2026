"""Original first-pass geometry based on the supplied moodboard. Blender Python."""
import bpy, math, json, random
from mathutils import Vector
from pathlib import Path
OUT=Path(__file__).resolve().parent
random.seed(27)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
def mat(n,c,metal=0):
 m=bpy.data.materials.new(n); m.diffuse_color=(*c,1); m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*c,1); p.inputs['Roughness'].default_value=.78; p.inputs['Metallic'].default_value=metal
 return m
skin=mat('Warm skin',(.57,.29,.14)); skinlight=mat('Knuckles',(.64,.34,.18)); black=mat('Black leather',(.025,.023,.021)); edge=mat('Leather edges',(.06,.045,.032)); vest=mat('Dirty ivory vest',(.5,.43,.32)); stain=mat('Vest stains',(.25,.19,.115)); pants=mat('Charcoal trousers',(.055,.045,.037)); patch=mat('Worn trouser patches',(.13,.09,.055)); iron=mat('Dark iron',(.10,.105,.11),.7); tooth=mat('Uneven ivory teeth',(.81,.73,.51)); mouth=mat('Mouth and brows',(.012,.006,.003)); eye=mat('Eye whites',(.83,.74,.5)); wood=[mat('Tankard oak '+str(i),c) for i,c in enumerate([(.24,.085,.023),(.32,.12,.035),(.39,.17,.055)])]; foam=mat('Cream foam',(.83,.71,.45))
char=bpy.data.collections.new('Chuggernaught'); bpy.context.scene.collection.children.link(char)
tank=bpy.data.collections.new('Tankard'); bpy.context.scene.collection.children.link(tank)
active=char

def finish(o,n,m):
 o.name=n
 for c in list(o.users_collection): c.objects.unlink(o)
 active.objects.link(o); o.data.materials.append(m); return o

def box(n,loc,size,m,b=.06):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc); o=bpy.context.object; o.dimensions=size; bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if b:
  mod=o.modifiers.new('Blocky softened edges','BEVEL'); mod.width=b; mod.segments=1; bpy.context.view_layer.objects.active=o; bpy.ops.object.modifier_apply(modifier=mod.name)
 return finish(o,n,m)
def uv(n,loc,size,m,segments=16,rings=8):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=segments,ring_count=rings,radius=1,location=loc); o=bpy.context.object; o.scale=size; bpy.ops.object.transform_apply(location=False,rotation=False,scale=True); return finish(o,n,m)
def cyl(n,loc,r,depth,m,vertices=16):
 bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=depth,location=loc); return finish(bpy.context.object,n,m)
def poly(n,verts,faces,m):
 mesh=bpy.data.meshes.new(n); mesh.from_pydata(verts,[],faces); mesh.update(); o=bpy.data.objects.new(n,mesh); active.objects.link(o); o.data.materials.append(m); return o
# Front points toward -Y. Total height eight studs.
box('Torso_Vest',(0,0,4.9),(2.8,1.4,2.55),vest,.15)
box('Pelvis',(0,0,3.42),(2.6,1.4,.65),pants,.08)
box('Neck',(0,0,6.3),(1,.85,.65),skin,.14)
box('Bald_Head',(0,-.04,7.08),(1.55,1.32,1.84),skin,.29)
for s in [-1,1]:
 uv('Ear',(s*.8,-.02,7.0),(.14,.18,.25),skin)
 box('Jacket_Front_L' if s<0 else 'Jacket_Front_R',(s*1.13,-.77,4.95),(.62,.22,2.55),black,.045)
 # Lapel broad at shoulder, narrow at midsection.
 poly('Lapel',[(s*.78,-.93,6.16),(s*1.4,-.93,5.88),(s*.96,-.95,5.24)],[(0,1,2)],edge)
 box('UpperArm_L' if s<0 else 'UpperArm_R',(s*1.96,0,5.45),(1.05,1.25,1.45),skin,.16)
 box('Forearm_L' if s<0 else 'Forearm_R',(s*2.05,-.04,4.3),(.94,1.12,1.15),skin,.12)
 box('Wristband',(s*2.05,-.04,3.92),(1.02,1.2,.42),edge,.045)
 for x in [-.27,.27]: box('Wristband_Stud',(s*2.05+x,-.665,3.94),(.09,.06,.1),iron,.015)
 box('Fist_L' if s<0 else 'Fist_R',(s*2.05,-.09,3.48),(.88,1.05,.63),skin,.12)
 box('Thumb',(s*1.63,-.57,3.5),(.25,.28,.4),skinlight,.06)
 x=s*.73
 box('TrouserLeg_L' if s<0 else 'TrouserLeg_R',(x,0,2.28),(1.18,1.3,1.9),pants,.07)
 # Jagged trouser hems and visible skin at shins.
 for k in range(4):
  xx=x+(k-1.5)*.28
  poly('RaggedHem',[(xx-.14,-.67,1.65),(xx+.14,-.67,1.65),(xx+.10,-.67,1.18+random.random()*.25)],[(0,1,2)],pants)
 box('ExposedShin',(x,0,1.05),(.95,1.05,.65),skin,.06)
 box('Boot',(x,-.22,.42),(1.3,1.85,.74),black,.13)
 box('BootSole',(x,-.25,.13),(1.37,1.92,.26),edge,.04)
 box('BootCuff',(x,.04,.84),(1.18,1.3,.25),edge,.035)
 box('BootStrap',(x,-1.13,.5),(1.16,.1,.21),edge,.025)
 # A ripped knee opening with a small exposed skin triangle.
 poly('KneeTear',[(x-.33,-.665,2.52),(x+.30,-.665,2.64),(x+.2,-.665,2.22),(x-.26,-.665,2.17)],[(0,1,2,3)],skin)
 for z in [1.86,2.85]:
  o=box('TrouserPatch',(x+s*.22,-.68,z),(.33,.025,.36),patch,.01); o.rotation_euler.y=s*.2
 for z in [4.2,4.8,5.4,5.92]: uv('Jacket_Rivet',(s*1.06,-.91,z),(.045,.035,.045),iron,8,4)
box('Jacket_Back',(0,.77,4.98),(2.85,.22,2.5),black,.05)
for i in range(7):
 x=(i-3)*.39
 poly('Jacket_TatteredBack',[(x-.2,.9,3.85),(x+.2,.9,3.85),(x+.08,.9,3.52+random.random()*.18)],[(0,1,2)],black)
box('Belt',(0,-.04,3.68),(2.7,1.52,.3),edge,.035)
box('BeltBuckle',(0,-.845,3.68),(.54,.12,.38),iron,.025)
box('BuckleInset',(0,-.92,3.68),(.34,.04,.2),black,.01)
# Graphic face geometry, kept separate for future expression swaps.
for s in [-1,1]:
 box('Eye',(s*.35,-.708,7.28),(.4,.055,.18),eye,.04)
 box('Pupil',(s*.34,-.749,7.27),(.12,.04,.14),mouth,.02)
 o=box('HeavyBrow',(s*.36,-.76,7.5),(.58,.12,.18),mouth,.025); o.rotation_euler.y=-s*.23
box('Nose',(0,-.79,7.0),(.29,.22,.25),skinlight,.06)
box('Grin',(0,-.746,6.72),(1.02,.07,.36),mouth,.09)
for i in range(6): box('GrinningTooth',((i-2.5)*.145,-.795,6.81),(.125,.04,.14),tooth,.015)
for i in range(8):
 x=random.uniform(-.75,.75); z=random.uniform(4.05,5.8)
 o=box('VestDirt',(x,-.718,z),(random.uniform(.12,.35),.015,random.uniform(.1,.3)),stain,.015); o.rotation_euler.y=random.uniform(-.6,.6)
# Separate oversized wooden tankard, standing beside the right fist for art review.
active=tank
cx,cy,cz=3.75,0,0
for i in range(12):
 a=i*math.tau/12; da=.245
 verts=[]
 for z,r in [(0,.68),(.2,.72),(1.9,.85),(2.1,.85)]:
  verts.extend([(cx+r*math.cos(a+t),cy+r*math.sin(a+t),z) for t in [-da,da]])
 poly('WoodenStave',verts,[(0,1,3,2),(2,3,5,4),(4,5,7,6)],wood[i%3])
for z,r in [(.17,.74),(1.93,.89)]:
 cyl('IronBand',(cx,cy,z),r,.25,iron,12)
 # Solid bands are hidden inside the closed vessel; no drinking simulation in this pass.
 for i in range(12):
  a=i*math.tau/12; uv('BandRivet',(cx+(r+.025)*math.cos(a),cy+(r+.025)*math.sin(a),z),(.055,.055,.055),iron,8,4)
cyl('TankardBottom',(cx,cy,.04),.68,.08,wood[0],12)
cyl('FoamSurface',(cx,cy,2.08),.82,.13,foam,16)
for i in range(11):
 a=i*math.tau/11; uv('FoamBubble',(cx+.61*math.cos(a),cy+.61*math.sin(a),2.17),(.24,.23,.15+random.random()*.12),foam,12,6)
box('HandleTop',(cx+1.05,0,1.75),(.7,.3,.3),iron,.08)
box('HandleSide',(cx+1.35,0,1.13),(.3,.3,1.5),iron,.08)
box('HandleBottom',(cx+1,0,.48),(.78,.3,.3),iron,.08)
# Export each group with preserved editable mesh names.
report={}
for name,c in [('Chuggernaught_FirstPass',char),('Tankard_FirstPass',tank)]:
 bpy.ops.object.select_all(action='DESELECT')
 if c==tank:
  for o in c.objects: o.location.x-=cx
 for o in c.objects: o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 pts=[o.matrix_world@Vector(v) for o in c.objects for v in o.bound_box]
 report[name]={'dimensions_xyz':[round(max(p[i] for p in pts)-min(p[i] for p in pts),3) for i in range(3)],'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in c.objects),'mesh_objects':len(c.objects)}
 if c==tank:
  for o in c.objects: o.location.x+=cx
assert 7.9 < report['Chuggernaught_FirstPass']['dimensions_xyz'][2] < 8.1
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
scene=bpy.context.scene; scene['reference']='assets/concepts/The Chuggernaught_ Last Orders Moodboard.png'; scene['units']='1 Blender unit = 1 Roblox stud'; scene['status']='Static first art pass; unrigged. Front is -Y.'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Chuggernaught_FirstPass.blend'))
# Neutral review stage; not exported.
active=bpy.data.collections.new('RenderOnly'); scene.collection.children.link(active)
box('Ground',(0,0,-.12),(200,200,.2),mat('Backdrop',(.065,.075,.085)),0)
def aim(o,p): o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for pos,power,size in [((-6,-9,12),1900,7),((7,-4,10),1500,6),((0,6,11),2300,5)]:
 bpy.ops.object.light_add(type='AREA',location=pos); o=bpy.context.object; o.data.energy=power; o.data.size=size; aim(o,(0,0,4))
bpy.ops.object.camera_add(location=(11,-22,11)); camera=bpy.context.object; aim(camera,(.9,0,3.9)); scene.camera=camera; camera.data.type='ORTHO'; camera.data.ortho_scale=12
scene.render.engine='CYCLES'; scene.cycles.samples=40; scene.world.color=(.22,.22,.22); scene.render.resolution_x=1200; scene.render.resolution_y=1200; scene.render.resolution_percentage=100
scene.render.filepath=str(OUT/'preview.png'); bpy.ops.render.render(write_still=True)
camera.location=(-10,20,10); aim(camera,(.4,0,3.9)); scene.render.filepath=str(OUT/'preview-back.png'); bpy.ops.render.render(write_still=True)
print('VALIDATED',json.dumps(report))
