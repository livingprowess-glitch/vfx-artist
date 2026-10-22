# Startup: projectile wind-up (green with an orange accent)

## 1. Read
A "start-up" burst at the hand or origin before a projectile launches.
- In the first 0.1–0.2 s, a stack of radial air-burst textures and wind rings pops out.
- A spinning bezier carrier then whips two mirrored projectiles (green core, orange accent trails) around and out over 0.4 s.
- **Eye path:** the central white/green flash pops at frame 1, the wind rings and dome flatten outward, then the eye follows the bright mirrored trails as they swing away.

## 2. Timeline
| t (s) | layer | what happens |
|---|---|---|
| 0–0.1 | `CenterWinds` (14 emitters, Lifetime 0.1) | every one shares Size `0 → 0.44@7% → 3.6`: one radial pop built from 10 different textures |
| 0–0.15 | funnel mesh (125349505454888, textured) | 5→27 wide, 0.43→2.5 tall, rotates 135°, **Transparency 0.2→1**: the boldest mesh, alive for 9 frames |
| 0–0.2 | wind ring (6351288405) | 5.7→24.7 wide, flips orientation (rot 135→-30), Transparency 0.93→1 |
| 0–0.2 | `Bwa` domes (8501563708 + swirl decal 15249897265, HDR 10×) | flat lens (scale Y 0.1) → wide dome (Y 0.5), moves down 3–10 studs; the decal goes 0.8→1 |
| 0–1.0 | wavy ring (7430299023) | 8→20 wide, Transparency 0.9→1, plus a `MeshEmitter` JSON wobble: CFrame keyframes ping-pong (Sine Out ↔ Linear In) every ~0.25 s |
| 0–0.4 | `SpinModel` | spins 700° in 1 s with spin speed on outCubic (fast start, coasting stop); Bezier `MirrorPaths` with `MirrorRotation (0,0,180)` launches two symmetric projectiles along a 15-stud path, `Easing_Curve` bezier(.695,.037,.636,.522) (accelerating) |
| 0–0.2 | projectile head | `Roar` (white + green twins, 0.05 s), `glow`, `Spec` (LightEmission -3, RotSpeed -1200, shrinking), `Sparks` (Brightness 50, VelocityParallel, Squash -1) |
| 0–0.3 | trails ×3 | see §3 |

