# The Chuggernaught — first modelling pass

Reference: ../../concepts/The Chuggernaught_ Last Orders Moodboard.png, supplied in the project by the user. Character front/side/back views and the key-prop panel guide this model; incidental narrative text in the image does not override docs/narrative.md. Original reference remains untouched. No external models, textures or dependencies.

Files:
- Chuggernaught_FirstPass.blend: editable static character and separate tankard collections.
- Chuggernaught_FirstPass.glb: character only, feet at ground level, front -Z in glTF.
- Tankard_FirstPass.glb: separate tankard, with its vessel centred on the ground origin (handle extends sideways).
- preview.png and preview-back.png: neutral Blender review renders; lighting is not exported.
- manifest.json: measured Blender XYZ dimensions and triangle counts.
- build.py: reproducible Blender script; regeneration overwrites this folder's generated files. Run with Blender --background --python assets/characters/chuggernaught/build.py.

One Blender unit represents one Roblox stud. Character dimensions in Roblox XYZ are approximately 5.12 x 8 x 2.11 studs; height matches the current eight-stud placeholder, but visual width is greater. Do not replace its collision/navigation settings with the character's full visual bounding box without testing doorways and stairs. Studio scale unit should be Stud; verify against an avatar before integration.

This is a deliberately simple first art pass with solid materials and separate components. It is not rigged, skinned or animated, and the tankard is displayed separately rather than gripped. The jacket, stains and clothing tears are simplified geometry, not final weathered textures. Facial expression is static. Separate components make edits possible but are not an engine-ready hierarchy; optimise/join suitable components and build a rig during a later pass. The tankard is closed and its bands are solid, suitable for exterior views only.

Validation: Blender 5.2.3 LTS completed both GLB exports, dimension/height checks and front/back rendering. Renders visually inspected; embedded GLB structure checked. Git diff whitespace check passed. tests/README.md reviewed: gameplay checks remain pending because no scripts/place files were changed and this model has not been imported or integrated. Nothing published or uploaded. Original artwork and concurrent gameplay work preserved.
