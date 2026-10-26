# Local verification

No automated gameplay tests exist yet. Add focused tests when actual gameplay modules are implemented; no test framework is required for scaffolding.

After installing Rojo, run `rojo build default.project.json -o build/Halloween2026.rbxlx` (create build/ first). Open the generated file separately to check mappings. For the authored starter, sync into places/Halloween2026.rbxlx instead; building from this code-only configuration does not include its map.

In the local starter after syncing, press Play and check Output for both scaffold-ready messages and no errors. Stop and play again to verify startup is repeatable. Confirm HalloweenShared.Config is under ReplicatedStorage, server scripts under ServerScriptService and client scripts under StarterPlayerScripts.

Once gameplay exists: test objective ordering, invalid/repeated interactions, getting caught, restart, successful escape, and keyboard/touch UI. Keep all checks local.
