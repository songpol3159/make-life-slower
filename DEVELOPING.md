# Development

## Project layout

- `MakeLifeSlower/`: editable Godot project, GDScript, shaders, tests, runtime assets and license notices.
- `Rigged_Game_Models/`: editable Blender model sources with rigs.
- Root Python files and `tools/*.py`: asset preparation, build, validation and historical migration helpers.
- `docs/`: exported web game and model gallery served by GitHub Pages.

## Run and export

Use Godot 4.7.2 Standard (GDScript), with the Compatibility renderer. Import
`MakeLifeSlower/project.godot` and press F5. Install matching Godot export
templates before exporting Web or Windows through Project > Export. Create
`MakeLifeSlower/build/web` or `MakeLifeSlower/build/windows` if needed.

For a command-line web export, from the repository root:

```sh
godot --headless --path MakeLifeSlower --export-release Web
node MakeLifeSlower/serve.mjs
```

Open the local URL printed by the server. Web exports must be served over HTTP,
not opened as local HTML files. Browser saves are stored per browser and origin;
use the game's JSON export/import when transferring saves.

## Optional development tools

The game itself requires no Python packages. Some asset helpers use Python 3,
Pillow and NumPy; Blender scripts require Blender's `bpy` runtime. Scripts retain
the original workstation paths and workflow. Review their path constants before
running. Historical migration scripts modify project files and are not required
to open or play the current project. Imported runtime assets are already included.

The publishing helpers target `publish/make-life-slower` under the working
directory; they are records of the release workflow, not required to run the game.
`publish_github.py` creates a repository and should not be run for this existing
repository. Authentication helpers obtain credentials from Git's credential
manager at runtime; no login credentials are bundled.

Engine binaries, export templates, caches, local saves, private credential notes
and duplicate build archives are excluded. The admin gate in this offline game
is a convenience lock, not a security boundary against someone editing source.

See `MakeLifeSlower/LICENSES.md` and asset-specific source notices before reusing
third-party art, fonts or audio. Their licenses remain applicable.
