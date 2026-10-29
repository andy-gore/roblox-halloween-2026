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

## Expanded cellar and breaker puzzle — 28 October 2026

CellarMap replaces only the generated cellar, keeping the original stairs/opening. The underground floor is now 48 by 74 studs, with a west-wall maintenance panel, wide passages around a solid barrel rack, clear stair landing and a far reveal position approximately 42 studs from the main lever. The rack's upper shelf is open for the head/tankard reveal. Ceiling pieces cover the new area without sealing the stairs. Existing pub/bedrooms/key locations and authored Workspace geometry are preserved. Backups are under ignored build/backups/cellar-puzzle-20261028/.

BreakerSequence owns the fixed Cellar -> Guest Rooms -> Bar order and final main-lever completion. CellarPower owns switch poses, indicators, progress attributes, remote lamp, shifting crate and bundled clunk/thud/glug cues. Main validates active player, living character, distance, eye-level visibility and stage before panel actions. Partial progress cannot wake the monster or reveal the key. Wrong/repeated circuits reset the sequence without damage; an early main lever preserves progress and explains the order. Completion advances the existing power objective once. Capture/character reset clears circuit progress, lever/indicator state, sounds, crate tween and cue light. A printed/readable maintenance card also gives the order in the HUD; reading it does not advance objectives. Keyboard and touch use ordinary labelled proximity prompts with short holds.

Checks passed locally:

- BreakerSequence.spec.luau: wrong/unknown/repeated circuits, early main, fixed order, no power before final lever, idempotent completion and repeat/reset.
- CellarPuzzle.spec.luau: reveal separation, hidden key/dormant monster during partial progress, panel/cue reset and blocked stair-opening regression. Engine walking paths and actual monster movement both used each aisle with the opposite aisle blocked; navigation edges remained clear and no tested wall/rack overlaps occurred.
- Existing PubLayout, PubExterior, EscapeRoutes, ExpandedPub and MonsterIntelligence specs passed with the expanded cellar/new monster origin. The original stair, pub, eight bedrooms, staff stair and adjoining-room routes remain connected.
- Actual avatar walked from the panel around the rear/east aisle, back to the landing and upstairs to the bar without jumping or getting stuck.
- Normal client prompt interactions read the maintenance card before the warning without advancing stage; warning enabled the switches. Early main/wrong Bar/repeated Cellar left stage 2, health unchanged, monster Dormant and key hidden. Valid partial stages showed progress/lamp feedback, and all three circuits alone left main power off.
- Final lever reached stage 3/Reveal, powered the pub and revealed the original chosen key position. The monster subsequently reached and captured the player at the original stair landing; objective, panel, cue light, key and monster reset correctly.
- Character reload during partial progress also reset the puzzle. A subsequent full panel sequence, normal key pickup and emergency-exit use completed stage 5/Stopped with the key alone.
- Clunk, crate thud and glug sounds loaded locally; the original Chuggernaught mesh still loaded. Controls were restored, temporary fixtures removed and Play stopped.

Both Rojo builds and git diff --check pass. Standalone Luau Script Analysis remains unavailable. Human checks still required: printed card/label readability at small screen sizes, keyboard/touch prompt selection, anticipation cue volume, visibility of the far reveal from normal player camera angles, and escape pacing on both aisles. No assets or experience were uploaded/published.

### Panel discovery and reveal clarity

User clarified that finding the switches was the problem and was unsure whether main power had been restored when the monster seemed absent. Added larger orange housings/protruding handles, a distinct red main lever, permanent work light, panel trim/heading and a direction sign from the landing. The circuit order remains unchanged. Camera occlusion no longer hides the control prompts; server eye-level visibility/distance/stage validation still applies. Six-stud activation distance keeps adjacent switches from competing at each control's normal standing position.

World main-supply status, prompt ON/OFF/READY text and replicated HUD circuit count make completion explicit. The stage-2 HUD has extra vertical space for the instructions. Power completion now explicitly announces the wake-up beyond the rack. CellarReveal.client applies one camera look per local reveal, only in the cellar, preserving CameraType.Custom and all movement/look controls. It does not continuously track the monster or lock a cutscene.

