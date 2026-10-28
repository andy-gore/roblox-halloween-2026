# Objective props — first art pass

Original local Blender geometry for the approved existing interactions: restore lights, ring distraction bell, unlock exit with the brass key. Based on docs/narrative.md, the supplied pub moodboard's general atmosphere, and existing prop materials. These specific designs are proposed art, not extra canonical reference. No external models, textures or dependencies. No gameplay changes or additional puzzle.

## Files

- ObjectiveProps.blend: editable staged set in three collections.
- CellarFuseBox.glb, ServiceBell.glb, ExitDoorLock.glb: individual local exports with embedded flat materials; preview staging and lights excluded.
- preview.png: neutral Blender overview, not an in-game screenshot.
- build.py: reproducible generator; run Blender --background --python assets/props/objective-set/build.py. Regeneration overwrites generated files in this folder.
- manifest.json: measured dimensions, bounds, triangle and object counts.

## Integration handoff

One Blender unit represents one Roblox stud. Import with scale unit Stud and verify alongside an avatar. Front is Blender -Y / glTF +Z. Each asset's bottom is at height zero. Wall props are horizontally centred on their back mounting plane, not on their depth midpoint; preserve placement offsets when changing pivots.

| Model | Proposed Roblox width / height / depth | Mount |
| --- | --- | --- |
| CellarFuseBox | 2.5 / 3.68 / 0.945 studs | Back at glTF Z=0; conduit tops included |
| ServiceBell | 1.64 / 1.195 / 1.64 studs | Base on counter surface |
| ExitDoorLock | 1.35 / 2.5 / 0.67 studs | Back of oak block at glTF Z=-0.2 |

Fuse box: SwitchPivot is a parent Empty for SwitchArm and SwitchGrip. In Blender its local X rotation is 25 degrees for OFF; the proposed ON pose is -155 degrees. These are suggested visual poses, not an exported animation. Preserve the local transform hierarchy when importing; pivot metadata is stored in the Blender source. IndicatorLens uses a green material with no emission; implement dark/off versus lit/on presentation from the existing replicated power state. MAIN LIGHTS, ON/OFF and ISOLATE SUPPLY labels are geometry and can be replaced by native Studio UI for easier localisation/lower triangle count. No breaker puzzle or extra inputs are implied.

Bell: PressButton and PlungerShaft remain separate for a short downward press (approximately 0.06 studs) and return. BellShell is a hollow lathed mesh. Existing server distraction cooldown/priority stays authoritative; press animation should not imply a successful ring when cooldown rejects it. No sound file or animation included.

Lock: TurnKnob has its Blender origin at its centre and can rotate around local Y (suggested unlock turn 90 degrees). Escutcheon has a true keyhole opening with recessed backing. OakMount is an optional review mounting block; hide/remove it for a flush installation on an existing wooden door. The lock shares the exit key's brass material, but the key and lock are stylised props, not mechanically matched for insertion. No key-insertion animation is provided. Key-only exit logic remains authoritative; power does not unlock the door.

All visual meshes should be anchored/non-colliding/non-touching and excluded from navigation/visibility queries as appropriate; retain existing collision proxies and server interaction checks. Do not automatically replace prompt target parts with these multi-mesh visuals. Text, bevels and fasteners increase mesh counts; join static pieces by material during integration if needed, keeping moving parts separate. Final readability depends on game lighting; the neutral preview is brighter than the pub.

## Verification and boundaries

Blender 5.2.3 LTS completed model generation, finite positive dimension checks, individual GLB export and preview rendering. Preview visually reviewed. Local GLB headers, embedded buffers, accessor bounds and node transforms checked; Python syntax and git diff --check passed. tests/README.md reviewed: Studio import/scale, lighting, moving-part behaviour, keyboard/touch prompts, reset and objective regression checks remain pending in the build chat. This asset-only task makes no claim that gameplay checks passed.

Only this asset folder was edited. No scripts, map, place, source artwork or existing assets changed. Nothing uploaded or published.
