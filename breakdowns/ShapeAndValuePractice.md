# ShapeAndValuePractice (blue/orange comet projectile with impact explosion)

Source: `Workspace.modern_vfx.ShapeAndValuePractice`, a Folder with 355 instances: 92 emitters, 40 Beams, 51 Folders and 12 MeshParts. CFrames in this breakdown are **world** values, because a Folder has no pivot.

It has three children:
- **`Part` (70.5, 131.1, −27.8)** is the real effect. Its `Bezier` attachment (`#BezierParticle`) carries a 12.3 × 0.5 × 0.5 projectile part along a path. The end-point attachment `End` sits at local (−71.4, 2.4, 0), and `EmitOnFinish/Explodie` holds the impact. That Explodie is pre-placed at (1.01, 130.5, −25.7), about where the path ends.
- **`Part` (82.9, 137.0, 25.7)** is a loose copy of the projectile body.
- **`Explodie` (60.7, 131.0, 27.8)** is a loose copy of the impact.

A sorted line diff shows the loose copies are identical to the nested originals. They are the artist's turntable copies for viewing each piece on its own.

Explodie was captured with `ropilot_vfx_capture`, front view, at 0.03, 0.08, 0.2 and 0.45 s.

## 1. Read
A comet-shaped orb flies along a Bezier path, then bursts into a blue explosion with orange accents.
- **Projectile:** a spearhead silhouette built from beam cones, with streak particles riding it.
- **Impact frame (0.03 s):** a jagged, angular **star**, blue and orange, about 40 studs across.
- **0.08 s:** a bright round core inside **dark vertical speed streaks**.
- **0.2 s:** a round blue mass with grey smoke puffs at its base.
- **0.45 s:** a translucent blue dome shell with falling specks and curving comet trails, then fade.

The shape sequence runs **sharp → round → dots**. The value sequence runs **one bright point → dark streaks around a bright core → mid-value mass → scattered small highlights**.

## 2. Timeline
| t (s) | layer | what happens |
|---|---|---|
| 0–0.8 | projectile emitters (`@EmitDuration=0.8`, Rate 10, LockedToPart) and cone beams | The orb is alive for its flight. Particles live 0.2–0.6 s and stay locked to the moving part. |
| end of path | `EmitOnFinish` → Explodie | The impact fires. |
| +0 → +0.1 | `Impact46` ×2 (Lifetime 0.05–0.1, Size 0.002 → 40, LightEmission −1, ZOffset 5) | The star frame, on top of everything. |
| +0 → +0.4 | PointLight (Brightness 50, Range 20, `#2B7CFF`), enabled through `RayValue Enabled @Duration=0.4 @ResetOnFinish` | Lights the surroundings blue. |
| +0 → +0.55 | ring cards: StylizedImpat1, StylizedWind1, OdinOs_8, Blurred Spec 35 (0.36–0.55, Size 1.6 → 16.3); ground cards: New20, Detailed, Dissapearing Crescent (VelocityPerpendicular, Size 2.3 → 19.3±3.6) | Expanding impact rings in the air and on the ground plane. |
| +0 → +0.6 | core `ParticleEmitter` 105107349199911 (Size 1 → 10, 0.3–0.6 s, blue Brightness 50 / orange Brightness 15) | The round core. |
| +0.05 | `@EmitDelay=0.05` group: Speed lines, smoke, energy pulse, embers, specs | **The secondary wave lands 50 ms after the star**, giving a frame of separation between the impact and the mass. |
| +0.05 → +0.15 | Speed lines (0.05–0.1 s, **Brightness 0**), Multiple Specs 5 (0.05–0.1) | The dark radial streaks from the 0.08 s capture. |
| +0.05 → +1.25 | Stylized Smoke37/51, Realistic Energy Pulse, glowing abstract matrix spec, small ember specs, Blurred Spec 19, glowing embers, Stylizedenergy1 (0.6–1.2 s) | The mass, then residue. Specs fall under Acceleration −24.9 / −62.3. |
| +0 → +0.6 | 2 × `Bezier` sub-particles (`@EmitCount=4`, `@Duration=0.3..0.6`, `@SpreadAngle=(90,90,0)`, `@DestroyDelay=1`) | Eight curving comets: a Medium Dot head plus a Trail (0.3 s). |
| +0 → ? | three mesh models (no EffectDuration, so the runtime default applies) | Dome shells and a shockwave ring expand and fade from 0.6 (domes) or 0.8 (decal) to 1. |