## 3. Layer stack with reasons
- **CenterWinds radial pop: 14 emitters, one curve, many textures.**
  - The textures are `winds` 109440284900004 (×2: one LightEmission 0/Brightness 0 = **black**, one LightEmission 1), 17409991165 "best wind", 10859315454 (×2 in **#4B4B4B / #373737** with LightInfluence 0.55 and TimeScale 0.6), 10149702982, 88867995909352 (LightInfluence 1, not emissive), 11820076505, `LingerShock`, three `gradient` emitters (Color white→**black** over life), and `Shockwave`.
  - **Why:**
    - A burst made of 10 different but similar textures overlapping gives rich, non-repeating detail in 6 frames.
    - The dark copies (#373737/#4B4B4B, a black `winds`, gradients to black) give the pop an internal dark structure. Without them it would be a white blob.
    - The TimeScale 0.6 copies lag behind, so the burst has a trailing echo.
- **Funnel mesh at Transparency 0.2.**
  - This is the one near-solid mesh, and it only lasts 0.15 s.
  - **Why:** solid shapes are only allowed for a handful of frames. They give the impact silhouette, then hand over to translucent rings.
- **HDR-10× swirl decal on a dome (`Bwa`).**
  - The decal is driven only through `Transparency_Start 0.8 → End 1`, so it never gets more opaque than 20%.
  - **Why:** HDR makes even 20% opacity read as a bright energy swirl, and the low opacity keeps it from hiding the character.
  - The dome flattens into a lens and then opens. That's air being pushed out.
- **Mirrored bezier projectiles.**
  - `MirrorPaths=true` makes two symmetric arcs from one setup.
  - The accelerating easing (slow start, fast exit) reads as a whip-out.
- **Three trail layers (`SpinModel/.../Trail`):**
  1. **Core:** 9035801067 (streaks), Color **#75FF81 → #000000** (fades to black along its length), Brightness 10, LightEmission 0, WidthScale `0.42 → 0.14@21% → 0`, Lifetime 0.15. A thin, hard, dark-tailed core.
  2. **Body:** 12251461261 (soft smoke strip), #90FFAA, LightEmission 1, Brightness 2.86, Transparency `0.23 → 0.57@22% → 0.91@54% → 1`, WidthScale `1 → 0`, Lifetime 0.3. A soft additive glow wider than the core.
  3. **Accent:** 15398097961, **#FFA962 (orange)**, LightEmission 0.75, `TextureMode=Static`, TextureLength 40. A warm complementary wisp.
  - **Why:**
    - Core, body and accent is the standard trail stack.
    - Fading to black (not just transparent) gives the tail a value gradient.
    - The complementary orange at low intensity makes the green vibrate.
- **Projectile head.**
  - `Roar` is a white and green pair. `Spec` uses LightEmission -3 with RotSpeed -1200 and shrinks: a spinning glint that saturates.
  - `Sparks` use VelocityParallel with Squash -1 (stretched along velocity), Brightness 50 and a 0.1–0.25 s life.
  - `Circle72` and `Bezier1` are orange #FF8F34 at low opacity: the same accent as the trail.

## 4. Mesh VFX detail
| mesh | id | Start → End | transparency | life |
|---|---|---|---|---|
| wind ring | 6351288405 (torn wind ring) | 5.7×3.7×6.3 rot135 → 24.7×15.2×27.3 rot-30, Y -1 | 0.93→1 | 0.2 |
| funnel | 125349505454888 + TextureID 108085242936725 | 5×0.43×5 rot135 → 27×2.5×27 rot0 | **0.2**→1 | 0.15 |
| wavy ring | 7430299023 | 8×1.1×7.3 rot-135 → 20×5.4×18.4 rot60 | 0.9→1 | 1.0 + JSON CFrame wobble |
| dome ×2 (`Bwar`) | 8501563708 + decal 15249897265 hdr 10 | scale (0.41,0.10,0.10) → (0.37,0.51,0.50), Y -3.3 | decal 0.8→1 | 0.2 |
| dome ×2 (`Bwar2`) | same | (0.56,0.10,0.10) → (0.18,0.33,0.32), Y -10 | decal 0.8→1 | 0.2 |

- **Rotation deltas are large** (135°–195° in 0.15–0.2 s). The rotation itself is motion blur.
- Both domes start as **thin lenses** (two axes at 0.1) and open up: a pressure wave.
- **Two dome copies at different scales and drop distances** give a nested, parallax look.

## 5. Color & value
- **Green family:** #4AFF65 / #52FF66 / #5CFF82 / #6CFF78 / #75FF81 / #90FFAA (hue about 125–135°). The spread is mostly in lightness.
- **Accent:** orange #FF8F34 / #FFA962, which is complementary. It appears only in low-opacity layers (Transparency 0.93+, or LightEmission 0.75 trails).
- **Neutrals and darks:**
  - Winds: #848484, #4B4B4B, #373737, black (Brightness 0).
  - Gradients go white → black.
  - Meshes are #A3A2A5 / #A2A2A2 Neon.
  - Decals are hdr(10,10,10) white.

## 6. Rebuild recipe
```lua
local POP = NS{0,0, .068,.437, 1,3.625}  -- shared by every CenterWinds emitter, life 0.1
for _, tex in {109440284900004, 17409991165, 10149702982, 88867995909352, 11820076505, 17613747219} do burst(center, {tex=tex, color=WHITE, le=1, size=POP, life=.1, orient="VelocityPerpendicular", spin=±300..580}) end
burst(center, {tex=109440284900004, color="#848484", le=0, brightness=0, size=POP}) -- black twin
burst(center, {tex=10859315454, color="#373737", le=1, li=.55, size=POP, timeScale=.6}) -- dark lagging echo
burst(center, {tex=15855894460, color=CS{WHITE,BLACK}, transp=NS{0,.4, .2,.85, 1,1}, size=POP, timeScale=.9})
meshEmit(125349505454888, 5x.43x5 r135 -> 27x2.5x27 r0, .15s, transp .2->1)
meshEmit(6351288405, 5.7x3.7x6.3 r135 -> 24.7x15.2x27.3 r-30, .2s, transp .93->1)
decalMeshEmit(8501563708 + decal 15249897265 hdr10, lens -> dome, .2s, decal .8->1, y -3.3) -- and a smaller, deeper twin
spin(model, 700deg, 1s, outCubic)
mirroredBezier(path 15 studs, ease bezier(.695,.037,.636,.522), 0.4s,
  trails = { core {9035801067, #75FF81->#000, B10, w .42->.14->0, .15s},
             body {12251461261, #90FFAA, LE1, B2.86, transp .23->.57->.91->1, .3s},
             accent {15398097961, #FFA962, LE.75, static, len 40, .3s} })
```

## 7. Candidate principles
1. **Shared size curve, many textures.** One timing curve applied to 5–15 different radial textures gives a rich flash in under 0.1 s.
2. **Black and dark copies inside a bright burst.** Brightness 0, #373737 with LightInfluence 0.55, and gradients to black give the burst structure.
3. **Color → black over life or length** (trails, gradients) instead of only fading out.
4. **Complementary accent at ≤10–25% presence** (orange in green).
5. **Trail stack:** a thin hard core (LightEmission 0, Brightness 10, dark tail), a wide soft body (LightEmission 1, low Brightness, fading), and a static-noise accent.
6. **Solid meshes only for ≤0.15 s;** otherwise opacity stays at 0.07–0.2.
7. **Big rotation deltas (135–195°)** within short mesh lifetimes act as motion blur.
8. **MirrorPaths** gives symmetric projectiles from one definition.
