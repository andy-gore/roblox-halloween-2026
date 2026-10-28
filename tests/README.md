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


## Chuggernaught runtime rig and encounter — 27 October 2026

Original GLB/Blender files and artwork are unchanged. tools/export_chuggernaught.py converts the full original 6,449 triangles, vertex normals and flat colours into shared mesh data, with source checksums. The client creates one skinned EditableMesh with nine rigid-weight bones. Separate meshes per limb exceeded the tested client budget; the single-mesh version passed in local Play. If mesh creation fails, a simple Part-based rig remains available and the client model records MeshError. No meshes, animations or audio were uploaded.

The unchanged anchored 4×8×4 server proxy owns navigation and capture. Presentation follows it with interpolation and local joint poses; visual geometry has no collision/query participation. Server MonsterEncounter controls dormant/reveal/hunt/chug/distracted/stopped modes. Power triggers a 3.5-second reveal before pursuit; drinks pause him for 2.8 seconds at 12-second hunt intervals and add 0.5 speed per completed drink, capped at three boosts. The bell interrupts drinking. Capture/reset clears progression. The key's random room/reveal rules are unchanged.

Checks passed:
- Both Rojo configurations build and git diff --check passes.
- MonsterEncounter.spec.luau verifies reveal timing, pursuit, drinking pauses, bell interruption, stopped state, speed cap and reset using controlled time.
- ExpandedPub.spec.luau passed all eight bedrooms, office, exit and cellar with the transparent server proxy, including collision and key-location assertions.
- Local Studio Play loaded the actual single MeshPart with nine bones and all 6,449 triangles; ChuggernaughtRig.spec.luau verified collision/query isolation, finite poses and tankard-handle contact through a full chug cycle. Dormant presentation was hidden.
- Client prompt interaction restored power; the original mesh became visible during Reveal, then server pursuit started with LAST ORDERS text. Bundled footstep and water/drinking sounds loaded. Capture reset the run to stage 1, Dormant mode and zero drink count.
- A neutral Blender QA render used actual sampled game pose CFrames and exact exported geometry; idle/hunt/chug poses were visually inspected. The first sandboxed Blender launch failed during Metal device detection; the same local render succeeded outside the sandbox. This image is a pose preview, not an in-game screenshot.

Temporary test fixtures were removed and Play stopped. Manual checks still required: visual appearance inside the pub, animation/foot placement around furniture and both staircases, chase pacing after several drinks, touch/small-screen captions and low-memory clients. LAST ORDERS is captioned, not voiced; glug/footstep cues use bundled Roblox sounds. Published-experience mesh API permissions, final uploaded animation/voice assets and deployment remain outside this local prototype task.


## Live skin animation correction — 27 October 2026

The first mesh implementation changed EditableMesh:SetBoneCFrame, which edits bind-pose data rather than animating the rendered skin. This left the character rigid and the tankard at its original position despite valid offline pose maths. The correction creates nine named Bone instances under the MeshPart, matching the embedded mesh bone names. Their bind CFrames stay fixed; Bone.Transform now drives the live skin.

Studio Play verified nine actual Bone instances, the tankard grip beside the right fist, and tankard rotation during the power-triggered reveal. During Hunt, the live leg Transform changed by more than 0.6 radians across sampled frames, while the live tankard/hand grip error stayed below 0.001 studs. These measurements use Bone.TransformedWorldCFrame and Bone.Transform rather than generated pose tables. The client regression spec now requires the live bones and real hand/tankard attachment, which would fail the original implementation. Both Rojo builds and git diff --check passed. Play was stopped afterwards. Manual visual checks of gait and in-pub clipping remain useful.


## Stormy exterior — started 27 October 2026

Added local scenery around the existing L-shaped pub: split countryside ground, wet road/layby, exit courtyard and front path, broken-down car, gothic frontage/windows, hanging sign, gables, chimneys, fixed woodland and fences. Car body/cabin/wheels are solid; frontage decoration is non-colliding. Terrain never fills the cellar footprint. Existing spawn, objectives, key choices, NPC navigation and door logic are unchanged. Arrival and drive-away gameplay remain future work.

