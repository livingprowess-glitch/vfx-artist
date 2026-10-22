# Up / Down (fire swirl slash, launcher and slam variants)

Source: `Workspace.modern_vfx.Up` and `.Down`, Models with 203 instances and 181 ParticleEmitters each. Both pivots sit at (0.16, 175.17, 0.09). The dumps are relative to `GetPivot()`, which is the frame the effect is emitted in. Captured with `ropilot_vfx_capture` (front view) at 0.03, 0.1, 0.2 and 0.4 s.

## 1. Read
A red-orange **fire vortex ring** with a crescent slash and one long beam streak cut through it. On top of that are a ground scorch strip and a grey dust kick. Embers and smoke drift up and away.
- **First frame (0–0.04 s):** a flat, hot, saturated ring plus the slash crescent and beam. The flames are blue-violet at birth, so the ring has magenta fringes.
- **Peak (0.1 s):** the ring is fully formed and swirling, with a smoke puff popping out of it.
- **Residue (0.2–2.3 s):** the ring breaks into dark-red embers that rise and drift −Z, while slow grey smoke hangs.
- **Up** lays the ring flat, so the plane is horizontal and the swirl reads as an uppercut or launcher.
- **Down** tips the same ring 45° into a diagonal plane. It reads as an overhead slam cutting down-diagonal.

## 2. Up vs Down: the exact diff
I diffed every line of both dumps. Of 204 lines, **21 differ**, and every particle value is identical apart from the items listed below.

| What | Up | Down | Why |
|---|---|---|---|
| 6 ring parts + slash part `Up`/`Down` | CFrames as authored | **all = R · Up's CFrame**, where R is one rigid rotation of 157.94° about axis (0.815, 0.338, −0.471) | Down is literally Up's rig rotated as a unit. The ring normal goes from +Y to (0.707, −0.707, 0), a 45° diagonal pointing down. Positions keep their radius (6.24→6.24, 6.94→6.94 …), so this is a rotation, not a mirror. Handedness is preserved, so the swirl still turns the same way relative to its own normal. |
| Floor part | rot(0,60,135), normal ≈ (0.35, −0.71, −0.61), 45° | re-placed by hand at pos(4.63, 3.93, −2.31) rot(3.8, −165.5, 75.5), normal ≈ (0.26, −0.97, 0), almost flat | In Down the scorch strip lies almost on the ground: a slam hits the floor. In Up it is tilted along the swing. This is the only part that was not just carried along by R. |
| DustRaycast attachment | pos(1.78, 1.83, −0.48), rot z 134.8, dust "Right" = (0.35, 0.71, −0.61), i.e. up and out | pos(−1.26, −2.25, 0.34), rot z −30.2, dust "Right" = (−0.97, −0.26, 0), i.e. sideways and down | Dust is thrown **along the strike direction**: up for the launcher, down and out for the slam. |
| Slash 2D `Rotation` | Shaded Slash 17 = 180, Glowing Blurred = 140, Chromatic = 120, s4 = −180, s5 = −180, s6 = −155 | 30, −70, −75, 15, 0 (default), −5 | These are screen-space texture rotations, about 150–210° apart, so the crescent's opening matches the new swing direction. Rotating the attachment does not re-aim a flipbook crescent drawn inside a VelocityPerpendicular card, so the artist re-dialed each one. |
| `Spec` RotSpeed | −700 | **+700** | Seen from the camera, the tipped ring turns the other way, so the spinning spec flips sign to keep spinning with the ring. |
| Beam Slash 1/2 | Width1_Start unset | `@Width1_Start=5` | In Down the tail end gets 5 studs of width at birth, so the diagonal streak has some body at its far end. |
| Beam attachments A1/A2 | A1 (4.75, 1.46, −10.46), A2 (−17.92, −4.61, −4.17) | A1 (14.27, 4.01, −13.1), A2 (−9.19, −2.27, −6.59) | Same direction and length (~24–25 studs). It slides about +9 studs along its own axis, so the streak is centred on the tipped ring. |

**Unchanged in Down, and the reason for it:** `Acceleration=(0,30,−35)` is **world-space** on every ring emitter. Down does not flip it, so embers still rise (+Y 30) and drift −Z (35) after the drag (7) kills their launch speed. Heat rises no matter which way the move swings. Use world acceleration for "physics" residue and let only the emission frame follow the move. In the Down capture, the embers peel off the tipped ring and float up-left.

