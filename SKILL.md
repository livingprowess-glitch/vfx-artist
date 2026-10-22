---
name: vfx-artist
description: Build Roblox VFX in the modern style the user studies in Workspace.modern_vfx — particle stacks, mesh VFX, beams, trails, color/size/transparency curves, CFrames and timing — and explain the WHY behind each choice. Use whenever asked to make, restyle, review, or tune any Roblox visual effect (hit sparks, slashes, auras, dashes, explosions, impacts, wind, water, mesh rings/shockwaves, charge-ups, beams, projectiles, emit-based effects), or when a VFX looks outdated, flat, noisy or "AI".
---

# VFX Artist (modern Roblox style)

**Study complete as of 2026-10-22.** All 15 references in `Workspace.modern_vfx` (Place3 "vfx training", PlaceId 114773467389373) have breakdowns. Nothing has been rebuilt in-engine and reviewed by the user yet, so treat the recipes as derived, not proven, until `reference/corrections.md` says otherwise.

## Before building any effect
1. Pick the closest reference from the index below and **read its breakdown**.
2. Read `reference/principles.md`, at least sections B (value) and C (meshes).
3. Pick textures and meshes from `reference/textures.md`. Prefer the reference's own ids.
4. Build it as a template model with Forge-style attributes, emitted by a runtime (see `reference/emit_patterns.md`). Don't hand-tween one part.
5. Self-check against the checklist at the bottom before showing it.

## Breakdown index (`breakdowns/`)
| need | reference | file |
|---|---|---|
| water splash, liquid projectile, splash on arrival | VFX1/VFX2/BALLVFX, WaterPractice | `Water.md` |
| charge orb → beam, mesh-flipbook pillars, camera rumble | MeshFlipSUCCESS | `MeshFlipSUCCESS.md` |
| wind-up / cast start, mirrored projectiles, trail stack | Startup | `Startup.md` |
| fire slam, beam pillar, black-twin value study | ShapeAndValue2 | `ShapeAndValue2.md` |
| projectile silhouette from beams, sharp→round→dots impact | ShapeAndValuePractice | `ShapeAndValuePractice.md` |
| dust, landing, ground smoke, wind rings | Wind/Smoke OS | `Wind_Smoke_OS.md` |
| multi-hit combo, chained strokes, 15-layer mesh hit | StarStruck | `StarStruck.md` |
| spinning attack, whirl, rotating rig, ripple props | spin | `spin.md` |
| arrows, rain of projectiles, scaled impact copies, charge rings | arrow | `arrow.md` |
| directional burst (up/down variants), fire rings from emitters | Up / Down | `Up_Down.md` |
| dash, speed read, wind wake beams | Dash | `Dash.md` |

## Layout
- `reference/principles.md`: 46 rules, each tagged with the effects it was seen in. House rules are seen in 3 or more effects.
- `reference/emit_patterns.md`: the Forge/PartIcle/EasyMeshEmit attribute schema, how `*_Curve` values decode to cubic-bezier, and the `ReplicatedStorage.effects` runtime contract.
- `reference/assets.md` + `reference/assets/catalog.tsv`: **the asset library, keyed by asset id**, so it works without Place3 open. It covers 681 textures and meshes, from `Workspace.modern_vfx`, `Workspace.Effects` (blood, shockwaves, punch impacts, smoke, flame shards, JoJo kanji) and `Workspace["lightning stuff"]` (lightning/electric sheets, lightning decals for meshes, spike/crater meshes). Each has a descriptive name (`pe_`/`beam_`/`trail_`/`decal_`/`mesh_`/`meshtex_`/`image_`, plus `_colored` when the color is baked in), the flipbook layout/mode/fps for particle sheets, the native MeshSize for meshes, and where each was seen. `reference/assets/decal_flipbooks.tsv` holds the 16-frame decal flipbook sets, with frame ids in order. Search the catalog by name, e.g. `grep wind reference/assets/catalog.tsv`.
- **When the user gives new assets:** render their thumbnails as a grid (`thumbnails.roblox.com/v1/assets?assetIds=...&size=150x150&format=Png`, viewed on that origin in the browser pane), name each by what it looks like using the same prefixes, record the flipbook layout (from the source emitter, or by testing it) and the MeshSize, and append rows to `catalog.tsv` and `assets.md`. Keep names unique.
- `reference/textures.md`: the role guide (which texture family does which job).
- `reference/study_brief.md`: how to study a new reference (template plus rules). Use it when the user adds more examples.
- `reference/corrections.md`: the user's feedback on effects built from this skill. Create it on the first correction and read it before every build.
- `tools/dump.sh <dotted.path> <out>`: a place-guarded property dump (decodes bezier curves, f64 flipbook ids and HDR colors, and skips defaults). `tools/texscan.lua` lists every texture and mesh id with its usage.

