# arrow (`Workspace.modern_vfx.arrow`)

Source: dumped 2026-10-22 from Place3 (PlaceId 114773467389373). A Folder of 558 instances: 253 ParticleEmitters, 82 Parts, 52 SpecialMesh+Decal pairs, 12 Trails, 33 Models and 1 MeshPart. It holds **three phases of one green "arrow storm" skill, not independent variants**:
- `Windup` charges at the archer's feet.
- `Shoot` fires arrows up into a point in the sky.
- `Rain` pours arrows down from that point onto a 26-stud circle.

One standalone single-arrow impact is stored in `Windup.Arrow`, and the effect re-instances its building blocks at different scales. Section 3 compares those copies. World positions are as stored, because the folder has no root:
- archer ≈ (−38.4, 0, −43.2)
- sky point ≈ (−38.4, 22.5–23.4, −10.5)
- rain ground center ≈ (−38.4, 0.26, −10.5)
- the single-arrow demo sits at (13.5, 0.5, 1.6)

Nothing was captured visually.

## 1. Read
Green energy coils at the archer's feet: pulsing HDR rings, a tornado of four trails rising, and sparks converging into the bow. A volley of four mirrored, arcing trail-arrows whips up into the sky and bursts. A magic circle and stacked rings open in the sky, and for 1.4 s green speed-line streaks hammer down while impact bursts pop at random spots inside a ground circle. Swirling specs orbit the circle's rim and a rising ring pillar joins ground to sky.
- **First frame:** the white-hot HDR ring flash at the feet.
- **Peak:** the sky burst plus the first rain impacts.
- **Residue:** the 2.5 s ground crack decals and the dust from the last impacts.

## 2. Timeline
The phase offsets are not stored, because the ability script sequences them. They are inferred from geometry: the Shoot path ends exactly at the Rain sky point.

| t (s) | phase.layer | what happens |
|---|---|---|
| 0 | Windup.GroundMeshes.Chargeup (6 ring models) | `#ConstantVFX`, Rate 5–6 for EmitDuration 1.4. Each ring re-emits ~7× (with random yaw `MaxInitRot (360,0,0)`), and each copy lives 0.45–1 s, so the rings **pulse** |
| 0 | Windup.StartSwirlTrail | carrier part rises 11.85 studs (y −2.75 → 9.1) over **0.4 s**, spinning at Part_RotSpeed **40** (outCubic decay), and drags **4 trail pairs** at r ≈ 7–10. This is the tornado spiral. Trail heads re-emit sparks for 0.15 s |
| 0–0.6 | Windup.ArrowChargeBezier | `#BezierParticle` on a 27-stud sphere (Shape Sphere, Surface): Rate 40 for 0.6 s (~24 + mirrored twins), each traveling a 10.8-stud path **inward** in 0.1 s (inOut). Each carries a 0.1 s gradient trail and flare head |
| ~0.6–1.4 | Shoot.ShootMesh | muzzle shells: ImpactMeshNW/Blue **0.2 s** and ShockwaveWind **0.4 s**, firing forward along the 30° launch line |
| +0 | Shoot.BezierArrows | **EmitCount 4**, MirrorPaths (roll 180°), so 4 arrows on mirrored arcs from the bow to the sky point (37.5-stud chord, tangent T0 = (0.5, 27.5, 0) → a tall loop). Duration **0.23 s, linear**. Each projectile carries a trail pair (green 0.25 s, orange core 0.12 s), a head flare stack (EmitDuration 0.4) and a fire stack |
| +0.1 | Shoot projectile `F` | swirl/impact flashes on the head start after **EmitDelay 0.1**, so they kick in mid-flight, not at the bow |
| +0.23 | Shoot `EmitOnFinish.Arrowhit` | each arrival bursts the impact stack at **×2.95 scale, EmitCount 1** (see 3.D) |
| +0.23 → +1.65 | Rain.* | every Rain emitter uses EmitDuration 1.4 at its Rate: sky rings pulse, speed lines fall (Rate 35, ~49 streaks), ground hits pop (Rate 18, ~25 hit bursts), magic circles hold, SpinnySpecs orbit for 1.5 s, and the bezier sparks converge into the sky point (Rate 20) |
| → +4 | Rain ground cracks | crack decals in each hit stack have Lifetime 2.5 s, the longest residue |

