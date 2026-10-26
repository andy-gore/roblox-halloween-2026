# roblox-halloween-2026

## The Chuggernaught: Last Orders

Minimal local scaffold for Halloween 2026. No finished gameplay is implemented.

- [Setup and prerequisites](docs/SETUP.md)
- [Existing canonical narrative](docs/narrative.md)
- [Deadline scope](docs/SCOPE.md)
- [Local checks](tests/README.md)

Open `places/Halloween2026.rbxlx` as the new local Studio project. It contains only a baseplate and spawn. Install Rojo and sync `default.project.json` to add the code scaffold. Keep PumpkinTest.rbxl separate.

`src/server` maps to ServerScriptService/HalloweenServer; `src/client` to StarterPlayerScripts/HalloweenClient; `src/shared` to ReplicatedStorage/HalloweenShared. `assets/concepts` holds original approved art when supplied; `tools` documents development tools.

The narrative is present at its original lowercase path. Chuggernaught artwork is missing. Nothing here publishes or uploads to Roblox.
