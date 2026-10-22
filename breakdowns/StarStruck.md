# StarStruck (Workspace.modern_vfx.StarStruck)

Source: Place3 "vfx training" (114773467389373), studied 2026-10-22 from dumps of `StarStruckLine1.boom` and `StarStruckLine1.Meshes`, plus probes of the geometry, delays, colours, line-to-line diffs and `u4_effects.EmitMesh`. One Ropilot capture of Line 1 (top view) was used to confirm the impact read. Ropilot's preview runtime does not play the Forge mesh/beam tweens, so the mesh analysis comes from the data, not the capture.

Inventory: 1,222 instances. Root `Part` plus 5 `StarStruckLineN` models. Each line holds:
- `boom`: an invisible 1.3-stud Part. It carries 66 emitters at the origin, 4 beams, and a second identical 66-emitter impact at the far end of the beam.
- `Meshes`: 16 Start/End mesh models.

Line 1 also has `Meshes.Whirlwind` (a beam-only model) that the other lines lack. Totals: 5 x 132 = 660 emitters, 5 x 16 = 80 mesh models (+1 Whirlwind), 5 x 4 + 8 = 28 beams, and 10 Highlights (all disabled, 2 per line on W3Decal).

## 1. Read
A violet-and-orange energy slash **draws a five-pointed star on the ground, one stroke every 0.15 s**. Each stroke is the same unit:
- a hard violet-white impact pops at the stroke's start;
- a beam slashes about 85 studs across the star;
- a tunnel of twisting, stretching meshes shoots down the stroke;
- 0.1 s later a second identical impact lands at the far vertex. That vertex is where the next stroke starts 0.05 s after.

The eye is dragged **vertex → vertex around the pentagram**. Every arrival pops, and every pop launches the next line. The peak is the fifth stroke (t ≈ 0.6–0.8 s), when all five strokes' residue overlaps and the star shape reads as a whole. The residue is long faint beam "shards" (up to 2 s) and slow neon-grey/white mesh swirls (1–2 s) that hold the star's outline after the hits are gone.

## 2. Timeline
All lines are identical apart from their CFrame and delays. Each line's delay `D` is 0, 0.15, 0.30, 0.45 or 0.60 (`StarStruckLineN@EmitDelay`), and it is **baked onto every emitter, beam and mesh model** inside the line, not only the parent model.

| t (s) | layer | what happens |
|---|---|---|
| D + 0 | origin impact (66 emitters, about 140 particles) | 1-to-3-frame flash: `Hit` orange Br40 for 0.056 s, `vfxtuff` orange shrinks 30→0 in 0.045 s, violet `glow` Br15 for 0.085 s, and `Flash` shrinks 40→0 in 0.094 s. Rings, sparks and smoke follow. |
| D + 0 | 4 stroke beams (A1→A2, 85.5 studs) | `Beam Slash 2` (orange) and `Beam Slash 1` (dark violet) collapse from Width0 200 over 0.2 s / 0.4 s with outCubic. `Shards` beams start at the same moment and linger for 1.7 s / 2.0 s. |
| D + 0 | 16 mesh models | fire together. The 0.2 s hot neon cones/rings and the 0.4–0.7 s decal streaks and dark swirls give way to 1–2 s faint residue. |
| D + 0.0–0.2 | fast layers | sparks (68–170 st/s, gravity −129), ThickRing/HardRing spin at about −900 °/s, and the 0.2 s mesh cones peak and finish. |
| D + 0.1 | end impact (the same 66 emitters at A2, delayed +0.1) | the beam "arrives" and the far vertex pops. |
| D + 0.15 | next line's origin | starts about 5 studs from where this line's end impact sits (the vertices overlap with jitter), so every vertex pops twice in 0.05 s, as a double hit. |
| D + 0.3–1.0 | mid residue | smoke `2` x3, `filler` haze (0.6–1 s), `Glow` 1.6 s halo, Spin2-white (1 s), W (1 s) and Wind-decal (1 s). |
| D + 1.7 / 2.0 | beam shards | `BeamSlight shards` fade (Transparency_Scale 1→2), so the star's lines are the last thing visible. |
| 0.6 + 2.0 = **2.6** | end | W4 (2 s mesh residue) and shards of Line 5 finish. Destroy at about 2.7 s. |

