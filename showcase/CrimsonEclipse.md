# Crimson Eclipse: original showcase effect (2026-10-22)

A ground-slam rend. A crimson charge pulls inward, there's one beat of anticipation, then a hitstop impact, then the body, then lit residue.
- **Template:** `ReplicatedStorage.VFX.CrimsonEclipse`, played by `ReplicatedStorage.VFX.Emit`.
- **Stage:** `Workspace.CrimsonEclipseStage`.
- **Loop:** `StarterPlayerScripts.CrimsonEclipseShowcase` (E replays it, Q plays it at 0.25×).
- **Builder:** `build_crimson_eclipse.lua`. Rerun it to rebuild the template.

**Status: the user hasn't reviewed it yet.** The edit-mode capture returned flat frames for every effect, corpus effects included, so it has only been checked by `Emit.check` and by the mesh axes.

## Beats
| t (s) | beat | layers |
|---|---|---|
| 0–0.6 | charge | inward streaks on a 26-stud sphere surface plus a black twin; a core glow growing 0→9 while a dark-saturated orb (LightEmission −5) **implodes** 11→0.5 (push-pull); rising specs; two torn bands rising out of the floor, narrowing as they lengthen and counter-rotating (+165° / −140°, Quad In); hoop implodes ring→needle (0.45–0.7); camera rumble fades in |
| 0.62 | anticipation | 12 stretched glints (Squash −3, LightEmission −3, Brightness 50, 0.05–0.08 s) |
| 0.70 | impact | 0.07 s hitstop and camera kick; a **teal** core flash 40→0 in 0.08 s (the accent carries the hottest pixel); the crimson Impact4 star with a larger black twin; hot meshes ≤0.2 s (a crimson Neon spike crown dropping and flattening 6×10 → 30×3, a crimson needle lengthening 4→36 while thinning to 0.1, a black crumpled shell pancaking) |
| 0.70–1.2 | body | 3 slash flipbooks × EmitCount 2, each with its own Squash, LightEmission −1, plus a black twin; ground ring plus a black twin lagging 0.02 s; a shockwave fading to black; embers fading to black plus black embers at half gravity; lit debris; 5 teal twinkles; decal-on-mesh with HDR crimson Decal.Color3 (a rend column torus stretched Y ×5, a spike-ring cone erupting Y ×7, a lens→dome shock that opens plus a black-decal dome twin) |
| 0.7–1.4 | follow-through | grey Neon wavy slam ring dropping and flattening (0.8 → 1, Cubic) plus a pulse copy at 0.8 |
| 0.72–2.8 | residue | a white sheen ring at ≥0.93 transparency (1.2 s, Quart); a grey swirl ghost (1.6 s, Quint); radial lit smoke in warm crimson-brown and cool grey twins (LightInfluence 1.5/2, transparency floor 0.6, keypoints >1); black grains; ground scorch (Brightness 60, LightEmission 0); dust blast that darkens over life |

## Principles exercised
These are rule numbers from `reference/principles.md`:
- 1, 2: beats, and the impact/mass split
- 8: light and camera timed to the beats
- 9–12: one hue, dark twins on every bright layer, negative LightEmission, fade to black
- 14: the complement as the hottest pixel
- 16: matter is lit
- 17–19: grey or translucent mesh bodies, HDR decals
- 21–25: anti-correlated scale, rotation on every expansion, push-pull, rings that drop and bands that rise
- 30, 31: multi-texture burst with per-emitter Squash, drag and gravity kinematics
- 34: sharp → round → dots

## Mesh axes (MeshSize) that matter
- **Hoop 18434669670:** thin on X, so it's sized `(thin, d, d)`.
- **Dome 8501563708:** its height is X, so it's rotated (0,0,90) as in the corpus.
- **Wavy, torus and swirl rings:** flat on Y.
- **Cylinder 137685697016553:** tall on Y.
