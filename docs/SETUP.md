# Local setup

## Observed 26 October 2026

- Roblox Studio exists at /Applications/RobloxStudio.app; its StudioMCP executable exists.
- Studio MCP successfully listed an unrelated open PumpkinTest.rbxl session. It was not modified. A successful listing verifies connectivity, not this project's setup.
- rojo, luau, luau-analyze, stylua, selene, aftman and rokit were not on PATH in this session. No tools were installed. Rojo Studio plugin installation has not been verified.
- Existing docs/narrative.md was preserved. No Chuggernaught artwork was found in the repository.

## New local Studio project

Open places/Halloween2026.rbxlx in Studio. This is a new local starter with only a baseplate and spawn; it has no experience/place ID and no gameplay. Save locally. Do not use PumpkinTest.rbxl. The starter is an authored map, separate from generated build output.

## Rojo

Install a Rojo 7 CLI binary from the official releases and put it on PATH, then verify `rojo --version`. Alternatively follow the official Rokit instructions. Install the matching Studio plugin using `rojo plugin install`, then restart Studio if needed.

From the repository root run:

```sh
rojo serve default.project.json
```

In the new local starter, open the Rojo plugin and connect to localhost port 34872. Review the proposed changes before syncing. The project maps only HalloweenServer, HalloweenClient and HalloweenShared under their respective services; Workspace is left for Studio authoring. Save the local place after map edits. Rojo sync is not publishing.

For a disposable code-only build:

```sh
mkdir -p build
rojo build default.project.json -o build/Halloween2026.rbxlx
```

This build excludes the Studio-authored map. Never replace the authored starter with it. Follow tests/README.md for local checks. Build and runtime checks were not run during scaffolding because Rojo was unavailable.

## Luau and optional tooling

Roblox Studio supplies Luau and Script Analysis. Standalone `luau` and `luau-analyze` are available from Luau releases; the latter needs appropriate Roblox definitions to analyse engine-dependent code. StyLua and Selene are optional, not deadline prerequisites. Select and pin compatible tool versions when installing; none are guessed here.

## Studio MCP

In Studio: Assistant → … → Manage MCP Servers → Enable Studio as MCP server. Use the displayed client connection instructions. On this Mac the server executable is `/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`. List connected instances and identify the new Halloween2026 local file before any future inspection or edit. No Studio mutation or live publishing was performed during scaffolding.

## Official references

- https://rojo.space/docs/v7/getting-started/installation/
- https://rojo.space/docs/v7/getting-started/new-game/
- https://github.com/rojo-rbx/rojo/releases
- https://luau.org/getting-started/
- https://github.com/luau-lang/luau/releases
- https://create.roblox.com/docs/studio/mcp
