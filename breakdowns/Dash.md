# Dash (sustained dash rig: rings, wind sheath, fire jets, dust kick)

Source: `Workspace.modern_vfx.Dash`, a Model with 150 instances: 47 emitters, 16 Beams, 6 MeshParts plus SurfaceAppearance, and 2 SpecialMeshes. The pivot is rot(−90, 180, 0), so in the showcase the pivot's local +Y points along world +Z. All CFrames below are relative to the pivot.
- **Axis convention:** the travel axis is **pivot-local Y**. **+Y is "behind" the runner**: DashFire's `Back` face = +Y, and every mesh tweens from −Y toward +Y.
- **Capture:** Ropilot's runtime does not run Forge mesh/beam tweens, because EffectDuration is stored as a NumberRange. The capture therefore shows only the particle layers: a white-blue wind swirl, a red fire core and grey dust. The mesh read below comes from the data.

## 1. Read
A dash that leaves **world-anchored rings stamped along its path**, a **wind-tunnel sheath** of beams flaring back from the body, **flame jets** shooting backward, and a **dust and wind kick** at the feet.
- **First frame:** a red-hot implosion flicker and speed-line flash at the body.
- **Peak:** the ring stamps are already left behind at 5 per second while the sheath twists.
- **Residue:** a lingering shock haze and dust. The value is mostly pale, faint grey-white wind, with a small saturated red fire accent and black speed-line twins.

## 2. Timeline
These are the timings of one dash: the one-shot pieces plus the `#ConstantVFX` pieces, which repeat at their `Rate` for as long as the dash runs. The sustained beams carry `EmitDuration=3`, the maximum dash hold.

| t (s) | layer | what happens |
|---|---|---|
| 0–0.06 | MainSpeedline / SpeedlineContrast / Shard | A one-or-two-frame streak flash. Size 6 → 0, Squash −0.49 → 3: wide to needle-thin. |
| 0–0.1 | `Model` implode mesh (EffectDuration 0.1) | A red SurfaceAppearance shell collapses from 19.6 × 9.3 × 18.5 to 0.38 × 19 × 0.36 while yawing 105°. It is a pinch that becomes a vertical spike. |
| 0–0.1 | DashDust/CenterWinds `winds` ×8, LingerShock, gradient ×3, Shockwave (Lifetime 0.1, Speed 146–366) | Wind cards fly 15–37 studs in 0.1 s: **motion-blur streaks**. |
| 0–0.3 / every 0.2 | `Dash` ring mesh (0.3, Rate 5) | A Neon ring is flung 13.5 studs back while it widens ×1.9 and thins to zero. |
| 0–0.4 / every 0.2 | `DASH` swirl mesh (0.4, Rate 5) | A decal-on-mesh wind tube grows ×4 across and yaws 42°. |
| 0–0.4 | `DashFire` Fir ×7 (0.2–0.4, EmitCount 2) | Flame jets shoot backward at Speed 30–100 with Drag 7, Squash 0 → 2–3, so they stretch. |
| 0–0.4 | `windtwirl` (0.4, one-shot) | Four beams twist 180° about the axis and slide 10.5 studs (outCubic): a corkscrew. |
| 0–0.4 → 3 | `WindBeams` (EffectDuration 0.4, EmitDuration 3) | Eight radial sheath beams with scrolling texture. Transparency_Scale 1 → 2 fades them in the tween. |
| 0–0.7 | `RunMesh` (0.7, one-shot, **not** ConstantVFX) | A start crown: ×7 wider, travels 17.5 studs back. The kick-off ring. |
| 0–1.9 | DashDust smoke kit (0.3–1.9, TimeScale 0.6–0.7) | Dust kick and residue. |
| 0–2.9 | DashFire/CenterWinds `winds` ×8, LingerShock (1.75–2.9 s), gradient ×3 (0.9–1.7 at TimeScale 0.9) | **The slow twin** of the fast wind set: haze lingering where the dash started. |

## 3. Layer stack
### Mesh models (Start → End, tween outCubic `.215,.61,.355,1`)
See section 4.

