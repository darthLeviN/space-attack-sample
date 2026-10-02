# Development Guide

> Draft: ignore this guide for now; it is still being written.

Keep changes focused on the stated requirements. Ask before adding extra scope.

## Tasks

Implement these numbered tasks only when requested.

1. [ ] Create folder structure for globals, systems, and UI.
2. [ ] Create `globals.tscn` and `globals.gd` as an autoload. Add one member variable of type `GameState`.
3. [ ] Create the `GameState` class extending `Node` and wire it into `globals.tscn`. Add a function that accepts a `Dictionary` (unused for now), creates a `GameState`, and adds it as a child. Remove the existing instance first if it is valid. Add `start_game(params: Dictionary) -> Dictionary` and `stop_game() -> Dictionary`.
4. [ ] Create `main_menu.tscn` and `pause_menu.tscn`. Add an enum to `globals.tscn` for whether the game is in the main menu or in-game, with scene switching handled by a setter. Create `game_level.tscn` as an empty level; do not add the pause menu yet. This gives the setter a game scene to switch to. `start_game` should perform the switch, and the setter should call it.
5. [ ] Set up a properly looping infinite parallax background in `game_level.tscn`.
6. [ ] In the main script for `game_level.tscn`, add the built-in `_unhandled_key_input(event)` hook and mark input as handled. Add a `pause_menu` action to the project Input Map, bound to the Escape physical key, and use it to show `pause_menu.tscn`. The pause menu should pause the scene tree when it appears and unpause it when it disappears. Its input hook should use the same action to hide the menu. Disable unhandled-key input processing while the menu is not visible; use `is_visible_in_tree()` in the process function to enable or disable it.
7. [ ] Create a UI element using a `FlowContainer` that creates reusable elements from a list of action names and descriptions. Each reusable element should find the physical key bound to its action in the project Input Map and show the key and description compactly. If the action name is empty, show only the description (for example, “Arrow keys to move.”). Add a `shoot` action bound to the Space physical key. The flow container should have two elements. Place it at the bottom of `game_level.tscn` by creating a `game_hud.tscn` with a `CanvasLayer` root and adding it to `game_level.tscn`.

## Extra tasks

- TODO

## Documentation

### GameState

`GameState` should define an internal enum for its state: running or ended. Add a member variable of that enum type, defaulting to running.

The local `stop_game()` function should set the state to ended and be called by the global `stop_game()` function. The local `start_game()` function should be wrapped by the global `start_game()`. If the global function invalidates a previously running game, it should return the result of `stop_game()`.

### Input handling

In an unhandled key-input hook, check `event.is_action_pressed("action_name")` and perform the action if it returns `true`. Call `get_viewport().set_input_as_handled()` regardless of whether the action was pressed.