## 3. Timeline
No EmitDelay exists anywhere. **Everything bursts at t=0**, and the stagger comes purely from Lifetime and TimeScale. `TimeScale_Start == TimeScale_End` everywhere: there is no ramp. Fixed `TimeScale` 0.6–0.95 is used only to slow smoke and sparks.

| t (s) | layer | what happens |
|---|---|---|
| 0–0.07 | ring `4`/`5`, Speedline-type flames (Lifetime 0.2) | Size starts at 7–8 and collapses to 2 within 3–10% of life. A huge birth frame that snaps to the ring, i.e. an impact "frame 1". |
| 0–0.15 | `s4` slash (0.15), beams (EffectDuration 0.15; Width0 tweens 40 → 23.96 outCubic) | Crescent slash and long streak. The beam narrows as it fades. |
| 0–0.2 | Shaded/Glowing/Chromatic slash (0.2), Floor slash/Ground18/Glass Shatter/Finished fade (0.2) | Slash body, its black twin and the ground scorch. |
| 0–0.4 | `s3` (0.3, fades **in** to peak at 0.27), `s5` blue under-slash (0.4), `s6` dark-red under-slash (0.4), Floor `Tewak` (0.4) | Afterimage layers behind the slash. |
| 0–0.7 | ring flames `Fir`×7, `1`, `2`, `L4`, `GroundBurn`, `Galaxy Burst`, `b`×5, `Extra` (0.2–0.7) | Ring body. Particles fly tangentially, drag 5–7 stops them, and world acceleration lifts them. |
| 0–1.0 | `n3`×3, `Impact289` (0.5–0.6), `ParticleEmitter` 109440284900004 (0.3–0.4) | Soft expanding shock discs at 0.58–0.7 start transparency. Pressure, not flash. |
| 0–1.9 | ring `3` sparks (0.7–1.4 at TimeScale 0.75, so up to 1.87 s real) | Ember sparks that outlive the ring. |
| 0–2.7 | DustRaycast smoke set (0.4–1.9 at TimeScale 0.6–0.7) | Grey dust residue, the last thing to leave. The capture reports ~2.26 s total. |

## 4. Layer stack
### A. Six ring parts `_` (one 26-emitter template, cloned six times)
- **Geometry:** each part is 4 × 0.001 × 4, placed at radius 6.2–7.3 at angles 89°, −5°, −48°, 41°, 138° and 178°. **The quadrant between 178° and 312° is left empty**, which gives a C-shaped, broken ring rather than a perfect circle.
- **Emission:** each part's `Right` (+X) is the ring **tangent**, all in the same rotational sense. `EmissionDirection=Right`, `Shape=Disc`, `ShapePartial=0.5`. A disc whose normal is X, on a part only 0.001 thick in Y, flattens to a radial 4-stud line. The inner half is masked out, so particles spawn in two short radial bands, which makes the ring about 3 studs thick with a hollow centre line.
- **Template fidelity:** the clones are exact copies. The only exception is `_1`'s emitter `1`, which has Brightness 10 instead of 25, a leftover tweak.

