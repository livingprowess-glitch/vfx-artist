# ShapeAndValue2: fire meteor / pillar slam (orange)

The name says it all: a practice piece on **shape** (silhouette of each element) and **value** (light vs dark masses). Every orange element has a black twin.

## 1. Read
At t=1 s a fire impact lands on the ground at the origin (`Attachment` at y-16).
- A fire pillar of 4 stacked beams rises.
- Rock chips, glowing embers and smoke burst downward and out.
- A ground spike ring and a torus shock column erupt.
- A bezier fire bolt (t=0.4) arrives just before and pops into a flame flipbook.
- **Eye path:** the bolt streak, then a frame of 20 flares at 0.95, then the pillar plus spikes at 1.0, then the black and orange debris falling, then smoke and fog lingering.

## 2. Timeline
| t (s) | layer | what happens |
|---|---|---|
| 0.4 → 0.7 | `Bezier` projectile (linear, 0.3 s, mirrored, SpreadAngle 90) | trail 106729630607723 (#FF4F1A, WidthScale `0 → 1@50% → 0`); on finish, flame flipbook `2` (Color #FF8C27 → #CF3313@75% → **#000000**) |
| 0.95 | `Flare141New` ×20 | Lifetime 0.05–0.1, Squash ±3, LightEmission -3, Brightness 50: an anticipation flash **one beat before** the hit |
| 1.0 → 4.0 | pillar beams ×4 per side (`T1→B1`, `T2→B2`) | width 30–50 holding on **inQuint** then collapsing; TextureSpeed -1/-2 (two speeds = parallax); spatial Transparency `[0:1 1:0]`, opaque at the ground, fading at the top |
| 1.0 → 1.6 | torus 7722530552 + crescent-ring decal (hdr 1.96) | scale Y 23.5 → **118.75** (×5), X ×1.7: a vertical shock column |
| 1.0 | flat cone 7423457269 + thin-ring decal (hdr 3.9) | scale Y 1.06 → **7.8** (×7.4), XZ ×1.4: a ground spike ring erupting |
| 1.0 → 1.1 | `wind6` dome + spiky decal 14277319792 (#C8C8C8 grey) | `Duration 0.1`, from 20×23×23 to 17×38×37 |
| 1.0 → 1.6 | debris: `glowing dark rock`, `Rock6`, `Sideways Spec 4`, `Glowing Spec 9`, `Blinking Spec` | Speed -100..-1 (sucked or pulled), accel -130 (orange) / **-65 (black twin)**, Drag 5 |
| 1.0 → 3.0 | `Fire6`, `Fire55`, `Dark Shadow Fire` | Rate 10 for 2 s, Size 1→10, Rotation ±20 (fire stays upright) |
| 1.0 → 3.0 | `Ground21`/`Ground30` (Brightness **156**, Squash -0.7, flat on the ground), `Line Slash 1` (22 → 0.001, Squash -1) | ground scorch glow and a vertical slash line |
| 1.0 → 4.0 | `PointLight` (#FF6811, Range 30, Shadows) with a RayValue `Enabled` (Duration 3) | the light switches on for exactly the effect's life |
| 1.0 → 3.6 | `Tall Realistic Smoke` (#878787 at 0.86 transparency, plus a white **Brightness 0** twin), `Seamless Fog` (#3A3A3A) | residue |

## 3. Layer stack with reasons
- **Value twins, the core lesson.**
  - Each of these appears twice: once in orange (#FF5C1C / #FF4B1E / #FF4F19) with Brightness 5–50, and once in **#FFFFFF with Brightness 0, which renders flat black**.
    - `glowing dark rock`
    - `Glowing Spec 9`
    - `Sideways Spec 4`
    - `Speed lines`
    - `Tall Realistic Smoke`
    - `Greyscale Cartoon AOE`
  - The black twin usually has **half the gravity** (-65 vs -130), so it separates from the orange copy as the particles fall.
  - **Why:** a fire effect made only of additive orange is a flat glow with no form. The black twins act as shadow and soot masses, giving the eye a light/dark pattern to read. The gravity offset turns that into a shadow trailing each ember.
- **Pillar beams (4 overlapping):**
  - `BeamWide Spiked smoke` ×2 (18762827354, LightEmission 0, Brightness 2 and 5, TextureSpeed -2 and -1)
  - `Beam132` (fire 119058761936819, width **50**, LightEmission 1, Brightness 15): a wide hot core glow behind
  - `Beam100` (85772363699785 torn energy ribbon, LightEmission 1, Brightness 2)
  - Every beam has 50 segments and uses the Forge Width curve **inQuint**.
  - **Why:**
    - Different TextureSpeeds make the layers slide past each other, so the beam churns.
    - The inQuint width holds full width for most of the 3 s and then pinches out fast. That's a decisive end, not a slow deflate.
    - The spatial transparency `[0:1 1:0]` roots the pillar at the ground and fades it into the sky.
- **Anticipation flare (0.95 s, ×20, 0.05–0.1 s life, Squash ±3).** One beat before the impact, a cluster of stretched glints fires. Classic anime anticipation: the flash precedes the hit.
- **Shape language:**
  - `Speed lines` (Squash 0 → -2.3, stretched, 0.05 s)
  - `Line Slash 1` (22 → 0, Squash -1)
  - `Flare141New` (Squash -3)
  - Long thin shapes say speed and force. Round ones (`Greyscale Cartoon AOE`, smoke) say mass and residue. The piece deliberately mixes sharp shapes for force with round ones for weight.
- **Fire emitters** use Rotation -20..20, not -360..360. Flames must stay upright to read as fire. Debris, by contrast, spins freely.

## 4. Mesh VFX detail
| model | mesh / decal | Start → End | note |
|---|---|---|---|
| shock column | torus 7722530552 + decal 108886089477305 (crescent ring), hdr 1.96 | scale (22.8, 23.5, 10.2) → (39.8, **118.75**, 17.8), y +10.5; EffectDuration 0.6 | a torus stretched ×5 vertically becomes a tube of crescent streaks |
| spike ring | flat cone 7423457269 + decal 18280512172 (thin ring), hdr 3.9 | scale (2.5, 1.06, 5.8) → (3.4, 7.8, 8.0), y -3.5 | a flat cone popping tall becomes erupting ground spikes |
| air dome | 8501563708 + decal 14277319792 (spiky radial), #C8C8C8 | scale (0.90, 0.78, 0.73) → (0.74, 1.28, 1.20); Duration 0.1 (Cubic/Sine Out) | a 0.1 s pressure flash |

- **Primitive meshes stretched far out of proportion** (×5–×7 on one axis) become new shapes. A torus becomes a column, a flat cone becomes spikes.
- **Decal color stays neutral** (hdr white or #C8C8C8 grey). Orange comes from particles, beams and the light.

## 5. Color & value
- **Orange family:** #FF3C15 → #FF6822 (hue 10–20°). Ember/smoke variants are #FF5C1C / #FF4B1E / #FF4F19. The light is #FF6811.
- **Black:** white with Brightness 0 for twins, #444444 rock, #3A3A3A fog, #545454 `1_Disappear`.
- **Grey smoke:** #878787 at 0.86 transparency (barely there).
- **Value structure:** a hot core (Brightness 15–156), mid orange (Brightness 2–6), black twins, grey residue. Four steps, every one present.

## 6. Rebuild recipe
```lua
at(0.4)  bezierBolt{trail=106729630607723 "#FF4F1A" w{0,1@.5,0} .3s, onFinish=flame(105107349199911, CS{"#FF8C27",.75,"#CF3313",1,"#000"})}
at(0.95) burst(flare 17230437889, "#FF531A", LE=-3, B=50, squash=-3, life=.05-.1, count=20)
at(1.0)  pillar(T->B, { {18762827354,LE0,B2,spd-2,w30}, {18762827354,LE0,B5,spd-1,w30}, {119058761936819,LE1,B15,spd-2,w50}, {85772363699785,LE1,B2,spd-2,w30} },
              transp=NS{0,1, 1,0}, widthCurve=inQuint, life=3)
         decalMesh(torus 7722530552 + 108886089477305 hdr1.96, scaleY 23.5->118.75, .6s)
         decalMesh(cone 7423457269 + 18280512172 hdr3.9, scaleY 1.06->7.8, y-3.5)
         for each debris in {darkRock 88172632768007, rock6, specs...}:
             burst(debris, "#FF5C1C", B=50, accel=-130); burst(debris, WHITE, B=0, accel=-65)  -- black twin
         emit(fire 16845227778/17062535921/15371082237, rate 10 for 2s, size 1->10, rot ±20)
         light(#FF6811, range 30, shadows, 3s)
```

## 7. Candidate principles
1. **Every bright element gets a black twin** (Brightness 0) with half the gravity. Value comes before color.
2. **Anticipation flash 0.05 s before impact** (a cluster of stretched glints).
3. **Beams = 3–4 stacked textures at different TextureSpeeds** with an inQuint width collapse and spatial transparency rooted at the origin.
4. **Stretch primitive meshes ×5–×7 on one axis** to invent shapes (torus → column, flat cone → spikes) and wrap them in a broken decal.
5. **Sharp/stretched shapes for force, round shapes for mass.** Fire stays upright (±20° rotation), debris spins freely.
6. **Lights are timed to the effect** (a RayValue Duration), not left on.
7. **Flipbook endings fade color to black** (#FF8C27 → #CF3313 → #000).
