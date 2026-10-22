# How modern_vfx effects are emitted

The corpus was authored mostly in **Forge VFX**, a Studio plugin. Its runtime reads attributes off each instance, and the tags `ConstantVFX`, `BezierParticle`, `__forge_excludeFromEmit`, `AuraInstance`, `CameraShake` and `LoadVFXTextures` identify it. Smaller pieces come from other tools:
- **PartIcle:** `Configuration` children with SizeX/Y/Z, RotSpeedX/Y/Z, PosOffset and similar sequences. It turns real 3D parts into particles.
- **EasyMeshEmit:** generates code from `Model._EasyMeshEmitData` (the `mesh_effects*` modules).
- **Pesto:** `PestoId` / `#PestoTracked`, an asset tracker. Ignore it.
- **Qwinkle:** `IsEmitter` / `EmissionMode` on ImageLabels and parts.

Every emitter in the corpus is `Enabled=false`. **Nothing loops by default; everything is a timed burst.**

## Runtime contract (ReplicatedStorage.effects)
- `effects.simple_emit(root)`: for every ParticleEmitter, `task.delay(EmitDelay or 0, Emit, EmitCount or 1)`.
- `u4_effects.Emit(root)`: waits `EmitDelay`, then `Emit(EmitCount or @Rate or .Rate)`. If an EmitDelay exists, it also enables the emitter for EmitDelay seconds. The intended key is almost certainly **EmitDuration** (1,875 emitters carry it): emit the burst, then `Enabled=true` for `EmitDuration` seconds, then off. When rebuilding, implement it that way.
- `u4_effects.Enable(root, bool)`: toggles ParticleEmitter, Beam, Trail, PointLight and SpotLight. Used for sustained auras (`#ConstantVFX`).
- `u4_effects.ScaleParticles(root, k, t?)`: multiplies Size keypoints, Speed, Drag, VelocityInheritance and Acceleration by k. **Scale all five together** or the effect's shape changes with size.
- `u4_effects.EmitMesh(model, cf)`: the **Start/End mesh pattern** described below.
- `mesh_effects*` (EasyMeshEmit export): clones `Start`, sets `General.Transparency`, places it at `cf * Offset`, then tweens Size, CFrame, Color and Transparency to the `BasePart.Property` target over `Tween_Duration` with Quad/Quart/Quint Out, and destroys it afterwards. **If the part carries a Decal, the part goes invisible and the Decal's transparency is animated instead.** The texture lives on a decal wrapped onto the mesh, not on the mesh itself.

## Forge attribute schema
Every animatable property is a triple: `X_Start`, `X_End` and `X_Curve`, sometimes plus `X_Duration`.
- **`*_Curve`** is a 48-byte string of 12 float32 values: `[0,1, x1,y1, x2,y2, 1,0, 0,0,0,0]`. That is a CSS cubic-bezier in screen space, so the real easing is `cubic-bezier(x1, 1-y1, x2, 1-y2)`. `dump_vfx.lua` decodes it as `bezier(...)=name`. Forge's default is `.215,.61,.355,1` = **easeOutCubic**.
- **ParticleEmitter:**
  - `EmitCount`, `EmitDelay`, `EmitDuration`
  - `Size_Start/End/Curve/Envelope`
  - `Transparency_Start/Curve`
  - `TimeScale_Start/End/Duration/Curve`, on 1,117 emitters: a **time-scale ramp, usually fast to slow**. This is the "hang" in modern hits.
  - `BaseEmitCount`/`BaseRate` (scaling), `EmitType`
  - `UseGroundColor`/`GrassColor`/`MaterialIgnore`: ground debris tinted to the floor.
- **Mesh Model (Start + End children, 306 models):**
  - `EffectDuration` (NumberRange), `EmitCount`, `EmitDelay`, `EmitDuration`, `Rate`
  - `Part_Transparency_Start/End/Curve`, `Part_Size_Curve`, `Part_CFrame_Curve`
  - `Part_RotSpeed_Start/End/Curve`, `Min/MaxInitRot` (random initial spin, e.g. Y 0..360)
  - `SpreadAngle`, `Speed_Start/End`, `RotAroundOrigin`, `SyncPosition`, `DestroyDelay`
  - Mesh/Decal variants: `Mesh_Scale_Curve`, `Mesh_Start/EndTransparency`, `Decal_Start/EndTransparency`, `*_TweenParams`, `Flipbook`, `FlipbookFadeOffset`
  - **The mesh tweens from Start's CFrame and Size to End's.** Start and End are always `Transparency=1` in the editor. The real visibility comes from `Part_Transparency_Start`, typically 0.8–0.9, going to 1.
- **Beam (96):**
  - `Width0/1_Start/End/Curve`, `CurveSize0/1_Start/End`
  - `Length_Texture_Start/End/Curve` (TextureLength animates), `Speed_Texture_Start/End/Curve` (TextureSpeed animates)
  - `Transparency_Scale_Start/End/Curve`, `Length_Scale_Start/End`
  - `EffectDuration`, `EmitDelay`, `EmitDuration`
- **Bezier particles (`#BezierParticle` Attachment):**
  - `Points/1..n` attachments, each with a `T0`/`T1` tangent child.
  - Particles travel the path over `Duration` with `Easing_Curve`.
  - Other keys: `Speed/RotSpeed_Start/End`, `MirrorPaths` + `MirrorRotation` (a symmetric twin path), `FacePath`, `Projectile*`, `Hitbox*`.
- **Model spin:** `SpinRotation` (Vector3 degrees), `SpinDuration`, `SpinSpeed_Start/End/Curve`, `Scale_Start/End/Curve`, `ResetOnFinish`.
- **RayValue:** camera shake (`Amplitude`, `Frequency`, `Falloff`, `FadeInTime`, `SustainTime`, `FadeOutTime`, `#CameraShake`).

## Rebuilding in the user's pipeline
A modern effect is a template model with these attributes. A small runtime does four things:
1. Clone the template to the target CFrame.
2. Read every `*_Start/_End/_Curve` triple and tween it with the decoded bezier, either through TweenService with the nearest EasingStyle, or by sampling the bezier on a Heartbeat.
3. Burst the emitters by EmitDelay/EmitCount/EmitDuration.
4. Destroy everything after the longest `EmitDelay + EffectDuration + Lifetime.Max`.

**Never hand-tween a single part as the whole effect.** In One Piece Prime, the frame tables in `classes.effects` call this runtime.
