# Local verification

RunState.spec.luau contains focused state assertions for execution in Studio. Full gameplay checks remain manual.

After installing Rojo, run `rojo build default.project.json -o build/Halloween2026.rbxlx` (create build/ first). Open the generated file separately to check mappings. For the authored starter, sync into places/Halloween2026.rbxlx instead; building from this code-only configuration does not include its map.

In the local starter after syncing, press Play and check Output for the server readiness message and no errors. Stop and play again to verify startup is repeatable. Confirm HalloweenShared.Config is under ReplicatedStorage, server scripts under ServerScriptService and client scripts under StarterPlayerScripts.

Once gameplay exists: test objective ordering, invalid/repeated interactions, getting caught, restart, successful escape, and keyboard/touch UI. Keep all checks local.

## Prototype checks — 26 October 2026

Rojo 7.7.1 built both project configurations successfully. A temporary Studio Play session passed RunState ordering/duplicate/reset assertions, six prompt existence checks, initial server player state, and client HUD text replication. A second Play session also started a fresh run successfully. `RunState.spec.luau` contains repeatable state checks. The authored place was backed up under ignored `build/backups/` before runtime checks; runtime test objects were discarded on Stop.

The Output also contained asset-type errors for existing asset ID 203785492; no asset is referenced by this prototype code. Their origin is unverified.

Still required: full keyboard/touch playthrough, rejected distant interactions, capture and character reset during each objective, bell distraction expiry/reuse and key-based escape. Visual checks remain deferred: layout, HUD sizing on small screens, prompt visibility and chase feel. The original direct chase and single-room markers have since been replaced; see the layout checks below. Character artwork and finale presentation remain future work.

Build with `rojo build prototype.project.json -o build/LastOrdersPrototype.rbxlx`, open that file separately, and press Play. The standard default project intentionally leaves the greybox disabled.


## Revised loop — 27 October 2026

The user confirmed the revised key-based loop worked before the pub layout changes. That does not verify the new layout.

- On a fresh run, confirm OfficeKey is invisible, non-colliding and has no enabled pickup prompt. Attempting to collect it before restoring the lights must not grant the key.
- Read the warning and restore the lights: the key and its prompt appear, and the monster wakes. The fuse box is now below ground in the cellar; lamps brighten when power is restored.
- Collect the key while hunted: its world marker/prompt disappear and HasExitKey becomes true. Unlock the exit without ringing the bell or taking a tankard; victory must stop pursuit.
- Ring the bell before and after collecting the key: it must distract without advancing objectives or removing inventory. After the distraction expires, pursuit resumes. Ringing again must work.
- Capture/reset before power, after power and after key pickup: confirm the key is hidden, its prompt disabled, inventory cleared and objectives restarted. Repeat a successful run.
- Check distant/repeated/out-of-order interactions and keyboard/touch prompts. Run RunState.spec.luau in Studio to check ordering, terminal victory and fresh state.


## Compact pub layout — 27 October 2026

- Backups made under ignored build/backups/ before layout work; places/Halloween2026.rbxlx is unchanged. Geometry changes are confined to the disposable prototype configuration.
- Studio Edit-mode fixture checks passed for initial hidden/unavailable key and RunState ordering, duplicate rejection and terminal victory. Five walking paths succeeded: cellar → bar, bar → office, office → exit, bar → snug, hall → kitchen.
- Final Studio fixture traversal passed all six destinations (bar, office, exit, snug, kitchen, cellar) with no wall/partition overlaps. Both Rojo builds and git diff --check passed; the saved layout and navigation specs were executed in isolated fixtures and removed afterwards.
- PubLayout.spec.luau repeats the hidden-key and walking-route checks in a temporary offset fixture and removes it afterwards. MonsterNavigation.spec.luau checks actual traversal through the bar, office, exit, snug, kitchen and back down the stairs, rejecting wall/partition overlaps. RunState.spec.luau remains the separate objective-state check.
- Manual Play checks still required: descend/ascend stairs with keyboard and touch; restore power; avoid the pursuing monster through doorways; collect the office key from the desk; use/expire/reuse the bell; unlock the physical door; capture/reset and a second complete run. Check Output, HUD sizing and readable lighting from player height.
- The placeholder follows a fixed room/stair route graph, checking its full body against walls and furniture before moving. Engine pathfinding found routes but clipped corners during traversal, so it is not used for pursuit. It remains an anchored block, not the final rig/animations. The roof, exterior arrival/car finale, storm/audio and full narrative presentation remain unfinished.

The fixed route graph is specific to PrototypeMap geometry. Re-run both layout and navigation checks after changing room boundaries, stairs or furniture. Studio Script Analysis and a complete player-controlled playthrough remain required.


## Stair visibility and signs — 27 October 2026

The connected authored starter's 128×1×128 baseplate covered the runtime cellar opening. The greybox startup now hides and disables only that exact starter plate in Play; Stop restores it. The authored geometry is retained. Signs now use bright, high-contrast text on both faces; stairs have illuminated tread edges and a permanent safety light.

Backed up connected Studio script sources under build/backups/Studio-before-stair-sign-fix.json before updating PrototypeMap and Main only. Both Rojo builds and diff checks passed. A Studio Play check confirmed sixteen treads, two sign faces, the disabled baseplate and a downward ray reaching a cellar step instead of the baseplate. Full player stair traversal and small-screen sign readability still need manual verification.

## Warning interaction regression — 27 October 2026

The waist-height server visibility ray hit the bar when standing close to the warning. Interaction visibility now starts at the character's head (or two studs above the root if no head exists); distance and wall rejection remain server-side. Blocked visibility now supplies feedback instead of silently returning.

Studio Play regression passed: placed the player at the close front of the bar, used the normal client ProximityPrompt InputHoldBegin/InputHoldEnd API, and verified stage 2 plus the canonical warning message. A geometric check reproduced the old Bar obstruction, confirmed eye-level visibility, and confirmed OfficeSnugPartition still blocks a through-wall approach. Rojo synced the change before the guarded manual source update, so that redundant update was skipped. Both builds and git diff --check passed; Play was stopped afterwards. Manually repeat with keyboard E and touch input, then check the bell and office key.
