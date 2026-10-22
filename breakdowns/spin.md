# spin (`Workspace.modern_vfx["spin "]`, trailing space in the name)

Source: dumped 2026-10-22 from Place3 (PlaceId 114773467389373). 607 instances: 416 ParticleEmitters, 40 MeshParts, 40 Beams, 27 Models, 8 Motor6Ds, 3 Trails. The root is an **unanchored, invisible Part** (22.3 × 1.7 × 22.3, Transparency 1) with four children: `Out beam`, `Model` (the Motor6D rig), `Meshes` and `Lotus`. Nothing was captured visually; everything below comes from the property dump.

## 1. Read
This is a ground-level spinning attack, a whirlwind about 26 studs across. Eight banked emitter carriers fling red-to-green petal and fire slashes tangentially around a ring. Eight S-curved beam blades lean outward like the arms of a pinwheel. Three faint white wind meshes twist and expand upward. Rings of textured lotus meshes bloom out of the floor around it.
- **First frame:** the white wind shells (95% transparent) and the burst of tangential slashes from the eight carriers.
- **Peak (0–0.3 s):** the beam blades are at full width, the slashes are curving around the ring, and the inner and outer lotus rings break the ground.
- **Residue (0.6–2.2 s):** the middle lotus ring arrives late (+0.2 s), the lotuses fade over 2 s, and the black fog beam and dark debris linger to 1.4 s.

## 2. Timeline
| t (s) | layer | what happens |
|---|---|---|
| 0 | Meshes.SpinWind | wind shell 39.6×8.1×35.5 → 47.7×18.9×42.8 over **0.325 s**, rising 2.2 studs, RotSpeed 9 → 0 (outCubic), transparency .95 → 1 |
| 0 | Meshes.Spinnywind | swirl mesh 22.7 → 49 wide (×2.16) over **0.62 s**, rising 2.6 studs, RotSpeed 15 → 0, transparency .9 → 1 on an overshooting curve; Speed 1 → .7 over the first 0.155 s |
| 0 | Meshes.Spinnywind_A | the same swirl mesh, smaller (17 → 36.8), slow: **1.5 s**, RotSpeed 3, transparency .92 → 1. This is the residue copy |
| 0 | Model carriers 1–8 (×18 emitters each) | burst: Star ×3, Spinning Petal ×2 (+Rate 16 for 0.2 s ≈ +3), linesup ×1 ×2 colors, Fir ×1 ×7 textures, debris 1/2/3/6 ×1, Extra dust ×1. Lifetimes 0.2–0.6 s |
| 0 | Model.1 trails | 3 trails (red/black core 0.04 s, two black smears 0.15 s), always enabled, so they only draw while the carrier moves |
| 0 | Out beam ×8 slots (5 beams each) | Width0 10 → 15, Width1 7 → 15 (or 1 → 15), texture length and speed decelerate, Transparency_Scale 1 → 2. Duration **1.0 s** (cyan fog, `4`, `4d`) or **1.4 s** (orange fog, black fog) |
| 0 | Lotus G2 (6, inner r≈7.3) + G3 (6, outer r≈13.5) | lotus mesh grows ×1.8 and rises 0.6–1.05 studs over **2 s**, transparency 0 → 1 outCubic. Each lotus's Start part bursts its own 16-emitter stack (Speed 1–10, Spread 50) |
| 0.2 | Lotus G1 (6, middle r≈10) | the same bloom, **delayed 0.2 s**, so the rings read as a ripple (inner + outer first, then the gap fills) |
| 2.2 | — | last lotus fully transparent. The two `dur=1` Lotus1 models have only a Start part (no End): dead leftovers, so skip them |

## 3. Layer stack

