#!/usr/bin/env bash
# usage: dump.sh <dotted.path> <outfile> [placeId]
# Dumps a VFX subtree through rbxbridge with a PlaceId guard; retries if another Studio answers.
target="$1"; out="$2"; place="${3:-114773467389373}"
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -t vfxdump.XXXXXX).lua"
{ echo "if game.PlaceId ~= $place then return \"WRONGPLACE \" .. game.Name end"; sed "s|__PATH__|$target|" "$here/dump_vfx.lua"; } > "$tmp"
for i in 1 2 3 4 5 6 7 8; do
	powershell -NoProfile -ExecutionPolicy Bypass -File C:/Users/osaya/rbxbridge/rbx.ps1 -Op run -File "$(cygpath -w "$tmp" 2>/dev/null || echo "$tmp")" -TimeoutSec 90 > "$out" 2>&1
	head -c 10 "$out" | grep -q WRONGPLACE || break
done
rm -f "$tmp"
echo "$(wc -l < "$out") lines -> $out"; head -c 200 "$out"; echo
