# Pub details — first art pass

Nine original Blender scenery assets for The Crooked Tankard, using the current pub/bedroom dark oak, brass, burgundy and ivory palette. General atmosphere follows docs/narrative.md and the supplied original moodboard. These are proposed reusable prop designs, not replacement canonical references. Source artwork is unchanged. No external meshes, textures or dependencies.

## Deliverables

- PubDetails.blend: editable source with nine named collections, staged for review.
- OpenGuestbook.glb, PortraitFrame.glb, LandscapeFrame.glb, GreenBottle.glb, AmberBottle.glb, StonewareMug.glb, PubNameSign.glb, RoomsAvailableSign.glb, CellarSign.glb: separate local exports with embedded solid materials.
- preview.png: neutral Blender overview; floating wall objects are arranged for review, not a room layout. Preview lighting/ground is not exported or included in the saved asset source.
- manifest.json: measured dimensions, mesh counts and triangle counts.
- build.py: self-contained Blender generator. Run Blender --background --python assets/props/pub-details/build.py. Regeneration overwrites generated files in this folder.

## Integration notes

One Blender unit represents one Roblox stud. Use Stud as the Studio import scale unit; verify with an avatar and the existing pub furniture. Each prop's bottom is at height zero. Front of signs/frames is Blender -Y / glTF +Z. Tabletop pieces are horizontally centred on their main bodies; the mug handle and guestbook bookmark extend beyond them.

| Asset | Approximate Roblox width / height / depth (studs) |
| --- | --- |
| Open guestbook | 2.46 / 0.374 / 1.835 |
| Portrait frame | 1.55 / 2.05 / 0.305 |
| Landscape frame | 2.2 / 1.45 / 0.305 |
| Green bottle | 0.602 / 1.51 / 0.602 |
| Amber bottle | 0.722 / 1.29 / 0.722 |
| Stoneware mug | 1.130 / 0.77 / 0.7 |
| Pub-name sign | 3.5 / 0.67 / 0.237 |
| Rooms-available sign | 2.6 / 0.67 / 0.237 |
| Cellar sign | 1.8 / 0.67 / 0.237 |

Frames: layered oak/brass rails and a recessed BlankPictureInsert. Back is at Blender Y=0.12 / glTF Z=-0.12. Insert openings are approximately 1.20 × 1.70 studs portrait, and 1.85 × 1.10 landscape. Picture inserts are plain ivory; no photograph, character portrait, historical artwork or date is fabricated. Supply approved imagery separately. The inserts are geometry without prepared image UVs; native UI/decals or UV mapping will be needed for actual pictures. No glass or reflection implementation supplied.

Guestbook: open leather-bound ruled pages, paper layers and ribbon. Entries remain blank, with no guest names, date or new lore. Pages have simple geometry; no readable story content, UV artwork, page-turn animation or interaction. Add any narrative entry only after its text is approved.

Bottles: two opaque stylised shapes, corks and blank paper bands. These use solid materials rather than transparency/refraction for simple predictable rendering. No real brand, alcohol label or drinking mechanic. Mug is hollow and empty, distinct from the monster's canonical wooden tankard.

Signs: THE CROOKED TANKARD, ROOMS AVAILABLE and CELLAR use existing project wording. Back is at Blender Y=0.16 / glTF Z=-0.16. Lettering is geometry. Native Studio UI may be preferable for small-screen text, localisation and lower triangle counts. These art assets must not replace working sign/prompt behaviour automatically.

All are static decorations. Keep anchored and isolate visuals from navigation, collision and query geometry as appropriate. Retain authoritative gameplay targets and visibility checks. Avoid hiding the key or obstructing counters, doorways and stairs. Join static components by material for integration if needed. Fine wood grain, fabric/leather texture, grime and detailed wear maps are not included; this remains a first art pass.

## Verification and boundaries

Blender 5.2.3 LTS completed finite positive bounds/floor checks, all nine GLB exports and rendering. Preview visually inspected. Binary GLB version/length, embedded buffers, mesh/material presence, accessor bounds and finite node transforms checked; Python syntax and git diff --check passed. tests/README.md reviewed. Studio scale, materials, text readability, actual room placement, navigation and gameplay regression checks remain for the build chat.

Only assets/props/pub-details was edited. Existing assets, artwork, scripts, maps and place files were preserved. Nothing uploaded or published.
