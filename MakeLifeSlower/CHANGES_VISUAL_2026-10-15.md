# Cozy environment polish

Visual target: the approved AI concept; the shipped result is actual Godot 3D with web-compatible materials, not an AI backdrop.

Ground now mixes short-grass detail with broad restrained color variation. All three roads are painted into the terrain using a compact offline mask with irregular feathered edges. The old elevated solid strips are removed. The same terrain mesh/collision remains in use. A second mask channel adds restrained contact darkening around building foundations.

Compact CC0 Poly Haven maps add ivory plaster, timber and roof tiles. House foundations, fascia, corner posts, chimney caps and entrance steps gain rounded edge details. Roof snow remains a shader blend. Mountain surfaces gain triplanar rock detail. Daylight and blue ambient fill are rebalanced; existing night darkness, sun/moon direction and vehicle/lantern behavior remain intact. Fuller existing Quaternius tree variants replace sparse near-home crowns; small flower clusters dress selected edges, while the main lawn stays clear.

Free CC0 equipment replaces placeholder geometry: Isa Lousberg watering can (tinted sage), Quaternius fishing rod/reel, Kenney hoe/upgraded hoe including its color atlas. Equipment sizes are normalized consistently for first- and third-person use. Exact attribution is in LICENSES.md and assets/equipment/SOURCES.md.

Performance: native RTX 4050 test at 1280x720, VSync/cap disabled, measured approximately 462 FPS high / 695–705 FPS low in a fixed farm test. These are local native measurements, not a promise for browsers or other computers. Web scene and legacy save/import/export tested separately before release.

Includes the five systems in CHANGES_2026-10-15.md: processing, villagers, festivals, garden decoration and save slots, plus harder fishing and the owner's administrator-password change. See that file for gameplay and validation details. Visual-specific regression checks: 21 passing (equipment scale/geometry, road alignment/collision, seasonal roof snow). Existing checks also passed after visual integration.
