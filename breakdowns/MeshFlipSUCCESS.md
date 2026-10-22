# MeshFlipSUCCESS: charge orb → sky beam (pink/magenta)

## 1. Read
A pink energy sphere charges for 1.3 s, with flickering lightning, floating specs and a camera rumble that builds up. At 0.8 s ground rings slam outward. At 1.3 s a vertical beam fires: mesh pillars with animated decal textures, streaking flares and a black smoke column, while a torn shell collapses into a wide pancake.
- **Eye path:** the orb at the center, then the ring slam on the ground at 0.8, then the beam shooting upward at 1.3, then the dark smoke and collapsing shell as residue.
- "MeshFlip" is in the name because the core technique is **meshes with flipbook decals** (`DecalMesh` models, `FlipbookEnabled`, 16 textures stored as f64 ids in `FlipbookTextures`).

## 2. Timeline
| t (s) | layer | what happens |
|---|---|---|
| 0 → 1.3 | `Sphere/DecalMesh` ×2 | the sphere mesh grows ×1.7 (scale 0.067→0.113) with outCubic while its decal plays 16 frames over 1.3 s |
| 0 → 1.3 | `CameraShake` RayValue | Amplitude 1, Frequency 0.1, **FadeIn 2 s**: a rumble that rises under the charge, never a single jolt |
| 0 → 0.9 | `LightningNew2` + `Dark Lightning` | Size 0.001→33 within 0.05–0.1 s lifetimes, Rate 5 for 0.9 s: strobing arcs |
| 0 → 1.5 | `Floating Animated Spec`, `spinning triangle 2`, `Grey Galaxy Smoke`, `Fog patch` | specs drift out (Speed 1–60, Drag 5), triangles fall (accel -200), fog fades |
| 0 → 1.3 | `Erica Water Wave Blur` (30 studs, LightEmission -10, Brightness 50) | a dark-saturated pink wave disc behind the orb |
| 0.8 → 0.9 | spike crown Model (102470267627424) | **0.1 s**: from 28×53×27 to 106×84×100, drops 40, rotates 118°, Transparency 0.7→1 |
| 0.8 → 1.8 | torn swirl ring Model (129778117978668) | from 61×20×63 to 93×**0.9**×96 (flattens ×0.045 while widening ×1.5), drops 9.5, rotates 142°, Transparency 0.9→1, Rate 5 × 0.3 s with random Y rotation |
| 1.3 → 2.3 | beam `DecalMesh` cylinder + twisted cylinder | scale (0.13,0.2,0.13)→(0,0.1,0): width collapses to 0 on `Mesh_Scale_Curve` bezier(.95,.05,.795,.035), a strong ease-in |
| 1.3 → 1.9 | `Flare296New` (Squash 3→-3), `Spiked Spec` (Lifetime 0.03, Rate 50), `Glow`, `Black Smoke 3` | Speed 228.6 with Drag 2: up-streaks; the spec strobe flickers every frame; black smoke grows 0→29.5 by 7%→76 |
| 1.3 → ~2.3 | torn shell Model (71849885439764) | from 58×63×54 at y+31 to 121×11.6×125: a dome pancakes ×2 wide, ×0.18 tall, rotates 183° |