### Beams
**`windtwirl`** has four beams on Start and four on End, all texture 85772363699785 with TextureMode Static:
- **Rest property values:** TextureLength 59.36, Width0 6.1 / Width1 90.5, CurveSize0 4.12 / CurveSize1 −5.50, Segments 100, LightEmission 1, Transparency `1 → 0.60 (0.15) → 0.94 (0.44) → 1`.
- **Start set:** TextureSpeed 2, EffectDuration 0.6, Width0 15 and Width1 40 (held), Transparency_Scale 1 → 2.
- **End set:** TextureSpeed 3.5, EffectDuration 1, Width0 9.4, Width1 **26 → 139** (outCubic).
- **Geometry:** the four `Beams` attachments sit at ±4.9 studs on X and ±5.1 on Y, i.e. 90° apart around the axis. Each beam runs from A0 about 3 studs out to A1 about 21.6 studs back.
- **Motion:** the Start→End parts differ by **180° roll** (rot z 167.9 → −12.1), and End's inner Attachment sits at z −10.55. Tweening between them twists the four-beam fan half a turn while it slides 10.5 studs. That corkscrew is the "twirl".
- **Why:**
  - Width0 ≪ Width1 gives a cone flaring backward, which is how wind wakes look.
  - Opposite CurveSize signs make each beam an S-curve.
  - Static TextureMode with TextureLength 59 stretches one wisp texture across the whole beam, so it reads as a single stroke rather than a tiled pattern.
  - The transparency peak at 15% puts the visible part near the body and lets it dissolve behind.

**`WindBeams`** has eight beams, texture 137097904100100:
- **Placement:** the beam attachments sit at a radius of about 4.6 at 0°, 45°, 90° … 315°, a full radial sheath around the axis. Each runs from `front` near the body to `back` 17.5 studs behind.
- **Values:**
  - Width 8 → 30 (Forge; the rest values are 8.3 / 55)
  - CurveSize ±2 (rest values ±5.5) for a slight bulge
  - TextureLength 0.5 with Speed_Texture 3, so the texture scrolls
  - Length_Scale 0.925
  - **Brightness 0.1, LightEmission 1**
  - Transparency `1 → 0.42 (0.4) → 0.85 → 0.95 → 0.97 → 1`, with Transparency_Scale 1 → 2 outCubic
- **Why:** at Brightness 0.1 additive, the sheath is almost invisible on its own. It only lifts the value where the beams overlap, so the tunnel is suggested, not drawn. The scrolling texture supplies the **sense of flow even when the runner's on-screen speed is low**.

### Particles
**DashFire part**, 4 × 1 × 2, placed behind and below the body at (0.64, −4.6, −2.5). It holds seven `Fir` emitters, the same seven flame flipbooks as Up/Down:
- Same gradient: `#1E29FF → #441EB8 → #FF3B21 → #F12424 → #FF3122`.
- **EmissionDirection Back**, Speed 30–100, `SpreadAngle (0,20)`, Drag 7, Lifetime 0.2–0.4, EmitCount 2.
- **Squash ramps 0 → 2–3**, so the flame stretches along its velocity over its life.
- LightEmission −1, Brightness 25–40.
- Why: the flames are thrown backward hard, then drag pins them in place. Seen from a running camera, they hang behind the runner and stretch, and the stretch reads as a jet.

**DashFire/DustRaycast/CenterWinds** is the **slow wind set**. It has eight `winds` plus LingerShock, gradient ×3 and Shockwave, all at Speed 5–20:
- **Textures:** 109440284900004, 17409991165, 10859315454, 10149702982, 88867995909352 and 11820076505, plus LingerShock on 127240797498085.
- **Lifetimes:** winds 0.25–1.9 s; LingerShock 1.75–2.9 s with Size 0 → 12.6 and start transparency 0.8; gradient 0.9–1.7 s at TimeScale 0.9, Size 2 → 26.7 with start transparency 0.4.
- **Values:** greys `#848484`, `#4B4B4B` and `#373737`, at LightEmission 1 / LightInfluence 0.55.
- Everything is VelocityPerpendicular (camera-facing), with fade-in transparency starting at 1.
- Why: this set is residue, a pale haze that marks where the dash started.

