# Storm-view windows — first art pass

Two original local window designs for The Crooked Tankard: six-pane bedroom and nine-pane larger pub window. Dark oak, small pointed crest, deep sill, brass latches and separate tied-back burgundy curtains match the existing asset palette and supplied moodboard's general gothic atmosphere. Clear viewing panes implement the user's approved request to see the storm. These are proposed modular assets, not copies of an invented canonical window reference. Original artwork is unchanged.

## Deliverables

- StormViewWindows.blend: editable source, staged bedroom and pub assemblies in six named component collections.
- BedroomWindowFrame.glb, BedroomWindowGlass.glb, BedroomCurtainPair.glb: independent matching components.
- PubWindowFrame.glb, PubWindowGlass.glb, PubCurtainPair.glb: larger independent components.
- BedroomWindowComplete.glb, PubWindowComplete.glb: convenience exports combining their matching three components.
- preview.png: neutral Blender review with an illustrative static rain/lightning backdrop. That backdrop is NOT part of the models, saved source or exports and is NOT the game's weather or an in-game screenshot.
- manifest.json: component bounds, triangle/mesh counts and exact mounting dimensions.
- build.py: self-contained generator; run Blender --background --python assets/props/windows/build.py. Regeneration overwrites generated files here.

## Alignment and proposed mounting

One Blender unit equals one Roblox stud. Use Stud as the import scale unit and verify against the actual rooms. These are proposed reusable dimensions, not fitted to a specific current wall. Front/interior is Blender -Y / glTF +Z; vertical is Blender Z / glTF Y. Shared origin lies at sill-base height, horizontal centre, wall-depth centre Y=0. All matching component exports preserve that SAME origin, including the glass and curtains: do not independently floor-align or recentre those pieces. An importer that recentres mesh pivots must retain their scene-relative transforms or use the complete assembly.

| Dimension | Bedroom | Pub |
| --- | --- | --- |
| Suggested rectangular wall cutout width | 4.4 | 6.6 |
| Suggested rectangular wall cutout height | 5.4 | 5.8 |
| Cutout bottom above shared origin | 0.25 | 0.25 |
| Clear framed aperture, before thin mullions | 3.84 × 4.84 | 6.04 × 5.24 |
| Total frame width, sill included | 4.9 | 7.1 |
| Total frame height, crest included | 6.16 | 6.56 |
| Total frame depth | 1.1 | 1.1 |
| Curtain assembly width, finials included | 6.53 | 8.73 |

All measurements are studs. Cutouts should run from base+0.25 to base+5.65 (bedroom) or base+6.05 (pub), centred horizontally. Sill extends from Blender Y=-0.75 to +0.35; front trim/reveal geometry spans roughly Y=-0.38 to +0.31. Reveal pieces are only about 0.55 studs deep; thicker walls need extended reveals or adjusted wall geometry, not arbitrary whole-model depth scaling. Make a backup and review actual wall thickness/openings in the build chat before integrating. Allow space above the cutout for the crest and curtain rod and to the sides for the gathered panels.

The frame is an open tunnel with no backing board. Each pane is clear geometry, not an opaque painted window. Exported glass is pale cool-tinted alpha-blended material (alpha 0.10); narrow dust strips are alpha 0.26 and leave pane centres clear. There is no refraction shader, exterior image texture or baked storm. Roblox may handle glTF transparency/materials differently: verify actual visibility and use native transparent Glass panes if preferable. Avoid stacking imported and native panes or retaining old opaque window decorations behind them. Neither glass nor curtains is emissive.

Curtains are opaque folded geometry, tied back and static, with separate edging, cords, rod and rings. There is no cloth simulation, sway, draw animation or sash-opening mechanic. Fine weave, realistic grime and detailed wear textures are future polish. Join static components by material for performance, especially the numerous dust-strip meshes; keep translucent panes separate from opaque frame/curtains. Per-assembly curtain geometry is about 4,604 triangles before joining.

## Build-chat handoff

Current PubDressing/PubExterior windows were decorative coloured/neon panels over tested solid walls when this asset task began. Merely placing these models over them will not create storm views. The build chat must make actual wall openings, remove/replace opaque decoration at those chosen sites, and review roofs, exterior sightlines, interior light and weather clipping. Do not blanket-replace map walls or existing windows from this asset script.

Use simple invisible collision geometry if windows must block escape; visual meshes and curtain folds should not snag characters. Preserve navigation routes and server sight/reach rules deliberately. Decide whether the monster can see through each pane rather than accidentally changing it through CanQuery settings. Rain clipping should retain queryable roofs and keep droplets outside; panes do not implement weather or roof logic. Check the view at avatar eye height, especially window-base placement relative to floors/cabinets. Native storm lightning can illuminate the scene during integration; no lighting or sound was added here.

## Verification and boundaries

Blender 5.2.3 LTS generated the components, asserted finite positive bounds, completed eight GLB exports and rendered the preview. Preview visually inspected. Saved-source geometry ray checks verified an unobstructed frame and present glass at every one of the fifteen pane centres. GLB binary headers/lengths, embedded buffers, finite transforms/accessors, absence of preview geometry and BLEND material alpha on both glass exports checked. Python syntax and git diff --check passed. tests/README.md reviewed.

Studio import transparency, wall fit, exterior storm visibility, rain exclusion, camera behaviour, monster sight/collision, navigation and keyboard/touch gameplay checks remain for the build chat. No game behaviour is claimed verified by the Blender preview.

Only assets/props/windows was changed. Existing assets, source artwork, gameplay scripts, maps and place files were preserved. Nothing uploaded or published.
