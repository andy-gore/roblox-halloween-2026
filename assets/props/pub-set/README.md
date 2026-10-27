# Pub prop set — first art pass

Original locally generated geometry for The Crooked Tankard, based on the narrative's blocky Roblox style and existing prototype measurements. No external artwork, textures or dependencies. This set does not establish a canonical character/environment design.

- PubProps.blend: editable table, chair and barrel in separate collections, staged together for review.
- PubTable.glb, PubChair.glb, CellarBarrel.glb: individual exports with floor-centred origins, Y-up glTF convention, embedded flat materials; no external textures.
- preview.png: Blender render (preview lighting is not baked into models).
- manifest.json: measured Blender dimensions, mesh counts and triangle counts.
- build.py: reproducible Blender generation script. Run `/Applications/Blender.app/Contents/MacOS/Blender --background --python assets/props/pub-set/build.py` from the repository root. Regeneration overwrites this set's generated outputs.

One Blender unit represents one Roblox stud. In Studio's importer, use Stud as the scale unit and verify dimensions before placing. Expected Roblox X/Y/Z sizes: table 7/3/5.97, chair 2.5/4.4/2.37, barrel 4/4/4. The table matches the existing PubTable footprint/height; the barrel replaces a nominal four-stud-tall horizontal cylinder placeholder. The chair is a new prop with a seat top at two studs. The chair's back is toward Blender +Y (glTF -Z).

Keep geometry anchored. Decide collision proxies during integration; individual decorative components should not obstruct traversal. Do not replace greybox collision blocks blindly or place chairs in escape routes. Compare scale with a player avatar and test monster clearance before integration. Preview materials are solid colours with small bevels, not detailed aged-wood textures; weathering is a later pass.

Validation: Blender 5.2.3 LTS completed generation, GLB export, dimension assertions and preview rendering; preview visually inspected. GLB binary headers and mesh references checked locally. No gameplay scripts or place files changed, no upload performed. Studio import, material appearance, collisions and full keyboard/touch gameplay checks from tests/README.md remain unverified. These assets are not yet integrated into the map.