**DashDust part**, 8 × 6.86 × 8:
- **MainSpeedline** (92756777074741): `#FF2323`, Lifetime 0.06, Speed 0, VelocityParallel, Front. Size 6.1 → 0 on an ease-out, Squash −0.49 → 3.
- **SpeedlineContrast**: the same texture at `#FF2515`, Lifetime 0.07.
- **Shard** (18236638593): **black**, LightEmission 0.65, Size 0 → 3.6 → 0, Lifetime 0.06.
- Why: the line is visible for only 3–4 frames. The black Shard twin gives the red line a dark core, which is a value contrast. The Squash ramp turns a wedge into a needle during those frames, which the eye reads as acceleration.
- **DashDust/DustRaycast** carries the **same smoke kit as Up/Down** (smoke1, SmokeGround ×2, Rocks ×2, Smoke ×3, SmokeWind, goatedngl ×2). Here it has **SpreadAngle 20–40 instead of 180, and EmitCount 1 instead of 2**. Narrowing the cone turns the radial puff into a **directional kick**.
- **DashDust/DustRaycast/CenterWinds** is the **fast twin of the wind set**: the same eight textures, Lifetime **0.1**, **Speed 146–366**, Rate 7, and sizes ×1.46 larger.
  - Why: in 0.1 s a card travels 15–37 studs, so it renders as a smear, a particle-made motion blur.
  - The slow twin, with the same textures, lingers. One texture set covers both the **streak and the residue** read.

## 4. Mesh VFX detail
| model | mesh / texture | Start → End | duration / loop | transparency | read |
|---|---|---|---|---|---|
| `DASH` | SpecialMesh `8501563708`, Decal `9572542664`, Color3 HDR ≈ (2.18, 2.18, 2.18), ZIndex 0 | Part 3.12 × 1.17 × 1.17 → 3.04 × 4.82 × 4.82; mesh Scale (0.59, 0.117, 0.117) → (0.578, 0.482, 0.482), **×4.1 across, length held**; pos (0.87, 2.87, −0.26) → (0.63, 1.68, −0.59); rot (0, −180, 90.3) → (−0.7, 138.2, 89.2), **a 42° roll about the travel axis** | EffectDuration 0.4, **Rate 5, `#ConstantVFX`** | `Part_Transparency 1 → 1` (the part stays invisible); **Decal Transparency 0.8 → 1** | A wind-swirl tube around the body. The **decal-on-mesh trick**: the part never shows, and the decal carries the texture and its fade. HDR Color3 above 1 makes the decal glow without Neon. |
| `Dash` | MeshPart `18434669670`, Neon | 1.18 × 8.2 × 8.2 at y −5.97 → **0.001** × 15.72 × 15.72 at y +7.58 | 0.3 s, Rate 5, ConstantVFX, `Part_TweenParams=Cubic,Out` | 0.8 → 1 (outCubic) | A sonic-boom ring: diameter ×1.92, **thickness → 0**, flung 13.55 studs back. Thinning to zero kills it by geometry as well as by fade, so there is no hard pop. |
| `RunMesh` | MeshPart `7472102456`, Neon, `#F8F8F8`, DoubleSided | 3.46 × 1.49 × 3.86 at y −10.9 (ahead of the body) → 24.46 × 1.3 × 25.86 at y +6.55 | 0.7 s, EmitCount 1, **one-shot** | 0.8 → 1 | A kick-off crown: ×7 wider and 17.5 studs back. Near-white, but **never more opaque than 0.8**. |
| `Model` | MeshPart `76812637992657`, Neon, DoubleSided, **SurfaceAppearance AlphaMode=Transparency, Color #FF2403** | 19.6 × 9.33 × 18.49, rot y −75 → 0.38 × 18.98 × 0.36, rot y 180 | 0.1 s, Rate 5, ConstantVFX | no Part_Transparency attributes (runtime default) | An **implosion pinch**: X/Z collapse ×50 while Y doubles and it yaws 105°. A red flicker at the body on each pulse. The SurfaceAppearance (alpha-tested texture plus tint) replaces a decal on this mesh. |

All mesh models are anchored and placed once at the emit CFrame. They stay **world-anchored** while the runner moves on, so a `Rate 5` model drops a ring every 0.2 s along the path. **The spacing between stamps encodes the speed**: at 60 studs/s the rings land 12 studs apart.