## 3. Layer stack

### A. Pulsing HDR ring stack (Windup.GroundMeshes = Rain.TopMesh ×1.28 = Rain.BottomMesh ×1.7)
All use SpecialMesh **8501563708**, a cylindrical band or shockwave ring with its axis along the mesh's X. The parts are rotated `(0, 180, −90)`, so mesh-X is world-up and Scale.X is the band height. The **texture is a Decal on the invisible Part** (Part_Transparency 1 → 1). Only the Decal's transparency animates (`Transparency_Start/End` on the Decal). Scales are **negative on all three axes**, which inverts the mesh so the decal draws on the inner wall facing the camera across the ring.

| # | dur | decal tex | Decal.Color3 | decal T | Start → End (Scale, Y offset, twist) |
|---|---|---|---|---|---|
| 1 | 0.45 | 14101024770 | **(21.78, 21.78, 21.78)** | .8 → 1 | (0,0,0) → (−.155, −.387, −.375), same CFrame: **grows from nothing** |
| 2 | 0.7 | 14261953171 | (21.78)³ | .8 → 1 | (−.053, −.303, −.293) @y −1.6 → (−.394, −.733, −.709) @y +3.3, yaw 180 → 15 (**165° twist**): band gets 7.4× taller and 2.4× wider |
| 3 | 1.0 | 88983666349740 | (1.96)³ | .6 → 1 | ~0 @y .8 → (−.207, −.687, −.665) @y .5: flat wide disc |
| 4 | 1.0 | 88983666349740 | (0.40, 1.00, 0.63) | (default) → 1 | (−.053…) @y −1.1 → (−.378, −.571, −.552) @y +1.85, 165° twist |
| 5 | 0.5 | 88983666349740 | **(0.80, 3.92, 0.78)** | → 1 | @y −2.3 → (−.322, −.486, −.47) @y +.2, 165° twist |
| 6 | 0.45 | 88983666349740 | (1.96)³ | .7 → 1 | ~0 → (−.222, −.553, −.534) |
| Rain.Top +7 | 0.4 | 88983666349740 | **(0,0,0)** | → 1 | ~0 → (−.396, −.988, −.955), yaw −15, Spread (10,10) |
| Rain.Top +8 | 0.4 | 88983666349740 | **(0,0,0)** | .4 → 1 | @y 13.8 → (−.695, −.988, −.955) @y 27.9: a black band rising 14 studs |
| Rain.Bottom pillar ×3 | 0.6 | 15190416756 | (21.78)³ / (0,0,0) / (0.40, 1.96, 0.63) | .85 / .4 / → 1 | Start @y −10.6…−16 → End @y 11.6…22.1, sizes 4.6–6.6 → 35–50 wide, Part_RotSpeed −10: **a ring column shooting from under the floor up to the sky** |

- **Curves:** Mesh_Scale outCubic, Part_CFrame outCubic, **Part_Size `out` = cubic-bezier(0, 0, .58, 1)**, which is gentler than the scale curve. So the ring footprint and the band thickness ease differently.
- **Why HDR Decal.Color3:** `Color3` > 1 on a Decal multiplies the texture past white. At 21.78 even a 0.8-transparent decal on a dark texture region blooms. At 1.96 it is "bright but textured". (0.80, 3.92, 0.78) is **green-only overbright**: a saturated glow that doesn't wash to white. A black copy (0,0,0) of the same mesh and texture gives the dark band. One texture yields white-hot, tinted, green-HDR and black layers just by Color3.

