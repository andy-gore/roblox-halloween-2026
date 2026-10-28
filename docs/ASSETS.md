# Local asset integration

The runtime pub now uses original Blender/GLB geometry from all 47 opaque asset types in assets/props, plus native clear-glass panes for the storm-view windows. Original models/artwork remain unchanged; no uploads or publishing are involved. This applies only while LastOrdersGreybox is enabled.

AssetDressing places 164 instances/candidates across the bar, office, kitchen, cellar and eight bedrooms. Existing tested furniture proxies retain authoritative collision; bedside cabinets add simple solid proxies away from walking lanes. Replaced native visuals are hidden on each client only after the corresponding original mesh succeeds. The server still owns objectives, key selection, power, bell cooldown, exit and monster behaviour.

PropRenderer loads original GLB positions, normals and flat colours from generated shared data. Each unique mesh is converted to a fixed-size template and shared by its repeated MeshParts. The character also uses fixed topology while live Bones animate it, reserving enough local memory for scenery. The tested local client loaded all placements and 51 fixed-size prop meshes with zero fallback assets. Lower-memory clients may retain native fallback visuals; performance needs a real device playtest. Studio/local mesh API success does not establish published-experience permissions.

Power rotates the original main lever and lights its lens. The key mesh follows the actual random pickup and respects reveal/pickup/reset visibility; existing discovery cues stay server-controlled. Bell plunger presentation follows successful cooldown changes. Exit-lock visuals follow and disappear with the opened door. Cosmetic updates use Heartbeat, so replicated state remains correct when Studio rendering is throttled in the background.

Twelve storm-view windows replace selected opaque side-wall panels: one per bedroom, two larger bar windows, and office/kitchen windows. Runtime structural walls are split around the openings; invisible collidable/queryable barriers preserve their old navigation and NPC sight boundary. Native glass is non-colliding/non-queryable, with high transparency. The decorative mesh frames/curtains have no collision/query participation. Roof queries and existing storm clipping are preserved. Camera view and AI sight deliberately differ: players see the weather while the monster does not gain new cross-window tracking.

Cobwebs use sixteen curated candidate anchors, selecting ten per run. Only their enabled state changes on reset; key locations and objectives are untouched. At most one candidate exists per bedroom. Web geometry is non-colliding, non-queryable and shadowless. Pictures and guestbook entries remain blank; no new lore was invented.

## Regeneration and local files

Run `python3 tools/export_prop_meshes.py` after deliberately editing approved GLBs. It uses the Python standard library, checks source geometry and writes src/shared/PropMeshData plus an ignored checksum/count catalog. Glass exports are intentionally replaced by native panes rather than packed as opaque mesh data.

Both Rojo projects remain code-only sync mappings. The authored place is never replaced with a generated map. For this integration, the local place and Studio sources were backed up under build/backups/asset-integration-20261028 before edits. tools/update_local_place_code.py merges only the three managed code folders into the saved local XML place, asserting every byte outside them remains identical. It preserves unknown code-folder children. Do not run it without reviewing changes and backing up the local place first.

Saved local game: places/Halloween2026.rbxlx. Disposable build: build/LastOrdersPrototype.rbxlx. In the connected local game, press Play to see the integrated assets; Stop restores authored Workspace geometry. No test fixture remains in Edit mode.

Read tests/README.md for executed checks and remaining human review. Bedroom/bar Blender placement images in build/ use captured Studio transforms plus neutral review fill; they are not Roblox screenshots or proof of final game lighting. The native computer-use permission was unavailable, so the final keyboard/touch visual walkthrough remains a human check.