## 3. Layer stack with reasons
- **Charge orb (DecalMesh sphere ×2).**
  - Mesh 137603874842453 (sphere) with a decal flipbook.
  - Copy A: `Color3 = hdr(5.88, 1.96, 5.88)` (overdriven pink).
  - Copy B: `ZIndex 2`, `hdr(1.96, 0, 39.2)` (overdriven violet), plus a `PointLight` (#862FFF, **Brightness 5000**, Range 15).
  - **Why:**
    - HDR `Color3` values above 1 push the decal past white into bloom while keeping the hue in the highlights.
    - Two decals at different ZIndex on the same sphere layer two hue temperatures (pink over violet). That gives the orb a hot core and a cool rim.
    - The huge-brightness, short-range light paints the floor and nearby parts, so the orb feels like a light source, not a sticker.
- **Dark-saturated particles.**
  - `LightEmission = -10` with Brightness 50–500 on `Floating Animated Spec`, `spinning triangle 2` and `Erica Water Wave Blur`.
  - **Why:** strongly negative LightEmission inverts the additive blend toward darkening, so overlapping particles get deeper and more saturated instead of clipping to white. The pink stays pink at any density.
- **Black twins.** `Floating Animated Spec` and `Grey Galaxy Smoke` also exist with **Brightness 0**, which renders them black. The specs read as dark/bright pairs, a cel-shaded look.
- **Lightning pair.** `LightningNew2` (Brightness 50) with `Dark Lightning` (Brightness 5): a bright arc plus a dim duplicate at the same place gives the arc a glow edge. A 0.05–0.1 s life means every arc lasts 3–6 frames, so it strobes.
- **Ring slam at 0.8 s.**
  - The spike crown lives 0.1 s and the swirl ring lives 1 s, both on Forge's default outCubic.
  - **Why:** a 0.1 s mesh is an impact frame (it pops and is gone). The 1 s ring is the follow-through that carries the energy outward.
  - Flattening the ring (Y ×0.045) turns a tall swirl into a ground shock disc, the same collapse trick as Water's Meshdown.
- **Beam pillars at 1.3 s.**
  - Cylinder 137685697016553 and twisted cylinder 106381405601872, both DecalMesh with 16-frame flipbooks.
  - `Mesh_Scale_Curve` is bezier(.95,.05,.795,.035): the width stays nearly full for most of the duration, then **snaps to 0** at the end.
  - **Why:** a beam should hold and then cut off. Easing out (shrinking early) would make it look weak.
- **Up-streak particles.**
  - `Flare296New`: Speed 228.6, Drag 2, Squash 3→-3. The stretched streak flips to squashed, a speed smear followed by a pop.
  - `Spiked Spec`: Lifetime **0.03** at Rate 50, so a new frame-long spike appears every frame. That's a strobe that sells the energy.
  - `Black Smoke 3` (Brightness 5, size 0→29.5 by 7%): a dark column that frames the bright pillar.
- **Shell collapse.** The crumpled dome 71849885439764 flattens and widens while rotating 183°. The blast pressure pushes down and out after the beam fires.

## 4. Mesh VFX detail
- **The DecalMesh pattern:** `Start`/`End` Parts each hold a `SpecialMesh` (FileMesh) plus a `Decal`. The Start decal has `FlipbookEnabled`, `FlipbookTextures` (16 ids), `Flipbook_Change_Duration` = EffectDuration, and `Color_Curve`/`Transparency_Curve` (outCubic).
  - The Part is invisible, and the decal draws the texture on the mesh.
  - Scale is animated through `SpecialMesh.Scale` (Start→End), not Part.Size. That's why the End scale can be 0 on X/Z.
- **The MeshPart Start/End pattern** (rings and shell): Neon white `MeshPart`s with Transparency 1, and Forge `Part_Transparency_Start` 0.7–0.9. Even the boldest ring peaks at 30% opacity.
- **Random rotation:** `MaxInitRot (0,360,0)` plus Rate 5 × EmitDuration 0.3 gives 1–2 copies at different angles, so repeats never look identical.
- **The vertical drop:** every ground ring's End is **lower** than its Start (9.5–40 studs). It slams down into the floor while expanding.

## 5. Color & value
- **Palette:** the particle pinks #FF92F6 (charge) and #FF5CDC (beam), slightly more saturated at the release. The HDR decals are pink (5.9,2,5.9) and violet (2,0,39). The light is #862FFF.
- **Meshes are white Neon:** no hue, only shape. The pink comes from particles and decals.
- **Value:** black-twin specs and smoke, LightEmission -10 deepening, and the black smoke column against the white beam meshes.

## 6. Rebuild recipe
```lua
-- t=0 charge
decalMesh(sphere 137603874842453, flipbook16, hdr(5.88,1.96,5.88), scale 0.067->0.113, 1.3s outCubic)
decalMesh(sphere, flipbook16b, hdr(1.96,0,39.2), ZIndex 2, light {#862FFF, 5000, 15})
cameraShake{amp=1, freq=0.1, fadeIn=2, fadeOut=0.3}
strobe(lightning 86186431822396 B50 + 16034333422 B5, size 0.001->33, life .05-.1, rate 5, 0.9s)
burst(specs 15441262724 #FF92F6 LE-10 B50 x10 + black twin B0 x10; triangles 98762333116575 accel -200)
-- t=0.8 ring slam
meshEmit(102470267627424, start {28.5,52.7,26.9} y+39 -> end {106,84,100} rot118, 0.1s, transp .7->1)
meshEmit(129778117978668, start {61,20,63} y+9.5 -> end {93,0.9,96} rot142, 1s, transp .9->1, rate 5 for .3s, initRotY 0..360)
-- t=1.3 beam
decalMesh(cylinder 137685697016553, scale (.13,.2,.13)->(0,.1,0), 1s, scaleCurve bezier(.95,.05,.795,.035))
decalMesh(twisted 106381405601872, same curve, ZIndex 3)
burst(flare 9504165696 #FF5CDC squash 3->-3 speed 228 drag 2, life .05-.1; spikes 12800351319 life .03 rate 50 for .6s)
burst(black smoke 15222191191 B5 size {0:0 .07:29.5 .19:54.8 1:76}, life .3-.6)
meshEmit(71849885439764, start {58,63,54} y+31 -> end {121,11.6,125} rot183, transp .9->1)
```

## 7. Candidate principles
1. **Charge → slam → release, with explicit beats** (0 / 0.8 / 1.3 s). Each beat is a new layer set. Nothing just runs continuously.
2. **Camera shake fades in during a charge** (FadeIn 2 s) and fades out quickly after (0.3 s).
3. **HDR decal Color3 (2–40×)** turns meshes into glowing energy without Neon-white blowout. Two ZIndex-stacked decals give a hot core and a cool rim.
4. **Beams hold and then snap** (ease-in on width), and are built from a mesh pillar with a scrolling or flipbook decal plus streak particles.
5. **0.1 s mesh = impact frame; 1 s mesh = follow-through.** Fire both together.
6. **Ground rings drop as they expand** (End below Start) and flatten to a disc.
7. **Strobe** with Lifetime 0.03–0.1 and a high Rate for electric energy.
8. **LightEmission -10 at high Brightness** for saturated, non-clipping color.
