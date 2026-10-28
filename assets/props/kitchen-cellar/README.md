# Kitchen and cellar details — first art pass

Eight original local Blender assets: braced storage shelf, open and closed slatted crates, hollow stockpot, frying pan, four stacked plates, hollow metal bucket and straw broom. Palette matches the existing dark-oak/ivory/burgundy prop sets, with aged steel and straw. General atmosphere follows docs/narrative.md and the supplied pub moodboard. These are proposed decorative designs, not invented canonical reference or new gameplay equipment. Original artwork remains untouched; no external meshes, textures or dependencies.

## Files

- KitchenCellarProps.blend: editable source in eight named collections, staged for review.
- CellarShelf.glb, OpenCellarCrate.glb, ClosedCellarCrate.glb, KitchenStockpot.glb, KitchenFryingPan.glb, KitchenPlateStack.glb, CellarBucket.glb, CellarBroom.glb: individual models with embedded solid materials.
- preview.png: neutral Blender overview; preview camera/lights/ground are not exported or saved in the source.
- manifest.json: measured dimensions, triangle and mesh counts.
- build.py: self-contained Blender generator. Run Blender --background --python assets/props/kitchen-cellar/build.py. Regeneration overwrites generated outputs here.

## Proposed sizes

One Blender unit represents one Roblox stud. Use Stud as Studio's importer scale unit and check against actual furniture/avatar dimensions. All exports are floor-aligned, centred on the main body; pan handle extends toward Blender/glTF +X. Shelf's open front faces Blender -Y / glTF +Z. The preview is a prop catalogue, not a room layout.

| Asset | Roblox width / height / depth (studs) |
| --- | --- |
| Storage shelf | 3.6 / 4.5 / 1.48 |
| Open crate | 2.18 / 1.435 / 1.649 |
| Closed crate | 2.18 / 1.635 / 1.649 |
| Stockpot, handles included | 2.100 / 1.07 / 1.38 |
| Frying pan, handle included | 2.63 / 0.345 / 1.56 |
| Plate stack | 1.6 / 0.535 / 1.6 |
| Bucket, handle raised | 1.14 / 1.5 / 1.13 |
| Broom | 0.809 / 3.503 / 0.349 |

Shelf surfaces are at roughly 0.36, 1.70, 3.04 and 4.38 studs above its base. Front openings remain unobstructed; bracing is at the rear. Plate stack is a separate export, placed on the shelf only in the review scene. Its diameter slightly exceeds shelf depth; choose a deeper countertop for full support. Do not infer that the shelf can hold the larger crate models.

Open crate has an actual interior, spaced boards and simple end handholds. Closed crate's lid and battens are separate editable geometry but not hinged or animated. Pot, pan and bucket have hollow interiors with thickness built into their lathed profiles. Bucket handle is modelled raised; no hinge animation is supplied. Plates are four shallow dishes with burgundy rims. Broom uses opaque bundled-straw geometry rather than alpha textures. No food, liquids, brands, lore labels, pickup/cleaning/cooking behaviour or additional puzzle requirements.

All are static decorations. Keep anchored; plan collision/navigation proxies independently. Small handles, straw and cookware should not snag characters or interfere with visibility queries. Structural shelf/crate colliders, if added in the build chat, must retain walking routes and monster clearance. Avoid hiding key spots, the power controls or existing prompts. Join static meshes by material if needed; exports retain separate editable components rather than an optimised game hierarchy.

Solid materials and small bevels establish form; detailed grime, wood grain, fabric/metal wear maps and bespoke UV textures are future polish. Review in actual pub lighting; the neutral render is not proof of game readability.

## Checks and boundaries

Blender 5.2.3 LTS completed finite positive bounds and floor-alignment assertions, all eight exports and rendering. Preview visually inspected. GLB binary headers/lengths, embedded buffers, mesh/material presence, accessors and finite node transforms checked; Python syntax and git diff --check passed. tests/README.md reviewed. Studio import/material appearance, actual room fit, collision/navigation and gameplay regression checks remain for the build chat.

Only assets/props/kitchen-cellar was edited. Other asset sets, artwork, gameplay scripts, maps and place files were preserved. Nothing uploaded or published.