CellarPuzzle fixture/navigation checks passed with the larger controls. Live normal prompt interactions reached 3/3 and MAIN LEVER READY, then stage 3/Reveal. The original mesh loaded with transparency 0; its head was in front of the panel player's camera (positive depth approximately 44.6 studs), and camera type remained Custom. Controls were restored and Play stopped. This verifies state, rendering and camera framing; final visual readability and touch selection still need the user's playtest. Both builds and whitespace checks pass; standalone Luau analysis remains unavailable.

### Key discovery visibility

The pickup was a small plain block, and one of its nine valid spots is the downstairs office desk. Added native brass ring/teeth geometry and a local warm light plus an 18-stud depth-occluded EXIT KEY label. No uploaded art is replaced. Adjusted fixed markers to sit just above dresser/desk surfaces. Main refreshes all geometry/cues with stage 3 only, so partial power, pickup and reset cannot leave visible pieces or locator cues. KeyPlacement records KeyRoom on the server pickup for diagnostics; the HUD names the candidate furniture without revealing the chosen room.

KeyVisibility.spec.luau passed all nine choices with real doorway sight rays, furniture-height clearance, model relocation, hidden/available cue transitions and no through-wall/long-range label. Live prompt playthrough passed the full breaker sequence, stable Room06 choice through power, complete brass-key reveal, pickup hiding every piece/light/label, and key-only victory. Controls restored and Play stopped. Both builds and whitespace checks pass; standalone Luau analysis remains unavailable. Final perceived visibility on keyboard/touch remains a human playtest check.

## Original asset integration — 28 October 2026

Applied all 47 opaque GLB asset types locally through shared fixed-size EditableMesh templates: 164 placements/candidates across eight bedrooms, bar, office, kitchen and cellar. Source GLBs/artwork are unchanged and source hashes match the generated catalog. Glass uses native clear panes. Twelve real runtime wall openings retain invisible collidable/queryable barriers, preserving navigation/NPC sight; actual weather remains client-owned. Ten cobwebs are selected from sixteen curated candidates on each run reset. Existing collision proxies, objectives and all nine key spots remain authoritative. No uploads/publishing.

The local place and connected Studio sources were backed up under build/backups/asset-integration-20261028. Rojo synced the reviewed code changes. The saved places/Halloween2026.rbxlx was updated only inside HalloweenServer, HalloweenClient and HalloweenShared; the merge asserted every byte outside those code folders was identical, and final XML referents are unique. Authored Workspace geometry is preserved. Stop restores the temporary runtime changes.

Passed:

- Both Rojo builds and git diff --check.
- AssetIntegration.spec.luau: all original-data references and 164 placements, solid existing furniture, preserved prompts, all nine hidden key choices, bounded reset-safe cosmetic selection, twelve collision/sight barriers, clear through-window rays and navigation edge clearance. Repeated with the final visual corrections.
- Existing RunState, BreakerSequence, KeyVisibility, PubLayout (all eight rooms), ExpandedPub (actual monster traversal), EscapeRoutes (both stair routes/adjoining rooms) and CellarPuzzle (both aisles) specs, using fresh module clones. Fixtures and cloned modules removed.
- Client Play loaded all 164 placements with zero failed assets and 51 fixed-size prop meshes. Original Chuggernaught mesh remained loaded with 6,449 triangles/nine live bones; ChuggernaughtRig.spec.luau passed after the fixed-size conversion.
- Normal client prompt sequence completed warning, three circuits, main power, actual random-key pickup, bell and key-only escape with the integrated scene. Automated prompt activation needed camera framing/replication to settle; this is not a substitute for unassisted keyboard/touch play.
- PropRenderer.spec.luau locally varied and restored presentation inputs to verify original key reveal/follow/hide, main-lever rotation and lens material, bell plunger depress/return, opened-door lock hiding, finite non-colliding/queryable-disabled meshes and shadowless disabled webs. These are client presentation fixtures, not changes to server objective state. Heartbeat updates fix stale visuals when rendering is throttled in background Studio.
- Neutral Blender reviews of captured Studio asset transforms identified and corrected chair/sign facing, remaining old pointed-window trim and glowing bedroom placeholder cubes. Their lights remain. These are placement reviews with added review fill, not game screenshots or final lighting proof.

