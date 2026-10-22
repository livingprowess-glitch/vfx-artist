# Modern Roblox VFX principles (v2, full corpus)

These come from all 11 breakdowns in `../breakdowns/`. The tags in brackets name the breakdowns each rule was seen in:
- **W** Water (WaterPractice/VFX1/VFX2/BALLVFX)
- **MF** MeshFlipSUCCESS
- **St** Startup
- **SV2** ShapeAndValue2
- **WS** Wind_Smoke_OS
- **SS** StarStruck
- **Sp** spin
- **Ar** arrow
- **UD** Up_Down
- **Da** Dash
- **SVP** ShapeAndValuePractice

A rule seen in 3 or more effects is a **house rule**. Fewer than that is a **technique**.

## A. Structure and timing
1. **Use beats, not loops (house rule).** Every element is a disabled emitter fired as a burst (EmitCount/EmitDelay/EmitDuration). The beats run in this order:
   - anticipation (≈ −0.05 s)
   - impact frame (≤ 0.1 s)
   - body (0.1–0.6 s)
   - residue (0.5–2 s)
   - Charges use their own order: charge, then slam, then release.
   [all]
2. **Separate the impact from the mass by one frame.** Fire the secondary group at EmitDelay 0.05. Fire an anticipation glint cluster one beat before the hit. [SVP, SV2]
3. **Lifetime alone can stagger timing.** Up/Down use 181 emitters and zero delays. Fade-in transparency curves (peak at around 0.27 s) give a delayed afterglow. [UD]
4. **Use three mesh time bands:** hot (≈0.2 s), body (≈0.5 s), residue (1–2 s). About 15 mesh layers make one modern hit, not one ring. Hot layers start opaque. Residue starts at 0.9–0.96 transparency and lives 5–10× longer. [SS, Sp, MF]
5. **Big effects are repeated units with baked delays.** Clone one stroke, write EmitDelay = n·step onto every child, and fire the arrival impact as a full copy of the origin impact, delayed by the travel time. Chain the strokes so each arrival overlaps the next departure. [SS]
6. **Reuse kits.** Re-instance blocks at a scale (×1 / ×1.28 / ×1.7 / ×2.95) via `ScaleParticles(k)`, scaling Size, Speed and Acceleration together. When an impact fires N times at once, cut its EmitCount to about base/N. Changing only spread and count changes the read (radial puff vs directional kick). [Ar, Da, W, UD]
7. **Directional variants are a rigid rotation plus hand re-dials.** Rotate the rig, then fix the values that live in screen or world space: 2D Rotation, RotSpeed sign, floor placement. World Acceleration is physics, so it does not rotate. [UD]
8. **Time lights and camera to the effect:**
   - PointLight on only for the effect's duration (huge Brightness with a short Range for orbs; Range 30 with Shadows for fire).
   - Camera shake fades in during a charge (2 s) and out fast after (0.3 s).
   - A screen flipbook stays ≤0.6 opacity and lasts 0.15 s.
   [MF, SV2, W]

## B. Value and color
9. **One dominant hue (house rule).** It varies by value and Brightness. The dominant color gets **3–10× the Brightness, not more particles**. Everything else is neutral grey or black. [all]
10. **Dark twins (house rule, found in every effect).**
    - Every bright layer has a dark copy: Brightness 0 (which renders black), #000000, a dark shade of the hue with LightEmission 0, or negative LightEmission.
    - Give the twin a slight offset (half gravity, ZOffset −0.001, TimeScale 0.6, a different Squash) so it shows as an edge, a rim or a trailing shadow.
    - A dark twin of the shape costs nothing.
    - **Value comes before color.**
    [all]
11. **Saturated bodies use LightEmission 0 (or negative), with value set by Brightness.**
    - LightEmission −1 to −10 at Brightness 25–500 keeps dense overlaps saturated instead of clipping to white. Negative transparency keys (down to −50) are used too.
    - Additive blending (LightEmission 1) is reserved for thin glows, beams, trails and blooms.
    [W, MF, St, Ar, UD, SVP]
