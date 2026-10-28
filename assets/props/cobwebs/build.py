"""Original static mesh cobwebs. Run in Blender; 1 unit = 1 Roblox stud."""
import bpy,math,json,random
from pathlib import Path
from mathutils import Vector
OUT=Path(__file__).resolve().parent
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
for c in list(bpy.data.collections):
 if c.name!='Collection':bpy.data.collections.remove(c)
def linear(v):return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
def material(n,rgb):
 c=[linear(v/255) for v in rgb];m=bpy.data.materials.new(n);m.diffuse_color=(*c,1);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*c,1);p.inputs['Roughness'].default_value=.96;return m
silk=material('Dusty grey silk',(151,151,143))
# Opaque, slender geometry avoids overlapping alpha planes and needs no image upload.
assets={};meta={};verts=[];faces=[]
def strand(points,radius):
 start=len(verts)
 for i,p in enumerate(points):
  p=Vector(p);before=Vector(points[max(0,i-1)]);after=Vector(points[min(len(points)-1,i+1)]);tangent=(after-before).normalized()
  axis=Vector((0,1,0));u=tangent.cross(axis).normalized()
  if u.length<.1:u=tangent.cross(Vector((1,0,0))).normalized()
  v=tangent.cross(u).normalized()
  for j in range(4):verts.append(tuple(p+radius*(u*math.cos(j*math.tau/4)+v*math.sin(j*math.tau/4))))
 for i in range(len(points)-1):
  for j in range(4):
   a=start+i*4+j;b=start+i*4+(j+1)%4;faces.append((a,b,b+4,a+4))
 faces.extend([(start+3,start+2,start+1,start),(start+(len(points)-1)*4,start+(len(points)-1)*4+1,start+(len(points)-1)*4+2,start+(len(points)-1)*4+3)])
def finish(n,anchors,note):
 global verts,faces
 mesh=bpy.data.meshes.new(n);mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new(n,mesh);c=bpy.data.collections.new(n);bpy.context.scene.collection.children.link(c);c.objects.link(o);o.data.materials.append(silk);assets[n]=o
 for polygon in mesh.polygons:polygon.use_smooth=True
 meta[n]={'attachment_points_blender_xyz':anchors,'placement':note};verts=[];faces=[]
def fan(name,R,count,rings,seed):
 rng=random.Random(seed)
 # Shared origin at top-left wall/ceiling (or shelf/frame) corner.
 def point(k,t):
  a=k/(count-1);return Vector((R*a*t,.018*math.sin(a*math.pi*2)*t,-R*(1-a)*t-.10*R*math.sin(math.pi*a)*t))
 for k in range(count):
  strand([tuple(point(k,t)) for t in [0,.2,.4,.6,.8,1]],.009 if R>2 else .0055)
 for ring in range(1,rings+1):
  t=ring/rings
  for k in range(count-1):
   # Selective gaps make the outer web tattered, while all surviving arcs meet spokes.
   if ring in [rings-1,rings] and (k+ring)%5==1:continue
   a=point(k,t);b=point(k+1,t);pts=[]
   for j in range(6):
    u=j/5;p=a.lerp(b,u);p.z-=math.sin(math.pi*u)*R*.025*(.5+t);p.y-=math.sin(math.pi*u)*rng.uniform(.003,.017);pts.append(tuple(p))
   strand(pts,.0055 if R>2 else .0038)
 # Outer support line anchors the fan to the two bounding surfaces.
 strand([tuple(point(k,1)) for k in range(count)],.008 if R>2 else .005)
 if R>2:
  p=point(2,.96);strand([tuple(p),tuple(p+Vector((.04,0,-.16))),tuple(p+Vector((.08,.015,-.3)))],.004)
 finish(name,[[0,0,0],[R,0,0],[0,0,-R]],'Corner origin. +X right, -Z down; front Blender -Y. Fit anchors to wall/ceiling or frame edges.')
fan('CornerCobweb',2.65,9,7,28)
# Hanging radial web with broken arcs, suspension lines and loose lower threads.
rng=random.Random(29);centre=Vector((0,0,-1.15));count=11
angles=[i*math.tau/count for i in range(count)]
ends=[centre+Vector((1.02*math.cos(a)*(1+rng.uniform(-.07,.07)),rng.uniform(-.025,.025),.85*math.sin(a)*(1+rng.uniform(-.08,.08)))) for a in angles]
for end in ends:
 strand([tuple(centre.lerp(end,t)+Vector((0,-.018*math.sin(t*math.pi),0))) for t in [0,.25,.5,.75,1]],.0065)