### B. Converging bezier sparks (Windup.ArrowChargeBezier, Rain.StormBezier)
- **Path:** `#BezierParticle` Attachment. Points/1 at the center with T0 +11.5 Z, and Points/2 at −10.8 Z with T1 −11.3 Z. Spawned on a sphere surface (`Shape Sphere`, `ShapeStyle Surface`, `ShapeFace Outward`, `ArcSpace true`), with `MirrorPaths` + `MirrorRotation (0,0,180)` so each spark has a twin rolled 180°. `Duration 0.1`, `Easing inOut`, `DestroyDelay 1`.
- **Projectile part (1.35 studs):** a 0.1 s trail (118758348149908, #31B0FF → #2FD055 → #28B557 → #208D39 → #184B21, WidthScale 1 → .6 → .27 → 0, FaceCamera, Brightness 15) plus a head stack:
  - Flare Twinkles #FF9040: orange **accent**, LightEmission 1, Brightness 30
  - Fading Glow #3AFF8C, ZOffset −1, Size 0 → 10
  - specs #5CFF53: **Transparency −50, LightEmission −2**
  - Spec1/Spec2 #2FFF40 with gravity
  - Rainbow6 ring flash
  - Snowfall 8×8 flipbook
  - Flare247New and Flare20New
- **Windup vs Rain:** sphere 27 vs 37.4, Rate 40 vs 20, EmitDuration 0.6 vs 1.4, path ±10.8 vs ±14.9. Same recipe, rescaled.

### C. Rising swirl tornado (Windup.StartSwirlTrail.SwirlyTrails2)
- **Motion:** the Start part (0.8 cube) tweens to End **+11.85 Y in 0.4 s** (Part_CFrame outCubic) while **Part_RotSpeed 40 → 0**. `MaxInitRot (1,0,0)` and `SpreadAngle (5,5,0)` jitter it.
- **Trail pairs:** four, at (0,0,−9.9/−7.2), (0,1.34,8.9/7.1), (0,−10.5/−7,0) and (0,9/5.9,0). That puts four 2.7–3.1-stud trail segments on a radius of 7–10 around the spinning axis, so as it spins and rises they draw **four helical ribbons**.
- **Each pair:** a green gradient trail (Lifetime 0.1, Brightness 15) plus an **orange core trail** (132592993711073, #FF7729, Lifetime 0.05, Brightness 60). The core is half the lifetime of the green, so the hot orange sits only at the head. Each pair also has a spark sub-stack (specs/Spec1/Spec2/Snowfall/Flare) bursting over EmitDuration 0.15.

### D. Impact stack (Windup.Arrow.ArrowHit at 1×, Shoot EmitOnFinish.Arrowhit at ×2.95)
37 emitters in the base hit (Burst + Line attachments), the richest in the corpus so far.

| group | emitters | values | job |
|---|---|---|---|
| Flash core | Flash (10556525755), Flash1, R Impact ×2, Star3 | Size 4.6–7.8 → 0 in 0.04–0.1 s, Squash 1.05 → −3, LightEmission 1, Brightness 5–15 | 1–3 frame hit frame |
| Line burst | tp1–tp8 | 8 emitters, 3 textures, each with a **different Squash curve** (−2 → 3, −.84 → 1.98, oscillating .7/1.79/.34/1.79 …), Lifetime 0.06–0.1, Speed −191…159 (both directions), **Transparency −50**, LightEmission −10…0.4 | a starburst of hard lines, each line shaped differently |
| Directional blast | Blast1, Blast2, Dots, Lines1 ×2, [2], [4], [6] | EmissionDirection Back, Spread 180, LightEmission −1, Brightness 35–50, Drag 4–15, `BaseEmitCount 3.375` | a hemisphere spray **opposite the arrow's travel** |
| Fire puff | Fire11/11b/125/32/33, L4, GroundBurn, Galaxy Burst, 2 × ParticleEmitter | gradient #3AFF5B → #25FF5C → #18CC45 → #1EC12B, Speed 1–15, Spread 360, Drag 5, LightEmission 0–0.7, Brightness 8–50 | the body of the impact |
| Debris | Rocks (33 count, Grid2x2 random frame), Rocks2 (22), Sparks3 (15, Squash 2), 6 (Speed 49–97, **Drag 55**: shoots and stops dead), 1/6 (84849028410631) | colored #38FF45 at 1× | the high-count layer |
| Rings/waves | WindRings ×2 (Spread 7 and 180), Ring ×3, Flower Shockwave (#41FF6D → #187F20 → **#000000**), Forming flower (**black**), Expanding flower 3 (LightEmission −2), 1/3 (`#Emitters`, Back) | VelocityPerpendicular | ground-plane read |
| Ground residue | crack, crack1 (Lifetime **2.5 s**), BlackPatches, DustFlat, Dust1, DustFlatOut (**black**, 15) | | stays after the flash |
| Ground-tint | Extra (`UseGroundColor`) | | |

- **The 2.95× sky copy:**
  - Every Size keypoint ×2.95 (Dust1 0.059 → 0.175, Effect 0.256 → 0.756).
  - Every Speed ×2.95 (Effect 32.8 → 96.6, `6` 48.7 → 143.8).
  - Acceleration ×2.95 (Rocks 0.24 → 0.71).
  - Drag **not** scaled (it stays 8/10/55).
  - **EmitCount forced to 1.**
  - Rocks/Rocks2 turned **black** (silhouettes against the sky instead of green on the ground).
  - Crack/ground-only layers dropped.
  - It fires once per arrow (4 arrows + mirrors), so EmitCount 1 × 8 arrivals ≈ the base counts. **Counts were divided by the number of simultaneous instances.**

### E. Projectile (Shoot.BezierArrows.CurvedArrows)
- **There is no arrow mesh on the projectile.** The invisible 4×1×2 Part carries only trails and particles. The "arrow" is:
  - **trails:** green gradient trail (0.25 s) + orange core (0.12 s, Brightness 60) between attachments 3.5 studs apart
  - **`Effects` head:** Flare Twinkles orange, Fading Glow, specs, Spec1/2, Rainbow6 (Squash 0 → −3), Snowfall, Flare247New, Flare20New, all at EmitDuration 0.4
  - **`F`:** Bezier1 swirl, Sw1 ×2 (RotSpeed −500/−600), Burst (DustFlat, Flash, WindRings), Impact15 #BEFF5C, Impact327 **black** + green twin, and Impact333 **black at Brightness 500**, all at EmitDelay 0.1
  - **`fİRE`** (the name has a Turkish dotted İ): the green fire stack at Speed 1–10, Spread 40, EmissionDirection Right, so it sheds sideways off the flight line
- At 37.5 studs in 0.23 s (~163 studs/s), a mesh arrow would be a 1-frame blur anyway. The trail *is* the shape.
- The only arrow MeshPart in the folder (81511712010328, Neon #3FA561, 4.97×0.47×1.01) is the **static stuck-in-ground arrow of the single-hit demo** (`Windup.Arrow`, rot z −90, 1.4 studs above its hit point).

### F. Muzzle shells (Shoot.ShootMesh), same ring mesh 8501563708 with Decal Face=Top
| model | dur | decal | Start → End |
|---|---|---|---|
| ImpactMeshNW | 0.2 | 9572542664, Color3 (6.10)³ | (.208, .312, .317) @ bow → (1.152, .119, .12) **21 studs forward / 12 up** (exactly the 30° launch line): stretches 5.5× long while pinching 2.6× thin |
| ImpactMeshBlue | 0.2 | 9572542664, (1.08, 1.37, 6.10) blue-HDR | (.094, .285, .29) → (1.268, .106, .107), 17 forward / 8 up |
| ShockwaveWind | 0.4 (Duration .67) | 9622368924, extreme overbright | (.822, .171, .143) wide flat → (.267, .342, .381) compact, moving 9.6 forward / 5.5 up with a large rotation change (rot (−48, −129, −132) → (−28, 106, −34)) |

- All three use `Mesh_StartTransparency .98`, `Part_Transparency .98 → 1` and `Flipbook = true`, with `*_TweenParams` Sine/Cubic Out (the EasyMeshEmit dialect).
- **Why:** the cone is thrown *along* the shot and elongates, so it reads as recoil or air being punched. A ring expanding in place would read as an explosion.

### G. Rain field (Rain.MainPart, GroundHits, RainGroundCircle)
- **Speed lines = the rain.**
  - `MainPart.Part` is a **14.7 × 0.001 × 14.7 flat emitter plane** at the sky point (y 22.9).
  - MainSpeedline (92756777074741, #30FF41) plus a SpeedlineContrast twin (#38FF77): Speed **300**, EmissionDirection Bottom, Spread 20, Lifetime 0.15, Size 11.5 → 0, **Squash −.49 → 3**, Rate 35 × 1.4 s.
  - At 300 studs/s for 0.15 s each streak falls about 45 studs, past the ground (22.9 studs down), so a streak is never seen stopping in the air.
  - The **impacts are not spawned where the lines land.** They come from a separate emitter.
- **GroundHits:** a **26.6 × 0.6 × 26.5 invisible part**. Its emitters spawn at random points over the box, so Rate 18 for 1.4 s scatters ~25 impact bursts across the circle with no scripting.
  - Emit ×3: 11201546023 #21FF72, 1861106267 **#FF8640** (orange accent), 1315202524; Speed 50–100, Spread 60, Squash eased negative.
  - Flash 13.2 → 0 (0.09 s).
  - Glaze: Transparency **4 → −5**, Squash 1.19 → −.59, RotSpeed ±593.
  - Hit/Impact2 7.5 (0.06–0.09 s, TimeScale ramp 0.058–0.085 s).
  - Sparks, gravity −42.9.
  - Spec: RotSpeed ±1216.
  - `_33,1_2 rotspeed…` #77FF3D.
  - vfxtuff / yaversu **#FF9C46** orange flashes.
- **Ground circle (RainGroundVFX, LockedToPart, VelocityPerpendicular, all EmitDuration 1.4):**
  - magic_02-Hexagon 16
  - MagicCircle4 23
  - Bubbles Optical Illusion 15 (4×4)
  - Crystal Circle 13, **#FFC052 gold**
  - Circle8, Size 10 → 22, LightEmission −2
  - The circles fade in and out (Transparency 1 → 0 @0.5 → 1, Lifetime 1) at Rate 2–3, so they **breathe**.
- **SpinnySpecs:** 16 parts at r ≈ 13.7 around the ground center, every **22.5°**, each facing the tangent. Emitter `2` (#33FF66, Grid2x2 random frame):
  - LightEmission 1, ZOffset 5.2
  - EmissionDirection Left, **Speed −73.7** (negative = the opposite tangent)
  - **Acceleration (0, 126.7, −84.5)** with LockedToPart: up + inward
  - Drag 7, Lifetime 0.4, Rate 17 × 1.5 s, `#AuraInstance`

  The specs spiral up and inward off the rim, the same centripetal trick as `spin` (see spin.md principle 1).
- **Sky charge (RainMainPart Effects/StarStart/Charge/MagicCircles):**
  - the projectile head stack ×2.76
  - Charging swirl 2 (19.6 → 0, 1 s)
  - Spark Vortex (27.6 → 0, RotSpeed 360)
  - Swirls14 **#FFD063 gold**
  - Impact347/201 **#FF5820** at Brightness 0
  - Impact252, Circle72
  - Burst
  - Impact327 black/green pair and Impact333 black at Brightness 500
  - MagicCircle4 20 + Magic Circle 10 (LightEmission −1, Brightness 40), rotated Z −90 to face down, Lifetime 1.2, RotSpeed ±50

## 4. Mesh VFX detail (summary)
- **One mesh (8501563708), driven entirely by SpecialMesh Scale + Decal transparency.** It appears 52 times. The Part stays at Transparency 1. Size curves differ between the footprint (Part_Size `out`) and the mesh scale (outCubic).
- **Start scale 0 or near 0** for the burst rings, so they grow from a point. **Start below the floor + 165° yaw twist** for the rising bands.
- **Negative Scale on all axes** for every ground/sky ring.
- Decal Face=Top on the muzzle shells, so the texture projects along the shot.
- **Re-emission:** ConstantVFX + Rate 5–10 + EmitDuration 1.4 + `MaxInitRot (360,0,0)` makes ~7–14 overlapping ring copies per model at random yaw. That is a pulsing, never-identical stack from 6–8 templates.
- Durations are short: 0.2–1 s. Nothing in the mesh layer outlives the particles.

## 5. Color & value
- **Dominant green, three values:**
  - hot: #38FF45, #21FF72, #2FFF40, #34FF4C
  - mid gradient: #3AFF5B → #25FF5C → #18CC45 → #1EC12B
  - dark tail: #208D39 → #184B21 on the trail
  - Flower Shockwave ends at **#000000**
- **Cyan head:** the trail starts **#31B0FF**, so the head of every arrow is blue-shifted and the tail sinks to dark green. Hue and value both drop along the length.
- **Orange/gold accents:** #FF7729 trail core, #FF9040 twinkles, #FF8640 / #FF9C46 rain hits, #FF5820 sky charge, #FFC052 and #FFD063 gold circles and swirls. Always small, short or thin: the complement is used as a spark, never a body.
- **Black twins:**
  - Impact327 black vs green (same texture, size, timing)
  - Impact333 black at Brightness 500
  - black ring decals (Rain.Top #7/#8, pillar #2)
  - DustFlatOut, Forming flower, Rocks in the sky copy
- **LightEmission strategy:**
  - additive (1) on glows, flares and rings
  - **0 on fire puffs**
  - **negative (−1, −2, −10) with high Brightness (25–50)** on lines, blasts, dots and specs
  - plus **Transparency −50** on specs/tp lines and Glaze's 4 → −5

  Negative LightEmission plus negative transparency pushes those particles to dense, saturated, non-washing marks: they stay green against a bright sky instead of blooming to white.
- **HDR Decal.Color3:** 21.78 (white-hot), 6.10, 3.92 green-only, 1.96, and an extreme blue-weighted value on ShockwaveWind.

## 6. Rebuild recipe
```lua
-- one skill, three templates, sequenced by the ability script
local archer, sky, ground = hrp.CFrame, hrp.CFrame * CFrame.new(0, 22.5, -32.7), hrp.CFrame * CFrame.new(0, 0.26, -32.7)
local windup = place(arrow.Windup, archer)
forge.emitAll(windup)                       -- ring models: ConstantVFX -> emitMesh every 1/Rate s for EmitDuration 1.4, random yaw
forge.bezier(windup.ArrowChargeBezier)      -- 40/s for 0.6 s, sphere surface -> center, mirrored twins
forge.emitMesh(windup.StartSwirlTrail.SwirlyTrails2) -- rising + RotSpeed 40, trails do the drawing
task.wait(1.0)                              -- release
local shoot = place(arrow.Shoot, archer)
forge.emitAll(shoot.ShootMesh)              -- 0.2/0.4 s cones thrown along the 30 deg launch line
forge.bezier(shoot.BezierArrows, { onFinish = function(p) forge.emitAll(p.EmitOnFinish) end }) -- 4 arrows, 0.23 s linear
task.wait(0.23)
local rain = place(arrow.Rain, ground)      -- sky children keep their +22.5 offset
forge.emitAll(rain)                         -- every emitter: Emit(EmitCount) then Enabled at Rate for EmitDuration 1.4
task.delay(4.2, function() windup:Destroy() shoot:Destroy() rain:Destroy() end) -- 1.4 + 2.5 s crack residue
```
To reuse the single-arrow hit (Windup.Arrow.ArrowHit) elsewhere, scale it with `ScaleParticles(k)`. Size, Speed and Acceleration all scale by k. Then divide EmitCount by the number of simultaneous copies.

## 7. Candidate principles
1. **Projectiles are trails + a head flare, not meshes.** Evidence: the 4 Shoot arrows and every bezier spark have no mesh. They use a green gradient trail plus an orange core trail at half lifetime and twice the brightness (0.25/0.12 s, Brightness 15/60). The only arrow mesh is a static stuck-arrow prop.
2. **Make one ring mesh do everything through Decal.Color3 overbright and black copies.** Evidence: SpecialMesh 8501563708 appears 52 times with Color3 21.78 / 6.1 / 3.92-green / 1.96 / tinted / 0,0,0 on 4 textures. The Part stays invisible and only the Decal fades.
3. **Pulse meshes by re-emitting the template at a Rate, with random initial yaw, instead of tweening one ring.** Evidence: every ground/sky ring model is ConstantVFX + Rate 5–10 + EmitDuration 1.4 + MaxInitRot (360,0,0) + 0.4–1 s life.
4. **Rising bands start under the floor and twist about 165° as they grow.** Evidence: Chargeup models 2/4/5 (Start y −1.1…−2.3 → End y +0.2…+3.3, yaw 180 → 15) and the BottomMesh pillar (Start y −10…−16 → End y 11–22, RotSpeed −10).
5. **Throw muzzle/recoil shells along the action line, lengthening while pinching.** Evidence: ImpactMeshNW/Blue Scale (.21, .31, .32) → (1.15, .12, .12), moving 21 studs along the exact 30° launch vector in 0.2 s.
6. **Scatter area impacts with one emitter on a big invisible box.** Evidence: GroundHits (26.6 × 0.6 × 26.5) at Rate 18 for 1.4 s, separate from the speed-line plane (14.7² at Speed 300) that sells the falling.
7. **When an impact fires N times at once, scale it with ScaleParticles(k) and cut EmitCount to about base/N.** Evidence: the sky Arrowhit is the ground ArrowHit with every Size/Speed/Acceleration ×2.95 and every EmitCount set to 1. It is triggered by 4 mirrored arrows. Drag is left unscaled.
8. **Recolor debris for its background.** Evidence: Rocks/Rocks2 are #38FF45 in the ground hit and **#000000** in the sky copy, so they silhouette against the sky.
9. **Use negative LightEmission (and negative transparency keys) with high Brightness for marks that must stay saturated.** Evidence: tp1–tp8 (LE −10…0, T −50), specs (LE −2, T −50), Blast/Dots/Lines (LE −1, Br 50), Circle8/Expanding flower (LE −2) and Glaze (T 4 → −5). Glows that should bloom stay at LE 1.
10. **A burst of lines gets per-emitter Squash curves.** Evidence: tp1–tp8 share Size/Lifetime/Speed and use 3 textures, but every one has a different Squash sequence, so no two lines in the starburst have the same profile. This is the same idea as spin's 7-texture Fir burst.
11. **The complement is an accent, held to thin, short or small layers.** Evidence: orange appears only as trail cores (Lifetime 0.05–0.12), twinkles (0.1 s), two rain-hit sub-emitters, and gold circles/swirls under a green-dominant stack.
12. **Build a skill from reusable blocks re-instanced at scale.** Evidence: Chargeup rings ×1 (feet) / ×1.28 (sky) / ×1.7 (ground), bezier charge 27 → 37.4 sphere, and the hit stack ×1 → ×2.95.