| emitter | texture | role | key values | why |
|---|---|---|---|---|
| `Fir` ×7 | 86955745604080, 125589219124561, 90450352696620, 82694450715960, 125933365360022, 90941340189047, 99467489605633 | flame tongues (body) | Color `#1E29FF → #441EB8 (0.11) → #FF3B21 (0.2) → #F12424 → #FF3122`; Size 0 → 2±1 at 0.1 → 0 (some hold 0.875 to 0.42); Squash 0.19 → 1.09; LightEmission **−1** (one at 0); Brightness 25–40; Speed 40–60; Drag 7; VelocityParallel; Rotation ±90; ZOffset 1 | Seven different flame flipbooks with identical motion break up repetition. The **blue-violet birth (first 11–20% of life)** shows as a cool fringe for about 40 ms, then the flame turns hot red. That is a hue shift that reads as "hotter than red" without using white. Negative LightEmission with high Brightness keeps the colour saturated instead of adding up to white. |
| `1`, `4`, `5`, `6` | 84849028410631, 107845853952089, 129623777159943 | streak flames | Color `#FF2F14 → #FF3C2A → #661111 (0.62) → #000000`; `4`: Size 8.2±1.8 → 4.5 (0.03) → 2.5 (0.125) → 0, Lifetime 0.2; `5`: 7±2 → 2 (0.1), Brightness 55; `6`: VelocityPerpendicular, Squash −0.5 | Colour **ends at black, not at transparency.** Dying fire goes dark, which gives value contrast inside the ring. The giant first-3%-of-life size gives a one-frame bloom on impact. |
| `2` | 107420715710066 | additive flame | LightEmission 1, Transparency 0 → 1, Spread 20 | The only additive ring layer: a thin glow on top of the saturated body. |
| `3` | 125570183631896 | sparks | Size 0.35, Brightness 25, Lifetime 0.7–1.4, RotSpeed 360–720, TimeScale 0.75, Acceleration (0,15,−35) | Small, long-lived and slowed, they are the residue. They get half the lift of the flames (15 vs 30) so they lag behind. |
| `ParticleEmitter` ×2, `L4` | 16847071704, 119272314820246, 100003213330529 | grow-and-fade wisps | Size grows 0.2 → 1.4 (12-point ease-out); Drag 5; Rate 100; `L4` LightEmission −1, Brightness 50 | Fill between the tongues. |
| `GroundBurn`, `Galaxy Burst`, `b` ×5 | 129636587672114, 104302733170217, 16860226897, 16860219678, 122954463046434, 135866425386690, 125606840536264 | burst blobs | Color `#343EFF → #FF2525 (0.26) → #FF4625 → #FF2B2B`; Size 0 → 1–2.2; Brightness 10–30; ZOffset 1 | The same blue-birth trick, on round shapes. |
| `Extra` | 127816126678833 | ground-tinted debris | `@UseGroundColor=true`, `@GrassColor=#AC8A74`, `@MaterialIgnore=Glass`; LightEmission −1; ZOffset −1 | Forge tints it to the floor material. ZOffset −1 keeps it behind the fire. |
| `Origin/1` | 129623777159943 | central blast | Speed 60, Drag 15, Acceleration (0,10,−100), LockedToPart, LightEmission −2, Brightness 55 | Drag 15 stops it almost immediately, and the strong −Z pull smears it sideways. |

### B. Slash part `Up`/`Down` (rot(0,−135,−15)) and Attachment (rot z +15.179)
The slash attachment's net Y is **exactly the ring normal** in both variants: (0,1,0) in Up, (0.71,−0.70,0) in Down. Every slash card uses `Speed≈0.001`, `EmissionDirection=Bottom` and `Orientation=VelocityPerpendicular`, which makes it a flat card **coplanar with the swirl ring**. That is how a "2D" crescent sits in a 3D plane.

| emitter | texture | values | role / why |
|---|---|---|---|
| Shaded Slash 17 | 74423014151204 | Size 10, Lifetime 0.2, Color `#FF4E2F → #FF4423 → #FF2F2F → #000000`, Brightness 30, RotSpeed −360 | Main crescent. It sweeps 72° of spin in 0.2 s, which reads as the swing. |
| Glowing Blurred Slash | 87333577017587 | Size 11, `#FF3D23 → #FF1717 → #000000`, Brightness 20 | Soft halo, 1 stud bigger than the main slash. |
| Chromatic Shaded Slash | 95185012543861 | **Color #000000**, LightEmission 0.55, Brightness 10 | A black twin of the slash. It darkens the background behind the crescent so the red edge pops (value contrast). |
| s4 | 15637447149 | Size 10, 0.15 s, LightEmission −1, Brightness 15, RotSpeed −700 | A fast, saturated crescent that spins three times faster. |
| s5 | 15637447149 | **#2D11FF blue**, LightEmission 0.6, **Brightness 0**, ZOffset −0.2, 0.4 s | A deep-blue underlayer behind the red, for complementary temperature contrast. Brightness 0 keeps it from glowing, so it reads as a cool shadow. |
| s6 | 15637447149 | `#FF2410 → #340803 → #000000`, Transparency 0.744 → 1, ZOffset −0.2 | A dark-red afterimage. |
| s3 | 17085222506 | `#FF4534`, Transparency **1 → 0.23 → 0 (0.27) → 0.23 → 1**, LightEmission −2, Size 7 | It fades **in**, so it peaks after the slash: a delayed afterglow without needing EmitDelay. |
| Spec | 17826438728 | Size 7.8 → 15.6, `#FF3B21 → #FF2020 → #510A0A → #000000`, 0.25 s, RotSpeed ∓700, EmitCount 2 | Expanding spinning speck burst. The sign flips in Down. |
| n3 ×3 | 18527700887 | Size 0 → 16.8–18.8, Transparency 0 → 1 (ease-out), LightEmission 1/0.85, Brightness 0–0.435, 0.4–1 s, EmitCount 2–3 | Expanding shock rings, faint and additive. |
| Impact289, ParticleEmitter | 73649245182561, 109440284900004 | Size 0 → 18.5, start transparency 0.58/0.70, Brightness 0.3/1.1 | Big soft pressure discs that never become bright. |