## 5. Color & value
- **Wind:** greys `#848484 / #4B4B4B / #373737`, and white-ish textures at LightEmission 1 with very low Brightness (0–2).
- **Sheath:** Brightness 0.1 additive.
- **Meshes:** `#F8F8F8` at 0.8 transparency; decal HDR 2.18; ring Neon at 0.8.
- **Fire accent:** blue-birth red, `#1E29FF → #FF3B21`, at LightEmission −1 and Brightness 25–40. This is the only saturated element, and it sits small and low, behind the body.
- **Speed lines:** red `#FF2323` / `#FF2515` at Brightness 15, with a **black Shard twin**.
- **Implosion:** `#FF2403` SurfaceAppearance.
- **Value structure:** a large pale low-contrast envelope (wind, sheath, rings), one small high-saturation accent (fire and speed lines), and black twin accents. The motion reads through the light envelope, and the identity colour (red) reads through the small accent.

## 6. Rebuild recipe
```lua
-- template axis: pivot-local -Y = dash direction, +Y = behind
-- weld/anchor the template to the root each pulse: ConstantVFX children re-spawn at Rate while the dash is held
local function pulse(rootCf)
	emitMesh(DASH, rootCf)      -- decal fade 0.8->1, scale x4.1 across, roll 42, 0.4 s outCubic
	emitMesh(DashRing, rootCf)  -- ring diam x1.9, thickness->0, +13.5 studs back, 0.3 s
	emitMesh(Implode, rootCf)   -- 0.1 s pinch, X/Z x0.02, Y x2, yaw 105
end
local function start(rootCf)
	emitMesh(RunMesh, rootCf)   -- one-shot crown x7, 17.5 back, 0.7 s
	emitMesh(windtwirl, rootCf) -- 4-beam fan, roll 180 + slide 10.5, beams fade via Transparency_Scale 1->2
	enableBeams(WindBeams, 3)   -- 8 radial beams, scrolling texture, Brightness 0.1 additive
	burst(DashFire)             -- 7 Fir, Back, Speed 30-100, Drag 7, Squash 0->3
	burst(DashDust)             -- speedline (0.06 s) + black shard, smoke kit cone 20-40, fast winds (0.1 s, 146-366 speed)
	burst(DashFire.CenterWinds) -- slow wind twin: same textures, Speed 5-20, 0.25-2.9 s
	while dashing do pulse(root.CFrame); task.wait(1 / 5) end
end
```
Particles that should stay at the dash origin (residue) are **not** LockedToPart. Only the SmokeGround pair locks, to keep the ground dust under the feet.

## 7. Candidate principles
1. **A speed read comes from world-anchored stamps at a fixed Rate.**
   - The rings are spawned 5 times a second and left in place, so their spacing shows the velocity.
   - Evidence: `Rate=5` with `#ConstantVFX` on DASH, Dash and Model, all anchored Start/End parts.
2. **Use one texture set at two time scales: fast for the streak, slow for the residue.**
   - Evidence: the CenterWinds sets carry identical textures, at Lifetime 0.1 / Speed 146–366 versus Lifetime 0.25–2.9 / Speed 5–20.
3. **Kill a mesh by thinning it to zero as well as fading it.**
   - Evidence: `Dash` ring X size 1.18 → 0.001, `Model` X/Z → ×0.02, combined with a transparency of 0.8 → 1.
4. **Mesh rings start at 0.8 transparency, never opaque, and never pure white plus Neon at full opacity.**
   - Evidence: RunMesh `#F8F8F8` at 0.8, Dash ring at 0.8, DASH decal at 0.8.
5. **Decal-on-mesh with HDR Color3 gives glow without Neon.**
   - Evidence: the DASH part stays at Transparency 1 throughout. Its decal Color3 ≈ 2.18 carries all the visibility.
6. **Use SurfaceAppearance with AlphaMode Transparency to texture a MeshPart directly**, as an alternative to a wrapped decal. Evidence: the implosion `Model`.
7. **A wind wake is a flaring, S-curved beam fan that twists.**
   - Width0 ≪ Width1 (6 → 90), opposite CurveSize signs.
   - A 180° roll between the Start and End parts drives the twist.
8. **A sheath at Brightness 0.1 additive suggests the volume through overlap only.** Evidence: the WindBeams.
9. **Reuse kits across effects and change only spread and count to change the read.**
   - Evidence: the Up/Down smoke kit goes from SpreadAngle 180 / EmitCount 2 (radial puff) to 20–40 / EmitCount 1 (directional kick).
   - The same seven Fir flipbooks appear in Up, Down and Dash.
10. **A speed line lives for 0.06 s and turns from wedge to needle**, with a black twin underneath. Evidence: Squash −0.49 → 3 and the black `Shard`.
