# Asset guide

## Assets

Files are listed by path:

- `assets/audio/game/enemy-destroyed.ogg` — enemy explosion.
- `assets/audio/game/enemy-shoot.ogg` — enemy laser.
- `assets/audio/game/player-hit.ogg` — player damage.
- `assets/audio/game/player-shoot.ogg` — player laser.
- `assets/audio/ui/button-click.ogg` — button click.
- `assets/audio/ui/button-confirm.ogg` — button confirmation.
- `assets/backgrounds/space-far-stars.png` — transparent far parallax stars.
- `assets/backgrounds/space-near-stars.png` — transparent near parallax stars.
- `assets/sprites/enemies/enemy-cruiser.png` — enemy type two.
- `assets/sprites/enemies/enemy-scout.png` — enemy type one.
- `assets/sprites/player/player-ship.png` — player ship.
- `assets/sprites/projectiles/enemy-shot.png` — enemy projectile.
- `assets/sprites/projectiles/player-shot.png` — player projectile.

## Gallery

- `dev/interactive/show-all/show-all.gd` — gallery layout and preview logic.
- `dev/interactive/show-all/show-all.tscn` — scrollable asset gallery; sound cards play previews.
- `dev/interactive/parallax-background/parallax-background.tscn` — reusable 1080p starfield background with far and near parallax layers; its AnimationPlayer autostarts a slow, infinitely looping drift.

## Development plan

- `devplan.md` — draft implementation checklist for the game flow, parallax background, pause menu, and controls HUD. Implement numbered tasks only when requested.
- Top-level `globals/`, `systems/`, and `ui/` directories are reserved for shared state, game systems, and interface assets/scripts.
- `globals/globals.tscn` is registered as the `Globals` autoload; `globals/globals.gd` owns the typed `game_state` reference.
- `boot.tscn` is the project startup scene and changes to the empty `CanvasLayer` in `main_menu.tscn` from `boot.gd`.

## Import and licensing

- All PNGs are RGBA with transparent backgrounds. Place the star layers over a dark fill.
- `project.godot` sets nearest-neighbor texture sampling and pixel snapping; PNG import metadata disables mipmaps.
- `assets/LICENSES.md` records CC0 sources and attributions. Original Kenney sound license text is in `assets/licenses/`.
- `project.godot` uses a 1920×1080 viewport and window with CanvasItem stretch scaling.
