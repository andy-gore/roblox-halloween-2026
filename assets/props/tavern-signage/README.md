# Refined tavern signage

An original coordinated signage family for The Firefly Tavern. This is a local art pass while gameplay development continues in the other chat. Original signs, lighting assets, narrative/artwork, runtime scripts and place files are preserved.

## Contents

- TavernSignage.blend — editable geometry, 19 individual asset collections.
- Seven room plaques: THE SNUG, MAIN BAR, KITCHEN, LANDLORD’S OFFICE, GUEST ROOMS, CELLAR, STAFF STAIRS.
- BedroomNumber01–08 — matching numbered plaques for all eight bedrooms.
- DirectionLeft and DirectionRight — GUEST ROOMS boards with clear arrows. Choose the correct arrow only after checking the map.
- SharedBlankPlaque — reusable sign frame for editable native Roblox lettering and other existing sign wording.
- Individual GLBs, measured manifest.json, signage-preview.png and snug-detail.png.
- build.py — reproducible Blender generator. Run from the repo: `/Applications/Blender.app/Contents/MacOS/Blender --background --python assets/props/tavern-signage/build.py`. Regeneration replaces only this batch's generated files.

## Design

Restrained midnight-burgundy enamel, bevelled dark oak, muted brass cartouche outlines, small flush fixings and warm ivory serif letters. Room titles use consistent margins and paired ornamental hairlines. Numerals have stronger weight and the same proportioned frame. Direction arrows use plain geometric forms for rapid reading. No added lore, dates, invented room names or wear across essential letters.

Mesh lettering uses installed Georgia outlines, converted into geometry. It complements the Tavern Gothic direction; it is not an exact Fondamento font match. No font file is distributed. A native Fondamento SurfaceGui on SharedBlankPlaque is the preferred route for an exact match to the approved HUD/brand typography; Nunito remains suitable for longer directions. Preserve functional warning, breaker and emergency-exit wording. Do not change safety arrows or substitute room names for instructional content.

## Mounting and integration

1 Blender unit = 1 Roblox stud. Bottom-centred origin; front Blender -Y / glTF and Roblox +Z; back at Blender Y=+0.20 (Roblox Z=-0.20). Manifest gives actual bounds. Standard room plaques retain previous widths and 1.35-stud height; number plaques are 1.05 × 1.35 studs. Review positions in the .blend are staging offsets, not map placements. GLBs retain their own mounting origins.

Choose baked lettering OR native text, avoiding doubled lettering. SharedBlankPlaque avoids importing a separate mesh template for each label; it is preferred for the existing fixed-size EditableMesh budget. Use transparent SurfaceGui backgrounds, ivory text, generous margins, and constrained text sizes. Runtime font directions are documented in assets/ui/typography/README.md. Mount without blocking prompts, windows, doorways or headroom. Decorative meshes should be anchored, non-colliding, non-touching and non-querying.

The other chat's TavernSigns module already applies an initial native oak/brass finish. This batch supplies refined art references and import options; it does not overwrite that module, register geometry or alter the game. Live brand illustrations and functional warning/power displays remain in that game's existing treatment.

## Validation

Generator asserts 19 exports, finite positive bounds and <18,000 triangles per model. Review renders use neutral studio lighting, not game lighting. See manifest for actual triangle counts. Source syntax, GLB structure/accessors and preview appearance are checked before handoff. tests/README.md was reviewed; gameplay tests do not validate asset-only files.

Before integration: check scale/legibility at avatar height and mobile distance, front/back orientation, native label alignment, fixed-size mesh memory, collisions and graphics settings. Runtime integration and in-game visual/play checks are not claimed. No upload or publication.

Completed checks: Blender 5.2.3 LTS generated 18 GLBs and both renders successfully. All GLB headers, buffer ranges, finite position bounds and actual triangle-index bounds passed; 43,428 triangles across the whole library (repeated instances should share geometry). Python source syntax and git diff --check passed. Both renders were visually inspected for spacing, direction arrows, plaque edges and number fit. No runtime code changed, so no new Studio gameplay checks were run.


## Integrated locally — 28 October 2026

TavernSigns now reproduces the layered oak/enamel face, chamfered brass cartouche, fixings and restrained ornament with native SurfaceGui objects on 78 existing sign faces. Short room titles use Fondamento; longer directions use Nunito. All current wording, directions, board transforms, collision properties and the existing firefly illustration are preserved. Styling can be applied repeatedly without duplicating its finish. Warning papers and active maintenance instructions keep their treatment.

BedroomNumberBlank.glb is an additional shared version of the original numbered-plaque frame. All eight existing number placements use this one original mesh with native Fondamento numerals. The individual baked-number GLBs remain available for offline use. Eight separate baked-number templates exceeded the tested client's mesh budget for one unrelated prop; the shared frame resolves that failure and reduces the full scenery to 44 fixed meshes. export_prop_meshes.py packs 40 active asset types; old unused source modules remain preserved. No extra sign mesh types are loaded for the large editable signs.

Both Rojo builds passed. TavernSigns.spec and AssetIntegration.spec passed in disposable Studio Edit fixtures; PropRenderer.spec passed in Play. Live client: 78 refined sign faces, eight fitted numerals, 164 loaded asset placements and zero failed assets. Existing asset-type warnings for 203785492 remain unrelated. Play stopped and temporary fixtures removed. The backed-up local Halloween2026.rbxlx was saved in managed code folders only; authored bytes outside them are verified unchanged. No upload/publication. Human review of the native signs at avatar height and on touch remains necessary; Blender previews are not in-game screenshots.