### A. The Motor6D rig (`Model`): 8 carriers, the "body"
- **Geometry:** 8 invisible Parts (1.44×5.76×3.6) on a circle of **r = 12.96** around (0, 4.32, −1.44) relative to the root, at **45° steps** (yaw 0, ±40/50, ±90, ±130/140, 180). Each one faces the ring **tangent** and is **banked 20° on Z** (`rot(0, yaw, 20)`).
- **Joints:** each carrier is joined by a `Motor6D` with `Part0 = spin root` and `Part1 = carrier`. C0 is identity and C1 holds the offset. The carriers are `Massless` and unanchored. A stray `Root` part sits at the origin and nothing connects to it. It is a leftover from the rig being authored as an animatable model.
- **How it spins:** no script, attribute (`SpinRotation`/`SpinSpeed`) or Animator in the place drives it. A full scan of the ReplicatedStorage/SSS/StarterPlayer/Workspace/ServerStorage sources found no reference to Motor6D, Transform or SpinRotation. Because the root is unanchored with massless Motor6D children, it is meant to be **welded to the caster's HumanoidRootPart, or CFramed by the ability script**. Whatever rotates the root rotates every carrier **and** the beams, because `Out beam` is parented straight to the root. Motor6D was chosen over Weld so an Animator could also animate each carrier's `Transform` independently, for example to wobble blades during the spin. The rebuild needs only a root rotation.
- **Why tangential:** every carrier emitter uses `EmissionDirection = Left` (the carrier's local −X, which is the ring tangent) with `LockedToPart = true`. With LockedToPart, `Acceleration` is applied in the carrier's local frame, and local +Z points **toward the ring center**. So `Acceleration (0,0,250)` on Fir/debris and `(0,0,10)` on linesup is a **centripetal pull**. Particles launched tangentially at 40–60 studs/s bend around the circle instead of flying off straight. That is the whirl. It comes from the emitter, not from spinning the part. Star uses +7.2 (slight inward) on most carriers and −3.6 (outward) on carrier 1, a small asymmetry.
- **Per-carrier stack (18 emitters):**

| emitter | role | key values | why |
|---|---|---|---|
| Star (131311043057562) | twinkle core | #FF6E3E, Size 2.16 → 0, Transp 1 → 0 @0.49 → 1 (fade **in** then out), LightEmission 1, Brightness 12, ZOffset 4, Lifetime 0.5, Speed 18, TimeScale 0.8, EmitCount 3 | the only fully additive layer. The fade-in keeps it from popping on frame 1. ZOffset 4 draws it in front of the slashes |
| Spinning Petal (13802408466, Custom flipbook @16 fps) | the signature motif | gradient #FF9D47 → #FF1919 @0.27 → #87FFAD, Size 0 → .585 @0.12 → 0, Lifetime .3–.5, Speed 21.6–43.2, Spread 40, LightEmission 0, Brightness 10, ZOffset 4.2, EmitCount 2 + Rate 16 for EmitDuration 0.2 | **hue shift orange → red → mint over life**: complementary contrast inside one particle. LightEmission 0 keeps the color saturated and stops it going additive and white |
| linesup ×2 (73632766634333, 4×4) | speed streaks | #FF6B3A (Br 50) and a twin #5DFF86 (Br 35), Size .77 → 4.1 growing, Squash 0 → .64 eased, Lifetime 0.6, Speed 10–20, Accel +10 | two copies in complementary colors overlap into a warm/cool fringed streak. They grow through life, so the streak lengthens as it slows |
| Fir ×7 (7 different slash/fire textures) | body slashes | #FF2A2A → #33FF55, Size 0 → .99 @0.1 → .43 → 0, Squash .19 → 1.09, Brightness 25–40, ZOffset 1, Lifetime .2–.3, Speed 40–60, Spread 40, Disc ShapePartial .5, VelocityInheritance 1, Rotation ±90 | **seven textures at EmitCount 1 each instead of one texture at EmitCount 7**: every slash has a different silhouette, so the burst never looks cloned. The red → green shift matches the petal |
| Extra (102161518877797, 4×4) | ground-tinted dust | #000000 base with `UseGroundColor` (falls back to #AC8A74), Transp eases out late, Size .5 → .77 | anchors the effect to whatever floor it is on |
| 1 / 2 / 3 / 6 (84849028410631, 107420715710066, 125570183631896) | dark debris | **#883319** (dark brown-red), Sizes .17–1.24, Squash ±.5 (6 uses VelocityPerpendicular), 3 has RotSpeed 360–720 | the **dark value** in a stack of bright slashes. Without it the whole effect is mid-to-high value and flat |

- **Trails (carrier 1 only):** `Trails` attachment with a 0.92-stud pair (Attachment ↔ Attachment1, ±0.46 Z).
  - Trail A: 9035801067, #FF1E1E → #000000, Lifetime 0.04, Brightness 30. A hot sliver that cools to black at the tail.
  - Trails B and C: 12251461261 / 15398097961, **black**, Transp .23 → 1, WidthScale 1 → 0, Lifetime 0.15, LightEmission .75. A dark smear that trails the bright one.
  - Only one carrier has trails, so a single lead blade gets a motion path. Eight would be noise.

### B. Beams (`Out beam`): 8 slots × 5 beams, the "secondary" and silhouette layer
- **Slots:** 8 attachments on r ≈ 11.7–12.05 around the root at y +0.72, with Y rotation every 45° and Z tilt **50°** (one slot at 40°, a hand-placed irregularity). Each slot holds `debris ring` (5.68, −2.64, 1.10) and `Attachment` (≈ −3.2…−6.0, 5.02, −0.4…2.5) children with fixed local orientations. Each beam spans about 11–12 studs from low-outside to high-inside of the tilted slot, so it reads as a **diagonal blade leaning out of the ring**.
- **Curve:** CurveSize0 = −4 and CurveSize1 = +4 (attributes, start = end). Opposite signs make an **S-curve**, so each blade looks like a cupped wind swipe rather than a straight bar.
- **The 5-beam stack per slot:**

| beam | texture | color | key values | job |
|---|---|---|---|---|
| BeamFilled fog 2 (cyan) | 18470709110 | #A5FFE9 | LightEmission 1, Brightness 3, **Segments 8**, TexLen .6 → .2, TexSpeed .3 → .1, Dur 1.0 | soft cool haze. 8 segments is enough because the fog is blurry |
| BeamFilled fog 2 (warm) | 18470709110 | #FFB560 | LightEmission 1, Brightness 10, Segments 500, TexLen .2 → .4, TexSpeed 2 → 1, ZOffset .001, Dur 1.4 | the bright body of the blade. The fast scroll slowing to half speed reads as the spin losing momentum |
| `4` | 100013157062966 | gradient #FF9A34 → #FF2A2A → #AD7F56 → #31FF98 along the length | LightEmission .6, Brightness 10, Segments 1000, Width0 7 fixed, **Width1 1 → 15**, TexLen .5 → .3, TexSpeed 2 → .4, Transp min .26 at middle | the hard-edged streak. The far end flares from a point to full width (blade "opens") and the color runs orange → red → brown → mint end to end |
| `4d` | 131025768925255 | same gradient | **LightEmission 0**, Brightness 10, Width1 1 → 15, TexLen .2 → .3, TexSpeed .5 → .1, Transp min .69 | non-additive twin of `4` with a different texture. It gives the streak body and color without blowing out |
| BeamFilled fog 2 (black) | 18470709110 | **#000000** | LightEmission 0, Transp .51 @0.49 → .9 @0.68, Width0 10 → 15, Width1 7 → 15, Dur 1.4 | **dark twin of the warm fog**: the same texture, path and widths in black, so the blade has a shadowed core and edge contrast against bright skies |

- **Shared transparency envelope:** Transparency is 1 at both ends with a mid dip (.26–.73), so blades never show a hard end cap. `Transparency_Scale` 1 → 2 (outCubic) multiplies the whole envelope toward invisible over the effect duration.
- **Why the beams ride the root:** they are parented to `Out beam` under the root, not to the carriers. One rotation of the root sweeps all 40 beams. The beam slots (r ≈ 12, y 0.7) sit just inside and below the carrier ring (r 12.96, y 4.3), so blades and slashes interleave without z-fighting.

### C. Wind meshes (`Meshes`): the "core flash" and "secondary sheen"
See section 4. They are white Neon at 90–95% transparency. They are a **sheen, not a shape**: at that transparency the white only lifts value where the shells overlap the colored layers.

### D. Lotus ground blooms (`Lotus`): the "ground" layer
- **Count:** 18 working Lotus1 models in 3 rings of 6, plus 2 dead ones. Lotus mesh 117547468732069 with its own **TextureID 108137537040363** on the MeshPart. This is the one place in the effect where a texture sits directly on a mesh, because the lotus is a modelled, painted prop rather than a VFX shell.
- **Rings (root space):** inner G2 r ≈ 7.3 (Start 4.2 wide), middle G1 r ≈ 10 (5.23), outer G3 r ≈ 13.5 (7.04). Size grows with radius, so perspective-like scaling pushes the eye outward. Yaws vary in 15° steps (−165…135) so no two neighbors match.
- **Animation:** Start → End is exactly **×1.8 on every axis** (X/Z), with a slight Y bias (Y ×2.2), rising 0.63–1.05 studs out of the floor (Start sits below y 0, so the bloom emerges *through* the ground). Duration 2 s, Part_Transparency 0 → 1, all curves outCubic. It grows fast and fades early: half-transparent by about t = 0.4 s.
- **Tags:** `#ConstantVFX` with `Rate 1`. Played as a 2 s window it emits once.
- **Per-lotus emitters (16 on `Start.Start` attachment):** the same 16-emitter recipe as a carrier (Fir ×7, debris, Star, Petal, linesup ×2, Extra), but with **Speed 1–10, Spread 50, default Top direction, no acceleration**. Sizes scale with the lotus (×1.2 middle, ×1.35 outer). The bloom pops with the same vocabulary as the spin, which ties the ground layer to the body.

## 4. Mesh VFX detail
| model | mesh | Start (size @ offset) | End | scale | rise | time | spin | transparency |
|---|---|---|---|---|---|---|---|---|
| SpinWind | 113793875136271 (wind shell) | 39.6×8.06×35.5 @ (−.59, −2.23, 1.78) | 47.7×18.9×42.8 @ (−.38, 0, .26) | ×1.2 wide, **×2.35 tall** | +2.2 | 0.325 s outCubic (Mesh_Scale, Size, CFrame) | Part_RotSpeed 9 → 0 outCubic (RotSpeed_Curve .39,.575,.565,1) | .95 → 1 outCubic |
| Spinnywind | 4681227436 (classic swirl/tornado shell), DoubleSided | 22.7×10.6×22.7 @ (.57, −2.14, −.11) | 49×15.8×47.4 @ (0, .43, 0) | ×2.16 wide, ×1.5 tall | +2.6 | 0.62 s | RotSpeed 15 → 0 | .9 → 1, curve bezier(.321,1.2,.747,1.006): **overshoot**, so the shell flashes nearly invisible early, settles back, then fades |
| Spinnywind_A | 4681227436 | 17×7.9×17 | 36.8×11.9×35.6 | ×2.16 / ×1.5 | +2.6 | **1.5 s** | RotSpeed 3 | .92 → 1, same overshoot |

- **Why it reads modern:** three shells, not one, with **different durations (0.33 / 0.62 / 1.5 s) and spin rates (9 / 15 / 3)**. The eye sees a fast burst, a mid swirl, then a slow ghost. The fastest shell stretches mostly **vertically** (×2.35) while the swirls stretch horizontally (×2.16), so the silhouettes diverge as they grow. All Starts sit about 2.2 studs below the End and below the root, so the shells rise *out of* the spin plane.
- `MaxInitRot = (0,1,0)`: a random initial yaw per emit, so repeated casts never line up. `SpreadAngle (0,90,0)` on the swirls adds up to 90° of extra random yaw.
- No decal-on-mesh here. These are plain Neon white MeshParts driven by `Part_Transparency`. Color comes entirely from the particle and beam layers beneath them.

## 5. Color & value
- **Warm family:** #FF6E3E (star), #FF6B3A (linesup), #FF9D47 → #FF1919 (petal), #FF2A2A (fir start, trail), #FF9A34 → #FF2A2A (beam gradient), #FFB560 (warm fog).
- **Cool complement:** #33FF55 (fir end), #5DFF86 (linesup twin), #87FFAD (petal end), #31FF98 (beam tail), #A5FFE9 (cyan fog).
- **Darks:** #883319 (debris, about 30% value), #AD7F56 (beam mid-gradient, desaturated brown), #000000 (black fog beam, `4d`-style non-emissive twins, black trails, Extra dust).
- **Hue shift over lifetime:** every hero layer travels **red-orange → green** (Petal, Fir, beam gradient). The motion reads as heat turning into wind. This complementary pair is the whole identity of the effect.
- **LightEmission strategy:** only Star (1), the two fogs (1) and `4` (.6) are additive. Petal, Fir, linesup, `4d` and the debris are **LightEmission 0 with high Brightness (10–50)**, so they glow through Brightness while keeping saturation and occluding what is behind them. The black fog and the `4d` twin give every additive blade a non-additive body behind it.
- **White:** only on the wind meshes, and only at ≥ 90% transparency.

## 6. Rebuild recipe
```lua
-- template: root (unanchored, invisible) + Out beam attachments + 8 Motor6D carriers + Meshes + Lotus
local fx = template:Clone()
fx:PivotTo(hrp.CFrame * CFrame.new(0, -2.5, 0))  -- root sits at foot level; carriers at +4.32
local weld = Instance.new("Weld") ; weld.Part0, weld.Part1 = hrp, fx ; weld.C0 = CFrame.new(0, -2.5, 0) ; weld.Parent = fx
fx.Parent = workspace
-- spin: rotate the weld (or let the caster's spin animation do it); decelerate like the meshes
local t0 = os.clock()
local conn = RunService.Heartbeat:Connect(function()
	local a = math.clamp((os.clock() - t0) / 0.62, 0, 1)
	weld.C0 = CFrame.new(0, -2.5, 0) * CFrame.Angles(0, -math.rad(720) * outCubic(a), 0)
end)
forge.emitAll(fx.Model)          -- per emitter: Emit(EmitCount) after EmitDelay; then Enabled for EmitDuration
forge.beams(fx["Out beam"])      -- tween Width0/1, TextureLength, TextureSpeed, Transparency scale over EffectDuration (1 / 1.4)
for _, m in fx.Meshes:GetChildren() do forge.emitMesh(m) end  -- clone Start, tween to End, RotSpeed decays, random yaw
for _, ring in fx.Lotus:GetChildren() do
	task.delay(ring:GetAttribute("EmitDelay") or 0, function()
		for _, lotus in ring:GetChildren() do
			if lotus:FindFirstChild("End") then forge.emitMesh(lotus) ; forge.emitAll(lotus.Start) end
		end
	end)
end
task.delay(2.3, function() conn:Disconnect() fx:Destroy() end)
```
Key numbers to keep: carrier ring r 12.96 at +4.32, bank 20°. Beam slots r ≈ 12 at +0.72, tilt 50°, CurveSize ∓4. Lotus rings r 7.3/10/13.5 with the middle ring +0.2 s, ×1.8 bloom over 2 s. Wind shells 0.325/0.62/1.5 s.

## 7. Candidate principles
1. **Make a whirl with centripetal acceleration, not by spinning the emitter.** Emit with `EmissionDirection` along the ring tangent, set `LockedToPart`, and point `Acceleration` at the center in the part's local frame (here +Z 250). Evidence: every carrier emitter in spin, with Fir/debris at 250 and linesup at 10.
2. **One hero burst = several textures × EmitCount 1, not one texture × EmitCount N.** Evidence: 7 Fir emitters with 7 slash textures and otherwise identical curves, all at EmitCount 1.
3. **Every additive layer gets a non-additive or black twin on the same geometry.** Evidence: warm fog vs black fog (same texture, path and widths), `4` (LightEmission .6) vs `4d` (0), the red trail plus two black trails, and #883319 debris under the bright slashes.
4. **Hue-shift hero particles to the complement over their life.** Evidence: Petal #FF9D47 → #FF1919 → #87FFAD, Fir #FF2A2A → #33FF55, and the beam gradient orange → red → brown → mint.
5. **Stack mesh shells with staggered durations and spin rates (fast, mid, slow ghost).** Evidence: wind shells at 0.325/0.62/1.5 s and RotSpeed 9/15/3, each starting below the plane and rising 2.2–2.6 studs.
6. **Ripple ground props in rings with one ring delayed.** Evidence: Lotus inner and outer rings at t = 0, middle at +0.2 s. Size grows with radius (4.2/5.2/7.0) and yaws are offset in 15° steps.
7. **Beams that sell rotation are S-curves with an opening width and a decelerating texture scroll.** Evidence: CurveSize0/1 = −4/+4, Width1 1 → 15, TextureSpeed 2 → 0.4 / 2 → 1 / 0.3 → 0.1 (all outCubic), and Transparency 1 at both ends.
8. **Parent everything that should rotate to one root and rotate only that.** Use Motor6D (not Weld) when the parts might later be animated individually. Evidence: 8 Motor6Ds with Part0 = the root, and the beam attachments parented straight to the root.
9. **Pure white is acceptable only as a ≥ 90%-transparent sheen.** Evidence: all three wind shells are #FFFFFF/#F8F8F8 Neon starting at .9–.95. Every opaque layer is colored.