The short 0.15 s cadence matters. Five strokes take only 0.6 s, so the star reads as one gesture, but every stroke is still a distinct hit. The 0.1 s travel delay matches the beam's fast outCubic collapse: at 0.1 s outCubic is about 87 % done, so the beam has visibly "arrived" when the end impact fires.

## 3. Layer stack

### 3a. Geometry (per line)
- **Pentagram:** each stroke runs A1→A2 (85.5 studs) and lies flat at Root Y +0.08. The vertices sit about 43–46 studs from Root, at polar angles of about 0.6°, 211.8°, 74.4°, 284.3° and 146.5°. That is 72° spacing, visited by skipping every other vertex (0→2→4→1→3), the classic one-stroke star. Line N's A2 lands within about 5–8 studs of line N+1's A1.
- `boom` sits on the stroke, 8 studs inside A1 (A1 is at BeamLaunch local x −7.985). So the beam overshoots the impact slightly behind the hit. That is anticipation: the slash visibly starts before the impact point.
- `boom` rot is (0, yaw, 180), upside-down. The impact attachments carry compensating rotations (`boom` (−76.9, −18.5, 16.9), then `explosion` (77.4, 9.5, 5.5), then `Whitewind` (−82.5, 97.5, 90)). These orient the VelocityPerpendicular ring/wind layers to lie **flat on the ground plane**, facing up.
- `BeamLaunch` attachment (same parent) puts A1 at x −7.985 and A2 at x +77.523. The end-impact copy hangs under A2 at local (−4.078, −0.27, −0.15), so the arrival pop lands 4 studs short of the beam's tip.
- `Meshes` pivot = boom × CFrame(15.48, 0, 0) × rotZ(+90°). **Mesh-local −Y = forward along the stroke.** Below, `d` = forward distance from the impact origin = 15.48 − local Y.

### 3b. Origin impact (the same at A2 with +0.1 s): 66 emitters, about 140 particles
Groups are listed by attachment. Ex = EmitCount (fractional counts are floored by the runtime), Li = Lifetime, LE = LightEmission, Br = Brightness, Z = ZOffset.

**Core flash (`boom.explosion.Slam.Main`, Z 2–4, frames 0–5)**
| emitter | texture | color | key values | why |
|---|---|---|---|---|
| Hit | 17265977573 (2x2 flipbook, 7.27 fps) | #FF643D orange | Br 40, Li 0.056, size 0→22.7 | 3-frame hot core. **Orange inside a violet effect**: the complementary hue makes the hit's centre the warmest, highest-value point. |
| Impact2 | 17265977573 | #6633FF | Ex 3, Br 7, Li 0.085 | the same flipbook in the body color, a little longer, so the orange core sits inside a violet bloom. |
| glow (x2) | 1075864321 | #6633FF | Br 15 / Li 0.085, Br 5 / Li 0.512 (Transparency 0.67→1) | a fast big flash plus a slow dim halo. The same texture at two durations gives a hit-then-afterglow. |
| Flash | 130893832871890 | #6633FF | Ex 2, size 39.6→0 (shrinking), Li 0.094, VelocityParallel | **shrinking**, not growing, flash: it reads as energy collapsing into the point. |
| Spec | 17826438728 (4x4) | #FF5739 | Ex 2, RotSpeed ±1216, Li 0.41 | a spinning orange star-glint. It carries the warm accent past the first frames. |
| Sparks | 16002249604 | #6633FF | Ex 10, speed 68–170, Accel Y −129, Drag 4.8, VelocityParallel, Br 30, TimeScale 0.95 | streaks thrown out and pulled down by gravity. Drag 4.8 kills their speed fast, so they splash instead of flying off-screen. |
| 2 (x3) | 10859315454 smoke | #000000 LE −0.4 Br 0 / #6E6E6E LE 1 Br 3 / #6E6E6E LE 1 TimeScale 0.67 | Li 0.25–1.17, slow RotSpeed | **a dark twin and two grey glowing twins** of one smoke texture. The black copy gives the bright copies an edge to read against. |
| Roar | 10039693328 | white | size 0→47, Li 0.3, LE 1 | a big white distortion puff. It sets the impact's footprint size. |