## 3. Layer stack
### A. Projectile (`Bezier/Part`, 12.3 studs long on X, front = +X, tail = −X)
**Beam cones: the shape.**
- Inside `Folder/Folder/Folder` sit **16 `BeamFilled wavey` beams** (texture 18925205019, TextureSpeed 3, Segments 50).
- Each one runs from an attachment on a **ring of radius 2** to a single tail point at (−6.15, 0, 0).
- The ring points are spaced every 45°: (±2, 0), (0, ±2), (±1.414, ±1.414).
- There are **two rings**, one at x = 2.109 and one at x = 0. That makes two nested cones, offset 2.1 studs, so the silhouette is a stepped spearhead and not a single cone.
- **Two value layers share these cones:**
  - Ring at x = 2.109: Color **`#000000 → #2C6BFF`**, LightEmission 0, Brightness 2, Width 0 → 3, CurveSize0 −2. This is the *dark-to-blue* layer.
  - Ring at x = 0: Color `#2C6BFF`, LightEmission 1, Brightness 5, Width 0.1 → 3, CurveSize0 −1. This is the *additive blue* layer.
  - Both use Transparency `1 → 0 (0.3) → 0 → 0 (0.7) → 1`, so the beam is invisible at both ends.
- **Why:** 16 thin twisted strokes converge to a point, which gives a 3D cone that reads from any angle. The black-to-blue ramp along each stroke puts **dark at the head ring and light toward the tail body**, so the orb gets a dark rim around its front. That is a value edge, not a glow.

**Outline beams.** Two `5` folders hold four `Beam116` beams (texture 72969225620485, **FaceCamera**, TextureSpeed 2, Width 0.1 → 3, Transparency `1 → 0 (0.73) → 1`):
- The pairs start at (5.27, 0, ±1) and (8.79, 0, ±1) and run to the tail point.
- They use **CurveSize ±3**, which bows them into an almond or flame-tongue outline.
- The pair at 5.27: blue `#2C6BFF`, LightEmission 1, Brightness 6.
- The pair at 8.79: `#2C6BFF → #000000`, LightEmission 0, Brightness 2, the dark outline.
- **Why:** the FaceCamera pair always draws the 2D silhouette edge toward the camera, around the 3D cone mass. It is a *line drawing over a form*, the way a 2D effects artist would ink a comet.

**Riding particles.** All of these use LockedToPart, Speed 15, EmissionDirection Right, Rate 10 and EmitDuration 0.8. **Each is authored twice, orange and blue.**

| emitter | texture | values |
|---|---|---|
| Line Spec 16 ×3 | 87904104613018 | VelocityParallel; Size 0.001 → 4 (0.49) → 0.001, a diamond envelope; one variant holds Size 9 |
| Multiple Specs 26 ×2 | 12386363554 | Size 1.5, Spread 30 |
| Wiggly Ball ×2 (+1 each on the parent part) | 14004161351 | Size 0.001 → 0.66 → 0.001, Custom flipbook |
| Blurred Spec 11 | 284205403 | Size 7.5, Transparency `1 → 0.97 → 1`, almost invisible: a faint blue halo |

Shared values:
- Orange `#FF521D` at ZOffset 0.001; blue `#297BFF`.
- **LightEmission 0** and Brightness 5 on all of them.
- Transparency `1 → 0 (0.5) → 1`: they fade in and out, so there is never a pop.

