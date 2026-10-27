# The Chuggernaught: Last Orders

Local Halloween 2026 prototype. Original artwork is preserved; approved gameplay revisions are recorded in the narrative.

Build the separate playable greybox:

```sh
rojo build prototype.project.json -o build/LastOrdersPrototype.rbxlx
```

Open `build/LastOrdersPrototype.rbxlx` separately in Studio and press Play. Read the warning, restore the lights, find the newly visible key while being hunted, and unlock the emergency exit. The bell is an optional distraction; tankard theft is not required. Getting caught resets the run; Roblox Reset Character also restarts. Use the standard proximity prompts with keyboard, controller or touch.

The first pub greybox includes a main bar, snug, office, kitchen, connecting hall and a cellar sixteen studs below ground with walkable stairs. The monster remains a coloured placeholder but follows fixed server-controlled routes through the rooms, with body-sized obstruction checks. Lamps brighten when power is restored, and the physical exit door opens on escape. The roof is intentionally omitted for layout review. This is not finished character art or narrative presentation. The key is hidden and cannot be collected until the lights are restored. Capture/reset hides it again. Reset on capture remains provisional.

`places/Halloween2026.rbxlx` remains the authored starter. `default.project.json` syncs code only and does not enable the runtime greybox. The separate `prototype.project.json` enables it with a Workspace attribute. Never replace the authored place with generated build output.

- [Setup](docs/SETUP.md)
- [Canonical narrative](docs/narrative.md)
- [Scope](docs/SCOPE.md)
- [Checks and remaining playtest](tests/README.md)
