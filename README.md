# The Chuggernaught: Last Orders

Local Halloween 2026 prototype. Original artwork is preserved; approved gameplay revisions are recorded in the narrative.

Build the separate playable greybox:

```sh
rojo build prototype.project.json -o build/LastOrdersPrototype.rbxlx
```

Open `build/LastOrdersPrototype.rbxlx` separately in Studio and press Play. Read the warning, restore the lights, find the newly visible key while being hunted, and unlock the emergency exit. The bell is an optional distraction; tankard theft is not required. Getting caught resets the run; Roblox Reset Character also restarts. Use the standard proximity prompts with keyboard, controller or touch.

The expanded pub includes a main bar, snug, office, kitchen, a larger entrance lounge, a cellar sixteen studs below ground, and eight upstairs bedrooms with four on either side of a central corridor. Both staircases are walkable. The Chuggernaught now uses the original character/tankard geometry in one local skinned mesh, with nine procedural joints for idle, walking, chasing and chugging. His original 4×8×4 server proxy still controls navigation/capture. Restoring power triggers a short cellar reveal, followed by pursuit; periodic drinks pause him and add a capped speed boost. Footsteps and drinking use bundled Roblox sounds; the signature reveal line is captioned, not voiced. Lamps brighten when power is restored, and the physical exit door opens on escape. A first gothic visual pass adds a vaulted slate roof, dark oak framing, pointed stained-glass panels, a stone fireplace, candles and burgundy-cushioned furniture. Original Blender furniture and prop meshes now render locally with shared fixed-size templates; existing Part collision proxies remain authoritative. Twelve clear storm-view windows, bedroom details and sparse cobwebs are integrated without asset uploads. See [asset integration](docs/ASSETS.md). Night lighting applies only while the greybox runs. This is not finished character art or narrative presentation. The server chooses one key location per run from the eight bedrooms and office; it is hidden and cannot be collected until the lights are restored. Capture/reset hides it again. Reset on capture remains provisional.

The stormy exterior adds a wet country road, a broken-down hatchback with raised bonnet and hazard lamps, warm gothic windows, a hanging pub sign and surrounding woodland. Client-only rain is clipped against roofs; occasional lightning and bundled placeholder storm audio provide ambience. The initial spawn and escape objective remain unchanged; the arrival and drive-away sequences are still to be connected.

`places/Halloween2026.rbxlx` remains the authored starter. `default.project.json` syncs code only and does not enable the runtime greybox. The separate `prototype.project.json` enables it with a Workspace attribute. Never replace the authored place with generated build output.

- [Setup](docs/SETUP.md)
- [Canonical narrative](docs/narrative.md)
- [Scope](docs/SCOPE.md)
- [Checks and remaining playtest](tests/README.md)
