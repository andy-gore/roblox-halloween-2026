"""Neutral night QA render of exported Studio part geometry; never overwrites place/artwork.
Requires ignored build/exterior-scene.json captured from the temporary Studio scene.
This is a scene preview, not a Roblox screenshot.
"""
import bpy,json,math,random
from pathlib import Path
from mathutils import Matrix,Vector
ROOT=Path(__file__).resolve().parents[1]
data=json.loads((ROOT/'build/exterior-scene.json').read_text())
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
B=Matrix(((1,0,0,0),(0,0,-1,0),(0,1,0,0),(0,0,0,1)))
def linear(c):return c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4
materials={}
def mat(row):
 key=(tuple(round(c,3) for c in row['color']),row['material'],round(row['alpha'],2))
 if key in materials:return materials[key]
 m=bpy.data.materials.new(row['material']);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');color=tuple(linear(c) for c in row['color'])
 p.inputs['Base Color'].default_value=(*color,1)
 p.inputs['Roughness'].default_value=.27 if row['material'] in ('Asphalt','Glass','Metal') else .8
 if row['material']=='Metal':p.inputs['Metallic'].default_value=.55
 if row['material']=='Neon':p.inputs['Emission Color'].default_value=(*color,1);p.inputs['Emission Strength'].default_value=3
 p.inputs['Alpha'].default_value=max(.4,row['alpha'])
 materials[key]=m;return m
for row in data['parts']:
 shape=row['shape'];v=row['cf'];size=row['size']
 cf=Matrix(((v[3],v[4],v[5],v[0]),(v[6],v[7],v[8],v[1]),(v[9],v[10],v[11],v[2]),(0,0,0,1)))
 scale=Matrix.Diagonal((*size,1))
 if shape=='Wedge':
  verts=[(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
  faces=[(0,1,3,2),(2,3,5,4),(0,4,5,1),(0,2,4),(1,5,3)]
  mesh=bpy.data.meshes.new('Wedge');mesh.from_pydata(verts,[],faces);mesh.update()
  obj=bpy.data.objects.new(row['name'],mesh);bpy.context.collection.objects.link(obj)
 elif shape=='Ball':
  bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=6,radius=.5);obj=bpy.context.object
 elif shape=='Cylinder':
  bpy.ops.mesh.primitive_cylinder_add(vertices=16,radius=.5,depth=1);obj=bpy.context.object
  scale=scale@Matrix.Rotation(math.pi/2,4,'Y')
 else:bpy.ops.mesh.primitive_cube_add(size=1);obj=bpy.context.object
 obj.name=row['name'];obj.matrix_world=B@cf@scale;obj.data.materials.append(mat(row))
 if 'text' in row:
  bpy.ops.object.text_add();t=bpy.context.object;t.data.body=row['text'];t.data.align_x='CENTER';t.data.align_y='CENTER';t.data.size=1
  tm=B@cf@Matrix.Translation((0,0,size[2]/2+.035));t.matrix_world=tm
  bpy.context.view_layer.update()
  factor=min(size[0]*.9/max(t.dimensions.x,.01),size[1]*.8/max(t.dimensions.z,.01))
  t.scale=(factor,factor,factor)
  ink={'color':[1,.84,.53],'material':'Neon','alpha':1};t.data.materials.append(mat(ink))
for light in data['lights']:
 bpy.ops.object.light_add(type='POINT',location=(B@Vector((*light['pos'],1))).to_3d() )
 l=bpy.context.object;l.data.energy=light['brightness']*45;l.data.color=tuple(linear(c) for c in light['color']);l.data.shadow_soft_size=.7
# Cool moon/sky fill gives a readable night view without flattening the warm windows.
bpy.ops.object.light_add(type='AREA',location=(-80,20,100));moon=bpy.context.object;moon.data.energy=100000;moon.data.size=100;moon.data.color=(.35,.47,.8)
moon.rotation_euler=(Vector((0,-30,0))-moon.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.light_add(type='AREA',location=(-60,-130,70));fill=bpy.context.object;fill.data.energy=35000;fill.data.size=100;fill.data.color=(.25,.35,.6)
fill.rotation_euler=(Vector((0,-40,10))-fill.location).to_track_quat('-Z','Y').to_euler()
random.seed(20261027)
verts=[];faces=[]
for _ in range(1400):
 x,y,z=random.uniform(-130,110),random.uniform(1,48),random.uniform(50,160)
 if -8<x<49 and z<90:continue
 a=Vector((x,-z,y));b=a+Vector((.15,-.05,-1.7));right=Vector((.024,.024,0));i=len(verts)
 verts.extend([a-right,a+right,b+right,b-right]);faces.append((i,i+1,i+2,i+3))
mesh=bpy.data.meshes.new('PreviewRain');mesh.from_pydata(verts,[],faces);mesh.update();rain=bpy.data.objects.new('PreviewRain',mesh);bpy.context.collection.objects.link(rain)
rmat=mat({'color':[.3,.4,.57],'material':'Neon','alpha':.4});rain.data.materials.append(rmat)
bpy.ops.object.camera_add(location=(-140,-190,85));camera=bpy.context.object;camera.rotation_euler=(Vector((0,-45,14))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=220
scene=bpy.context.scene;scene.camera=camera;scene.world.color=(.12,.16,.24);scene.view_settings.exposure=1.25
scene.render.engine='CYCLES';scene.cycles.samples=16
scene.render.resolution_x=1500;scene.render.resolution_y=950;scene.render.resolution_percentage=100
scene.render.filepath=str(ROOT/'build/Stormy-exterior-preview.png');bpy.ops.render.render(write_still=True)
print('Exterior scene preview saved; original place and artwork unchanged.')
