# Local visual preview — not published

Project: MakeLifeSlower_VisualPreview. Live GitHub release is unchanged.

Models: Quaternius Stylized Nature MegaKit Standard (CC0 1.0), 11 selected assets.
https://quaternius.com/packs/stylizednaturemegakit.html
License included in assets/environment/nature/LICENSE.txt.
Selected PNG textures reduced to at most 512 pixels; crops reuse leaf geometry with green UV variants.

Photo sky: Kloofendal 48d Partly Cloudy (Pure Sky), Greg Zaal / Jarod Guest, Poly Haven (CC0).
https://polyhaven.com/a/kloofendal_48d_partly_cloudy_puresky
Tone-mapped photo resized to 2048x1024 JPEG. Daylight/dusk/night tint is controlled by the game.
Old sphere clouds removed. This is a static photo sky, not moving simulated clouds.

Trees/flowers use MultiMesh instances. Only nearby shade trees cast shadows.
Gameplay integration: 56 checks passed. Native GPU measurements are not browser measurements.

## Round 2: lush meadow and waterfall

Added short common/wispy grass, wind, extra wildflowers, bushes and shoreline rocks from Quaternius CC0 assets. Grass is instanced in spatial batches and kept off roads, buildings, crops and water.

Ground texture: Leafy Grass, Poly Haven, CC0.
https://polyhaven.com/a/leafy_grass
Cliff albedo and normal: Rock 01, Poly Haven, CC0.
https://polyhaven.com/a/rock_01
Mountains and waterfall meshes/effects are authored for this preview, with Quaternius rock props; they are not downloaded finished mountain/waterfall models.
The lake basin and collision terrain use the same height function.
Playable map bounds remain -140..140 meters.
Native benchmark: about 60 FPS capped at 60, NVIDIA RTX 4050, process ~6.1ms. This is not a browser benchmark.
Gameplay integration passed 56 checks.
The video is a deterministic 30FPS capture, not a performance recording.
GitHub has NOT been updated.