**Ground rings / wind (`Slam.Attachment.Whitewind`, flat to the ground)**
| emitter | texture | color | key values | why |
|---|---|---|---|---|
| winds (x4) | 109440284900004 (4x4) x2, 10149702982, 11820076505 | #F4F4F4 | one copy has Br 0 / LE 0, which renders it **black**, and its twin has LE 1. Size 0→29, Li 0.3–1.15, TimeScale_Duration 0.076. | flat wind puffs. The same flipbook as a dark twin plus a glowing copy. |
| ThickRing | 6862984716 | #000000 | Ex 2, size 0→13.9, RotSpeed −883..−589, TimeScale 0.8 | a **black ring under the coloured ring**: the same texture, smaller and slower. |
| HardRing | 6862984716 | #7958FF | Ex 2, size 0→17, RotSpeed −1050..−700, Br 10, Z 1, TimeScale 0.7 | the coloured shock ring. It spins the same direction as the black one but faster, so the two slip against each other. |
| FatImpact | 8048608283 | #7958FF | Ex 4, Br 10, TimeScale 0.7, Transparency 0→0.07 at 13.7 %, then a fast fade | a thick body burst. A slowed TimeScale is the "hang". |
| ParticleEmitter2 | 99457144599783 | #7958FF | size 0→45 in 0.5 s, transparent by 5 % | a one-frame huge violet wash. It lights the ground area. |
| ENERGYYY | 97130732091369 (8x8) | #7958FF | Ex 2, speed 12–24, Accel Y +29.6, Z −1, LockedToPart | rising energy wisps. Z −1 keeps them behind the core. |