12. **Fade color to black, not only to transparent.**
    - Fire color sequences end at #000 or #340803.
    - Trails run color → black along their length.
    - Beams ramp black → color, which leaves a dark rim at the leading edge.
    - Wind rings darken over life.
    [St, SV2, UD, SVP, WS]
13. **Hue-shift births and deaths.**
    - Blue → red in the first ~15% of life reads as hotter than red, without using white. [UD]
    - Hero particles shift toward the complement over their life (orange → red → mint). [Sp]
14. **The complement is the accent, held to thin, short or small layers.** It can carry the **hottest** pixel (an orange core at Brightness 40 for 0.05 s inside a violet effect, orange trail cores at Brightness 60 for 0.12 s) but never the mass. [SS, Ar, St]
15. **Warm inside, cool outside** (an orange dome nested in a blue one). [SVP]
16. **Matter is lit, energy is emissive.**
    - Smoke, dust and debris use LightInfluence ≥ 1 and LightEmission ≤ 0.55, with warm and cool twins.
    - Recolor debris for its background: green on the ground, black against the sky.
    [WS, Ar]
17. **Never let pure white be opaque.**
    - White and #F8F8F8 Neon is only allowed as a ≥ 90%-transparent sheen.
    - Mid-value Neon grey (#A3A2A5 / #A2A2A2) is the default body for big mesh envelopes.
    - Saturated Neon is reserved for ≤ 0.2 s hot meshes.
    - A glowing shell uses a mid-value color (#2268A5, not #2F66FF).
    [Sp, SS, Da, SVP, W]

## C. Meshes
18. **Meshes are translucent volume (house rule).**
    - Peak opacity is 2–30%: Part_Transparency_Start 0.7–0.97, or decal 0.8 → 1.
    - Only meshes that live ≤ 0.15–0.2 s get near-solid.
    [all]
19. **Glow comes from decal-on-mesh with HDR `Decal.Color3`** (2–40, or a single channel at about 10 for a saturated hue).
    - The Part and MeshPart stay at Transparency 1, and only the decal fades.
    - Decals can carry 16-frame flipbooks.
    - **One ring mesh (8501563708) is reused about 52 times** with different textures, HDR levels and black copies.
    - Other options: `SurfaceAppearance` with AlphaMode Transparency, or a negative SpecialMesh.Scale to view a tube from inside.
    [MF, SS, Ar, Da, St, SV2]
20. **Use broken, asymmetric geometry:** torn spiral ribbons, wavy and tilted rings, twisted columns, crumpled shells. A primitive is only used stretched ×5–×9 on one axis or wrapped in a broken decal. Ring "meshes" can even be built from tangential emitters on a broken circle (one quadrant skipped). [textures.md, SV2, SS, UD]
21. **Use anti-correlated, non-uniform scale (house rule).**
    - One axis shrinks ×0.02–0.4 while another grows ×1.5–9.
    - Typical moves: ring → needle, needle → ring, column → disc, lens → dome, torus → tube.
    - Kill a mesh by **thinning it to 0** as well as fading it.
    - **Uniform scale is the outdated "bubble" look.**
    [W, MF, St, SV2, SS, Ar, Da]
22. **Shape eases out and finishes early** (≥75% of the change in the first 20–40%).
    - Hot meshes fade linearly, so the opacity leaves steadily after the shape is done.
    - Residue meshes fade on outCubic.
    - Beams and pillars that must hold and then cut use a strong ease-in (inQuint / bezier(.95,.05,.795,.035)).
    [all, SS]
23. **Rotation is part of every expansion (house rule).**
    - Start → End yaw is 40–195°, and shells rotate as they scale.
    - Spin decays (RotSpeed 5 → 0.3, 135 → 63) or stays constant on slow ghosts. It never stays constant on hot layers.
    - Every copy gets a random initial yaw (`MaxInitRot (0,360,0)`).
    [all]
24. **Use push-pull motion.** About half the mesh layers travel forward and half implode or travel back. Shrinking flashes (40 → 0 in < 0.1 s) run together with exploding rings (0 → 45). [SS, St]
25. **Ground rings drop as they expand. Rising bands start under the floor** and twist about 165° as they grow. [MF, St, Ar, Sp]
26. **Pulse rather than tween once.** Re-emit a ring template at Rate 5–10 for about 1.4 s with random yaw. Stack shells with staggered durations and spin rates (fast, mid, slow ghost). Use random EffectDuration (a NumberRange) so repeats de-sync. [Ar, Sp, SS, Da]
27. **Speed is shown with world-anchored stamps:** dash rings spawned at Rate 5 and left in place, so their spacing shows the velocity. Muzzle/recoil shells are thrown along the action line, lengthening while pinching. [Da, Ar]
28. **Nest two offset copies** (in depth, or at ×0.75) for a stepped silhouette. [SVP, St]

## D. Particles
29. **Flipbook sheets carry the motion** (Grid4x4/8x8/Custom, OneShot, 16–64 fps). [all]
30. **One hero burst = several textures × EmitCount 1,** sharing curves. A starburst gives each emitter its **own Squash curve**, so no two lines match. [Sp, Ar, St]
31. **Burst kinematics:** high Speed with Drag 5–10 and gravity; Size `0 → peak@~20% → 0`; TimeScale 0.75–0.95. [W, SV2]
32. **Lay stationary cards flat** in the effect plane: Speed 0.001–0.1 with VelocityPerpendicular, and the emission axis equal to the plane normal. [W, SV2, UD]
33. **Make a whirl with centripetal acceleration:** tangential EmissionDirection, LockedToPart, and Acceleration pointing at the center. Don't spin the emitter. [Sp]
34. **Shape language goes sharp → round → dots.** The sharp read is the shortest-lived, largest and on top (ZOffset 5). Stretch for speed (Squash −1 to −3 or wedge → needle, VelocityParallel, 0.03–0.1 s). Fire stays upright (±20°) while debris spins freely. Smoke gets a Squash bulge-then-settle. [SVP, SV2, Da, MF]
35. **Strobe energy:** Lifetime 0.03–0.1 at a high Rate. [MF]
36. **Smoke:** a transparency floor of 0.6–0.7 with keypoints above 1, a flat radial throw for ground dust, and black grains. [WS]
37. **Scatter area hits with one emitter on a big invisible box.** Use one texture set at two time scales: fast streak and slow residue. [Ar, Da]
38. **Sustained riding particles fade in and out (`1 → 0 → 1`),** so nothing pops. [SVP]

## E. Beams and trails
39. **Beam = 3–4 stacked textures at different TextureSpeeds** (parallax), with spatial transparency rooted at the origin and a width that holds and then snaps. [SV2]
40. **Rotation and wake beams are S-curves** (opposite CurveSize signs) with an opening width (Width0 ≪ Width1, e.g. 6 → 90), a decelerating texture scroll, a 180° roll between ends for twist, and transparency 1 at both ends. [Sp, Da]
41. **A sheath beam at Brightness 0.1 additive** suggests volume through overlap only. [Da]
42. **A projectile is trails plus a head flare, not a mesh.** Trail stack:
    - a gradient body trail
    - a core trail at half the lifetime and twice the Brightness in the accent hue
    - black twin trails
    - Width tapers `0 → 1@50% → 0` on bezier paths.
    [Ar, St, SV2, Sp]
43. **Build a 3D silhouette from converging beam strokes**, and ink it with FaceCamera outline beams. [SVP]

## F. Rigging and authoring
44. **Rotate only the root.** Parent everything that rotates to one root with Motor6Ds. Spin it with Forge `SpinRotation`/`SpinSpeed_*`. [Sp, St, W]
45. **Ripple ground props in rings,** with one ring delayed and size growing with radius. [Sp]
46. **Production hygiene:** strip editor-only Highlights (red, AlwaysOnTop, disabled) and layers muted to Brightness 0 that aren't meant as twins. [SS]
