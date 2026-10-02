# Asset guide

## Assets

Files are listed by path:

- `assets/audio/game/enemy-destroyed.ogg` — enemy explosion and player death sound.
- `assets/audio/game/enemy-shoot.ogg` — enemy laser.
- `assets/audio/game/player-hit.ogg` — player damage, sourced from GreyFrogGames' CC0 Player Hit (damage) sound on OpenGameArt.
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
- `dev/interactive/parallax-background/parallax-background.tscn` and `parallax_background_preview.gd` — preview scene for the reusable parallax system, with X/Y sliders for checking the large-star layer offset from -1.0 to 1.0.
- `dev/interactive/player-ship/player-ship.tscn` — black-background preview for arrow-key ship movement and hold-to-fire with Space; it adds the player health display and a dev-only “Damage ship (-10 HP)” button directly to its own CanvasLayer.
- `globals/game_state.gd` — active game state, including its optional `player_ship: PlayerShip` reference.

## Game systems

- `systems/background/parallax_background.tscn` and `parallax_background.gd` — reusable screen-space starfield with separate autostarting infinite drift animations for each star layer, randomized startup offsets and animation phases, gently randomized speed scales, and an exported `big_stars_shift` vector for the near/big-star layer. The star textures are scaled 4× (256px tile spacing at the current assets' 64px size).
- `systems/player/player_ship.tscn` and `systems/player/player_ship.gd` — reusable `PlayerShip` in the `player_ship` group with `hp: int = 100`, a sprite-matched `player_hurtbox`, static `damage_ship(amount: int)`, and `kill_from_enemy_attack()`; route damage through `damage_ship` to update HP and play the player-hit sound. At zero HP it stops accepting input, clears its `GameState` reference, plays its death sound, spawns the pixel explosion, and emits `Globals.player_ship_died`. Movement limits are constants, bullet speed and shots per second are exported properties, shots use the `GameSFX` one-shot player, and the ship registers itself on `Globals.game_state.player_ship` when a game state exists.
- `systems/effects/player_ship_explosion.tscn` and `player_ship_explosion.gd` — short, procedural pixel burst used when the player dies.
- `systems/projectiles/player_bullet.tscn` and `systems/projectiles/player_bullet.gd` — upward-moving player bullet with a collision rectangle matched to the visible sprite alpha bounds and offscreen cleanup.
- `systems/projectiles/enemy_bullet.tscn` and `systems/projectiles/enemy_bullet.gd` — downward-moving enemy projectile (default 166.7 px/s) with a sprite-matched collision shape; hitting a player hurtbox applies lethal damage through `PlayerShip.damage_ship`.
- `systems/game_timer.tscn` and `systems/game_timer.gd` — shared elapsed-time clock in the `game_timer` group; GameState creates it as a child, and standalone previews may instance it directly.
- `systems/enemies/enemy.tscn` and `systems/enemies/enemy.gd` — reusable enemy Area2D with a collision rectangle matched to the visible sprite alpha bounds; exported DEBUG/NORMAL/ELITE type and IDLE/ATTACKING movement mode, configurable 1–10 HP (DEBUG always has 3), and synchronized slow left-right idle movement driven by its slot position and the first GameTimer. Enemies fire autonomously in either movement mode; each enemy gets an independent initial phase uniformly spread from zero to the longest difficulty-scaled interval, then fires at independent randomized intervals from 10–24 seconds at difficulty 1; firing rate rises linearly to 4× at difficulty 10. Attacking enemies move toward a player or straight down when none exists. Player bullets deal one damage and play impact feedback; enemy-to-player contact is lethal; defeated enemies play the explosion SFX and award one point to an available GameState; `despawn()` removes an enemy without awarding score.
- `systems/enemies/enemy_grid_spawner.tscn` and `systems/enemies/enemy_grid_spawner.gd` — reusable grid spawner with exported `spawn_root` and `spawn_grid(difficulty)`; EASY, NORMAL, and HARD create progressively larger grids and assign stable slot indices.
- `dev/interactive/enemy/enemy-movement-check.tscn` — idle formation preview with its own GameTimer and no GameState or PlayerShip; each “Attack Next” press chooses a random idle enemy from this preview and starts its movement attack, allowing multiple attacks to run concurrently. Enemy firing runs independently of this development button.
- `ui/player-health-display.tscn` and `ui/player-health-display.gd` — reusable bottom-left HP display; it shows the first `player_ship` group member's HP or zero if none exists.
- `ui/score-display.tscn` and `ui/score-display.gd` — reusable score panel that shows the active GameState score or zero.
- `ui/game_hud.tscn` — CanvasLayer HUD that instances the player health and score displays.
- `ui/game_over.tscn` and `ui/game_over.gd` — standalone `Control` game-over screen with no background; pauses the scene tree on entry, displays the active GameState score, consumes all unhandled key input, and returns to the main menu with its button or Escape. It is not wired into gameplay yet.
- `main_menu.tscn` and `ui/main_menu.gd` — production main menu with the shared parallax background and looping BGM; unpauses the scene tree on entry, offers Start Game and a native-only Quit, then opens the difficulty selector. The selector adjusts `Globals.difficulty` from 1 to 10 and includes a no-op Start Game placeholder and Back action.
- `ui/menu_text_button.tscn` and `ui/menu_text_button.gd` — reusable transparent text button with focus/hover highlighting, mouse and keyboard activation, and the shared `button-click.ogg` SFX through `systems/audio/sfx_player.tscn`.
- `globals/globals.gd` and `globals/globals.tscn` — `difficulty` is exported and clamped to 1–10 so the menu selector and the Globals autoload use the same value; enemy firing rate is scaled from this value.
- `dev/interactive/enemy/enemy-check.tscn` — enemy test harness with a button that fires the reusable moving player bullet at the enemy, a no-score respawn button, and the score display.
- `project.godot` — arrow-key movement actions and the `shoot` action bound to Space.
- `systems/audio/default_bus_layout.tres` — project audio buses; `Music` and `GameSFX` route to `Master`.
- `systems/audio/background_music.tscn` — autoplaying music-loop player assigned to the `Music` bus.
- `systems/audio/sfx_player.tscn` and `systems/audio/sfx_player.gd` — reusable one-shot player assigned to `GameSFX`; assign its `stream` before adding it to the scene tree. Use this scene for all one-shot SFX; do not create `AudioStreamPlayer` nodes manually for SFX. Example: `var sfx := preload("res://systems/audio/sfx_player.tscn").instantiate() as AudioStreamPlayer`, then set `sfx.stream` and call `add_child(sfx)`.

## Development plan

- `devplan.md` — draft implementation checklist for the game flow, parallax background, pause menu, and controls HUD. Implement numbered tasks only when requested.
- Top-level `globals/`, `systems/`, and `ui/` directories are reserved for shared state, game systems, and interface assets/scripts. Keep production implementations there; `dev/interactive/` is for preview/test harnesses that instance them.
- `globals/globals.tscn` is registered as the `Globals` autoload; `globals/globals.gd` owns the typed `game_state` reference.
- `globals/globals.gd` defines the global `player_ship_died` signal emitted when the player ship reaches zero HP.
- `globals/game_state.gd` exposes `score: int = 0`, registers active instances in the `game_state` group, and assigns/clears the Globals reference when the slot is available.
- `boot.tscn` is the project startup scene and changes to the empty `CanvasLayer` in `main_menu.tscn` from `boot.gd`.

## Import and licensing

- All PNGs are RGBA with transparent backgrounds. Place the star layers over a dark fill.
- `project.godot` sets nearest-neighbor texture sampling and pixel snapping; PNG import metadata disables mipmaps.
- `assets/LICENSES.md` records CC0 sources and attributions. Original Kenney sound license text is in `assets/licenses/`.
- `project.godot` uses a 1920×1080 viewport and window with CanvasItem stretch scaling.
