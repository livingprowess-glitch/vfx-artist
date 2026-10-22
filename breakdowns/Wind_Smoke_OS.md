# Wind/Smoke OS: ground dust and wind bursts (neutral)

Three or four test rigs (at x = 100, 0, -100, and -100 elevated): a `Smoke` burst, a `Smoke/Wind` combined burst, and `Wind` bursts. Hue-less. It's a study of **lit smoke vs emissive wind**.

## 1. Read
A landing or dash dust cloud. Puffs of warm-tan and grey stylized smoke shoot out sideways (Speed 50–120, SpreadAngle 10×360 = a flat radial ring), slow down hard, and hang. Translucent wind-blast rings expand once on top. Black specks (grains) scatter.
- **Eye path:** the wind ring flash, then the smoke ring pushing out, then the lingering puffs.

## 2. Timeline
| t (s) | layer | what happens |
|---|---|---|
| 0 | `Transparenct Blast 1/2/3` (Wind) | Size **0 → 26@20% → 35**, Transparency 0.8 → 1, Color #878787 → #383838 (darkens over life), LightEmission 1, Brightness 3.75, Lifetime 1–1.5, ×2 each |
| 0 | `Wind5/24/44`, `Transparenct Blast 5`, `Drawn Crescent` | Size 0 → 21.5@20% → 25 (envelope ±10), base Transparency 0.45 / 0.55 / 0.85, #5F5F5F → #383838, LightEmission 1, Brightness 0.1–0.94 |
| 0 → 1.5 | smoke puffs (Smoke attachment) | Speed 50–120, SpreadAngle (10, 360), constant Size 5/7/11 ± 2, Transparency floor **0.6/0.7**, Squash 0 → 0.2 (or 0.35–0.45) |
| 0 → 2.25 | `Multiple Specs 17` (grains) | #000000, Brightness 0, Transparency 0.54 → 1, Speed 50–120, accel -8 |

## 3. Layer stack with reasons
- **Smoke puffs, each texture twice:** once in warm tan (#B27452 or #BD9371) and once in grey (#4F4F4F → #454545).
  - The textures: `Stylized Smoke33` 11827618350, `Grey Smoke 13` 112656826514756, `Realistic Smoke with circle specs` 81580024241252, `Style Smoke 25` 98047670375459, `2x2 Smoke Grey` 13975873083, `Cloud1` 94705242050106, `Basic 2x2` 14050533905, `Grey Galaxy Smoke` 14919880888.
  - **LightInfluence 1.35–2 with LightEmission 0.2–0.55.**
  - **Why:**
    - Dust and smoke are matter, not energy. High LightInfluence makes them take the scene's lighting (shaded by the sun, darker in shade), so they sit in the world.
    - The warm/grey pair gives the cloud two temperatures: sunlit warm tops, cool grey shadows.
    - The partial LightEmission keeps them from going muddy at night.
- **Constant size, with motion from speed and drag.**
  - Puffs don't grow. They're thrown radially (SpreadAngle 10 on one axis = a flat ring) and decelerate.
  - The envelope (±2) gives size variety.
  - **Why:** a flat radial ring of puffs reads as a ground shockwave of dust. Growth would make it look like a gas explosion instead.
- **Transparency floor 0.6–0.7, with keypoints above 1** (`0.6 → 0.87@60% → 1.12@80% → 1.6`).
  - Values above 1 are clamped, so this reaches full transparency around 70% of life with a smooth curve before it.
  - **Why:** stylized smoke at full opacity looks like solid cotton. 30–40% opacity lets the layers stack into volume.
- **Wind blasts: emissive (LightEmission 1) but dark** (#5F5F5F → #383838, Brightness 0.1–0.94).
  - Additive dark grey is a subtle brightening, like heat haze.
  - The color darkens over life, so the ring fades by value, not just alpha.
  - The size curve is outExpo-like (0 → 75% of final size in the first 20%), then it creeps: a pop-and-hang.
- **Grains:** black specks (`Multiple Specs 17`, Brightness 0) with light gravity. The dark punctuation keeps the cloud from reading as fog.

## 4. Mesh VFX detail
No meshes. This is the pure particle reference for **lit residue**. Pair it with mesh wind rings (see Startup/Water) when the effect needs a perspective ring.

## 5. Color & value
- **Warm:** #B27452 / #BD9371 (tan, desaturated orange).
- **Cool:** #4F4F4F → #454545 grey.
- **Wind:** #878787 → #383838, and #5F5F5F → #383838.
- **Grains:** black.
- **No saturated hue anywhere.** This layer is meant to sit under any colored effect.

## 6. Rebuild recipe
```lua
local TRANSP = NS{0,.6, .2,.63, .4,.72, .6,.87, .8,1.12, 1,1.6}
for _, tex in {11827618350, 112656826514756, 81580024241252, 98047670375459, 13975873083, 94705242050106} do
  burst(ground, {tex=tex, color="#B27452", le=.55, li=1.35, size=7±2, transp=TRANSP, speed={50,120}, spread=Vector2(10,360), drag=?, life={1,1.5}})
  burst(ground, {tex=tex, color=CS{"#4F4F4F","#454545"}, le=.55, li=2, size=7±2, transp=TRANSP, ...}) -- grey twin
end
for _, tex in {13959942757, 15846370432, 15846427306} do
  burst(ground, {tex=tex, color=CS{"#878787","#383838"}, le=1, b=3.75, size=NS{0,0, .2,26±5, 1,35±5}, transp=NS{0,.8, 1,1}, life={1,1.5}, count=2, orient="VelocityPerpendicular"})
end
burst(ground, {tex=1349050856, color=BLACK, b=0, speed={50,120}, accel=Vector3.new(0,-8,0), transp=NS{0,.54, 1,1}, life={1.5,2.25}})
```

## 7. Candidate principles
1. **Matter (smoke, dust, debris) is lit:** LightInfluence ≥1 and low LightEmission. **Energy is emissive:** LightEmission 1, LightInfluence 0.
2. **Warm/cool twins** of every smoke texture give volume through temperature.
3. **Transparency floor 0.6+** for stylized smoke. Use keypoints above 1 to shape the fade.
4. **Flat radial throw** (SpreadAngle (10, 360)) with drag for ground dust rings. Puffs don't need to grow.
5. **Wind rings fade by value** (Color darkens over life) as well as by alpha. Their size is a pop-and-hang (≥75% of final size at 20% of life).
6. **Black grains** punctuate soft clouds.
