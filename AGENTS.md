# Project instructions

Build The Chuggernaught: Last Orders for Halloween 2026. Keep changes small and playable.

- Read docs/narrative.md before creative or gameplay changes; preserve it and original artwork. Do not invent missing canonical references.
- Initial scope: single-player, one compact pub, a short objective sequence, one monster, tankard theft and escape. Defer co-op, monetisation, persistence and procedural systems.
- Keep authoritative objectives, inventory and NPC behaviour on the server. Client handles input, camera and UI; shared modules contain common configuration and types.
- Use strict Luau and small modules. Do not add dependencies without a concrete need.
- Work in local place files. Never publish, upload assets or modify a live experience without explicit user instruction. PumpkinTest.rbxl is unrelated; do not edit it.
- Preserve existing work. Do not overwrite Studio-authored maps with a fresh build; save backups and review Rojo sync changes first.
- Check Git diff and follow tests/README.md before handing off. Report unavailable checks honestly.