Storm.client and StormRain provide a bounded local rain pool (100 desktop/64 touch), roof-clipped columns, muffled indoor water ambience, mild occasional lightning, low-volume bundled impact cues, hazard blinking and gentle sign sway. Sounds are bundled placeholders; no asset uploads. Rendering/weather do not control game state.

Checks passed: both Rojo builds and git diff --check; PubExterior.spec.luau verified car collision, hidden key/nine locations, original spawn, open cellar stairs, queryable roofs, unchanged monster route clearance, and walking routes exit→car→frontage without jumping. Studio Play verified 100 non-colliding rain streaks staying above roof/ground stops, moving rain, sign sway, loaded rain/thunder clips and unchanged stage 1 while inspecting the exterior. Play stopped afterwards.

The user's modified places/Halloween2026.rbxlx was backed up under build/backups/ before this work and preserved byte-for-byte. Temporary test/render scenes were removed after use. A neutral night preview of exported Studio geometry was rendered and visually checked; it is not an in-game screenshot. Manual checks remain: exterior lighting/readability in game, thunder timing/volume, touch performance, door/path transitions and the saved authored place after the next normal sync. No live experience was modified.

## Hunt and escape routes — 28 October 2026

Approved scope is the hunt and layout refinement only. Objectives, all nine random key spots, power-triggered key visibility and key-only exit remain unchanged. No breaker puzzle, second antagonist or exterior finale was added. Saved authored place and original artwork are preserved; backups are in ignored build/backups/hunt-review-20261028/.

Server MonsterHunt uses bounded sight, fixed bell sounds and last-seen memory for Patrol, Investigate, Chase and Search. MonsterSenses uses real collidable geometry to block sight and reach through walls/floors. MonsterGrab provides a 0.5-second visible windup and 0.9-second recovery after a miss. Walking through the monster's central body during a grab commits capture; dodging around him works. Capture remains active during drinking and investigation. The bell has an 18-second server cooldown with a client countdown; a visible player overrides its sound. Chase starts at 17.5 studs/sec versus default player speed 16; patrol is 9.5, investigation 12 and search 10.5. Drinks now occur at 20-second intervals and retain the existing bounded boosts. These are initial playtest values.

StaffStairs adds an enclosed rear stair and ground-level return passage between the north end of the upper corridor and kitchen. Both floors have labelled entrances. Rooms 1 and 2 share one open adjoining doorway; the remaining six keep single entrances. Native geometry, collision, rails, roof, lanterns and monster route graph are included. No Studio-authored Workspace geometry was replaced.

Passed in local Studio:

- MonsterEncounter.spec.luau: reveal, drinks, interruption, bounded speed, stop/reset with controlled time.
- MonsterHunt.spec.luau: unseen-player isolation, last-seen search/expiry, patrol, bell priority/cooldown/reuse/reset, grab windup/dodge/recovery/capture, central-body bypass rejection and drink interruption.
- MonsterSenses.spec.luau: actual frontal/peripheral rays, reach/contact, rear approach, walls, storey separation and sight range.
- EscapeRoutes.spec.luau: player walking paths and actual monster traversal through the staff stair in both directions with the main stair blocked; adjoining bedroom traversal in both directions with corridor doors blocked; every normal route edge clear and annex roof queryable. Fixtures removed. For repeat tests after editing modules, use fresh module clones or a new Play session to avoid Studio's require cache.
- Existing RunState, PubLayout (all eight bedrooms), ExpandedPub (furniture, nine key locations and actual pursuit) and PubExterior specs.
- Actual player avatar walked from kitchen to the upper corridor and back through the staff stairs without jumping or getting stuck. Controls were restored.
- Normal client prompt interactions advanced warning/power, revealed the key, and exercised a repeated bell ring without refreshing ReadyAt. An unseen upstairs player produced Patrol; a visible player overrode bell investigation with Chase; moving behind a bedroom wall produced Search.
- A natural drinking pause was interrupted by a live grab/capture, resetting objectives, inventory, drink count and bell cooldown. A separate live side dodge produced Recover without capture. The player then collected the actual random key and escaped, reaching stage 5 and Stopped without another requirement.
- ChuggernaughtRig.spec.luau passed in Play with the original mesh. The actual grab rotated the live left upper-arm bone by 1.45 radians, displayed its warning caption and kept tankard/hand grip error below 0.001 studs.

