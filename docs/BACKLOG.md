# Playtest and release backlog

Updated 29 October 2026. Local changes are implemented; release acceptance and live administration are listed separately below. Nothing has been published or uploaded by this work.

## Implemented locally

- [x] **Replace the drink-prevention warning.** The bar staff note, reading card, repeat reads and feedback now explain the locked emergency exit, restoring power and finding the key. The original narrative/artwork remain historical references.
- [x] **Reduce signage.** Remove the large three-switches/main-lever board and duplicate cellar aisle sign. Remove all large cellar direction/status boards. Keep two subtle floor chevrons, compact control labels and one small maintenance card. The card is the source of circuit order; the HUD shows progress/read-card guidance rather than repeating the solution. Remove two redundant lounge directions.
- [x] **Compact mobile HUD.** On phones, show only a notebook objective icon; tapping opens/closes details. Do not auto-expand phone instructions. Desktop retains the compact objective strip; feedback is separate and temporary; notes have a reading panel. Red health is a 56-pixel circle split into two halves, with a gap and outlined empty halves. Put the circle beside the objective at the top left, clear of the lower phone controls. Damage wording is temporary. iPhone 13 simulator portrait and landscape bounds/text checks passed.
- [x] **Single-player code guard.** Extra joins are rejected instead of entering the shared pub without a controller. This is a guard only; published capacity still needs to be 1.
- [x] **Visible awakening.** Fade-masked, collision-checked shot visibly frames the Chuggernaught, with protected timing/input lock and a safe return. Simulator framing and sightline checks passed.
- [x] **Mandatory first views across visits.** Approved by Andrew. Only Arrival/Awakening/Escape completion flags persist per account. Server timing marks completion; interrupted/dead/reset scenes remain unseen. Studio bypasses live stores; cloud verification remains below.
- [x] **Hold-to-skip repeats.** Continuous one-second touch/mouse/Space/B hold, circular fill, cancellation on release, drag-out, focus loss or scene changes, and server eligibility/hold validation. Short taps and accumulated partial holds fail. First views have no active skip button.
- [x] **Longer opening.** Ten-second single continuous establishing move from the parked-car view into the normal entrance-facing gameplay view. No sign-closeup/backtracking sequence. Caption explains the dare; control returns beside the car.
- [x] **Sound pass.** Lower bell/impact peaks, audible indoor/outdoor storm balance, distinct drinking/footstep levels, wall/floor muffling and a footfall retrigger limit. No new uploaded sound IDs or invented voice recordings.
- [x] **Local asset checks.** After retiring three obsolete sign placements, all 194 placements/59 fixed mesh groups loaded without failures on the observed desktop Studio client. Original art is preserved; runtime reduced meshes/native water keep the pack within that observed budget. This is not a phone-hardware guarantee.
- [x] **Regression pass.** Seventeen scene/objective/survival/hold/audio/puzzle/key/navigation/asset/layout specs passed. Live checks covered two hits/game over/reset, escape/victory/replay, interrupted drive/reveal, camera subject restoration and mandatory interrupted scenes. Camera restoration now selects the current avatar after character reload.
- [x] **Release presentation prepared.** Existing v2 icon/thumbnail reviewed and dimensions verified; description, player instructions and administrative handoff are in [RELEASE.md](RELEASE.md). Original marketing artwork remains unchanged.

## Release acceptance — still needs external action or human review

- [ ] **Published starting-place capacity:** verify/change Maximum Visitor Count to 1 in Creator Dashboard; refresh existing servers as appropriate; test a friend/second account gets a separate solo run. The connected Studio place reports 60, and the live dashboard setting has not been changed.
- [ ] **Published scene history test:** in a separate authorised test experience, complete scenes, leave/rejoin and verify repeat eligibility; fresh accounts must receive mandatory first views. Also test a transient data-store failure. No live store was accessed from Studio.
- [ ] **Father/son complete playtest:** use [PLAYTEST.md](PLAYTEST.md) to assess puzzle clarity, search time, pursuit/loop evasion, first-hit recovery and courtyard difficulty. Do not change balance merely because automated teleports finish quickly.
- [ ] **Actual iPhone/tablet review:** touch interactions, hold/cancel circle, safe areas, captions/reading panels, camera comfort, real frame rate and mesh-memory headroom at low/default graphics. Emulator layout checks do not establish hardware performance.
- [ ] **Visual/audio approval:** native/reduced props and signs at avatar height; bell/thunder/rain/monster balance on phone speakers/headphones. Geometric/audio-state tests cannot decide comfort or polish.
- [ ] **Launch approval:** review content settings, copy and marketing art; explicitly authorise uploads/publication when the candidate is approved.

## Deferred scope

Co-op, extra antagonists, monetisation and general progression saving remain outside this release. Scene-seen flags are the sole approved persistence exception.


Latest review: the icon is 56×56 next to red health, and simulated iPhone taps opened/closed its 340×90 instruction drawer with fitting text. The opening was sampled for 598 frames with non-negative forward progress. Cellar SurfaceGuis now occur only on the four small control labels and one maintenance card; imported obsolete sign props are no longer placed (source art retained).

Latest cellar feedback: remove the maintenance card/reading overlay completely. Players infer circuit order from controls, indicator lights and reset feedback; early-main/wrong-order messages do not give the order.

## Latest playtest feedback — 29 October 2026

- [x] Remove the “CELLAR / STAIRS DOWN” sign at the cellar entrance. Keep the stairs identifiable through their existing lighting and geometry.
- [x] Remove the directional arrows/chevrons from the cellar floor. Let players find the panel through the room layout and lit controls.
- [x] Repair missing avatar face/head content locally when loading fails. Studio reproduced an authenticated mesh-load failure with normal head transparency. A bundled classic head/face fallback preserves server avatar, joints and accessories; actual affected-device review remains required.

Latest verification supersedes earlier cellar descriptions: no entrance sign, floor chevrons or maintenance card remain; the four small control labels and existing lighting remain.
