# Local verification

No automated gameplay tests exist yet. Add focused tests when actual gameplay modules are implemented; no test framework is required for scaffolding.

After installing Rojo, run `rojo build default.project.json -o build/Halloween2026.rbxlx` (create build/ first). Open the generated file separately to check mappings. For the authored starter, sync into places/Halloween2026.rbxlx instead; building from this code-only configuration does not include its map.

In the local starter after syncing, press Play and check Output for the server readiness message and no errors. Stop and play again to verify startup is repeatable. Confirm HalloweenShared.Config is under ReplicatedStorage, server scripts under ServerScriptService and client scripts under StarterPlayerScripts.

Once gameplay exists: test objective ordering, invalid/repeated interactions, getting caught, restart, successful escape, and keyboard/touch UI. Keep all checks local.

## Prototype checks — 26 October 2026

Rojo 7.7.1 built both project configurations successfully. A temporary Studio Play session passed RunState ordering/duplicate/reset assertions, six prompt existence checks, initial server player state, and client HUD text replication. A second Play session also started a fresh run successfully. `RunState.spec.luau` contains repeatable state checks. The authored place was backed up under ignored `build/backups/` before runtime checks; runtime test objects were discarded on Stop.

The Output also contained asset-type errors for existing asset ID 203785492; no asset is referenced by this prototype code. Their origin is unverified.

Still required: full keyboard/touch playthrough, rejected distant interactions, capture and character reset during each objective, bell timeout/retry, successful theft and escape. Visual checks remain deferred: layout, HUD sizing on small screens, prompt visibility and chase feel. Direct chase ignores obstacles; proper navigation, cellar layout, character artwork and finale presentation are future work.

Build with `rojo build prototype.project.json -o build/LastOrdersPrototype.rbxlx`, open that file separately, and press Play. The standard default project intentionally leaves the greybox disabled.
