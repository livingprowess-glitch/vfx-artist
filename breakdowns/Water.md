# Water kit: WaterPractice, VFX1, VFX2, BALLVFX

`VFX1`/`VFX2`/`BALLVFX` were added 2026-10-22 as the "new water VFX". `WaterPractice` is the older practice piece. All four come from one asset kit: the same water flipbook textures and the same #277AFF family.

## 1. Read
- **VFX1:** a medium water splash on the ground. A spray crown erupts, sheets of water flip outward, droplets arc down under gravity, and a faint grey mist and a few leaves settle.
- **VFX2:** the same kit scaled up about 2.5×, adding a bubble pop, a big ring wave and a one-frame flash (`14`, Lifetime 0.1).
- **BALLVFX:** a water ball flies a bezier arc (0.2 s) with a trail and splashes on arrival (`EmitOnFinish`).
- **WaterPractice:** a water vortex. A bezier droplet with a blue trail circles the center while a spinning model (`SpinRotation (0,360,0)`, 3 s) carries an orb of glow, ripple and lens flare.
- **Eye path (VFX1/2):** the bright frame-1 flash and ring, then the outward splash sheets, then the arcing droplets, then the grey mist and leaves as residue.

## 2. Timeline (VFX1)
Everything fires at t=0 (`EmitDelay` 0). The motion comes from flipbooks, drag and gravity, not from delays.

| t (s) | layer | what happens |
|---|---|---|
| 0–0.05 | `wind` mesh (Lifetime 0.05) | a flat disc slams out: X 10→1.8, YZ 2.3→18.8, Transparency 0. This is the impact frame. |
| 0–0.15 | `SCREENEFFECT` ImageLabel | an 8×8 flipbook overlay, peak Transparency 0.58. A camera-space splash. |
| 0–0.6 | `Meshdown` mesh particle | a tall column collapses into a wide disc while spinning up (see §4) |
| 0–0.6 | `Images/water_2`, `31`, `Images/42` | ground ring sheets expand (VelocityPerpendicular = flat on the ground plane) |
| 0–0.5 | `fluid11`, `15011456461`, `Sprite_012` | droplet flipbooks fly 50–100 studs/s and fall at Acceleration -150 |
| 0–1.0 | `redmesh2` ring | an almost invisible expanding ring (Transparency 0.973→0.995) that adds a sheen |
| 0–1.0 | `BrightFrontWind` ×2 | torn wind ribbons spin out with decelerating spin |
| 0.1–1.5 | `Stylized Smoke59`, `Smoke-Effect`, `rockflip2`, `stylized leaf` | residue: grey mist, rock chips and leaves drift and settle |

## 3. Layer stack (VFX1), with reasons
**Core (frame-1 read)**
- **`wind`** (MeshPart 8089863097, a vertical hoop, white Neon, Lifetime 0.05, Transparency 0):
  - It's the only fully opaque mesh, and it exists for a single frame.
  - **Why:** an impact needs one frame of solid, high-contrast shape. Any longer and it reads as a solid object, not energy.
