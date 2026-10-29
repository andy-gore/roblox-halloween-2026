# Tavern atmosphere — four local art packs

Twenty original static assets for The Firefly Tavern, following the existing dark oak, aged brass, burgundy, ivory and weathered iron palette. The current narrative and original concept art are preserved. Landscapes, clock hands and dressing are proposed art details, not new canonical references or gameplay clues. The concurrent architecture/game work is untouched.

## Deliverables

- TavernAtmosphere.blend — editable source, one collection per asset. Different packs overlap in review staging; isolate collections to inspect a pack. Exported GLBs are in their own mounting coordinates.
- bar/, wall/, storm/, courtyard/ — individual GLBs, manifest.json and preview.png per group.
- manifest.json — all measured bounds, triangle counts, origins and material/runtime notes.
- build.py — deterministic self-contained generator. Requires the installed Georgia Bold system font for clock/dartboard text; outlines are converted to geometry and no font file is redistributed.

Regenerate from the repository with `/Applications/Blender.app/Contents/MacOS/Blender --background --python assets/props/atmosphere-set/build.py`. This overwrites this batch's generated deliverables. All preview cameras/lights/floor are created after saving source and excluded from GLBs.

| Group | Assets |
| --- | --- |
| Bar | TwinBeerPump, BarDripTray, PewterTankardRack, CoasterStack, SinglePewterMug |
| Wall | StoppedPubClock, FramedCountryside, FramedWoodland, PubDartboard |
| Storm | RainStreakPaneNarrow, RainStreakPaneWide, SmallPuddle, DoorwayPuddle, CourtyardPuddle |
| Courtyard | DrainpipeStraight, DrainpipeOffset, DrainpipeShoe, GalvanisedBin, BrokenCourtyardPlanter, CourtyardWallLantern |

## Mounting

One Blender unit = one Roblox stud. Front Blender -Y becomes glTF/Roblox +Z. Vertical Blender Z becomes Roblox Y. Counter/floor props are bottom-centred; wall objects are bottom-centred with back offsets in the manifests. Do not independently recentre the pieces after import. Numbers in manifests are actual export bounds, not review-stage positions.

- Counter dressing should leave the warning, bell, hand reach and prompt view clear. The rack uses ordinary pewter mugs, visually distinct from the monster's wooden tankard. Pumps have unbranded badges, no invented breweries or text.
- Clock and paintings mount flat against walls; the two countryside scenes are original simple geometric relief compositions, not reproductions or supplied canonical artwork. Clock hands are stopped decorative scenery, not a puzzle/time clue. Dartboard has twenty alternating beds and the standard number sequence; it is not interactive.
- Rain panes are optional transparent overlay references sized 2.4×4.4 and 4.8×4.4 studs. Match the actual window aperture before use. Leave the established native glass/barriers in control of window collision, occlusion and navigation. Never stack multiple full glass sheets just to add streaks.
- Puddles are low-profile irregular transparent surfaces. Place slightly above outdoor ground to prevent z-fighting; avoid covering steps, prompts or the entire chase route. They do not change traction, damage, pathfinding or player physics.
- Drainpipe modules join by translation/rotation; bracket offsets are recorded. Place the shoe above the ground. Courtyard props should sit against walls, outside walking/chase clearances. The broken planter has an actual missing wall sector plus separate fallen shards; shards are decoration, not physical debris.
- Lantern has a suggested native light position in its manifest. Actual emission, power switching and brightness are not baked into the model. Start with one warm PointLight; tune range and shadow cost in Studio. Glass panes can be omitted/replaced with native glass if needed.

## Integration limits

This task creates assets only: no map/scripts/place edits, mesh registration, upload or publishing. The current renderer supports opaque flat-colour GLBs and deliberately rejects transparency. Do **not** feed the rain panes, puddles or lantern glass directly into tools/export_prop_meshes.py. For the current upload-free path, use native translucent Parts/Glass/SurfaceAppearance-compatible rendering as appropriate, or split the lantern into opaque body and native glass first. Roblox transparency and reflections require in-engine review; the Blender render is not proof of the final effect.

The full game previously approached its EditableMesh memory budget. Integrate selected repeated templates deliberately; do not import all new props without rerunning client load checks. Native/shared meshes, reused mug geometry and simplified distant versions are reasonable integration options. Decorative parts should be anchored, non-colliding, non-touching and non-querying. Retain existing server-owned collision proxies, objectives and monster navigation.

These are solid-colour/bevel/geometry assets. No detailed PBR texture maps, baked grime, runtime rain animation, particles, dynamic clock, usable dart minigame, new objectives or layout changes are included. Metal/water/reflection/material settings need tuning at avatar height and on mobile.

## Checks

The generator asserts twenty exports, finite positive bounds and fewer than 12,000 triangles per asset. Source syntax, GLB buffers/accessors/indices and all four neutral review renders are checked before delivery. tests/README.md was read; gameplay tests are not applicable to standalone art files. No Studio playtest or actual game screenshot is claimed for this batch.

Completed file checks: 20 GLB headers and declared lengths, buffer-view ranges, finite node transforms/position bounds and actual triangle index ranges passed. Total library: 37,356 triangles (bar 6,888; wall 12,256; storm 14,248; courtyard 3,964). Transparent material declarations are present in both rain panes, all three puddles and the lantern. Python syntax and git diff --check passed.

Blender 5.2.3 LTS completed the source save, all exports and all four renders. All review images were visually inspected; storm/courtyard framing was adjusted to show separated puddles and the full drainpipe. All twenty source assets remain in the editable .blend. This chat changed only assets/props/atmosphere-set; concurrent place/architecture/test-document edits belong to the other build work.


## Integrated runtime edition — 29 October 2026

The source blend and twenty original GLBs above are preserved. `build_runtime.py` creates lighter derived GLBs in runtime/ using planar dissolve and a roughly 240-triangle per-asset target (small separate components affect the exact count). Regenerate with Blender in background, then run `python3 tools/export_prop_meshes.py`. Source artwork is never overwritten by this step.

Seventeen runtime asset types are placed in the game: bar dressing, original wall pictures, clock, dartboard, rain beads/trails, modular pipes, bin, broken planter and courtyard lantern. ClearRainSheet is omitted so the native window glazing/barriers remain authoritative. Transparent and opaque groups are packed separately; the renderer preserves group alpha and suppresses transparent shadows. The three puddle references are implemented as native translucent water shapes using their measured footprint, rather than loading six more mesh groups. The full originals and derived puddle exports are retained for future import.

The complete full-detail pack exceeded the observed editable-mesh budget. The reduced edition plus native water loaded 197 placements and 62 fixed-size groups with zero mesh failures alongside the existing monster. Large scratch meshes build first to reduce allocation peaks. This is an observed desktop Studio result, not a mobile performance guarantee. Decorative numbers and bevels are simplified in the runtime copies. No asset upload/publishing occurred.