### B. Explodie (15 × 0.1 × 15 part)
**Shape groups.**
- **Angular / star:** Impact46 ×2 (16997072742). One is `#FF7322`, one `#2E3CFF`. Size 0.002 → 40 in 0.05–0.1 s, LightEmission −1, Brightness 15, ZOffset 5, VelocityParallel.
- **Ring / round, air:**
  - StylizedImpat1 (8048608283), StylizedWind1 (11820076505), OdinOs_8 (136040076370041) and Blurred Spec 35 (13580351149).
  - All are `#3369FF` / `#346AFF`, Size 1.63 → 16.32 (×10), Lifetime 0.36–0.55.
  - **Each texture appears twice, at Brightness 15 and at Brightness 0.**
- **Ring / round, ground:** New20 (16434901408), Detailed (122460061985642) and Dissapearing Crescent (87180053247428). All are `#2E6DFF`, Size 2.29 → 19.28±3.57, VelocityPerpendicular (a flat ground plane), Brightness 3, EmitCount 3.
- **Core:** the `ParticleEmitter` 105107349199911 pair. Size 1 → 10, Transparency held at 0. Blue `#2B5CFF` at **Brightness 50**, orange `#FF4C15` at **Brightness 15**.
- **Mass / smoke:**
  - Stylized Smoke37 (16924719592): **`#3F3F3F` dark grey**, Size 20, Squash `0 → 0.41 → 0.23 → 0.04` (it bulges, then settles), Speed 0.01.
  - Stylized Smoke51 fading (16867479408): blue and orange copies, Speed 37.4, Spread (50, 360).
  - Realistic Energy Pulse (16511790647): Size 0 → 6.25 (0.085) → 9.25 → 10, a fast-out ring.
- **Dots / specks:**
  - glowing abstract matrix spec (113297314814130), Size 5 → 0.
  - small ember specs (88848729824097), Size 0 → 12.5, Acceleration −62.3.
  - Blurred Spec 19 (14159634300), Size 6.07 → 1.64 (0.036) → 0, a flash then shrink.
  - glowing embers 4×4 (80656721027970), white.
  - Stylizedenergy1 (97130732091369): `#FFFFFF → #2A2A2A`, starting at 0.77 transparency.
  - Shared: Acceleration −24.9 (gravity), Drag 4, EmitCount 3, Rotation −360..60.
- **Streaks:** Speed lines (73607860120690) at **Brightness 0**, Size 10, Squash 0 → −3, Speed 62, Spread (0, 360), Lifetime 0.05–0.1. Multiple Specs 5 (15142050539): blue at Brightness 50, orange at Brightness 5.
- **Secondary motion:** two Bezier sub-emitters. Each sends 4 particles along a path from (0, 0, 0) to (0, 0, −15), with tangents T0 (−4, 0, 6) and T1 (4, 0, −6), an S-curve. Spread (90, 90, 0) and Duration 0.3–0.6.
  - The head is `Medium Dot 2` (120240711510201): Size 1 → 0, Brightness 15.
  - The first sub-emitter has a blue `#296DFF` dot with `BeamSideways Trail 2` (6203493685, `#2B80FF`, LightEmission 1, WidthScale 1 → 0).
  - The second has an orange `#FF6B15` dot with `BeamStretched Wave` (14543379496, `#FF6B15`, LightEmission 1).
- **Light:** PointLight `#2B7CFF`, Brightness 50, Range 20, held for 0.4 s and reset.