The initial full scenery load hit the client editable-memory limit for three asset types; converting the established character topology and scenery templates to fixed-size meshes resolved it in the tested local client. Preserve that memory optimisation when changing the renderer. Device-specific budgets and FPS remain real-device checks.

Play ended; temporary geometry, review capture buffers and cloned test modules were removed. Studio Edit contains its original Camera, Terrain, Baseplate and SpawnLocation. Standalone Luau Script Analysis remains unavailable. Output retained the unrelated existing asset-type warning for 203785492; no new runtime script errors remained after fixes.

Human review still required: press Play, walk the stairs and bedroom/bar/cellar routes; inspect furniture and window fit at avatar height, actual rain/lightning through windows, prompt/key readability, captures/resets and escape; check touch controls, low-memory devices and frame rate. Native computer-use access was unavailable, so no final in-game screenshot/visual walkthrough is claimed.

## Two-hit health and holding — 28 October 2026

PlayerSurvival owns two run-health segments on the server, separate from Humanoid health to allow the fatal presentation before reset. A confirmed MonsterGrab costs one segment and enters a one-second Held phase. First-hit release starts three seconds of monster recovery and four seconds of damage protection. Player inventory, objective/panel state, selected key and drink count remain intact. The second hit holds again, then shows game over for two seconds and resets the run. Prompt handlers reject actions while held/game over, but allow interaction during first-hit recovery. Victory retains the surviving health and clears recovery/protection.

PlayerHold anchors the avatar briefly, disables its collisions/movement, and places it at a left-hand grip only if overlap and body-sweep checks are clear. Tight-space fallback holds in place. Release restores the original CFrame, collision flags, anchoring, movement/jump settings, auto-rotation and network ownership, with zero impulse. Character reset/removal cancels the sequence and restores surviving references safely. No throwing or ragdoll physics. Client left-arm IK follows the held chest; the tankard remains in the right hand. Hold/Stunned/Defeat presentation pauses navigation without resetting completed drink boosts.

Survival.client displays a two-segment health bar, held/protected feedback and a brief fatal overlay. Only movement controls are locked during the hold/game over; normal camera type is preserved. The unrelated default Humanoid health display is hidden in the prototype. All health/damage, timing, movement restriction and objective decisions remain authoritative on the server.

Passed:

- PlayerSurvival.spec.luau controlled-clock checks: first/second hits, no repeat hit during a hold, protected release, protection beyond recovery, delayed fatal/game-over/restart, exactly-once restart, reset cancellation, one-health victory and preserved drink count.
- PlayerHold.spec.luau: safe lift, original release transform, collision/movement restoration, obstructed grip fallback, repeated cleanup and destroyed-character cleanup.
- Existing MonsterEncounter and MonsterHunt specs, including windup/dodge, bell behaviour and finite search.
- Live first grab with the key: health became 1/2, avatar anchored and held, stage 4/key/panel progress retained. Actual animated left-hand/chest error was below 0.001 studs, as was tankard/right-hand grip error. Health UI showed one hit left; camera stayed Custom. Release returned to the original position with normal movement; the monster stayed still during recovery and no second health loss occurred in that checked interval.
- Live second hit: holding before game over, held exit interaction rejected, visible fatal overlay, then stage 1/full health with puzzle/key/drinks reset and no anchored avatar or stale grip target.
- Live staircase hit released onto the original step without a throw/fall. Manual character reload during a subsequent hold restored full health/unlocked movement and cancelled the old fatal timer.
- Fresh-run first-hit recovery allowed key-only escape with 1/2 health; victory stopped the monster and cleared protection/hold flags. For that isolated prompt probe the exit prompt was temporarily disabled during positioning, then restored, to prevent queued automated interaction from winning before the test grab. This did not change source behaviour.
- Existing ChuggernaughtRig client spec passed. Sampled Hold/Stunned/Defeat poses, including distant fallback targets, remained finite and retained tankard contact. Temporary Play fixtures/controls were restored and Play stopped.