Both Rojo builds and git diff --check pass. Temporary fixtures and Play sessions were removed/stopped. Script Analysis CLI is not installed; no standalone static Luau analysis was run. Existing asset-type errors for unrelated asset 203785492 remain in Studio Output; no new gameplay script errors appeared during these checks.

Review manually with keyboard and touch: grab reaction time, whether sight breaks feel fair, whether straight chases close the gap sufficiently, signs/camera/head clearance on the staff stair, and escapes through rooms 1/2 with the monster following. A full unassisted playthrough and difficulty tuning remain human playtest checks; scripted movement does not establish that the game feels balanced.

## Pursuit intelligence — 28 October 2026

Playtest feedback: a quick corner or circuit of the new loop lost him too easily. The refinement keeps chase speed for 1.25 seconds after losing sight and then searches for up to 18 seconds at 14.5 studs/sec. Search plans follow the last witnessed movement direction and inspect up to three distinct nearby escape branches. He checks rooms and landings instead of pausing mid-stair. Observed direction is sampled across replicated position bursts, so network cadence does not erase his heading estimate. An alert monster has wider vision and a 14-stud peripheral range; actual walls and floors still occlude it.

Fast grounded footsteps (at least 10 studs/sec) provide sampled sound positions: up to 28 studs in open space, reduced to 12 through an interior wall, within the same floor level. Standing still supplies no new sound trail. The server samples sounds at most every 0.9 seconds. Footsteps can redirect investigation/search; a visible player still takes priority over the bell. The reveal hint and sound feedback explain keeping quiet. No new control, enemy, objective or speed boost was added.

MonsterRoutes replaces edge-count routing with actual walking-distance costs, making existing shorter connections useful. MonsterNavigation pursues directly when full-body and floor casts confirm a clear same-level approach; it no longer walks back to a graph marker behind itself before chasing through clear space. Hidden player positions are not inputs to route prediction: plans use remembered sightings, witnessed heading and the fixed pub graph, refreshed only by valid new sights or sounds.

Checks passed:

- Extended MonsterHunt.spec.luau: corner memory, directional branch searches, alternate-exit inspection, finite alert expiry/reset, sampled sound retargeting, silent unseen-position isolation and heading preservation with bursty replicated movement. Existing bell/grab/drinking checks retained.
- Extended MonsterSenses.spec.luau: alert rear reacquisition, wall/floor occlusion, real grounded fast/quiet motion, distance limits and wall-muffled footsteps.
- MonsterRoutes.spec.luau: shorter physical walk versus fewer graph edges, reversed paths, distinct direction-ranked exits and disconnected nodes.
- MonsterIntelligence.spec.luau: direct pursuit/reversal in real geometry, alternative corridor search exits and a search down the full guest stairs to a landing.
- EscapeRoutes.spec.luau and ExpandedPub.spec.luau: both new connections and the existing full furnished pub remain traversable by the monster, with no tested wall/furniture overlaps.
- Live Play: retained Chase behind a verified bedroom obstruction, transitioned to Search and continued to approximately z=27 after the last sighting at z=15; reacquired a player looping ten studs behind. A separate actual avatar MoveTo at 16 studs/sec behind him, initially outside his sight, made him turn and resume Chase from the sound trail. Silent stationary/out-of-range player positions did not supply a new target in the isolated checks.
- Normal client key pickup and emergency-exit interaction still completed stage 5 with the monster Stopped. Local Play ended and controls/fixtures were restored.

Both Rojo configurations and whitespace checks pass. Standalone Luau Script Analysis remains unavailable. Human review still needs to establish chase fairness, whether players understand the footstep cue, quiet hiding opportunities and difficulty on keyboard/touch. This was a local refinement; the saved authored place and original artwork were preserved and no live experience was modified.
