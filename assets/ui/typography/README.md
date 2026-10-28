# In-game typography direction — proposal

Design exploration only. The other chat is actively building the game; no HUD, survival logic, map or place file is edited by this proposal. Current narrative name is The Firefly Tavern; game title remains The Chuggernaught: Last Orders. Current first-hit/recovery and second-hit/game-over flow is preserved.

## Recommended direction: Tavern Gothic

- Fondamento for short objective headings and occasional story/room titles, in warm ivory.
- Nunito for objective details, feedback, control hints and restart/status text. Body text remains upright and easy to scan.
- Creepster for the final defeat headline only, in deep crimson. Keep ordinary objective text free of horror distortion.

These are existing Roblox font options; no custom font upload is needed to test the typography. Official reference: https://create.roblox.com/docs/reference/engine/enums/Font . Font family paths: rbxasset://fonts/families/Fondamento.json, Nunito.json and Creepster.json respectively; family names apply within the same rbxasset://fonts/families/ directory. UI stroke/gradient options: https://create.roblox.com/docs/ui/appearance-modifiers .

Current HUD concatenates title, objective and messages inside one large Gotham label. Proposed hierarchy separates a small LAST ORDERS eyebrow, a larger short objective heading, one or two lines of detail, and transient feedback. Avoid leaving the full game title in the largest always-visible HUD block. Use a compact opaque/near-opaque dark panel so text remains legible over windows/lightning; keep it clear of movement/action controls and do not obscure the world.

Starting sizes for Studio review: heading 24–30px; body 18–20px; secondary status 14–16px; defeat title 56–88px on desktop with appropriate mobile constraints. These are design targets, not a fixed pixel layout. Use constrained automatic sizing/wrapping and verify small screens, localisation and actual player-camera backgrounds. Keep drop shadows/strokes restrained; do not shrink long objectives into tiny text. Separate title/body labels allow different fonts without fragile rich-text parsing.

Palette: dark panel RGB 23/19/22; warm ivory RGB 240/223/188; brass accent RGB 188/161/106; defeat crimson RGB 196/59/71 (#c43b47). The crimson is for a large headline with clear ivory supporting text on a dark backdrop. Avoid using dark red for small essential instructions.

## Defeat treatment

Only show the full defeat treatment for LastOrdersGameOver=true, after the second hold ends. A first hit uses a clear warning and the existing one-segment health/recovery feedback; it must not look like a full death/restart. Hide the normal objective HUD while the full defeat overlay is visible.

Recommended headline: small YOU WERE above large CAUGHT in Creepster; short support line Two hits. Last orders!; quiet Restarting… status. Alternative Haunted Poster direction uses LAST ORDERS! as the dramatic crimson headline with YOU WERE CAUGHT below. Both are proposed presentation copy, not new lore or a different game outcome.

Use a few stylised rounded drips attached to letter bottoms, not a graphic injury scene or full-screen splatter. A short 150–200ms settling motion and roughly 400–600ms drip extension can play once on the defeat transition, leaving the headline fully readable during the existing two-second game-over interval. No flashing, looping or pulsing. Reduced motion should keep a static version. Do not extend server restart timing merely to accommodate effects without a deliberate gameplay review.

Roblox implementation can use Creepster TextLabels plus a handful of same-colour slender Frames/UICorner drips and TweenService; no bitmap upload is necessary for an initial version. Add the effect only on the game-over transition, cancel tweens/clear visuals on reset, and keep the text itself readable throughout. Do not animate gameplay state or award/restart logic from the UI. A dedicated static graphic can be considered later if a more precise title silhouette is wanted.

## Review preview

Two contained design alternatives (Tavern Gothic and Haunted Poster) demonstrate objective, defeat and optional victory states. Preview objective/defeat buttons and Replay lettering are review controls, not proposed in-game buttons. The existing server flow automatically restarts after defeat; no Try Again button is implied. The victory state reflects the current escape/drive completion, not the original tankard-theft ending.

The review is an illustrative UI composition, not a screenshot. It uses web-loaded versions of the named display fonts, with platform fallbacks, and local presentation-only interactions. The alternate poster layout uses Oswald for its objective heading. Nothing is installed, uploaded, published or applied to the running game by this proposal.