Automated prompt probes require camera framing and time for reveal/replication; failed setup probes were corrected before the verified runs. These are state/pose/physics checks, not an unassisted visual walkthrough. Human review still required: holding-animation feel, camera comfort, health-bar readability on touch, jump/movement restoration, escape-window balance, and playthroughs with varied avatar sizes. Standalone Luau Script Analysis remains unavailable. Both Rojo builds and whitespace checks pass. The saved local place is updated in managed code folders only; authored map/artwork is preserved and nothing is published/uploaded.

### Grab animation readability refinement

The initial hold was an immediate placement and static grip that could happen outside the player's view. PlayerHold now drives a continuous 1.6-second reach/lift/hold/lower path: 0.24 seconds into the grip, 0.31 lifting, a short steady hold, then 0.4 lowering to the original position. Both movement legs and raised headroom are checked before moving; obstruction fallback still holds safely in place. Fatal holds retain the raised grip until reset. The first-hit recovery/protection durations and two-hit count are unchanged.

The original skin now leans into the reach, blends the left arm into the live avatar chest, follows the lift, then drops the hand during recovery. The right hand retains the tankard. A bundled thud marks a successful catch. GrabCamera uses a short collision-checked view during Hold only, framing both actors. Player visibility is restored for first-person users, with lens-close geometry hidden during the pullback. Previous camera frame/subject, normal camera type and local visibility return on release, fatal overlay, character removal or script cleanup.

Updated PlayerHold controlled-time checks passed for progressive motion instead of teleport, visible lift/lower, safe original return, fatal grip retention, obstruction and reset cleanup. PlayerSurvival timing tests passed with the new hold duration. Live samples showed an approximately 1.6-stud lift, a steady elevated phase and lowering before release. Camera samples framed both actors in open space and near the closed exit wall, with the view remaining inside the wall. First-person avatar visibility and restoration of first-person preference/normal camera type passed. Transient hand error during moving replicated frames was about 0.24 studs (within the 0.35-stud fist tolerance); steady live grip error was below 0.001 studs, as was tankard contact. A fatal lift followed by character reload restored health/movement and Custom camera without a stale hold. Existing live ChuggernaughtRig spec passed. Play/temporary controls were cleaned up.

Both builds and whitespace checks pass. The saved place is updated in managed code only with outside bytes preserved. Standalone Luau analysis remains unavailable. Human review remains necessary for how clear/comfortable the short holding view feels, especially portrait/touch screens and tight spaces.


## Arrival, Firefly Tavern and car finale — 28 October 2026

The approved current pub name is The Firefly Tavern. Start outside by a working car. Open the front door, then walk through: only crossing the threshold drops the beam and advances to the warning. Power separately wakes the monster. Unlocking the emergency exit starts the courtyard escape; boarding the car drives away before victory/replay.

Studio Play checks passed for opening without advance, physical walking triggering stage 1, warning, three circuits/main supply, key pickup, exit advancing to stage 5, car boarding/drive to stage 7, and replay restoring stage 0, full health, unanchored root and Custom camera. Existing asset 203785492 warnings remain; no new gameplay errors appeared. A first-hit recovery was observed during the exterior sequence.

Journey.spec.luau passed in a disposable fresh-module fixture: threshold gating, collapse/reset, closed/open navigation validation, monster traversal through both courtyard turns, timed car movement and driver/car restoration. RunState.spec.luau covers revised stages 0–7. Both Rojo builds and diff checks passed. Standalone Luau analysis is unavailable.

Manual keyboard/touch checks remain for courtyard chase balance, boarding readability, entrance camera comfort and reset during the drive. Interior/message visual polish is deferred. The saved local place receives managed code only, preserving authored geometry and artwork. Nothing was published.


## Interior finish pass — 28 October 2026

InteriorFinish adds cosmetic oak wainscot, dado mouldings, faded patterned wallpaper on internal wall segments, bordered woven rugs, bedroom headboard accents/ceiling beams, lounge ties and framed existing room signs. Window openings, furniture proxies, key surfaces and objectives are retained. All 649 new decorative parts are non-colliding, non-querying and non-touching.

Studio fixture validation passed for closed/open navigation graphs. Live Play confirmed finish replication, normal stage 0/two-health startup and all nine existing KeyVisibility sightline/clearance/gating checks. No new runtime errors appeared; existing asset 203785492 warnings remain. Both Rojo builds and git diff --check passed. Saved place changes are confined to managed code folders with authored geometry/art preserved.