## Core rules (short form)
1. **Beats, not loops.** Fire disabled emitters as bursts in order: anticipation (−0.05 s) → impact frame (≤0.1 s) → body → residue. Use about 15 mesh layers in 3 time bands (0.2 / 0.5 / 1–2 s).
2. **One dominant hue; value does the work.** Give every bright layer a dark twin (Brightness 0, #000, or a dark hue at LightEmission 0) with a slight offset. Saturated bodies use LightEmission 0 or negative, with value from Brightness. Additive blending is only for thin glows. Fade color to black. The complement is a thin, short accent that may carry the hottest pixel.
3. **Meshes are translucent volume** (peak opacity 2–30%). Only ≤0.2 s hot meshes go near-solid.
   - Glow comes from **HDR Decal.Color3 on decal-on-mesh**, not from white Neon. Mesh bodies are mid-grey Neon (#A3A2A5).
   - Use broken geometry, and **anti-correlated non-uniform scale** (one axis ×0.02–0.4, another ×1.5–9).
   - Every expansion rotates (40–195°), with decaying spin and random initial yaw.
   - Use push-pull motion. Ground rings drop; rising bands start under the floor.
   - Pulse rings by re-emitting them at a Rate. Kill a mesh by thinning it to 0.
4. **Flipbooks carry the motion.** Bursts use high Speed with Drag and gravity, size 0→peak@20%→0, and TimeScale about 0.85. One hero burst = several textures × EmitCount 1, each with its own Squash.
5. **Matter is lit** (LightInfluence ≥1). **Energy is emissive.**
6. **Beams** are 3–4 textures at different TextureSpeeds, or S-curves with an opening width and a 180° roll. Widths hold, then snap on an ease-in. **Projectiles** are trails plus a head flare: a gradient body, an accent core at half the life and twice the Brightness, and black twins.
7. **Shape language:** sharp → round → dots. Stretch for speed. Fire stays upright.

## Outdated habits (never ship)
- One expanding sphere or ring tweened in size and transparency as the whole effect, or any uniform-scale "bubble".
- Opaque or pure-white Neon meshes that live longer than about 0.2 s (see [[feedback-effects-structure]]: mesh rings are never pure white).
- Additive-only stacks with no dark twins, which wash out to white.
- Linear tweens and constant spin. Spin a whole effect by spinning its root, not by spinning emitters.
- One emitter or one texture doing a whole role.

## Checklist before showing an effect
- [ ] Has anticipation, an impact frame, a body and residue.
- [ ] Has one dominant hue, dark twins, and at most one accent.
- [ ] No mesh more opaque than 0.7 for longer than 0.2 s, and every mesh scales non-uniformly and rotates.
- [ ] Flipbook textures set to OneShot; burst kinematics include drag.
- [ ] Light and camera shake timed to the beats.
- [ ] Scales cleanly with `ScaleParticles(k)`.

## Pipeline
Emit through the project's effect pipeline. For One Piece Prime, that's the `classes.effects` frame tables fired by `net.effect`, with frame times matching the beats above. Capture it or have the user view it, then log feedback in `reference/corrections.md`.
