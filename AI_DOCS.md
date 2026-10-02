# Asset guide

## Assets

Files are listed by path:

- `assets/audio/game/enemy-destroyed.ogg` — enemy explosion.
- `assets/audio/game/enemy-shoot.ogg` — enemy laser.
- `assets/audio/game/player-hit.ogg` — player damage.
- `assets/audio/game/player-shoot.ogg` — player laser.
- `assets/audio/music/simple-bgm-loop.ogg` — CC0 space / sci-fi background music loop.
- `assets/audio/ui/button-click.ogg` — button click.
- `assets/audio/ui/button-confirm.ogg` — button confirmation.
- `assets/backgrounds/space-far-stars.png` — transparent far parallax stars.
- `assets/backgrounds/space-near-stars.png` — transparent near parallax stars.
- `assets/sprites/enemies/enemy-cruiser.png` — enemy type two.
- `assets/sprites/enemies/enemy-scout.png` — enemy type one.
- `assets/sprites/player/player-ship.png` — player ship.
- `assets/sprites/projectiles/enemy-shot.png` — enemy projectile.
- `assets/sprites/projectiles/player-shot.png` — player projectile.

## Interactive previews

`dev/interactive/` contains preview and test harness scenes only. Reusable game systems belong under `systems/` (or `ui/` for interface systems); preview scenes should instance those implementations.

- `dev/interactive/show-all/show-all.gd` — gallery layout and preview logic.
- `dev/interactive/show-all/show-all.tscn` — scrollable asset gallery; sound cards play previews, and the background music card has start / stop controls.
- `dev/interactive/parallax-background/parallax-background.tscn` — preview scene for `systems/background/parallax_background.tscn`.
- `dev/interactive/player-ship/player-ship.tscn` — black-background preview for arrow-key ship movement and hold-to-fire with Space; it adds the player health display and a dev-only “Damage ship (-10 HP)” button directly to its own CanvasLayer.
- `globals/game_state.gd` — active game state, including its optional `player_ship: PlayerShip` reference.

## Game systems

- `systems/background/parallax_background.tscn` — reusable screen-space starfield with far and near parallax layers and an autostarting infinite drift animation.
- `systems/player/player_ship.tscn` and `systems/player/player_ship.gd` — reusable `PlayerShip` in the `player_ship` group with `hp: int = 100` and static `damage_ship(amount: int)`; movement limits are constants, bullet speed and shots per second are exported tuning properties, shots use the `GameSFX` one-shot player, and the ship registers itself on `Globals.game_state.player_ship` when a game state exists.
- `systems/projectiles/player_bullet.tscn` and `systems/projectiles/player_bullet.gd` — upward-moving player bullet with an Area2D collision shape and offscreen cleanup.
- `ui/player-health-display.tscn` and `ui/player-health-display.gd` — reusable bottom-left HP display; it shows the first `player_ship` group member's HP or zero if none exists.
- `ui/game_hud.tscn` — CanvasLayer HUD that instances the player health display.
- `project.godot` — arrow-key movement actions and the `shoot` action bound to Space.
- `systems/audio/default_bus_layout.tres` — project audio buses; `Music` and `GameSFX` route to `Master`.
- `systems/audio/background_music.tscn` — autoplaying music-loop player assigned to the `Music` bus.
- `systems/audio/sfx_player.tscn` and `systems/audio/sfx_player.gd` — reusable one-shot player assigned to `GameSFX`; assign its `stream` before adding it to the scene tree. Example: `var sfx := preload("res://systems/audio/sfx_player.tscn").instantiate() as AudioStreamPlayer`, then set `sfx.stream` and call `add_child(sfx)`.

## Development plan

- `devplan.md` — draft implementation checklist for the game flow, parallax background, pause menu, and controls HUD. Implement numbered tasks only when requested.
- Top-level `globals/`, `systems/`, and `ui/` directories are reserved for shared state, game systems, and interface assets/scripts. Keep production implementations there; `dev/interactive/` is for preview/test harnesses that instance them.
- `globals/globals.tscn` is registered as the `Globals` autoload; `globals/globals.gd` owns the typed `game_state` reference.
- `boot.tscn` is the project startup scene and changes to the empty `CanvasLayer` in `main_menu.tscn` from `boot.gd`.

## Import and licensing

- All PNGs are RGBA with transparent backgrounds. Place the star layers over a dark fill.
- `project.godot` sets nearest-neighbor texture sampling and pixel snapping; PNG import metadata disables mipmaps.
- `assets/LICENSES.md` records CC0 sources and attributions. Original Kenney sound license text is in `assets/licenses/`.
- `project.godot` uses a 1920×1080 viewport and window with CanvasItem stretch scaling.
