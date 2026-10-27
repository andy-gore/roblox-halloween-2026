"""Export the existing local GLBs into bounded, joint-centred runtime mesh data.
No Blender regeneration, network calls or asset uploads. Python standard library only.
"""
import hashlib, json, math, struct
from collections import Counter
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
JOINTS = {
    'Torso': (0,3.5,0), 'Head': (0,6.2,0),
    'UpperArmLeft': (-1.5,6,0), 'LowerArmLeft': (-2,4.85,0),
    'UpperArmRight': (1.5,6,0), 'LowerArmRight': (2,4.85,0),
    'LegLeft': (-.73,3.3,0), 'LegRight': (.73,3.3,0), 'Tankard': (0,0,0),
}
def matrix(node):
    if 'matrix' in node:
        a=node['matrix']; return [[a[c*4+r] for c in range(4)] for r in range(4)]
    x,y,z,w=node.get('rotation',[0,0,0,1]); sx,sy,sz=node.get('scale',[1,1,1])
    assert max(abs(s-1) for s in (sx,sy,sz)) < 1e-5, 'Apply nonuniform scales before export'
    tx,ty,tz=node.get('translation',[0,0,0])
    return [[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w),tx],
            [2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w),ty],
            [2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y),tz],[0,0,0,1]]
def multiply(a,b): return [[sum(a[r][k]*b[k][c] for k in range(4)) for c in range(4)] for r in range(4)]
def transform(m,p,point=True):
    v=[sum(m[r][c]*p[c] for c in range(3))+(m[r][3] if point else 0) for r in range(3)]
    return [-v[0],v[1],-v[2]] # rotate +Z-front glTF to Roblox -Z-front

def srgb(v): return 12.92*v if v<=.0031308 else 1.055*v**(1/2.4)-.055

def load(name):
    path=ROOT/'assets/characters/chuggernaught'/f'{name}.glb'; raw=path.read_bytes()
    magic,version,length=struct.unpack_from('<III',raw)
    assert magic==0x46546C67 and version==2 and length==len(raw)
    json_len,kind=struct.unpack_from('<II',raw,12); assert kind==0x4E4F534A
    g=json.loads(raw[20:20+json_len]); at=20+json_len
    bin_len,kind=struct.unpack_from('<II',raw,at); assert kind==0x004E4942
    binary=raw[at+8:at+8+bin_len]
    def accessor(i):
        a=g['accessors'][i]; view=g['bufferViews'][a['bufferView']]
        code={5121:'B',5123:'H',5125:'I',5126:'f'}[a['componentType']]
        count={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}[a['type']]
        size=struct.calcsize('<'+code*count); stride=view.get('byteStride',size)
        start=view.get('byteOffset',0)+a.get('byteOffset',0)
        return [struct.unpack_from('<'+code*count,binary,start+j*stride) for j in range(a['count'])]
    parents={c:i for i,n in enumerate(g['nodes']) for c in n.get('children',[])}
    def world(i):
        m=matrix(g['nodes'][i]); return multiply(world(parents[i]),m) if i in parents else m
    yield 'source', {'file':str(path.relative_to(ROOT)), 'sha256':hashlib.sha256(raw).hexdigest()}
    for i,node in enumerate(g['nodes']):
        if 'mesh' not in node: continue
        m=world(i)
        for primitive in g['meshes'][node['mesh']]['primitives']:
            assert primitive.get('mode',4)==4
            pos=[transform(m,p) for p in accessor(primitive['attributes']['POSITION'])]
            norms=[transform(m,n,False) for n in accessor(primitive['attributes']['NORMAL'])]
            indices=[v[0] for v in accessor(primitive['indices'])]
            factor=g['materials'][primitive['material']]['pbrMetallicRoughness']['baseColorFactor'][:3]
            color=tuple(round(srgb(v),6) for v in factor)
            yield node['name'], (pos,norms,indices,color)

def group_for(name,pos,tankard):
    if tankard: return 'Tankard'
    if name.startswith(('Bald_Head','Neck','Ear','Eye','Pupil','HeavyBrow','Nose','Grin')): return 'Head'
    side='Left' if sum(p[0] for p in pos)/len(pos)<0 else 'Right'
    if name.startswith('UpperArm'): return 'UpperArm'+side
    if name.startswith(('Forearm','Wristband','Fist','Thumb')): return 'LowerArm'+side
    if name.startswith(('TrouserLeg','RaggedHem','ExposedShin','Boot','KneeTear','TrouserPatch')): return 'Leg'+side
    return 'Torso'

def export():
    groups={k:{'positions':[],'normals':[],'faces':[],'colors':[],'materials':Counter()} for k in JOINTS}
    palette=[]; sources=[]
    for file in ('Chuggernaught_FirstPass','Tankard_FirstPass'):
        for name,data in load(file):
            if name=='source': sources.append(data); continue
            pos,norm,indices,color=data; key=group_for(name,pos,file.startswith('Tankard'))
            group=groups[key]; start=len(group['positions'])//3
            if color not in palette: palette.append(color)
            ci=palette.index(color)+1
            group['materials'][ci]+=len(indices)
            group['positions'].extend(c for p in pos for c in p)
            group['normals'].extend(c for n in norm for c in n)
            group['colors'].extend([ci]*len(pos)); group['faces'].extend(v+start+1 for v in indices)
    result={'sources':sources,'palette':palette,'groups':[]}
    for name,g in groups.items():
        xyz=g['positions']; assert xyz
        lo=[min(xyz[i::3]) for i in range(3)]; hi=[max(xyz[i::3]) for i in range(3)]
        center=[(a+b)/2 for a,b in zip(lo,hi)]
        g['positions']=[round(v-center[i%3],6) for i,v in enumerate(xyz)]
        g['normals']=[round(v,6) for v in g['normals']]
        g.update(name=name,center=[round(c,6) for c in center],joint=JOINTS[name],size=[round(b-a,6) for a,b in zip(lo,hi)],color=g.pop('materials').most_common(1)[0][0])
        assert len(g['faces'])%3==0 and len(g['positions'])==len(g['normals'])
        result['groups'].append(g)
    assert sum(len(g['faces'])//3 for g in result['groups'])==6449
    payload=json.dumps(result,separators=(',',':'))
    out=ROOT/'src/shared/ChuggernaughtMeshData.luau'
    out.write_text('--!strict\n-- Generated by tools/export_chuggernaught.py from original GLBs. Do not edit by hand.\nreturn [==['+payload+']==]\n')
    print(f'{len(result["groups"])} mesh groups, 6449 triangles, {len(payload)} bytes: {out}')
if __name__=='__main__': export()
