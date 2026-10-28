"""Pack original local GLBs for upload-free client meshes. Standard library only."""
import json,struct,math,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SETS={'pub-set':['PubTable','PubChair','CellarBarrel'],'bedroom-set':['InnSingleBed','BedsideCabinet','InnWardrobe','DresserMirror'],'bedroom-details':['BedsideLamp','TravellerSuitcase','BedsideBooks','BedroomCoatRail']+[f'RoomPlaque_{i:02d}' for i in range(1,9)],'exit-key':['ExitKey'],'objective-set':['CellarFuseBox','ServiceBell','ExitDoorLock'],'pub-details':['OpenGuestbook','PortraitFrame','LandscapeFrame','GreenBottle','AmberBottle','StonewareMug','PubNameSign','RoomsAvailableSign','CellarSign'],'kitchen-cellar':['CellarShelf','OpenCellarCrate','ClosedCellarCrate','KitchenStockpot','KitchenFryingPan','KitchenPlateStack','CellarBucket','CellarBroom'],'windows':['BedroomWindowFrame','BedroomCurtainPair','PubWindowFrame','PubCurtainPair'],'cobwebs':['CornerCobweb','HangingCobweb','ShelfCobweb']}
def mul(a,b):return [[sum(a[r][k]*b[k][c] for k in range(4)) for c in range(4)] for r in range(4)]
def matrix(n):
 if 'matrix'in n:return [[n['matrix'][c*4+r] for c in range(4)] for r in range(4)]
 x,y,z,w=n.get('rotation',[0,0,0,1]);s=n.get('scale',[1,1,1]);t=n.get('translation',[0,0,0])
 r=[[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],[2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],[2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]]
 return [[r[i][j]*s[j] for j in range(3)]+[t[i]] for i in range(3)]+[[0,0,0,1]]
def point(m,v):return [sum(m[r][c]*v[c] for c in range(3))+m[r][3] for r in range(3)]
def normal(m,v):
 # inverse transpose for any applied GLB node scale
 a,b,c=m[0][:3];d,e,f=m[1][:3];g,h,i=m[2][:3];det=a*(e*i-f*h)-b*(d*i-f*g)+c*(d*h-e*g);assert abs(det)>1e-12
 cof=[[e*i-f*h,f*g-d*i,d*h-e*g],[c*h-b*i,a*i-c*g,b*g-a*h],[b*f-c*e,c*d-a*f,a*e-b*d]]
 n=[sum(cof[r][k]*v[k] for k in range(3))/det for r in range(3)];length=math.sqrt(sum(x*x for x in n));return [x/length for x in n]
def srgb(v):return 12.92*v if v<=.0031308 else 1.055*v**(1/2.4)-.055

def export(path):
 raw=path.read_bytes();magic,version,length=struct.unpack_from('<4sII',raw);assert (magic,version,length)==(b'glTF',2,len(raw));jl,kind=struct.unpack_from('<II',raw,12);g=json.loads(raw[20:20+jl]);at=20+jl;bl,bk=struct.unpack_from('<II',raw,at);binary=raw[at+8:at+8+bl]
 def accessor(index):
  a=g['accessors'][index];view=g['bufferViews'][a['bufferView']];code={5121:'B',5123:'H',5125:'I',5126:'f'}[a['componentType']];n={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}[a['type']];size=struct.calcsize('<'+code*n);stride=view.get('byteStride',size);start=view.get('byteOffset',0)+a.get('byteOffset',0)
  return [struct.unpack_from('<'+code*n,binary,start+j*stride) for j in range(a['count'])]
 parents={c:i for i,n in enumerate(g['nodes']) for c in n.get('children',[])}
 def world(i):
  m=matrix(g['nodes'][i]);return mul(world(parents[i]),m) if i in parents else m
 groups={};palette=[]
 for ni,node in enumerate(g['nodes']):
  if 'mesh'not in node:continue
  name=node['name'];group='Static';pivot=[0,0,0]
  if path.stem=='CellarFuseBox' and name.startswith(('SwitchArm','SwitchGrip')):group='Switch';pivot=[0,1.6,.8]
  if path.stem=='CellarFuseBox' and name.startswith('IndicatorLens'):group='Indicator'
  if path.stem=='ServiceBell' and name.startswith(('PressButton','PlungerShaft')):group='Press'
  if path.stem=='ExitDoorLock' and name.startswith('TurnKnob') and not name.startswith(('TurnKnobBezel','TurnKnobStem')):group='Turn';pivot=[0,1.65,.39]
  data=groups.setdefault(group,{'name':group,'pivot':pivot,'positions':[],'normals':[],'faces':[],'colors':[]});m=world(ni)
  for prim in g['meshes'][node['mesh']]['primitives']:
   assert prim.get('mode',4)==4
   pos=[point(m,v) for v in accessor(prim['attributes']['POSITION'])];norm=[normal(m,v) for v in accessor(prim['attributes']['NORMAL'])];idx=[a[0] for a in accessor(prim['indices'])];assert max(idx)<len(pos)
   rgba=g['materials'][prim['material']]['pbrMetallicRoughness'].get('baseColorFactor',[1,1,1,1]);assert rgba[3]>.99,'Native glass is separate'
   rgb=[round(srgb(v),5) for v in rgba[:3]]
   if rgb not in palette:palette.append(rgb)
   ci=palette.index(rgb)+1;start=len(data['positions'])//3
   data['positions'].extend(v for p in pos for v in p);data['normals'].extend(v for n in norm for v in n);data['faces'].extend(v+start+1 for v in idx);data['colors'].extend([ci]*len(pos))
 for data in groups.values():
  xyz=data['positions'];lo=[min(xyz[i::3]) for i in range(3)];hi=[max(xyz[i::3]) for i in range(3)];center=[(a+b)/2 for a,b in zip(lo,hi)];data['center']=[round(v,6) for v in center];data['size']=[round(max(.001,b-a),6) for a,b in zip(lo,hi)];data['positions']=[round(v-center[i%3],6) for i,v in enumerate(xyz)];data['normals']=[round(v,6) for v in data['normals']]
  assert len(data['faces'])//3<20000 and all(math.isfinite(v) for v in data['positions']+data['normals'])
 return {'source':str(path.relative_to(ROOT)),'sha256':hashlib.sha256(raw).hexdigest(),'palette':palette,'groups':list(groups.values())}

def main():
 out=ROOT/'src/shared/PropMeshData';out.mkdir(exist_ok=True);catalog={}
 for folder,names in SETS.items():
  for name in names:
   path=ROOT/'assets/props'/folder/(name+'.glb');data=export(path);payload=json.dumps(data,separators=(',',':'));(out/(name+'.luau')).write_text('--!strict\n-- Generated from '+data['source']+'; original geometry unchanged.\nreturn [==['+payload+']==]\n');catalog[name]={'source':data['source'],'sha256':data['sha256'],'triangles':sum(len(g['faces'])//3 for g in data['groups']),'groups':len(data['groups'])}
 (ROOT/'build/prop-export-catalog.json').write_text(json.dumps(catalog,indent=2)+'\n');print(len(catalog),'original assets packed;',sum(x['triangles'] for x in catalog.values()),'unique triangles')
if __name__=='__main__':main()
