# Make Life Slower

A cozy 3D farming demo for desktop web browsers, made with Godot.

## Play and update

Enable GitHub Pages: Settings → Pages → Deploy from a branch → main → /docs.
The published URL remains the same when new builds are pushed to main.

To update, replace the files in docs with the latest web export, commit, and push.
Keep the filenames and save format compatible to preserve existing browser saves.
Saves stay on each browser and origin; a localhost save will not automatically
transfer to GitHub Pages. Controller navigation is supported in game and menus.

## Controls

WASD: move; mouse: look; Shift: run; E: interact; 1–4: tools; V: FPS/TPS;
I: inventory; M: map; L: lantern; Esc: menu. Xbox: sticks move/look, A interact,
X use, Y inventory, shoulders tools, Start pause. In menus, D-pad/stick selects,
left/right adjusts, A confirms and B returns.

This repository contains the editable Godot project, development scripts, Blender
model sources, the web release and third-party license notices.

## Open the source

Clone or download this repository. Import `MakeLifeSlower/project.godot` in
Godot 4.7.2 Standard, wait for asset import, then press F5 to play.
See [DEVELOPING.md](DEVELOPING.md) for the project layout and export instructions.

## Latest update — October 15, 2026

Cozy environment polish: feathered dirt paths painted into the terrain, short-grass
variation, textured plaster/timber/roof tiles, fuller tree crowns and warmer light.
Free CC0 watering can, hoe variants and fishing rod replace placeholder equipment.

Open the pause menu or gardener journal for processing machines, garden decoration,
the calendar/festivals and save slots. Visit shopkeepers to talk, give gifts and
unlock rewards. Fishing includes species-specific movement and surges.

Three save slots support JSON file export/import. Export a backup before clearing
browser data or moving between localhost and this site; saves are not cloud synced.
The original save remains in slot 1. Export a slot before importing a replacement.

See docs/LICENSES.md for equipment and environment attribution.