### C. DustRaycast (smoke kit, the same kit Dash reuses)
Ten emitters: smoke1, SmokeGround2, SmokeGround, Rocks ×2, Smoke ×3, SmokeWind and goatedngl ×2.
- **Colour:** grey `#9D9D9D → #646464`, with LightInfluence 0.5–1, so the smoke takes on scene lighting.
- **Spread:** `SpreadAngle=(0,180)`, a half-sphere fan along the dust Right axis.
- **Speed:** 7–154, with Drag 2–8. The smoke shoots out, then hangs.
- **Rocks:** texture 81575182597575 on a Grid2x2 flipbook with FlipbookStartRandom. Speed 121, Lifetime 0.3. One is grey `#707070`, the other green-grey `#64766B` debris.
- **SmokeWind:** VelocityParallel, Size 0 → 13.5, LightEmission −0.5. It reads as a streaked gust.
- **Timing:** TimeScale 0.6–0.7 slows the puffs, which gives the "hang".

### D. BeamLaunch: two beams A1 → A2, about 24 studs long
| beam | texture | values |
|---|---|---|
| Beam Slash 2 | 13821091893 | `#FF0F0F`, Transparency 1 → 0.81 → 0.36 → **0 at 0.5** → 0.34 → 1 (bright in the middle), LightEmission 0.4 |
| Beam Slash 1 | 12991508490 | `#FF2D11`, Transparency 1 → 0.63 → 0.23 → **0 at 1.0**, so it brightens toward A2, LightEmission 0.5, ZOffset −0.05 |

Shared by both beams:
- Width0 40 → 23.96 (outCubic over 0.15 s) and Width1 0, a wedge taper.
- FaceCamera, Segments 360, TextureLength 0.5, TextureSpeed 10, Brightness 10.
- `@EmitDuration=0.2`.

The two transparency profiles are offset: one peaks in the middle and the other at the far end. Together they put the hot spot off-centre, toward the leading tip.

### E. Floor part: a 0.001 × 0.545 × 12.754 strip, `ShapeStyle=Surface`, EmissionDirection Left
Particles spawn along a 12.75-stud line, which gives a scorch crack.
- **Tewak** (125314922601956): Size 0 → 3.2, Brightness 50. One copy with Rate 11, one with EmitCount 3.
- **Slash** (82576941307593): **black**, Squash −0.65, ZOffset 2.
- **Slash** (17511015942): `#FF3815`, **LightEmission 10**, ZOffset 3.
- **Finished fade** (13781849388): `#FF3511 → black at 0.435`, Squash 1 → 3, so it stretches out.
- **Glass Shatter** (123537613064060): **black**, Squash 2.
- **Ground18** (112043969867945): `#FF2C19`, LightEmission −1, Squash 0.26 → 3.

The floor pairs every hot layer with a black one: two black emitters against three hot ones.

## 5. Mesh VFX detail
There are **no meshes.** The ring that an old-style effect would build from a tweened torus mesh is made of particles spawned in a broken ring of tangential emitters. That gives a hand-drawn, uneven ring with internal value variation that no single mesh provides.

## 6. Color & value
- **Hot ramp:** `#FF2F14 → #FF3C2A → #661111 → #000000`. The fire **dies to black**.
- **Cool birth:** `#1E29FF / #343EFF → #441EB8 → #FF3B21`. Blue becomes red within the first 11–26% of life. In motion it shows as a magenta/violet fringe, visible in the 0.04 s capture.
- **Complement underlayer:** `s5` `#2D11FF` at Brightness 0, sitting behind the red slash.
- **Black twins:** Chromatic Shaded Slash, Floor Slash and Glass Shatter, all `#000000`.
- **Neutral:** smoke `#9D9D9D → #646464`, rocks `#707070` / `#64766B`.
- **LightEmission strategy:**
  - The body uses **LightEmission −1/−2 with Brightness 25–55**: saturated, dense colour with no white blowout.
  - Additive (LightEmission 1) is reserved for thin glows: `2`, `n3`, the beams at 0.4–0.5, and Floor Slash at 10.
  - Shock discs stay at Brightness ≤ 1.1, so they never compete with the fire.

