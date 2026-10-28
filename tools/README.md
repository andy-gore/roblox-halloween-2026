# Development tools

See [setup](../docs/SETUP.md). No deployment scripts or credentials are included. Rojo CLI and Studio plugin are separate installations. Do not run rojo init in this existing repository.

Optional later: StyLua for formatting, Selene for Roblox-aware linting, and a pinned tool manager once versions are chosen. Standalone luau-analyze needs Roblox definitions for engine APIs; Studio Script Analysis is the initial check for Roblox scripts.


## Chuggernaught local rig

Run `python3 tools/export_chuggernaught.py` to regenerate the shared mesh data from the unchanged character/tankard GLBs. This uses Python's standard library and makes no network requests. Runtime presentation uses one client-local skinned mesh; server movement, capture and encounter modes remain authoritative.

For a QA render, run tools/capture_chuggernaught_poses.luau in the Studio Edit Command Bar and save its JSON to ignored build/chuggernaught-pose-frames.json. Then run Blender with `--background --factory-startup --python tools/render_chuggernaught_rig.py`. The render uses the game module's sampled joint frames and exact generated geometry; it is a neutral pose preview, not a game screenshot. It never saves over the original Blender source or GLBs.


## Exterior QA preview

`render_exterior_preview.py` renders a temporary Studio part export from ignored `build/exterior-scene.json` into `build/Stormy-exterior-preview.png`. The export contains part names, sizes, CFrames, colours, materials, alpha and primitive shapes, plus PointLight positions. It is an optional local Blender QA helper, not part of the game build. Its night lighting and rain are review staging; the image is not a Roblox screenshot. It does not save over the authored place or source artwork.
