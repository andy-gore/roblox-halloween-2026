"""Generate original local storm-view window assets. Run with Blender --background --python build.py."""
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

# Glass remains separate so Studio can use native panes if preferable.
glass=material('ClearCoolGlass',(190,207,216),0,.12)
p=glass.node_tree.nodes.get('Principled BSDF');p.inputs['Alpha'].default_value=.1;glass.diffuse_color=(*glass.diffuse_color[:3],.1)
if hasattr(glass,'surface_render_method'):glass.surface_render_method='DITHERED'
grime=material('GlassEdgeDust',(94,86,67),0,.9)
g=grime.node_tree.nodes.get('Principled BSDF');g.inputs['Alpha'].default_value=.26;grime.diffuse_color=(*grime.diffuse_color[:3],.26)
if hasattr(grime,'surface_render_method'):grime.surface_render_method='DITHERED'
specs={}
for prefix,w,h,columns in [('Bedroom',4.4,5.4,2),('Pub',6.6,5.8,3)]:
 base=.25;t=.28;bottom=base+t;top=base+h-t;left=-w/2+t;right=w/2-t;opening_w=right-left;opening_h=top-bottom
 specs[prefix]={'frame_width':w,'frame_height':h,'opening_width':opening_w,'opening_height':opening_h,'opening_bottom_z':bottom,'opening_top_z':top,'rectangular_wall_cutout_width':w,'rectangular_wall_cutout_height':h,'cutout_bottom_z':base,'rod_width':w+2.1,'columns':columns,'rows':3}
 begin(prefix+'WindowFrame')
 # Front trim, deep reveal and rear trim form a clear tunnel, no backing board.
 for y,depth in [(-.29,.18),(.25,.12)]:
  for x in [-w/2+t/2,w/2-t/2]:box('FrameUpright',(x,y,base+h/2),(t,depth,h),wood[0],.035)
  for z in [base+t/2,base+h-t/2]:box('FrameRail',(0,y,z),(w,depth,t),wood[0],.035)
 for x in [-w/2+.055,w/2-.055]:box('SideReveal',(x,0,base+h/2),(.11,.55,h-.12),wood[1],.015)
 for z in [base+.055,base+h-.055]:box('RevealEnd',(0,0,z),(w-.12,.55,.11),wood[1],.015)
 box('DeepSill',(0,-.2,.125),(w+.5,1.1,.25),wood[2],.06)
 box('SillApron',(0,-.325,.28),(w-.18,.18,.16),wood[0],.025)
 box('LintelCap',(0,-.28,base+h+.09),(w+.36,.46,.18),wood[2],.035)
 peak('SmallGothicCrest',0,-.27,base+h+.18,1.25,.33,.22,wood[1])
 for i in range(1,columns):box('VerticalMullion',(left+opening_w*i/columns,-.01,(bottom+top)/2),(.095,.18,opening_h),wood[0],.015)
 for j in [1,2]:box('HorizontalMuntin',(0,-.01,bottom+opening_h*j/3),(opening_w,.18,.085),wood[0],.012)
 for i in range(columns):
  x=left+opening_w*(i+.5)/columns
  box('BrassLatchPlate',(x,-.132,bottom+opening_h/3+.01),(.18,.065,.27),brass,.025)
  box('LatchThumb',(x,-.185,bottom+opening_h/3),(.27,.08,.07),brass,.018)
 begin(prefix+'WindowGlass')
 for i in range(columns):
  for j in range(3):
   x0=left+opening_w*i/columns+.035;x1=left+opening_w*(i+1)/columns-.035;z0=bottom+opening_h*j/3+.035;z1=bottom+opening_h*(j+1)/3-.035
   box('ClearPane_%d_%d'%(i,j),((x0+x1)/2,.065,(z0+z1)/2),(x1-x0,.025,z1-z0),glass,0)
   # Narrow grime strips leave most of every pane completely clear.
   for x in [x0+.012,x1-.012]:box('EdgeDust',(x,.045,(z0+z1)/2),(.025,.008,z1-z0),grime,0)
   for z in [z0+.014,z1-.014]:box('BottomTopDust',((x0+x1)/2,.045,z),(x1-x0,.008,.028),grime,0)
 begin(prefix+'CurtainPair')
 rodz=base+h+.24
 rod=cyl('CurtainRod',(0,-.57,rodz),.045,w+1.65,brass);rod.rotation_euler.y=math.pi/2
 for side in [-1,1]:
  x=side*(w/2+.96)
  bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=6,radius=.105,location=(x,-.57,rodz));finish(bpy.context.object,'RodFinial',brass)
  box('RodWallBracket',(side*(w/2+.45),-.3,rodz-.05),(.13,.56,.13),brass,.025)
  verts=[];faces=[];nu=16;nz=12
  for j in range(nz+1):
   v=j/nz;z=.35+(rodz-.45)*v
   # Panel gathers at tieback height while keeping the centre view open.
   gather=math.exp(-((v-.43)/.14)**2)
   width=1.24-.63*gather
   centre=side*(w/2+.12+.18*gather)
   for i in range(nu+1):
    u=i/nu
    xx=centre+(u-.5)*width
    yy=-.58-.12*math.cos(u*math.tau*4)*(1-.3*gather)
    zz=z+(.025*math.cos(u*math.tau*4) if j==0 else 0)
    verts.append((xx,yy,zz))
  for j in range(nz):
   for i in range(nu):
    k=j*(nu+1)+i;faces.append((k,k+1,k+nu+2,k+nu+1))
  mesh=bpy.data.meshes.new('PleatedCurtain');mesh.from_pydata(verts,[],faces);mesh.update();o=custom('CurtainLeft' if side<0 else 'CurtainRight',mesh,cloth)
  bpy.context.view_layer.objects.active=o;mod=o.modifiers.new('Fabric thickness','SOLIDIFY');mod.thickness=.018;bpy.ops.object.modifier_apply(modifier=mod.name)
  # Binding follows the sculpted outer edges; tieback is a separate brass cord.
  for uindex in [0,nu]:tube('CurtainEdgeBinding',[verts[j*(nu+1)+uindex] for j in range(nz+1)],clothlight,.018)
  tube('CurtainHem',[verts[i] for i in range(nu+1)],clothlight,.018)
  tie_z=.35+(rodz-.45)*.43
  cx=side*(w/2+.3)
  tube('TiebackCord',[(cx-.32,-.58,tie_z+.05),(cx-.16,-.76,tie_z),(cx+.16,-.76,tie_z),(cx+.32,-.58,tie_z+.05)],brass,.024)
  for i in range(5):
   xx=side*(w/2+.12)+(i/4-.5)*1.15
   bpy.ops.mesh.primitive_torus_add(major_segments=12,minor_segments=6,major_radius=.07,minor_radius=.015,location=(xx,-.57,rodz),rotation=(0,math.pi/2,0));finish(bpy.context.object,'CurtainRing',brass)
