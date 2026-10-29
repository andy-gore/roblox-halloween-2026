import bpy
from pathlib import Path
root=Path(__file__).resolve().parent
out=root/'runtime';out.mkdir(exist_ok=True)
for path in sorted(root.glob('*/*.glb')):
 if path.parent.name=='runtime':continue
 bpy.ops.wm.read_factory_settings(use_empty=True)
 bpy.ops.import_scene.gltf(filepath=str(path))
 # Strip the reference rain backing; keep the existing in-game native window panes.
 for obj in list(bpy.context.scene.objects):
  if obj.type!='MESH':continue
  if path.stem.startswith('RainStreakPane') and obj.name.startswith('ClearRainSheet'):
   bpy.data.objects.remove(obj,do_unlink=True);continue
  # Preserve silhouettes/colours while reducing bevel loops and tiny number outlines.
  bpy.context.view_layer.objects.active=obj
  mod=obj.modifiers.new('Runtime planar dissolve','DECIMATE');mod.decimate_type='DISSOLVE';mod.angle_limit=.16;mod.delimit={'MATERIAL','SHARP'}
  bpy.ops.object.modifier_apply(modifier=mod.name)
 meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
 count=sum(sum(len(f.vertices)-2 for f in o.data.polygons) for o in meshes)
 if count>240:
  for obj in meshes:
   bpy.context.view_layer.objects.active=obj
   mod=obj.modifiers.new('Runtime silhouette budget','DECIMATE');mod.ratio=max(.025,240/count);mod.use_collapse_triangulate=True
   bpy.ops.object.modifier_apply(modifier=mod.name)
 bpy.ops.export_scene.gltf(filepath=str(out/(path.stem+'.glb')),export_format='GLB',export_materials='EXPORT',export_yup=True)
 print('RUNTIME',path.stem,sum(sum(len(f.vertices)-2 for f in o.data.polygons) for o in meshes))