- **`SCREENEFFECT`** (ImageLabel, #559CFF, 8×8 flipbook, 0.15 s):
  - It sells the hit in screen space.
  - Peak transparency is only 0.58, so it tints the view rather than covering it.

**Body (the splash itself)**
- **`Images/42`, `Images/DONE`, `waterflipbook`** (Grid4x4/8x8 flipbook sheets, #277AFF, Brightness 10, Lifetime 0.4, size grows ×2–3):
  - `Speed` ≈ 0.05 with `Orientation=VelocityPerpendicular` keeps them on the ground.
  - **Why:** the flipbook already contains the splash animation. The emitter only places, scales and tints it.
- **`31`** (texture 18838828771, a white ring, Size 0→14.7, SpreadAngle 15, EmitCount 9):
  - Nine slightly tilted rings stacked on each other make a thick, wobbly shockwave edge from a thin texture.

**Secondary (motion)**
- **`fluid11`, `15011456461`, `Sprite_012`** (water flipbooks):
  - Speed 50–100, SpreadAngle 90, Acceleration -150, Drag 5, Size `[0:0 0.197:3.8 1:0]`.
  - **Why:**
    - High speed combined with Drag 5 gives an explosive start that quickly bleeds off, so the droplets hang and then fall under strong gravity.
    - Size peaks at 20% of life and shrinks to 0, so the droplets thin out as they fall instead of popping off.
    - `TimeScale 0.86` slows everything about 14%, giving it weight.
- **`image (2) (6)`** (`LightEmission = -1`):
  - A negative LightEmission darkens and saturates instead of adding light.
  - This keeps the blue deep where droplets overlap. Additive layers would wash to white there.
  - Its two-hump size curve (`0:0 0.096:3.4 0.396:0 0.599:3.25 1:0`) makes each droplet blink twice, like a glint.

**Residue**
- **`Stylized Smoke59`** (#8B8B8B, LightEmission 1, Transparency floor 0.8), **`Smoke-Effect`** (#545454) and **`rockflip2`** (#8D8D8D):
  - These are neutral greys.
  - **Why:**
    - Mist and debris are not water, so they don't get the effect's hue.
    - Grey residue next to saturated blue makes the blue read stronger (simultaneous contrast).
- **`stylized leaf 1`** (#005500 dark green, 6 leaves):
  - Grounds the effect in the environment. It's a cheap storytelling detail: "this hit a grassy floor".

**Mesh particles (PartIcle)**
- These are covered in §4.

## 4. Mesh VFX detail (the modern part)
All meshes are emitted as **mesh particles** (PartIcle `Configuration`), not tweened once.

| mesh | id / shape | lifetime | size curve (X/Y/Z) | transparency | color, brightness | role |
|---|---|---|---|---|---|---|
| Meshdown | 7430299023, thin wavy tilted ring | 0.6 | XZ 6.5→21.6 linear-ish; Y 15.6→4.5 by 19%→3.3 | 1→**0.825**→1 | #A2A2A2 Neon | the column-to-disc collapse that sells the splash shape |
| redmesh2 | 12070899434, open band ring | 1.0 | XZ 0.26→22 by 39% →29; Y const 2.7 | 0.973→0.98→0.995 | white | a barely-there sheen ring |
| wind | 8089863097, vertical hoop | 0.05 | X 10→1.8; YZ 2.3→18.8 | 0→0.988 | white Neon | the one-frame impact slam |
| BrightFrontWind | 7211026250, torn swirl ribbon | 0.4–1.0 | XZ 0.15→15.4 by 20% →19 (env ±4); Y 0→7.3→8.6 | 0.9→1 | #8D8C8B, Brightness 0.4 | wind spin-out, ×2 with random RotY 0..360, RotSpeedY 135→63 |
| ater2 / ater3 | 117825344749393 / 128408217404396, cone / twist | 0.5–0.6 | XZ 0.15–0.23→0.3–0.65 | 1→0→0.97 | #2C76FF / #2A6AC4, Brightness 2.5–3.5 | **16-frame decal flipbook on a mesh** (`MeshFlipbooks` 1..16); RotY random, RotSpeed up to 287°/s |
| wind6 | 8501563708 dome + decal 14277319792 (spiky radial) | 0.1 / 0.6 | YZ 0.22→0.71 / 0→0.99 | 0→1 | white (0.1 s) then #286CFF (0.6 s) | a white flash dome followed by a blue dome that lingers |

**Why this works, and what was wrong before:**
- **Transparency ceiling.**
  - Most meshes never get more opaque than 0.8–0.97.
  - The mesh provides **volume and motion direction** (a perspective-correct ring, a spinning ribbon), while particles provide the color and detail.
  - The old approach made the mesh the opaque hero.
- **Non-uniform scaling.**
  - Meshdown grows XZ ×3.3 while Y shrinks ×4.7. A column that collapses into a disc is a splash crown in two keyframes.
  - Uniform `Size*k` tweens can't do this.
- **Front-loaded growth.** 75% of the radius is reached in the first 20–40% of life, then the mesh crawls. That's ease-out, done with sequence keypoints.
- **Neutral grey meshes in a blue effect.** #A2A2A2 / #8D8C8B under Neon read as bright air/water sheen, not as more blue. The palette stays two-tone (blue + grey).
- **Spin decelerates** (RotSpeed 135→63) or accelerates (0→149). It's never a constant spin.
- **Duplicates with random rotation** (`EmitCount=2`, RotY 0..360) break symmetry for free.
- **Decal flipbooks on meshes** (`ater`): the mesh gives a 3D shape and the 16 decals animate the water surface on it. It's a 3D flipbook.

## 5. Color & value
- **Hue family:** #1E74FF–#3992FF (blue at roughly 220°). Variation comes **from value and Brightness (5, 10, 15, 50), not hue.**
- **Twin rule** (WaterPractice): `simple glowing star` and `fireflies` appear twice, once as #3172FF with LightEmission 1 and once as **#173378 with LightEmission 0**. The dark twin sits behind the glow and gives it an edge. The `Erica Water Wave Blur` pair is the same thing: Brightness 5 vs 0, ZOffset -3 vs -3.001.
- **Neutrals:**
  - greys #8B8B8B / #545454 / #8D8D8D for mist and rocks
  - #A2A2A2 / #8D8C8B for meshes
  - #005500 for leaves
- **Accents:** `Rainbow6` (#79B5FF, Transparency floor 0.8) and `Rainbow Lens Flare`. They add an iridescent fringe at very low opacity.
- **LightEmission:** 0 on most blue layers (they rely on Brightness and stay saturated), 1 on glows, **-1 on droplets** (to deepen overlaps).

## 6. Rebuild recipe (VFX1, Forge/PartIcle runtime)
```lua
-- t=0 at the impact point (Y = ground)
burst(attachment, { -- droplets
  tex = {12800352684, 79998832137235, 118811675581971}, color = "#277AFF",
  count = 5, size = NS{0,0, .2,3.8, 1,0}, speed = {50,100}, spread = 90,
  accel = Vector3.new(0,-150,0), drag = 5, life = {0.3,0.5}, timeScale = 0.86, flipbook = "4x4 OneShot" })
burst(ground, { tex = 129550154917593, size = NS{0,7.4, 1,14.4}, orient = "VelocityPerpendicular", speed = 0.05, life = 0.6, count = 1 })
burst(ground, { tex = 18838828771, size = NS{0,0, 1,14.7}, spread = 15, count = 9, transp = NS{0,1, .29,.92, 1,1} })
meshParticle(7430299023, { life = 0.6, sx = {6.5, 21.6}, sy = {15.6, 4.5@0.19, 3.3}, rotSpeedY = {0, 102@0.4, 149},
  transp = {1, 0.825@0.17, 1}, color = "#A2A2A2", material = Neon, rise = 0.3 })
meshParticle(8089863097, { life = 0.05, sx = {10, 2.7@0.06, 1.85}, syz = {2.3, 18.8}, transp = {0, 0.988} }) -- impact frame
meshParticle(7211026250, { count = 2, rotY = {0,360}, life = {0.4,1}, sxz = {0.15, 15.4@0.2, 19}, transp = {0.9, 1}, rotSpeedY = {135, 63} })
burst(ground, residue: grey smoke #8B8B8B LE1 transp floor .8, rocks #8D8D8D accel -15, 6 dark-green leaves)
screenFlipbook(12353440665, "#559CFF", 8x8, 0.15s, transp {0.97, 0.58@0.4, 1})
```
**To scale** (VFX2): multiply size, speed and acceleration together (VFX2 uses about ×1.6 speed, ×1.6 gravity and ×2.5–3 sizes). This is `u4_effects.ScaleParticles`.

## 7. Candidate principles
1. **One hue per effect, with value doing the work.** Blue spans #1E74FF–#3992FF. Everything else is neutral grey or a tiny accent. (Evidence: every water emitter.)
2. **Dark twin.** Duplicate a glowing layer in a darker shade of the hue with LightEmission 0, or Brightness 0, which renders black. (Evidence: the WaterPractice star/fireflies/Erica pairs.)
3. **Meshes are translucent volume, not the hero.** Peak opacity is 2–18%, except for single-frame slams (0.05 s at full opacity).
4. **Shape change beats size change.** Animate X, Y and Z separately: collapse one axis while growing another.
5. **Burst with Speed + Drag + gravity, and size `0 → peak@20% → 0`.** Particles explode, hang and thin out.
6. **Flipbooks carry the motion.** Grid4x4/8x8 OneShot sheets at 16–64 fps. The emitter only positions, scales and tints them.
7. **TimeScale 0.86** (≈0.85–0.95 across the corpus) gives the whole burst weight.
8. **Negative LightEmission** keeps overlapping colored particles saturated instead of blowing out to white.
9. **Neutral residue** (grey mist, rocks, environment debris like leaves) frames the hue and grounds the effect.
10. **A screen-space flipbook** at ≤0.6 peak opacity for 0.15 s on big impacts.
