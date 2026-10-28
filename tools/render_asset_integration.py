"""Render captured local Studio placements with the original exported mesh data. QA, not a screenshot."""
import bpy,json,math
from pathlib import Path
from mathutils import Matrix,Vector
ROOT=Path(__file__).resolve().parents[1]
data=json.loads((ROOT/'build/asset-review-scene.json').read_text())
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
B=Matrix(((1,0,0,0),(0,0,-1,0),(0,1,0,0),(0,0,0,1)))
def cf(a):return Matrix(((a[3],a[4],a[5],a[0]),(a[6],a[7],a[8],a[1]),(a[9],a[10],a[11],a[2]),(0,0,0,1)))
def linear(x):return x/12.92 if x<=.04045 else ((x+.055)/1.055)**2.4
cache={}
def material(rgb,kind='SmoothPlastic',alpha=1):
 key=(tuple(rgb),kind,alpha)
 if key in cache:return cache[key]
 m=bpy.data.materials.new(kind);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF');c=tuple(linear(v) for v in rgb);p.inputs['Base Color'].default_value=(*c,1);p.inputs['Roughness'].default_value=.75
 if kind=='Glass':p.inputs['Roughness'].default_value=.12
 if kind=='Metal':p.inputs['Metallic'].default_value=.6;p.inputs['Roughness'].default_value=.4
 if kind=='Neon':p.inputs['Emission Color'].default_value=(*c,1);p.inputs['Emission Strength'].default_value=2
 p.inputs['Alpha'].default_value=alpha;cache[key]=m;return m
for row in data['parts']:
 size=row['size'];shape=row['shape']
 if shape=='Wedge':
  v=[(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)];f=[(0,1,3,2),(2,3,5,4),(0,4,5,1),(0,2,4),(1,5,3)];mesh=bpy.data.meshes.new('Wedge');mesh.from_pydata(v,[],f);mesh.update();o=bpy.data.objects.new(row['name'],mesh);bpy.context.collection.objects.link(o)
 elif shape=='Ball':bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=6,radius=.5);o=bpy.context.object
 elif shape=='Cylinder':bpy.ops.mesh.primitive_cylinder_add(vertices=16,radius=.5,depth=1);o=bpy.context.object
 else:bpy.ops.mesh.primitive_cube_add(size=1);o=bpy.context.object
 scale=Matrix.Diagonal((*size,1))
 if shape=='Cylinder':scale=scale@Matrix.Rotation(math.pi/2,4,'Y')
 o.name=row['name'];o.matrix_world=B@cf(row['cf'])@scale;o.data.materials.append(material(row['color'],row['material'],row['alpha']))
 if 'text'in row:
  bpy.ops.object.text_add();t=bpy.context.object;t.data.body=row['text'];t.data.align_x='CENTER';t.data.align_y='CENTER';t.data.size=.6;t.matrix_world=B@cf(row['cf'])@Matrix.Translation((0,0,size[2]/2+.025));bpy.context.view_layer.update();factor=min(size[0]*.88/max(t.dimensions.x,.01),size[1]*.8/max(t.dimensions.z,.01));t.scale=(factor,)*3;t.data.materials.append(material([1,.87,.65],'Neon'))
meshes={}
for placement in data['assets']:
 name=placement['name']
 if name not in meshes:
  text=(ROOT/'src/shared/PropMeshData'/(name+'.luau')).read_text();d=json.loads(text.split('return [==[',1)[1].rsplit(']==]',1)[0]);meshes[name]=[]
  for group in d['groups']:
   c=group['center'];p=group['positions'];verts=[(p[i]+c[0],p[i+1]+c[1],p[i+2]+c[2]) for i in range(0,len(p),3)];idx=group['faces'];faces=[tuple(v-1 for v in idx[i:i+3]) for i in range(0,len(idx),3)]
   mesh=bpy.data.meshes.new(name+'_'+group['name']);mesh.from_pydata(verts,[],faces);mesh.update()
   for rgb in d['palette']:mesh.materials.append(material(rgb))
   for polygon,i in zip(mesh.polygons,range(0,len(idx),3)):polygon.material_index=group['colors'][idx[i]-1]-1
   norms=group['normals'];mesh.normals_split_custom_set_from_vertices([tuple(norms[i:i+3]) for i in range(0,len(norms),3)])
   meshes[name].append(mesh)
 for mesh in meshes[name]:
  o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o);o.matrix_world=B@cf(placement['cf'])@Matrix.Diagonal((*placement['scale'],1))
for light in data['lights']:
 bpy.ops.object.light_add(type='POINT',location=(B@Vector((*light['pos'],1))).to_3d());o=bpy.context.object;o.data.energy=light['brightness']*85;o.data.color=tuple(linear(v) for v in light['color']);o.data.shadow_soft_size=.35
# Exterior moon fill, actual walls/windows still occlude it.
for pos,power,size,color in [((80,55,10),35000,65,(.3,.43,.75)),((-80,55,10),35000,65,(.3,.43,.75))]:
 location=(B@Vector((*pos,1))).to_3d();bpy.ops.object.light_add(type='AREA',location=location);o=bpy.context.object;o.data.energy=power;o.data.size=size;o.data.color=color;o.rotation_euler=((B@Vector((0,20,0,1))).to_3d()-o.location).to_track_quat('-Z','Y').to_euler()
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=16;scene.world.color=(.06,.08,.13);scene.view_settings.exposure=1.15;scene.render.resolution_x=1500;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
bpy.ops.object.camera_add();camera=bpy.context.object;scene.camera=camera;camera.data.lens=22
# Neutral review fill approximates non-physical Roblox ambient; it is not game lighting.
bpy.ops.object.light_add(type='AREA');review=bpy.context.object;review.data.energy=18000;review.data.size=18;review.data.color=(.78,.75,.7)
for name,pos,look in [('Bedroom-assets-in-place',(13,23.5,18),(40,20.3,9)),('Bar-assets-in-place',(-8,8.5,31),(-28,5,17))]:
 camera.location=(B@Vector((*pos,1))).to_3d();target=(B@Vector((*look,1))).to_3d();camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler();review.location=camera.location+Vector((0,0,2));review.rotation_euler=(target-review.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(ROOT/'build'/(name+'.png'));bpy.ops.render.render(write_still=True)
print('Actual Studio placements reviewed in Blender; not in-game screenshots.')
