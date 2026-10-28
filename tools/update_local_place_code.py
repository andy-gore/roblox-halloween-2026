"""Merge reviewed Rojo code folders into a backed-up local place; preserve all other bytes."""
from pathlib import Path
import copy,hashlib,xml.etree.ElementTree as ET,xml.parsers.expat
ROOT=Path(__file__).resolve().parents[1]
TARGETS={'HalloweenServer':'ServerScriptService','HalloweenClient':'StarterPlayerScripts','HalloweenShared':'ReplicatedStorage'}
def spans(raw):
 parser=xml.parsers.expat.ParserCreate();items=[];result={};capture=None
 def start(tag,attrs):
  nonlocal capture
  if tag=='Item':items.append({'start':parser.CurrentByteIndex,'class':attrs.get('class'),'name':None})
  if tag=='string' and attrs.get('name')=='Name' and items:capture=[]
 def chars(text):
  if capture is not None:capture.append(text)
 def end(tag):
  nonlocal capture
  if tag=='string' and capture is not None:
   items[-1]['name']=''.join(capture);capture=None
  if tag=='Item':
   item=items.pop();name=item['name']
   if name in TARGETS and items and items[-1]['class']==TARGETS[name]:result[name]=(item['start'],parser.CurrentByteIndex+len(b'</Item>'))
 parser.StartElementHandler=start;parser.CharacterDataHandler=chars;parser.EndElementHandler=end;parser.Parse(raw,True)
 assert set(result)==set(TARGETS),result
 return result

def name(item):return item.findtext('./Properties/string[@name="Name"]')
def main():
 place=ROOT/'places/Halloween2026.rbxlx';generated=ROOT/'build/Halloween2026.rbxlx';backup=ROOT/'build/backups/asset-integration-20261028'
 assert backup.exists() and (backup/'places/Halloween2026.rbxlx').exists(),'Back up place first'
 raw=place.read_bytes();source=generated.read_bytes();oldsp=spans(raw);newsp=spans(source);replacements=[]
 for index,n in enumerate(TARGETS):
  a,b=oldsp[n];c,d=newsp[n];old=ET.fromstring(raw[a:b]);new=ET.fromstring(source[c:d]);newNames={name(i) for i in new.findall('Item')}
  # Retain code-folder children that are not controlled by the current Rojo project.
  for child in old.findall('Item'):
   if name(child) not in newNames:new.append(copy.deepcopy(child))
  refs={item.get('referent'):f'RBXAssetIntegration{index}_{i}' for i,item in enumerate(new.iter('Item')) if item.get('referent')}
  refs[new.get('referent')]=old.get('referent')
  for item in new.iter('Item'):
   if item.get('referent') in refs:item.set('referent',refs[item.get('referent')])
  for ref in new.iter('Ref'):
   if ref.text in refs:ref.text=refs[ref.text]
  replacements.append((a,b,ET.tostring(new,encoding='utf-8')))
 before=raw
 for a,b,value in sorted(replacements,reverse=True):raw=raw[:a]+value+raw[b:]
 # Every byte outside the three reviewed code folders must remain identical.
 finalsp=spans(raw)
 def untouched(data,regions):
  cursor=0;pieces=[]
  for a,b in sorted(regions.values()):pieces.append(data[cursor:a]);cursor=b
  pieces.append(data[cursor:]);return b''.join(pieces)
 assert untouched(before,oldsp)==untouched(raw,finalsp),'Authored place bytes changed outside code folders'
 ET.fromstring(raw)
 (backup/'before-code-merge.rbxlx').write_bytes(before)
 place.write_bytes(raw)
 print('Saved local place code only; all bytes outside HalloweenServer/Client/Shared preserved')
 print('SHA256',hashlib.sha256(raw).hexdigest())
if __name__=='__main__':main()