Visual screen inspection was unavailable because computer-use permissions are absent. Review the colours, pattern density, bedroom differentiation and handheld performance in Play; those are not verified by geometry checks. Standalone Luau analysis remains unavailable.


## Signs, window lightning and arrival facing — 28 October 2026

TavernSigns styles 78 existing sign faces with oak, brass borders, ivory lettering, Fondamento brand text and Nunito directions; warning papers and live panel displays retain their own treatment. The hanging Firefly sign has a native engraved firefly illustration on both faces, requiring no external asset upload. Original mesh artwork is retained; its blank pub-name board is stored in the cellar while the live branded board displays text.

Lightning now flashes 17 shadowed local sources inside actual side windows and front facade windows, fading over 0.32 seconds. Interior screen-wide brightening is removed; room light comes from windows. Server spawn orientation and the initial/replay client camera face the entrance from outside the car.

Studio Play assertions passed for 78 styled faces, two illustrations, replicated text colours/backgrounds, unchanged closed navigation graph, player/camera entrance-facing dot products of 1, and all 17 shadowed light sources brightening then returning to zero. No new runtime errors; the existing 203785492 warnings remain. Both builds and whitespace checks passed. Visual sign readability, lightning balance/occlusion on device graphics settings and touch performance still need human Play review; no screen access is available. Standalone Luau analysis remains unavailable.


## Refined signage integration — 28 October 2026

TavernSigns.spec.luau checks repeat-safe styling of 78 faces, preserved wording/arrows, unchanged board transforms/collision/query flags, eight shared number plaques and navigation. It passed in a disposable Edit fixture, as did AssetIntegration.spec. PropRenderer.spec passed in Play. The live client loaded 164 asset placements with 44 fixed meshes and zero failed assets; all eight native numerals fit their allocated labels.

The first implementation used eight baked-number meshes and exhausted the editable-mesh budget for TravellerSuitcase. Replacing these with one shared original BedroomNumberBlank mesh and native numerals resolved the issue. Both Rojo builds and git diff --check passed. Saved local place changes are limited to managed code folders, with authored bytes outside those folders preserved. Play stopped and fixtures cleaned. Existing asset-type warnings for 203785492 remain. Standalone Luau analysis and human visual/mobile readability review are not claimed; no publishing/upload.


## Tavern HUD, facade and visible lightning — 29 October 2026

TavernUI applies the approved gothic direction: Fondamento objective/victory headings, Nunito body/status text, Creepster only for the final CAUGHT headline, ivory/brass on a dark panel. The compact objective panel separates heading, persistent detail, circuit progress and timed feedback (8–22 seconds according to length). Health retains two segments and first-hit feedback; only server GameOver shows the full defeat card. Driving/game-over/entry scenes hide the normal HUD. Victory retains the existing server replay event. No server objective, health, recovery or restart timing changes.

Studio client presentation checks passed for stages 0–5, main-lever-ready progress, first hit without defeat overlay, GameOver hiding the HUD, and victory card visibility. Cloned objective/ending panels within a 320×568 container fit their text and bounds: objective 288×174, both sample ending cards about 282×207 (replay adds its button on the actual victory screen). Native touch controls and visual typography still need device review.

ExteriorFinish adds 124 non-colliding/non-querying decorative facade parts: stone plinth/quoins, diagonal timber braces, a slate entrance canopy, sills, rain marks and planting. Closed/open navigation graphs passed. SkyLightning adds a distant six-segment bolt and a brief OutdoorAmbient lift alongside existing window lighting and delayed thunder. First flash occurs after 6–11 seconds, subsequent events after 22–40 seconds. Client checks passed for bolt creation/fade/removal, outdoor fill restoration and cleanup; an actual scheduled event was observed during a 41-second Play sample.

No new runtime errors appeared; existing 203785492 warnings remain. Both Rojo builds and diff checks passed. The saved local place is backed up and updated in managed code folders only; authored geometry/art are preserved. Visual rendering, lightning intensity and touch performance remain human-review items because screen access is unavailable. Standalone Luau analysis remains unavailable. Nothing was published.
