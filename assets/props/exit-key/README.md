# Brass emergency-exit key — first art pass

Original local Blender geometry implementing the approved large-bow brass-key design. No external models or textures. Narrative reference: docs/narrative.md, current key-based escape revision. This asset does not determine the key's spawn location or visibility.

- ExitKey.blend: editable model, separate named components.
- ExitKey.glb: embedded materials, floor-centred origin, flat key with shaft along X; glTF Y up.
- inventory-icon.png: 1024px transparent PNG rendered from the same geometry.
- preview.png: neutral lit model review; lighting is not exported.
- build.py: reproducible Blender script; regeneration overwrites generated outputs here.
- manifest.json: dimensions and mesh/triangle counts.

One Blender unit represents one Roblox stud. Import with scale unit Stud and verify the roughly two-stud length against an avatar. This is larger than the old 1.5-stud marker to improve readability. Keep visual mesh non-colliding and retain the existing server-authoritative pickup/visibility logic and prompt. A subtle in-game reveal highlight is an integration task, not baked into the model.

Solid brass materials have polished edges/recessed collar accents but no detailed wear texture; this is a first pass. Components intersect by design and can be joined/optimised for integration. No scripts, places, source artwork or existing work modified. No upload performed.

Checks: Blender 5.2.3 LTS completed dimensions assertions, GLB export and both renders. Images visually inspected, binary GLB structure checked and git diff --check passed. tests/README.md reviewed; Studio import, material appearance under game lighting, small-size icon readability and pickup/visibility/reset tests remain pending until integration.
