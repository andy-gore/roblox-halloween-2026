# Lighting fixtures and proper room signs — first art pass

Eleven original local Blender assets: four matching lighting fixtures and seven room signs. Designed to replace the remaining light placeholders and plain room-label boards when the background build chat integrates them. Dark oak, aged brass, burgundy-black enamel and warm ivory match the existing pub palette. General atmosphere follows docs/narrative.md and the supplied original moodboard; these are proposed designs, not invented canonical artwork. No gameplay, map or existing asset changes.

## Deliverables

- LightingAndRoomSigns.blend: editable source with eleven separate collections, arranged as fixture and sign review boards.
- BedroomCeilingLight.glb, PubWallSconce.glb, PubChandelier.glb, CellarBulkheadLight.glb: individual static fixtures.
- SnugRoomSign.glb, BarRoomSign.glb, KitchenRoomSign.glb, OfficeRoomSign.glb, GuestRoomsSign.glb, CellarRoomSign.glb, StaffStairsSign.glb: individual plaques with raised mesh lettering.
- lighting-preview.png and signs-preview.png: separate neutral Blender reviews. Preview backdrop/camera/lights are excluded from exports and saved source.
- manifest.json: measured bounds, triangle/component counts, exact sign wording and mounting/light-source positions.
- build.py: self-contained generator; run Blender --background --python assets/props/lighting-signs/build.py. Regeneration overwrites generated files in this folder.

The signs use Georgia Bold outlines converted into meshes. The font file is already installed on this Mac; no font file is redistributed or required to import/edit the delivered geometry. Rebuilding uses the local system font if present, otherwise Blender's bundled font, which changes typography.

## Mounting and proposed sizes

One Blender unit represents one Roblox stud. Use Stud as Studio's importer scale unit and verify at player eye height. Front is Blender -Y / glTF +Z. Ceiling-fixture origins are on the mounting ceiling with geometry extending DOWN (negative Blender Z / Roblox Y); do not floor-align or independently recentre them. Wall-fixture/sign origins are bottom-centred, with back offsets noted below. The staged source positions are for review, not world placement coordinates.

| Fixture | Roblox width / height / depth (studs) | Mounting |
| --- | --- | --- |
| Bedroom ceiling light | 1.38 / 1.285 / 1.38 | Ceiling origin, lowest point at local Y=-1.285 |
| Pub wall sconce | 1.02 / 2.015 / 1.47 | Backplate back at local Roblox Z=-0.15 |
| Six-arm pub chandelier | 3.24 / 1.94 / 2.868 | Ceiling origin, lowest point at local Y=-1.94 |
| Caged cellar bulkhead | 0.98 / 1.68 / 0.624 | Housing back at local Roblox Z=-0.12 |

Sconce shade is open; ceiling bowl and bulkhead diffuser are opaque opal-coloured geometry. Chandelier chain and six bulb shapes are rigid scenery, with no physics. Actual Roblox lighting, emission, switching, flicker and power/safety behaviour are NOT baked into these models. Use native light objects at the supplied local locations and preserve existing server-owned power state. Start with one warm PointLight per fixture; the chandelier can use one centre light rather than six shadowed lights. Suggested range/brightness in the manifest are tuning starting points, not verified game settings. For enclosed opaque diffusers, use an unshadowed light or appropriate native diffuser/glow handling so the mesh does not block its own light. Keep the visual fixture non-colliding/queryable-disabled and allow safe overhead clearance.

All seven plaques are 1.35 studs high and approximately 0.346 deep. Widths: The Snug/Main Bar 4.5, Kitchen/Cellar 4.2, Landlord's Office 5.8, Guest Rooms/Staff Stairs 5.1. Back of oak is at local Roblox Z=-0.2. Front lettering faces local Roblox +Z. Scale uniformly as appropriate for mounting distance; leave space around the border. No arrow direction is baked in, since route arrows must follow the actual layout.

## Sign style and build-chat handoff

Wording: THE SNUG, MAIN BAR, KITCHEN, LANDLORD'S OFFICE, GUEST ROOMS, CELLAR, STAFF STAIRS. No new room names or lore. Front plaques have layered oak, a dark burgundy-black face, slim chamfered brass border, two brass fixings and small centre diamonds. Raised ivory bold serif lettering replaces the current plain black-on-white appearance.

For readable, editable runtime labels, the same panel design may use native SurfaceGui text rather than seven separate baked-letter meshes. Suggested colours: dark face RGB 38/24/28; ivory lettering RGB 237/222/182; serif/bold typography with generous margins. Keep SurfaceGui background transparent so it never adds a white rectangle. Use the native text layer only after removing/hiding the baked letter object to prevent doubled lettering. Mesh lettering is provided as a reference and offline import option. A shared plaque mesh plus native text also reduces the existing client editable-mesh memory cost.

Potential label targets in current source: PrototypeMap SnugLabel and HallLabel; PubExpansion GuestSign labels; StaffStairs signs. SnugRoomSign is the direct THE SNUG replacement. Combined labels such as OFFICE / KITCHEN or directional instructions need appropriate separate plaques or native text; do not silently replace them with incomplete wording. These plaques are room-name signs, not replacements for functional maintenance instructions, breaker progress, warning-note content or exit interaction prompts. They are front-lettered; make a second correctly oriented face if a hanging sign must be readable from both directions. Mount beside/above doors without reducing headroom or hiding prompts.

This task only builds assets. It does not register new mesh data in tools/export_prop_meshes.py, alter AssetDressing or change Studio. The background build chat should review the current fixed-size mesh budget before adding all eleven types; retaining native sign text/shared panels and merging static fixture pieces can reduce cost. Existing memory/fallback tests should be repeated after integration.

## Checks and limitations

Blender 5.2.3 LTS completed finite positive bounds and per-model triangle-budget assertions, all eleven exports and both review renders. Previews visually inspected. GLB versions/file lengths, embedded buffers, materials/meshes, finite transforms/accessors and actual index bounds checked. Generator syntax and git diff --check passed. tests/README.md reviewed.

Solid colours/bevels establish the design; detailed aged wood/metal textures, fabric weave, UV maps, actual light emission and game readability remain a later integration/polish step. Studio scale, brightness/shadows, sign legibility at distance/on touch, mounting/collisions and runtime performance are unverified for this new batch. No game/playtest result is claimed from the Blender previews.

Only assets/props/lighting-signs was edited. Concurrent game-building work, all existing models/artwork, code, map and place files were preserved. Nothing uploaded or published.