## 7. Rebuild recipe
```lua
-- Forge-schema template; one burst at t=0, everything relative to the model pivot
local up = Instance.new("Model")
-- 1) ring: one template part, 4 x 0.001 x 4, CanCollide=false, Transparency=1
--    26 emitters, see table A (Disc, ShapePartial 0.5, EmissionDirection Right, VelocityParallel, Drag 5-7,
--    Acceleration world (0,30,-35))
for _, a in {89, -5, -48, 41, 138, 178} do -- leave the 178..312 quadrant open
	local r = 6.5
	local cf = CFrame.new(math.cos(math.rad(a)) * r, 0, math.sin(math.rad(a)) * r)
		* CFrame.Angles(0, math.rad(-a + 90), 0) -- +X = tangent; check sign against _1 (+Z position, +X right)
	ringTemplate:Clone().CFrame = pivot * cf
end
-- 2) slash part at pivot, Attachment whose Y = ring normal; cards Speed 0.001, EmissionDirection Bottom,
--    VelocityPerpendicular; Size 10-11; Lifetime 0.15-0.4; red crescent + black twin + blue Brightness-0 underlayer
-- 3) BeamLaunch: A1/A2 ~24 studs apart through the ring; two FaceCamera beams, Width0 40->24 outCubic over 0.15 s
-- 4) Floor strip 0.001 x 0.545 x 12.75, Surface emission, hot + black pairs
-- 5) DustRaycast smoke kit aimed along the strike
-- emit: for each emitter task.defer(e.Emit, e, e:GetAttribute("EmitCount") or 1); beams Enabled for EmitDuration
```
- **Down:** build Up, then `PivotTo` the ring and slash rig by R, a 158° rotation that puts the ring normal at (0.707, −0.707, 0).
  - Lay the floor strip almost flat on the ground.
  - Point the dust down and out along the strike.
  - Re-dial each crescent's `Rotation` by about 150–210° so it opens along the new swing.
  - Flip the sign of Spec's `RotSpeed`.
  - **Leave Acceleration in world space.**

## 8. Candidate principles
1. **A directional variant is a rigid rotation plus hand re-dials, not a re-author.**
   - Evidence: 7 of 8 parts in Down are Up multiplied by a single rotation R.
   - Only screen-space quantities were changed by hand: 2D `Rotation`, `RotSpeed` sign, floor placement and dust aim.
   - Rule: rotate the rig, then fix every value that lives in screen space or world space.
2. **World Acceleration is physics and does not rotate with the move.**
   - Evidence: `(0,30,−35)` is unchanged in Down, and the embers still rise.
3. **Build rings from tangential emitters around a broken circle, not from a ring mesh.**
   - Evidence: six cloned parts at 60–90° steps, with one quadrant skipped for asymmetry.
   - Each part uses a Disc ShapePartial of 0.5 for band thickness.
4. **A hue-shift birth (blue → red in the first ~15% of life) reads as "hotter than red" without using white.**
   - Evidence: the Fir, GroundBurn and b gradients.
5. **End fire colour sequences at black, not only at transparency.**
   - Evidence: every hot ColorSequence ends at `#000000` or `#340803`, which gives value variation inside the effect as it dies.
6. **Use negative LightEmission with high Brightness for saturated bodies, and keep additive blending for thin glows.**
   - Evidence: the body runs at LightEmission −1/−2 with Brightness 25–55.
   - Additive blending appears only on `2`, `n3` and the beams.
7. **Pair every bright slash or ground layer with a black or dark twin.**
   - Evidence: the Chromatic slash, Floor Slash and Glass Shatter are `#000000`, and `s5` is blue at Brightness 0.
8. **Lay "2D" crescents in the effect plane** with VelocityPerpendicular cards, Speed 0.001 and an emission axis equal to the plane normal.
9. **Stagger timing with Lifetime alone, without EmitDelay.**
   - Evidence: 181 emitters, zero delays. Fade-in transparency curves such as `s3` peak at 0.27 s to give a delayed afterglow.