**Contrast/shape stack (`Slam.z`, Li ≈ 0.3)**
- `wadwawdad` x3: 88904091359499, #000100 near-black, Br 0, size 0→14/17/20 at Z 0/0.7/0.7. This is a **dark backing plate** under the whole impact, so the glow layers have a black edge to sit on. The three sizes give it a soft ramp.
- `goodshockwa`: 81831254526415, #000000, 0.3 s. A dark shockwave.
- `Impact4` x2: 78043674430474, #411212 and #CB4625, both Br 0, so both render dark. Two more dark shapes.
- `vfxtuff`: 130039509044466, #FF864E orange, size 30→0 in 0.045 s. A one-frame orange pop.
- `best wind` x2: 17409991165, #393939 Br 7 (0.1–0.2 s, VelocityParallel) and white (0.6–1 s, spinning). A quick dark streak, then a slow white swirl.
- `Wind` x2: 15380148205, #ABABAB, Transparency 0.75. Faint grey swirl filler.
- `spec` sub-attachment (11 emitters, Li 0.04–1):
  - `flipbook` 125377110978480 (#6D53FF) and `ParticleEmitter` 73635973004302 (#FF843C 4x4): violet and orange twin flipbooks with the same size curve, layered.
  - `_33,1_2` x2: 16879806460, #6D53FF, Ex 4, speed 32–61, Br 20. Secondary glitter.
  - `Transparenct Blast 1`: 15846370432, #6D53FF, and `ParticleEmitter`: 131637240475311, white. Expanding blasts with the Forge `Size_Curve bezier(.372,.832,.568,.777)` and `Transparency_Start .4`.
  - `circle`: 13911306541, #646464. `Impact1`: 15333808121, #A1A1A1. Both grey.
  - `Impact16` (#29A72F) and `Full Shockwave` (#48FF34) are **green, but Br 0**: they are muted to dark. These are leftovers from a green source effect, killed with Brightness instead of being deleted.

**Afterglow (`boom.Glowy`, Z 3, 0.06–1.6 s)**
- `Fading Glow` (107821950776778, #FF7E3E, 0.4 s), `Flare Twinkles` (96013523226630 4x4, #FF7F23, 0.15 s) and `vfxtuff` (#FF9E49, 0.06–0.1 s) form a **warm orange centre that outlives the violet flash**.
- Nested `Glowy`:
  - `filler` x3 (12937922388 #559EF6, 15694384576 #D0E5F2, 71260831432005 white): Br 0.05, LE 0.98, Li 0.6–1, size to 24–36. A **cool, near-invisible haze** that fills the gaps between hits.
  - `Impact1` x4 (6763809313, 13051695094, 14813420032, 10598374841): #7945EA / #3B6FEA, Squash 0.3–3, Li 0.03–0.25, Z −1, LockedToPart. Squashed streak flashes behind everything.
  - `Glow` x3: 129922860680208 #8546F2 with Squash 0→3 (Ex 5); 72485468908363 #6687F2 with Li 1.6, size 1→25 outCubic, the **longest-lived halo**; 13992197350 #6687F2 4x4.
- `Spin` attachment:
  - `Swirls15` 125315542080455 and `Simple Stylized Swirl` 118331182227573: #774EFF, RotSpeed 1000, Li 0.5.
  - `Glow` x2.
  - `Bold.b`: 13115734886 4x4, LE −1.
  - `Bold.Fire`: 4 violet glows. One is 139851738398320 with Br 50.
  - `C1` x2: 85519442962093, Ex 15 at LE −2 and Ex 5 VelocityParallel, speed 13–77. Two tiers of violet debris.

Negative LightEmission (−0.4, −1, −2) shows up exactly on the "dense" copies (the smoke twin, `b`, and C1). The author uses it to make a same-hue layer read **darker and more opaque** than its additive siblings. It is a value tool, not a color tool.

### 3c. Stroke beams (`BeamLaunch` A1→A2, FaceCamera, Segments 360)
| beam | texture | color | widths (Forge) | life | why |
|---|---|---|---|---|---|
| Beam Slash 2 | 13821091893 | #FF9130 LE .4 Br 10 | W0 200→(25.5), W1 6→(0), outCubic | 0.2 | a fat orange slash that collapses onto the line. Its transparency peaks mid-line (0.5), so it reads as a swoosh, not a bar. |
| Beam Slash 1 | 12991508490 | #5420AF dark violet, LE .5, Z −.05 | W0 200→(25.5) | 0.4 | a **dark body under the orange slash**. Its transparency goes 1→0 toward A2, so it darkens toward the arrival point. |
| Shards (violet) | 12781855094 | #6030FF Br 20 LE 0 | W0 60→15, W1 15; TexLength 1→0.1, TexSpeed 5→0.4, Transparency_Scale 1→2 | 1.7 | the lingering star outline. Shrinking TextureLength compresses the shard pattern, so it reads as a decelerating crackle. |
| Shards (orange) | 12781855094 | #FF5F37 LE .35 | W0 50→10, W1 5; TexSpeed 1→0.1 | 2.0 | a warm copy that is 0.3 s longer, so the star fades violet → orange at its very end. |

`(x)` = no `_End` attribute, so the beam is presumed to tween to its authored property value.

## 4. Mesh VFX detail (the part to copy)
16 mesh models per stroke. All have EmitCount 1, `#ConstantVFX`, outCubic CFrame/Size curves (`bezier(.215,.61,.355,1)`) and Part_Transparency_End 1.

**A missing `Part_Transparency_Start` means 0, fully visible.** Forge only writes non-default values, and `u4_effects.EmitMesh` defaults StartTransparency to 0 as well. Start/End parts sit at Transparency 1 in the editor only so the template is invisible.

Axis convention: mesh Y = along the stroke. d = forward distance from the impact.

| model | mesh / decal | color / material | Start → End (size; d) | rot delta + spin | dur | transp | role / why |
|---|---|---|---|---|---|---|---|
| Spin2 (orange) | 5922911630 (flat twisted ring, MeshSize 6.6x1x6.3), DoubleSided | #FF8D60 Neon | 31x17x31 → 12x54x12 (cross ×0.39, length ×3.1); d 10→37 | Y −90→+30 (+120°), RotSpeed 5→0.3, random init Y 0–360 | 0.2 | 0→1 **linear** | the hot **drill**: a wide short ring stretches into a long thin tube while it twists, so it reads as a spiral bore shot down the line. |
| Spin2 (blue) | 5922911630, single-sided | #6A85FF Neon | 21x16x21 → 10x53x10; d 9→35 | +165°, the same spin | 0.4 | 0→1 linear | a cooler, thinner, 2x longer copy **inside** the orange one. It leaves a blue tail after the orange drill dies. |
| Spin2 (white) | 5922911630 | #FFFFFF Neon | 15x59x15 → 31x14x31; d 32→12 (**backward**) | −45°, the same spin | 1.0 | 0.95→1 | the reverse of the drill: a long tube collapsing back into a ring at the origin. A faint recoil/residue. |
| Model (blue cone) | 113322248153294 (dome/cone, 196x79x196), DoubleSided | #6078FF Neon | 42x20x42 → 5.6x22x5.6 (cross ×0.13); d 11→30 | 180° flip, Spread (10,10) | 0.2 | 0→1 outCubic | a funnel that **pinches** to a spike while flying forward. It sells direction in 12 frames. |
| Model (grey disc) | 113322248153294 | #A3A2A5 Neon (default grey) | 54x11x54 → 1.7x2.7x1.7 (×0.03); d 15→20 | 180°, Spread 10 | 1.0 | 0.9→1 | a huge faint plate **imploding** to a point. Mid-value glow (grey Neon), so it never competes with the core. |
| Model (black shell) | 74181482131152 (rounded shell, 49x42x50), DoubleSided | **#000000 Neon** | 14x6x15 → 44x17x46 (×3.1); d 18→12.5 | 180° | **0.2–0.5 random** | 0.6→1 | a **dark expanding mass** behind the bright cones. Value contrast in 3D. The random duration keeps 5 strokes from fading in lockstep. |
| Wind (decal) | SpecialMesh 122638957149603, **scale negative** (−0.018,−0.011,−0.018 → −0.249,−0.261,−0.249), Offset Y .21→−5.23; Decal 84938636872942 Face Right | Decal Color3 **(21.8, 21.8, 21.8)** HDR | ×14 cross, ×24 length; d 23→18 | −45° | 0.2 | **decal** 0.8→1, part 1→1 | a wind ring. A negative scale turns the mesh inside out, so the decal reads from the inside. A Color3 of 21.8 makes a decal at 80 % transparency still bloom white. |
| Wind (ring) | 95063569401865 (flat ring, 50x5.9x50), DoubleSided | #A3A2A5 Neon | 3.8x7.5x3.8 → 28x0.8x28 (×7.4 cross, ×0.1 length); d 21.5→18 | – | 0.2 | 0.7→1 | a **sonic-boom ring** perpendicular to the stroke. A tall needle flattens into a wide disc. |
| Wind (decal 2) | SpecialMesh 103992871225921, scale (−0.001,−0.015) → (−0.271,−0.114), Offset Y 0→−8.14; Decal 74266965397559 | Decal Color3 21.8 | ×270 cross, ×7.6 length; d 21→20 | −135° | 1.0 | decal 0.7→1 | a slow wind swirl that grows from a point. The 1 s residue. |
| Wind (needle) | 95063569401865 | #A3A2A5 Neon | 2.9x37x2.9 → 22x1.1x22; d 39→16 (backward) | Spread (5,5) | 0.2 | 0.7→1 | a long speed-line needle **snapping back** into a ring at the origin. |
| W | 87273433428492 (wide swirl shell 44x14x50), DoubleSided | #A3A2A5 Neon | 20x8x22.5 → 58x71x65 (×2.9 cross, ×8.9 length); d 10→25 | Y +50 → −90 (−140°) | 1.0 | 0.5→1 | a big grey twisting envelope around the whole stroke. It is the mid-value "body" of the mesh tunnel. |
| W2Decal | SpecialMesh 8501563708, scale (0.92,1.37,1.33) → (2.81,0.23,0.22); Decal 9581481497 Face Top | Decal Color3 **(0.35, 0.47, 10.0)**, overbright blue only | long ×3.1, cross ×0.17; d 23→34 | ~+40° | 0.5 | decal 0→1 (default start) | a **stretched blue slash** that gets longer and thinner. The B channel at 10 gives a saturated electric blue without white-out. |
| W3Decal | the same mesh and decal | Decal Color3 (3.7, 3.7, 3.9), near-white HDR | long ×1.6, cross ×5.4; d 22→47 | +85° | 0.7 | decal 0.8→1 | the inverse of W2: a thin streak that **fattens** into a puff downstream. Carries 2 disabled Highlights (red fill .5, white outline, AlwaysOnTop): **an authoring aid to see the invisible part in the editor, not a runtime layer**. |
| W4 | 4681227436 (swirl, 11x8.7x11), DoubleSided | #FFFFFF Neon | 31x26 → 57x48 (×1.8); d −1.5→27 | Y flip, RotSpeed 10 | **2.0** | 0.963→1 | barely visible long spin. The final residue that keeps the line alive. |
| W5 | 4681227436 | #FFFFFF Neon | 20x8 → 65x42 (×3.3/×5.4); d 38→14 (backward) | upside-down flip, RotSpeed 10, Spread 5 | 0.5 | 0.9→1 | a swirl rushing back toward the origin while it grows. |
| Spin (black decal) | SpecialMesh 136867373491158, scale (0.9,3.4) → (5.65,15.3); Decal 13530571563 | **Decal Color3 #000000** | ×6.3 cross, ×4.5 length; d 48→27 (backward) | RotSpeed 3 | 0.7 | decal 0→1 (default) | a **black spinning swirl**: the dark twin of the bright tunnel, travelling the opposite way. |
| Whirlwind (Line 1 only) | invisible Part (Part_Transparency 1→1) carrying 4+4 beams | beams 124753331461910 / 92479326699673, #FF7A21, LE .6, Br 10 | Part 3.4 → 0.64, −165° | 4 beams fan at 45° from a hub with CurveSize ±10, TexSpeed −15 / −1 | 1.0 (beams 0.2) | beams only | an orange 4-arm spiral burst on the first stroke only. It is the "opening flourish". |

Structure of the mesh stack, in order of importance:
1. **About 16 mesh layers per hit, not one.** Three bands:
   - **hot** (0.2 s, fully opaque at the start: orange drill, blue cone, black shell, two rings, wind decal);
   - **body** (0.4–0.7 s: blue drill, W2/W3 decal streaks, black Spin, W5);
   - **residue** (1–2 s, starting at 0.9–0.96 transparency: white drill, grey disc, wind decal 2, W, W4).
2. **Push-pull.** About 8 layers travel forward (d grows) and about 7 travel backward or implode (d shrinks or the size collapses to a point). The opposite motion gives a single stroke depth and "suck-and-blast" energy instead of everything drifting one way.
3. **Non-uniform scale is the motion.** Almost no layer scales uniformly. Cross-section and length move in opposite directions (×0.13 cross while length holds, ×0.1 length while cross ×7), so a ring becomes a needle and a needle becomes a ring. That is what reads as speed.
4. **Twist plus spin.** Start→End rotation deltas of 40–165°, plus Part_RotSpeed 5→0.3 (fast, then settling) and random initial yaw, so 5 strokes never look stamped.
5. **Decal-on-mesh for texture.** The textured layers are invisible Parts with a SpecialMesh and a Decal. Visibility runs through the decal's Transparency_Start/End, and the decal Color3 is **HDR** (3.7–21.8, or a single channel at 10) so a mostly-transparent decal still blooms. A negative SpecialMesh scale flips the mesh inside out so the decal faces the camera from inside the tube.
6. **Neon colour by value role.** Only 2 meshes are saturated hue (orange #FF8D60, blue #6A85FF/#6078FF). The rest are **default-grey Neon #A3A2A5** (mid-value glow), **white** at 0.9–0.96 start transparency (faint), or **black** Neon (the dark mass). No mesh is pure white at low transparency.
7. Easing: all CFrame/Size are outCubic. The hot spiral meshes fade **linearly** (Part_Transparency_Curve linear) while their shape eases out, so they lose opacity steadily while their shape has already arrived. The rest fade outCubic (mostly gone early, long faint tail).

## 5. Color & value
- **Body (violet):** #6633FF, #7958FF, #6D53FF, #774EFF, #7945EA, #8546F2, #6030FF. Dark body #5420AF.
- **Cool support (blue):** #6078FF, #6A85FF, #6687F2, #3B6FEA, #559EF6, #D0E5F2. Decal HDR (0.35, 0.47, 10).
- **Warm accent (orange):** #FF643D, #FF5739, #FF5F37, #FF7A21, #FF7E3E, #FF7F23, #FF843C, #FF864E, #FF8D60, #FF9130, #FF9E49.
- **Neutrals:** #F4F4F4, #ABABAB, #A3A2A5 (Neon grey), #A1A1A1, #6E6E6E, #646464, #393939.
- **Darks:** #000000, #000100, and anything at Brightness 0 (#411212, #CB4625, the green leftovers, one winds copy).

Value structure:
- the **hottest point is orange**, not white (`Hit` Br 40, `vfxtuff`, `Spec`);
- violet is the body (Br 5–20);
- blue is the cooler secondary that lingers (filler haze, blue drill, blue cone, W2 decal);
- grey Neon is the mid-value volume;
- black is the backing: 3 wadwawdad plates, ThickRing, goodshockwa, the black smoke twin, the black shell mesh, the black Spin decal.

Warm/cool split by time: the orange core and orange beam die first (0.05–0.2 s), the violet body survives to about 0.5 s, the blue/white residue survives to 1–2 s, and the orange shards reappear at the very end (2.0 s vs violet 1.7 s), so the effect closes on the colour it opened with.

LightEmission strategy:
- LE 1 on glows/wind;
- LE 0–0.5 on rings and sparks, which keeps them saturated instead of washing to white;
- **negative LE** on the dense twin of a layer;
- **Brightness 0** to turn a coloured texture into a black shape without changing its texture.

## 6. Rebuild recipe (Forge-schema runtime)
```lua
-- template: StarStruck { Root, Line(1..5) }, each Line = { boom(Part), Meshes(Model) }
local STROKE_GAP, ARRIVE = 0.15, 0.1
local R = 45                                                        -- vertex radius
local order = {0, 2, 4, 1, 3}                                       -- pentagram vertex order
local function vertex(i) local a = math.rad(i * 72) return Vector3.new(math.cos(a) * R, 0, math.sin(a) * R) end
for n = 1, 5 do
	local a, b = vertex(order[n]), vertex(order[n % 5 + 1])
	local dir = (b - a).Unit
	local D = (n - 1) * STROKE_GAP
	local boomCf = CFrame.fromMatrix(a + dir * 8, dir, -Vector3.yAxis) -- X along the stroke, Y down (the template's boom is rolled 180)
	local line = template.Line:Clone()
	-- 1. origin impact: 66 emitters, Emit(EmitCount) at D
	-- 2. BeamLaunch A1 = boom * (-8,0,0), A2 = boom * (77.5,0,0); end impact at A2 * (-4,0,0) at D + ARRIVE
	-- 3. beams: Width0 200 -> rest over 0.2/0.4 s outCubic; shards 60->15 / 50->10, TexLength 1->.1, TexSpeed 5->.4, TransparencyScale 1->2 over 1.7/2.0 s
	-- 4. Meshes at boomCf * CFrame.new(15.48, 0, 0) * CFrame.Angles(0, 0, math.rad(90)); for each Start/End model:
	--    clone Start, set Transparency = Part_Transparency_Start or 0 (or Decal.Transparency = Decal@Transparency_Start or 0 and part = 1),
	--    random yaw in [MinInitRot, MaxInitRot], tween CFrame/Size (and SpecialMesh.Scale/Offset) to End with outCubic,
	--    Transparency with Part_Transparency_Curve, RotSpeed lerp Start->End about local Y, Duration = EffectDuration (random if NumberRange)
	-- all of the above at delay D; destroy the line at D + 2.1
end
```
Checklist for 1:1:
- copy textures, colors and curves verbatim from §3–4;
- floor the fractional EmitCounts (1.318→1, 1.82→1, 2.5→2);
- keep the black/Brightness-0 twins;
- keep the HDR decal Color3 values;
- keep the negative SpecialMesh scales;
- give stroke 1 the Whirlwind.

## 7. Candidate principles
1. **Sequence a big effect as a repeated unit with baked delays.** StarStruck is one 300-instance stroke cloned 5x with EmitDelay `D` written onto every child, plus an arrival copy at +0.1. The evidence: all lines are identical except for CFrame and per-instance EmitDelay (0/0.15/0.30/0.45/0.60, end impacts +0.1).
2. **The arrival impact is a full copy of the origin impact, delayed by the travel time.** It is not a smaller "hit spark". Evidence: the 66 emitters under A2 match the origin's, with +0.1.
3. **Chain the strokes so each arrival overlaps the next departure** (the vertex double-hit, 0.05 s apart). It turns 5 hits into one rhythmic gesture.
4. **Mesh VFX = about 15 layers in 3 time bands (0.2 / 0.5 / 1–2 s), not one ring.** Hot layers start opaque. Residue layers start at 0.9–0.96 transparency and live 5–10x longer.
5. **Push-pull motion.** Roughly half the mesh layers travel forward and half implode or travel back toward the origin. Evidence: the d deltas in §4 (Spin2-white, Spin, Wind needle, W5 and grey disc go backward; drills, cone, W, W2/W3 go forward).
6. **Animate the shape with anti-correlated non-uniform scale** (cross ×0.1–0.4 while length ×3–9, or the reverse). Ring→needle and needle→ring read as speed. Uniform scale reads as an outdated "bubble".
7. **Twist plus decaying spin plus random initial yaw on every swirl mesh.** Start→End rotation 40–165°, RotSpeed 5→0.3 or a constant 10, MaxInitRot Y 360. This kills stamped-copy repetition.
8. **Textured mesh layers go through decal-on-mesh:** an invisible part plus a SpecialMesh plus a Decal, with visibility on the decal. Use **HDR Decal.Color3** (4–22 white, or a single channel at 10 for a saturated hue) so a decal at 70–80 % transparency still blooms. Use a negative SpecialMesh.Scale to view a tube from inside.
9. **Every bright layer has a dark twin.** Black ring under the coloured ring, black smoke under the grey smoke, near-black backing plates under the impact, black Neon shell under the neon cones, black spinning decal opposite the bright swirls. Make them with Color #000000, Brightness 0, or negative LightEmission.
10. **The hottest pixel is the complementary accent, not white.** An orange core (Br 40, 0.05 s) in a violet effect, an orange beam over a dark-violet beam, and orange shards outliving violet shards to close the effect.
11. **Mid-value Neon grey (#A3A2A5) is the default body for big mesh envelopes.** Reserve saturated Neon for the 0.2 s hot meshes and white Neon for very-transparent residue.
12. **Shrinking flashes and exploding rings run together.** Flash 40→0 and vfxtuff 30→0 in under 0.1 s, while rings and blasts grow 0→20–45. The collapse frame is what makes the expansion feel violent.
13. **Fade the hot meshes linearly while their shape eases out** (shape done early, opacity leaves steadily). Residue layers use outCubic transparency (most of it gone early, long tail).
14. **Random EffectDuration (NumberRange) on dark/volume meshes** (black shell 0.2–0.5) so repeated strokes de-sync.
15. Authoring hygiene seen here, which is not a principle to copy: disabled red AlwaysOnTop Highlights are editor locators for invisible parts, and coloured layers get muted to Brightness 0 instead of being deleted. Strip both from production templates.
