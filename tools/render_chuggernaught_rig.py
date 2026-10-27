"""Local QA render of the exact generated geometry using CFrames sampled from the game rig.
Run with Blender --background --python tools/render_chuggernaught_rig.py.
Never saves or overwrites the original model files.
"""
import bpy,json,math
from pathlib import Path
from mathutils import Matrix,Vector
ROOT=Path(__file__).resolve().parents[1]
source=(ROOT/'src/shared/ChuggernaughtMeshData.luau').read_text()
data=json.loads(source.split('[==[',1)[1].rsplit(']==]',1)[0])
frames=json.loads((ROOT/'build/chuggernaught-pose-frames.json').read_text())
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
def linear(c):return c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4
def material(name,rgb):
 m=bpy.data.materials.new(name); m.use_nodes=True
 m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*rgb,1)
 m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.75
 return m
materials=[material('SourceMaterial'+str(i),[linear(c) for c in rgb]) for i,rgb in enumerate(data['palette'])]
for pose_index,pose in enumerate(['Idle','Hunt','Chug']):
 for group in data['groups']:
  v=frames[pose][group['name']]
  v=[v[str(i)] for i in range(1,13)] if isinstance(v,dict) else v
  matrix=Matrix(((v[3],v[4],v[5],v[0]),(v[6],v[7],v[8],v[1]),(v[9],v[10],v[11],v[2]),(0,0,0,1)))
  vertices=[]
  for i in range(0,len(group['positions']),3):
   p=Vector(group['positions'][i:i+3])+Vector(group['center'])-Vector(group['joint'])
   p=matrix@p
   vertices.append((p.x+(pose_index-1)*10,-p.z,p.y))
  faces=[tuple(index-1 for index in group['faces'][i:i+3]) for i in range(0,len(group['faces']),3)]
  mesh=bpy.data.meshes.new(group['name']); mesh.from_pydata(vertices,[],faces); mesh.update()
  obj=bpy.data.objects.new(pose+'_'+group['name'],mesh); bpy.context.collection.objects.link(obj)
  for m in materials:mesh.materials.append(m)
  for face,index in zip(mesh.polygons,range(0,len(group['faces']),3)):
   face.material_index=group['colors'][group['faces'][index]-1]-1
  if hasattr(mesh,'normals_split_custom_set'):
   normals=[]
   for index in group['faces']:
    n=matrix.to_3x3()@Vector(group['normals'][(index-1)*3:index*3])
    normals.append((n.x,-n.z,n.y))
   mesh.normals_split_custom_set(normals)
# Simple neutral review stage, independent of the game pub.
ground=material('ReviewGround',(.035,.045,.055))
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.06)); bpy.context.object.data.materials.append(ground)
def aim(obj,p):obj.rotation_euler=(Vector(p)-obj.location).to_track_quat('-Z','Y').to_euler()
for position,power,size in [((-10,8,16),3000,12),((12,5,12),2200,10),((0,-7,14),3300,12)]:
 bpy.ops.object.light_add(type='AREA',location=position); o=bpy.context.object;o.data.energy=power;o.data.size=size;aim(o,(0,0,4))
bpy.ops.object.camera_add(location=(13,31,13)); camera=bpy.context.object;aim(camera,(0,0,3.5))
camera.data.type='ORTHO';camera.data.ortho_scale=29
scene=bpy.context.scene;scene.camera=camera;scene.world.color=(.19,.19,.19)
caption=material('Caption',(.8,.62,.35))
for i,name in enumerate(['IDLE','HUNT','CHUG']):
 bpy.ops.object.text_add(location=((i-1)*10,3.5,-.1));t=bpy.context.object;t.data.body=name;t.data.align_x='CENTER';t.data.size=.55;t.rotation_euler=camera.rotation_euler;t.data.materials.append(caption)
scene.render.engine='CYCLES';scene.cycles.samples=16
scene.render.resolution_x=1500;scene.render.resolution_y=750;scene.render.resolution_percentage=100
scene.render.filepath=str(ROOT/'build/Chuggernaught-rig-preview.png')
bpy.ops.render.render(write_still=True)
print('Rig preview rendered without modifying original artwork.')
