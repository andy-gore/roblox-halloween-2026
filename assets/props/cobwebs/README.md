# Cobwebs — first art pass

Three original static mesh assets implementing the approved sparse decorative cobweb idea: large corner fan, hanging broken radial web and small shelf/frame fan. Dusty grey, thin opaque strands with sagging arcs, missing sections and a few loose ends. General abandoned-pub atmosphere follows docs/narrative.md and the supplied moodboard; these are proposed scenery assets, not new canonical artwork. No spider, trapping or damage mechanic. No external image, model or dependency.

## Files

- Cobwebs.blend: editable source with three staged collections; each web is one mesh.
- CornerCobweb.glb, HangingCobweb.glb, ShelfCobweb.glb: individual mesh-only exports, one material each, no backing planes or textures.
- preview.png: neutral Blender review with sample beams/wall and labels, none of which is exported or saved in the asset source.
- manifest.json: bounds, triangle counts and local attachment points.
- placement-guide.json: proposed candidate tags, scale range and integration constraints; not executable placement code or actual map locations.
- build.py: self-contained reproducible Blender generator. Run Blender --background --python assets/props/cobwebs/build.py. Regeneration overwrites this folder's generated outputs. Fixed local generation seeds reproduce geometry only; no procedural game system is added.

## Dimensions and alignment

One Blender unit represents one Roblox stud. Import using scale unit Stud and retain scene-relative geometry/origins. These assets use ATTACHMENT origins, not floor-centred origins. Blender front is -Y / glTF +Z; Blender +X is right; Blender -Z hangs down / glTF -Y. Nominal web plane is Blender Y=0, with slight strand offsets; stand it roughly 0.04–0.08 studs off a wall if needed to avoid clipping.

| Asset | Roblox width / height / depth (studs) | Triangles | Origin |
| --- | --- | --- | --- |
| Corner | 2.665 / 2.677 / 0.072 | 2,816 | Upper-left corner |
| Hanging | 2.002 / 2.450 / 0.065 | 2,352 | Centre of upper suspension line |
| Shelf/frame | 1.130 / 1.130 / 0.055 | 1,100 | Upper-left corner |

Corner attachment points in Roblox local XYZ: (0,0,0), (2.65,0,0), (0,-2.65,0). Small-web equivalents use 1.12. Hanging anchors are (-0.95,0,0), (0,0,0), (+0.95,0,0), with the web below. Exact Blender-space anchors are in the manifest. Shared origin placement is essential: an importer that recentres the MeshPart may require an attachment offset. Keep geometry anchored; no sway or physics animation supplied.

## Sparse random placement handoff

The build chat should define a small list of deliberate attachment transforms in actual geometry: high ceiling corners, unused shelf corners, frame corners and high beams. Pick a bounded subset once per run and keep it stable until reset; do not choose arbitrary coordinates or continuously respawn webs. Local random selection is sufficient for cosmetic visuals unless the build architecture wants shared choices. Nothing here changes objectives, NPC state, inventory or visibility rules.

Suggested starting budget: 8–12 total across the entire pub, with many bedroom candidates left empty and no more than one per bedroom. This is an art starting point, not a measured device-performance limit. Prefer cellar/storage corners and quiet edges over the busy bar or bright storm-view panes. Use modest uniform scale variation (0.75–1.15) and small rotations that preserve all anchors; avoid stretching separate axes or random rotation in open space. Validate the whole scaled bounds against furniture/architecture, not only the root attachment. Mirror only with a transform/import workflow that preserves normals.

In Studio, explicitly set all web visuals Anchored=true, CanCollide=false, CanTouch=false, CanQuery=false and CastShadow=false. Mesh exports cannot encode those Roblox properties. Keep them out of server monster sight/reach checks and rain/camera rays. No invisible full-web collision or query plane is needed. Reject candidate bounds near key spots (all possible locations), fuse switches/card, bell, exit lock/signs, doorway/stair headroom and player camera paths. Reserve key/prompt clearance regardless of the selected room or current hidden state, so reset cannot create an obstructed objective. Avoid covering readable signs, pictures or the main storm view.

## Checks and limitations

Blender 5.2.3 LTS generated all three single-mesh assets, asserted finite positive bounds and completed exports/rendering. Preview visually inspected. Local GLB version/file length, single mesh/material structure, embedded buffers, index/accessor bounds and finite transforms checked; Python syntax and git diff --check passed. tests/README.md reviewed.

Thin geometry can shimmer or disappear at a distance. Test at avatar height on desktop/touch and under actual pub lighting before changing strand thickness or placing many copies. Solid dusty material avoids alpha-plane overlap, but it is not textured silk or a distance-LOD implementation. Strand intersections deliberately overlap without welding to preserve simple single-mesh editing. Studio import, actual random placement, collision/query settings, small-screen appearance, navigation and runtime performance remain unverified until integration.

Only assets/props/cobwebs was edited. No runtime random-placement system, map, script, place, existing asset or original artwork changed. Nothing uploaded or published.