# Export each component at a shared mounting origin; don't floor-normalise glass/curtains.
report={}
for name,c in assets.items():
 bpy.context.view_layer.update();pts=[o.matrix_world@Vector(v) for o in c.objects for v in o.bound_box];low=[min(p[i] for p in pts) for i in range(3)];high=[max(p[i] for p in pts) for i in range(3)];dims=[round(b-a,4) for a,b in zip(low,high)]
 assert all(math.isfinite(v) and v>0 for v in dims)
 bpy.ops.object.select_all(action='DESELECT')
 for o in c.objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 report[name]={'blender_xyz_studs':dims,'roblox_xyz_studs':[dims[0],dims[2],dims[1]],'bounds_min_xyz':low,'bounds_max_xyz':high,'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in c.objects),'mesh_objects':len(c.objects)}
for prefix in specs:
 bpy.ops.object.select_all(action='DESELECT')
 for suffix in ['WindowFrame','WindowGlass','CurtainPair']:
  for o in assets[prefix+suffix].objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(OUT/(prefix+'WindowComplete.glb')),export_format='GLB',use_selection=True)
assert len(report)==6
(OUT/'manifest.json').write_text(json.dumps({'components':report,'mounting':specs},indent=2)+'\n')
# Staged source, same transform applied to each matching component set.
for name,c in assets.items():
 for o in c.objects:o.location.x+=(-4.25 if name.startswith('Bedroom') else 3.2)
scene=bpy.context.scene;scene['units']='1 Blender unit = 1 Roblox stud';scene['mounting']='Shared origins at sill base, wall centre Y=0. Front Blender -Y / glTF +Z.';scene['status']='Window art only. Real wall openings/weather integration required.';bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'StormViewWindows.blend'))
# Illustration-only storm backdrop demonstrates that the panes have an open view.
begin('PreviewOnly');sky=material('Preview night sky',(13,25,45),0,.9);rain=material('Preview rain',(91,120,155),0,.6);flash=material('Preview lightning',(194,217,244),0,.3)
flash.node_tree.nodes.get('Principled BSDF').inputs['Emission Color'].default_value=(.5,.7,1,1);flash.node_tree.nodes.get('Principled BSDF').inputs['Emission Strength'].default_value=1
for prefix,cx in [('Bedroom',-4.25),('Pub',3.2)]:
 w=specs[prefix]['frame_width'];h=specs[prefix]['frame_height']
 box('IllustrativeSky',(cx,1.3,h/2+.25),(w+.2,.08,h),sky,0)
 for i in range(17):
  x=cx-w*.43+(i%6)*w*.16;z=.7+(i//6)*1.55+(i%3)*.17
  tube('IllustrativeRain',[(x,1.2,z),(x+.16,1.2,z+.48)],rain,.008)
 tube('IllustrativeLightning',[(cx+.6,1.15,h),(cx+.22,1.15,h-.55),(cx+.45,1.15,h-.52),(cx-.12,1.15,h-1.38)],flash,.018)
box('PreviewFloor',(0,0,-.09),(200,200,.15),material('PreviewSlate',(66,74,80)),0)
def aim(o,p):o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for loc,power,size in [((-5,-7,11),2000,7),((7,-4,9),1600,6),((0,7,10),2100,6)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.size=size;aim(o,(0,0,2.8))
bpy.ops.object.camera_add(location=(7,-23,12));cam=bpy.context.object;aim(cam,(-.1,0,2.9));scene.camera=cam;cam.data.type='ORTHO';cam.data.ortho_scale=16.9
scene.render.engine='CYCLES';scene.cycles.samples=48;scene.world.color=(.22,.22,.22);scene.render.resolution_x=1800;scene.render.resolution_y=1150;scene.render.resolution_percentage=100;scene.render.filepath=str(OUT/'preview.png');bpy.ops.render.render(write_still=True)
print('VALIDATED',json.dumps(report))