## 4. Mesh VFX detail
| model | mesh / texture | Start → End (world, Explodie at y 130.5) | transparency | read |
|---|---|---|---|---|
| outer dome | `6351288405`, Neon, `#2268A5`, DoubleSided | 6.63 × 9.53 × 7.33 at y 133.04, rot (0, 180, 180) → 38.82 × 9.13 × 42.91 at y 132.84, rot (0, −76, 180): **×5.9 wide, height held, +104° yaw** | 0.6 → 1 | A blue dome shell expanding outward and spinning. The blue is deliberately **dark** (`#2268A5` is mid-value), so even Neon at 0.6 does not blow out. |
| inner dome | `6351288405`, Neon, `#FF5B1A` | 4.96 × 7.13 × 5.48 at y 131.84 → 29.05 × 6.84 × 32.11 at y 131.69, same 104° yaw | 0.6 → 1 | An orange shell **nested inside** the blue one, at ×0.75 size and 1.2 studs lower. You see orange through blue, a two-tone shell. |
| shockwave | `9729834399` (+ TextureID 9729834609), two Decals `10423614733` on **Top and Bottom**, Color3 HDR 1.176, ZIndex 0 | 13.5 × 1.49 × 13.5 at y 131.21, rot y 180 → 43.48 × 10.29 × 43.48 at y 129.81, rot y −94: **×3.2 wide, ×6.9 taller, +86° yaw, dropping 1.4 studs** | decal 0.8 → 1 (Bottom decal); the part stays invisible | A ground shock ring that rises into a wall as it widens. The decal on both faces is visible from above and below. HDR 1.176 adds a slight glow. |

**The domes rotate while they scale**: 104° and 86° over the tween. A scaling-only shell looks like a balloon. Adding yaw makes the texture sweep, which reads as energy.

## 5. Color & value (the practice's point)
- **Palette:**
  - Blue family, the **dominant**: `#2F66FF`, `#3369FF`, `#2E6DFF`, `#2B5CFF`, `#2C6BFF`, `#297BFF`, `#2268A5` (dark shell).
  - Orange family, the **accent**: `#FF6219`, `#FF521D`, `#FF4C15`, `#FF701D`, `#FF7322`, `#FF5B1A`, `#FF6B15`.
  - Neutrals: smoke `#3F3F3F`, energy `#FFFFFF → #2A2A2A`, black beam ends.
- **Dominance through Brightness, not count.** Every orange element has a blue twin with the same texture, count and motion. The blue runs **Brightness 15–50** and the orange **Brightness 5–15**:
  - core 50 vs 15
  - Multiple Specs 50 vs 5
  - embers and specs 16 vs 5
  - Blurred Spec 15 vs 5

  Blue wins the value read and orange reads only as hue temperature, a 3:1 to 10:1 ratio.
- **LightEmission 0 almost everywhere.** Normal alpha blending means overlapping layers do not stack to white, so each layer keeps its own value. The only exceptions:
  - additive (LightEmission 1): the beam glow layer, trails and outline beams
  - LightEmission −1: Impact46
  - Brightness is the only dial used for value.
- **Dark twins built into the stack:**
  - OdinOs_8 and StylizedImpat1 / StylizedWind1 each come at **Brightness 0 and Brightness 15**. The Brightness-0 copy renders as a near-black version of the same shape, a built-in shadow.
  - Speed lines at Brightness 0 give the dark streak frame at 0.08 s.
  - Dark grey smoke `#3F3F3F` sits under the bright core.
  - The black ends of the beam gradients form a dark rim on the projectile.
- **Value through time:**
  - the star: saturated, Brightness 15, on top at ZOffset 5
  - dark streaks plus the brightest core (Brightness 50)
  - mid-value smoke and shell (`#2268A5`, `#3F3F3F`)
  - small scattered highlights falling away
- **Colour temperature in depth:** orange sits **inside**, as the inner dome and the ZOffset-0.001 particles, wrapped by a cooler blue outside. The warm core and cool shell read as heat at the centre.

