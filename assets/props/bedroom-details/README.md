# Bedroom details — first art pass

Original local Blender geometry expanding the existing bedroom furniture set: bedside lamp, closed traveller's suitcase, stack of three books, three-hook coat rail, and individual room-number plaques 1–8. Uses the existing bedroom set's dark oak, brass, burgundy and aged ivory palette (sRGB colours converted to linear). The supplied moodboard establishes the general pub atmosphere; it does not depict these particular objects. These are proposed scenery designs, not new canonical references or story clues. Original artwork is untouched.

## Deliverables

- BedroomDetails.blend: editable source; twelve named asset collections, staged together for review.
- BedsideLamp.glb, TravellerSuitcase.glb, BedsideBooks.glb, BedroomCoatRail.glb and RoomPlaque_01.glb through RoomPlaque_08.glb: individual exports with embedded flat materials and no external texture dependencies.
- preview.png: neutral Blender overview, not a Studio screenshot. Floating wall props are arranged for review, not a bedroom layout.
- manifest.json: measured dimensions and triangle/component counts.
- build.py: self-contained, reproducible Blender generator. Run Blender --background --python assets/props/bedroom-details/build.py. Regeneration overwrites this folder's generated files.

## Sizes and placement

One Blender unit represents one Roblox stud. Import using scale unit Stud; verify with an avatar and actual furniture. Each exported model's bottom is at height zero. Tabletop pieces are centred horizontally; mounting blocks are centred horizontally with backs offset in depth as noted below. Front is Blender -Y / glTF +Z.

| Asset | Roblox width / height / depth (studs) | Notes |
| --- | --- | --- |
| Bedside lamp | 1.284 / 1.825 / 1.284 | Fits proposed 2.05 × 1.7 cabinet top footprint; place base on top surface |
| Traveller suitcase | 2.6 / 1.814 / 1.056 | Standing, closed case with handle, straps and blank tag |
| Three-book stack | 1.22 / 0.566 / 1.038 | Separate editable covers, pages and bookmark |
| Coat rail | 2.8 / 1.16 / 0.821 | Back of wood at Blender Y=0.2 / glTF Z=-0.2 |
| Each room plaque | 1.04 / 0.7 / 0.197 | Back at Blender Y=0.13 / glTF Z=-0.13 |

Lamp: open tapered shade, stem, bulb and pull chain are geometry only. No PointLight, power logic, emission or switch animation is included. Add a bounded warm light during integration, controlled by the existing power state if appropriate. Pull chain is decorative. Check shade appearance inside the actual pub; render lighting is not exported.

Luggage: static closed case; no inventory, opening or hiding interaction. Tag is deliberately blank. Books have no readable text, assigned owners, dates or lore. Coat hooks and plaques are static. Room numbers are real geometry; native text UI can replace these numbers for easier editing/localisation or lower mesh counts.

Join static components by material for integration if needed. Keep decorations anchored/non-colliding and use existing navigation and collision geometry rather than letting small hooks, handles or books obstruct players. Avoid masking key spawn points or blocking sight to prompts. Preserve door approaches and passage widths; repeated details need not fill every available surface. Re-run relevant layout/navigation checks after any placement changes in the build chat.

## Checks and limitations

Blender 5.2.3 LTS generated all twelve models, asserted positive finite dimensions and floor alignment, exported all GLBs and rendered the overview. Lamp bounds were checked against the existing cabinet's proposed footprint. Preview visually inspected. GLB headers/lengths, embedded buffers, accessor ranges and finite node transforms checked; Python syntax and git diff --check passed.

Materials are solid colours with bevels; detailed wood grain, leather wear, fabric weave and UV texture maps are not supplied. This is an asset first pass. Studio import/scale, game lighting, key visibility, low-end device performance and gameplay/layout regressions remain unverified. tests/README.md was reviewed; gameplay checks belong to integration because this task edits no game files.

Only assets/props/bedroom-details was changed. Existing assets, source artwork, scripts, maps and place files were preserved. Nothing uploaded or published.
