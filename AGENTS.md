# Project description
We're making a pixel-art basic space attack demo game where you move a ship at the bottom of the screen and a bunch of enemies attack you from the top.

the godot engine 4.7.2 is avaiblable in PATH and .local/bin/godot
project already created.

You may read up on [Dev Plan](./devplan.md)

Assets are in the `./assets` folder

Put reusable and production game implementations in `systems/` or `ui/`. Use `dev/interactive/` only for preview and test harness scenes that instance existing systems; do not put the only or primary implementation of a game system there.

For sound effects, use the reusable `systems/audio/sfx_player.tscn`: assign its `stream` before adding it to the scene tree. Do not create `AudioStreamPlayer` nodes manually for one-shot SFX.

Apply player damage through `PlayerShip.damage_ship(amount)` rather than changing `hp` directly; the shared method updates HP and plays the player-hit SFX.

Use `memory.md` to store short notes when you need them.

Multiple agents will be running so don't get confused.

Agents will update (AI DOCS)[./AI_DOCS.md] as they finish their works. you should read it and do that too.