## 6. Rebuild recipe
```lua
-- PROJECTILE: part 12.3 long, front +X; ride a #BezierParticle path; enable 0.8 s
for _, x in {2.109, 0} do -- two nested cones
	for a = 0, 315, 45 do
		local p = Vector3.new(x, math.sin(math.rad(a)) * 2, math.cos(math.rad(a)) * 2)
		beamBetween(p, Vector3.new(-6.15, 0, 0), {
			Texture = "rbxassetid://18925205019", TextureSpeed = 3, Width0 = x > 0 and 0 or 0.1, Width1 = 3,
			CurveSize0 = x > 0 and -2 or -1, Segments = 50,
			Color = x > 0 and seq("#000000", "#2C6BFF") or seq("#2C6BFF"),
			LightEmission = x > 0 and 0 or 1, Brightness = x > 0 and 2 or 5,
			Transparency = ns{0,1, 0.3,0, 0.7,0, 1,1},
		})
	end
end
-- FaceCamera outline pairs, CurveSize +-3, from (5.27,0,+-1) blue LE1 B6 and (8.79,0,+-1) blue->black LE0 B2
-- riding particles: each orange #FF521D + blue #297BFF, LightEmission 0, Brightness 5, LockedToPart, fade in/out
-- IMPACT on path end:
--   t0: Impact46 blue+orange (0.002 -> 40, 0.05-0.1 s, LE -1, ZOffset 5); air rings x2 (B15 + B0); ground rings;
--       core B50 blue / B15 orange; PointLight 0.4 s; 2 Bezier comet emitters x4
--   t0.05: speed lines B0 (dark), smoke #3F3F3F size 20 squash bulge, energy pulse, falling specs (Accel -25/-62)
--   meshes: blue dome #2268A5 Neon 0.6->1 x5.9 +104 yaw; orange dome inside x0.75; decal shockwave x3.2 wide x6.9 tall +86 yaw
```

## 7. Candidate principles
**Shape language**
1. **Impact shapes go sharp → round → dots.**
   - Evidence: a jagged star at 0.05–0.1 s, then round rings, domes and smoke over 0.36–1.2 s, then falling specks.
   - The sharp read must be the shortest-lived and the largest (Size 40) element, drawn on top (ZOffset 5).
2. **Build a 3D projectile silhouette from converging beam strokes, and ink it with a FaceCamera outline.**
   - Evidence: 16 radial cone beams form the form, plus four CurveSize ±3 FaceCamera beams for the edge.
3. **Nest two copies offset in depth to get a stepped silhouette.**
   - Evidence: cone rings at x = 2.109 and x = 0; the orange dome inside the blue dome at ×0.75.
4. **Expanding shells rotate as they scale.**
   - Evidence: the domes yaw 104° and the shockwave 86°. Scale-only reads as a balloon.
5. **Use Squash curves to give smoke a shape**: bulge, then settle.
   - Evidence: `0 → 0.41 → 0.23 → 0.04` on the Stylized Smoke emitters.
6. **Separate impact and mass by one frame.** Evidence: `@EmitDelay=0.05` on the whole secondary group.

**Value structure**
7. **Set value with Brightness at LightEmission 0, and keep additive blending only for line glows.**
   - Evidence: nearly every particle is LightEmission 0. Only beams and trails are additive, plus Impact46 at −1.
   - Result: overlaps keep their value and never wash to white.
8. **The dominant colour gets 3–10× the Brightness, not more particles.**
   - Evidence: twins with identical counts and textures at Brightness 50/15/16 vs 15/5/5.
9. **Make dark accents from the same texture at Brightness 0.**
   - Evidence: the OdinOs_8, StylizedImpat1, StylizedWind1 and Speed lines pairs.
   - A shadow copy of the shape costs nothing, and it gives each bright layer a dark edge.
10. **Ramp beams from black to colour along their length to put a dark rim at the leading edge.**
    - Evidence: `#000000 → #2C6BFF` on the head-ring cones and `#2C6BFF → #000000` on the outer outline.
11. **Glowing mesh shells use a mid-value colour.**
    - Evidence: the dome is `#2268A5`, not `#2F66FF`, starting at transparency 0.6. Neon plus a bright hue plus low transparency blows out.
12. **Put warm colours inside and cool colours outside.** Evidence: the orange inner dome and ZOffset-0.001 orange particles sit inside the blue.
13. **Fade in and fade out (`1 → 0 → 1`) on sustained particles, so nothing pops.** Evidence: every riding particle on the projectile.
