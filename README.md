# The Chuggernaught: Last Orders

Local Halloween 2026 prototype. Original narrative and artwork remain unchanged.

Build the separate playable greybox:

```sh
rojo build prototype.project.json -o build/LastOrdersPrototype.rbxlx
```

Open `build/LastOrdersPrototype.rbxlx` separately in Studio and press Play. Read the warning, restore power, find the key, ring the distraction bell, steal the tankard and use the emergency exit. Getting caught resets the run; Roblox Reset Character also restarts. Use the standard proximity prompts with keyboard, controller or touch.

The monster is a coloured block with a simple direct chase; the cellar fuse box and office key are markers in one room. This is a mechanics prototype, not the finished pub, character art or narrative presentation. The bell distraction and reset on capture are provisional gameplay decisions.

`places/Halloween2026.rbxlx` remains the authored starter. `default.project.json` syncs code only and does not enable the runtime greybox. The separate `prototype.project.json` enables it with a Workspace attribute. Never replace the authored place with generated build output.

- [Setup](docs/SETUP.md)
- [Canonical narrative](docs/narrative.md)
- [Scope](docs/SCOPE.md)
- [Checks and remaining playtest](tests/README.md)