for ring in range(1,6):
 for k in range(count):
  if (ring==5 and k in [1,5,8]) or (ring==4 and k==6):continue
  t=ring/5;a=centre.lerp(ends[k],t);b=centre.lerp(ends[(k+1)%count],t);pts=[]
  for j in range(5):
   u=j/4;p=a.lerp(b,u);p.z-=.04*t*math.sin(math.pi*u);p.y-=.015*math.sin(math.pi*u);pts.append(tuple(p))
  strand(pts,.0045)
for anchor,index in [((-.95,0,0),3),((.95,0,0),1),((0,0,0),2)]:
 end=ends[index];strand([anchor,tuple(Vector(anchor).lerp(end,.5)+Vector((0,-.02,-.035))),tuple(end)],.007)
for index,length in [(7,.31),(8,.45),(9,.24)]:
 p=ends[index];strand([tuple(p),tuple(p+Vector((.035,.01,-length*.5))),tuple(p+Vector((.02,.02,-length)))],.004)
finish('HangingCobweb',[[-.95,0,0],[0,0,0],[.95,0,0]],'Three upper suspension anchors. Origin at centre of anchor line; web hangs in local -Z. No spider included.')
fan('ShelfCobweb',1.12,6,4,30)
# Export mesh-only files; one object and no collision plane per asset.
report={}
for name,o in assets.items():
 points=[Vector(v) for v in o.bound_box];lo=[min(p[i] for p in points) for i in range(3)];hi=[max(p[i] for p in points) for i in range(3)];dims=[round(b-a,4) for a,b in zip(lo,hi)]
 assert all(math.isfinite(v) and v>0 for v in dims)
 assert len(o.data.vertices)>0 and all(len(p.vertices)>=3 for p in o.data.polygons)
 bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 report[name]={'blender_xyz_studs':dims,'roblox_xyz_studs':[dims[0],dims[2],dims[1]],'bounds_min_xyz':lo,'bounds_max_xyz':hi,'triangles':sum(len(p.vertices)-2 for p in o.data.polygons),'mesh_objects':1,**meta[name]}
assert len(report)==3
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
# Review staging; mounting origins are retained in individual exports above.
placements={'CornerCobweb':(-4.2,0,3.6),'HangingCobweb':(.1,0,3.6),'ShelfCobweb':(2.65,0,3.0)}
for n,o in assets.items():o.location=placements[n]
scene=bpy.context.scene;scene['units']='1 Blender unit = 1 Roblox stud';scene['placement']='Anchor origins, not floor-centred. See manifest attachment points.';scene['status']='Static decorative cobwebs; no runtime placement';bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Cobwebs.blend'))
# Contrasting sample surfaces are preview-only, not part of any asset.
dark=material('Preview charcoal plaster',(38,43,48));oak=material('Preview dark oak',(66,34,20));labelmat=material('Preview labels',(173,168,151))
def box(n,loc,size,m):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.name=n;o.dimensions=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(m);return o
box('PreviewWall',(0,.25,2.2),(10,.12,4.7),dark)
box('CornerUpperBeam',(-2.85,.05,3.7),(2.95,.18,.18),oak);box('CornerSideBeam',(-4.3,.05,2.3),(.18,.18,2.95),oak)
box('HangingBeam',(.1,.05,3.72),(2.45,.18,.18),oak)
box('ShelfUpperRail',(3.23,.05,3.1),(1.4,.18,.18),oak);box('ShelfSideRail',(2.55,.05,2.53),(.18,.18,1.3),oak)
for x,body in [(-2.95,'CORNER'),(.1,'HANGING'),(3.15,'SHELF / FRAME')]:
 bpy.ops.object.text_add(location=(x,-.01,.55),rotation=(math.pi/2,0,0));o=bpy.context.object;o.data.body=body;o.data.size=.15;o.data.align_x='CENTER';o.data.materials.append(labelmat)
def aim(o,p):o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
for loc,power,size in [((-3,-6,7),1300,6),((5,-4,5),900,5)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.size=size;aim(o,(0,0,2.2))
bpy.ops.object.camera_add(location=(.7,-15,5.4));camera=bpy.context.object;aim(camera,(0,0,2.1));scene.camera=camera;camera.data.type='ORTHO';camera.data.ortho_scale=10.4
scene.render.engine='CYCLES';scene.cycles.samples=64;scene.world.color=(.17,.17,.17);scene.render.resolution_x=1800;scene.render.resolution_y=1000;scene.render.resolution_percentage=100;scene.render.filepath=str(OUT/'preview.png');bpy.ops.render.render(write_still=True)
print('VALIDATED',json.dumps(report))
