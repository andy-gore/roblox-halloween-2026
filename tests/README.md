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


## Gothic visual pass — 27 October 2026

The user confirmed the complete layout worked before this pass. Added local Part-based furniture derived from the existing pub-set recipes, dark oak framing, pointed stained-glass panels, a vaulted slate roof, burgundy cushions, candle chandeliers, stair rails and a stone fireplace. Original GLB/Blender assets and moodboard are unchanged; no mesh or texture uploads. The existing furniture blocks remain as invisible collision proxies. Decoration is anchored/non-colliding/non-queryable except the roof, which remains queryable for the camera. Night lighting and post-processing apply only in greybox Play, and Stop restores editor settings.

Both Rojo builds and git diff --check passed. A Studio fixture verified decorative collision/query settings; the layout and six-destination monster traversal specs passed with the visual pass present. Test fixture offsets now include nested decorative parts. Later stair rails use the same non-colliding/non-queryable helper and do not change walking routes. Temporary review geometry and lighting were removed/restored after checks.

Screen capture and native-app preview timed out. Final rendered appearance, small-screen readability, camera behaviour beneath the roof and a player-controlled Play walkthrough remain unverified. Next manual check: view the bar, snug/fireplace, office and cellar before/after restoring power; confirm warning/bell/key prompts, stairs, capture/reset and escape.

## Customer-facing note — 27 October 2026

Moved the warning from the bar top onto the customer-facing bar panel, clear of both the counter and decorative top. The note now has printed text and a labelled Read note prompt. Camera line-of-sight is disabled for this prompt only; server eye-level visibility, proximity, player identity and health checks remain. Rereading displays the warning without advancing objectives again.

Studio Play verified first read and reread through the normal client prompt API, with server and client stage/message assertions. Allow character replication to settle after teleporting before triggering the prompt; an immediate first test raced that replication. Sight rays at three avatar heights reached the note, and a wall still blocked a through-wall ray. Both Rojo builds and whitespace checks passed. Test Play sessions were stopped; source changes are synced to the connected local Studio project. Keyboard/touch manual input and final text appearance remain user checks.

## Eight-bedroom expansion — 27 October 2026

Approved scope: a larger downstairs entrance lounge, one upper corridor with four guest bedrooms on each side, and a single key chosen from the eight bedrooms or office per run. KeyPlacement chooses only on run reset; restoring power reveals the existing choice. The key and prompt remain hidden/disabled before power and after pickup/reset. The HUD now asks players to search the bedrooms and office.

The new flight has seventeen broad treads, solid stair/landing guards, a clear first-floor opening and a raised roof. Bedroom furniture uses local Parts; existing Blender/GLB artwork is unchanged. Both the original cellar and exit remain in place. Backups are under ignored build/backups/; places/Halloween2026.rbxlx was not replaced. Runtime map changes are confined to the enabled greybox.

Checks passed:
- Both Rojo configurations build; git diff --check is clean.
- ExpandedPub.spec.luau verified eight furnished bedrooms, all nine distinct key spots, hidden state while choosing, every navigation edge's body clearance, and actual monster traversal through all eight bedrooms, downstairs office, emergency exit and back into the cellar without wall/partition overlaps.
- PubLayout.spec.luau now also checks walking paths to all eight rooms, with jumping disabled; all ground-floor and bedroom paths passed in Studio.
- Studio Play client prompt checks passed for reading the warning, restoring power, collecting an upstairs key, escaping and character reset. Assertions verified the key remained at its initial chosen position through warning/power, appeared only after power, granted inventory, unlocked the exit and became hidden with cleared inventory after reset.
- The staircase approach was routed around the existing table, guard ends shortened to clear the landing, and free corner-cutting removed from pursuit. Upper-body floor casts prevent shortcuts through stairs or between storeys.

Temporary test fixtures were removed and the local Play session stopped. Still required: full keyboard/touch walking playthrough of the larger layout, visual checks of upstairs signs/lighting and landing camera clearance, capture on the guest stairs/in a bedroom, and search/chase pacing across multiple random-key runs. The placeholder monster remains unanimated. Do not rerun the older initial warning-atop-counter geometry regression: the note is now customer-facing.


## Bedroom furniture collision and surface cleanup — 27 October 2026

User identified walking through upstairs furniture. Expanded the bed collider to cover the mattress/blanket height, made the headboard a solid navigation obstacle and set CanCollide explicitly on structural furniture. All eight beds, headboards, dressers and wardrobes were checked anchored and collidable; every monster route edge retained clearance. ExpandedPub.spec.luau now checks one solid piece of each furniture type per room.

In a local Studio Play session, disabled default input temporarily and used the actual player Humanoid MoveTo against a room-1 wardrobe, dresser, headboard and bed. The avatar stopped outside each piece rather than reaching the far side. Controls were restored and Play stopped afterwards. Other bedrooms use the same furniture construction. Repeat manually at any additional reported locations.

Also removed duplicate end treads over the ground floor/upper landing, trimmed the lounge roof back to the main roof seam, and lowered bottle shelves clear of the pub sign. Navigation nodes and key locations are unchanged. Both Rojo builds and git diff --check pass. Screenshot/render verification of those surface overlaps remains unavailable; a manual visual check is still required.
