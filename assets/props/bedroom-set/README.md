# Bedroom furniture — first art pass

A reusable single bed, bedside cabinet, wardrobe and dresser with mirror for The Crooked Tankard's bedrooms. Original locally generated geometry, guided by docs/narrative.md and the supplied assets/concepts/The Chuggernaught_ Last Orders Moodboard.png environment tone. The moodboard does not show a dedicated bedroom design: these are proposed reusable furniture designs, not invented canonical references. The original artwork is unchanged.

Palette follows the current local pub's dark oak, burgundy cushions, dark timber and brass in src/server/PubProps.luau. RGB colours are converted from sRGB to linear for Blender/glTF. Aged ivory bedding complements the palette. All materials are embedded solid colours, with small bevels and simple pointed trim; detailed wear and wood grain are future work.

## Files

- BedroomProps.blend: editable source; each prop has its own named collection, staged together for review.
- InnSingleBed.glb, BedsideCabinet.glb, InnWardrobe.glb, DresserMirror.glb: separate static exports with floor-centred placement origins and glTF Y-up convention.
- preview.png: neutral Blender review render; stage, camera and lights are not exported or included in the saved source.
- manifest.json: measured bounds, triangle counts and component counts.
- build.py: reproducible Blender script. From the repository root run `/Applications/Blender.app/Contents/MacOS/Blender --background --python assets/props/bedroom-set/build.py`. Regeneration overwrites generated files in this folder.

## Proposed sizes

One Blender unit represents one Roblox stud. These are reusable proposed dimensions; bedroom dimensions have not been specified and no room-fit claim is made.

| Asset | Roblox width × height × depth (studs) | Triangles |
| --- | --- | --- |
| Single bed | 4.58 × 3.84 × 7.08 | 1,460 |
| Bedside cabinet | 2.05 × 2.425 × 1.92 | 660 |
| Wardrobe | 4.3 × 7.03 × 2.66 | 1,168 |
| Dresser with mirror | 3.9 × 5.6 × 2.14 | 1,328 |

The mattress top is 2 studs high (blanket/pillow extend above it). The bed headboard points toward Blender +Y / glTF -Z. Cabinet/wardrobe/dresser fronts point toward Blender -Y / glTF +Z. Placement origins lie at ground level, centred on each main furniture body; small handles and decorative trim extend beyond body footprints.

In Studio, use Stud as the importer scale unit and verify against an avatar before placement. Keep static meshes anchored. Plan simple collision proxies independently of the decorative mesh components; preserve walking routes, door approaches and monster clearance. Re-run the project's layout/navigation checks after placing furniture.

## Limitations and checks

This is static scenery: drawers and doors are modelled closed, with no hinges, interaction, inventory or hiding behaviour. The mirror is a flat metal material proxy, not an implemented real-time reflection. Meshes have separate editable components, not an optimised single-mesh game hierarchy. No bespoke UV texture or normal map is supplied.

Blender 5.2.3 LTS completed local generation, floor-alignment assertions, all four exports and rendering. The preview was visually inspected. GLB headers, embedded buffers, mesh/material presence and binary lengths passed local validation. Git diff whitespace check passed.

Read tests/README.md before handoff. No scripts or place files changed, so Studio import/material appearance, collisions, routes and keyboard/touch gameplay remain unverified. The set is not integrated into the map. No uploads, publishing or asset-server operations performed.
