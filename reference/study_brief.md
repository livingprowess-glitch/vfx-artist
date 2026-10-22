# modern_vfx study: shared brief for every study session

## Goal
Reverse-engineer each effect in `Workspace.modern_vfx` (Place3 "vfx training", PlaceId 114773467389373) until it can be rebuilt 1:1. Explain the **why** behind every choice: color, texture, particle count, size curve, transparency curve, lifetime, speed, spread, LightEmission/Brightness/ZOffset, orientation, emit delay, and CFrame. The user's complaint is that my mesh VFX is outdated, so pay the most attention to the meshes, beams and the layer stack.

## Read first
1. `../SKILL.md`
2. `emit_patterns.md` (the Forge VFX attribute schema, curve decoding and runtime contract)

## Tools and rules
- Dump with `bash ~/.claude/skills/vfx-artist/tools/dump.sh "Workspace.modern_vfx.<Name>[.<Child>]" <outfile>`. It guards the PlaceId and retries. For big effects, dump one child at a time.
- Put outfiles in your own scratchpad, with names that include your effect.
- Custom probes go through `powershell -NoProfile -ExecutionPolicy Bypass -File C:/Users/osaya/rbxbridge/rbx.ps1 -Op run -File <your temp file>`.
  - The first line must be `if game.PlaceId ~= 114773467389373 then return "WRONGPLACE" end`.
  - Use a unique temp name, e.g. `$$`-suffixed.
  - **Return ASCII only.** Non-UTF-8 text in a result used to kill the bridge client.
- The bridge is shared with other sessions and handles one request at a time. Keep probes small. Never loop or sleep in Studio.
- **Read only.** Never edit, move or delete anything in the place. Cloning into `workspace` for a visual capture is allowed only if you destroy it in the same call. Never start a playtest.
- If `rbx.ps1 -Op status` shows `pluginAgeMs` over ~30000, the Ropilot-hosted client has stopped. Restart it by pasting `C:\Users\osaya\rbxbridge\ropilot_client.lua` into `mcp__Ropilot__ropilot_edit_ctx_run_command`. Rerunning it replaces the old loop.
- `mcp__Ropilot__ropilot_vfx_capture` may be used sparingly to see an effect play. Ropilot is single-connection, so keep captures short.
- **Write only your own files:** `~/.claude/skills/vfx-artist/breakdowns/<Effect>.md`. Put cross-effect insights in a `## Candidate principles` section at the end of your breakdown, never in shared files. The main session merges them.

## Breakdown template (`breakdowns/<Effect>.md`)
1. **Read**: what the effect is, in one sentence, and how the eye travels: first frame, peak, residue.
2. **Timeline**: a table of `t (s) | layer | what happens`, built from EmitDelay, EffectDuration, Lifetime and TimeScale ramps.
3. **Layer stack**: for each emitter, mesh model, beam or trail:
   - its role (core flash, body, secondary, sparks, smoke, residue, ground)
   - its key values: texture id, color sequence, size/transparency sequences or Forge curves, count, lifetime, speed, LightEmission, Brightness, ZOffset, Orientation
   - **why** those values: value contrast, silhouette, motion read, the depth trick, and so on
4. **Mesh VFX detail**: mesh ids, the Start-to-End CFrame/size delta (scale factor, rotation delta, offset), transparency range, easing, the decal-on-mesh trick, and spin.
5. **Color & value**: the palette as hex, where the light/dark pairs and hue shifts are, and the LightEmission strategy (for example, a dark twin of a glowing emitter used for contrast).
6. **Rebuild recipe**: the minimal steps or pseudo-Luau needed to reproduce it 1:1 with the Forge-schema runtime.
7. **Candidate principles**: generalizable rules, each with the evidence behind it.
