# Dev Guide
Note : Ignore this file for now. i'm still writing it

1- Do not overdo. stick to requirements only. Ask if you want to do anything extra.

# Tasks
Perform these numbered tasks only upon request

1. [ ] Create a folder structure for globals, systems and ui.
2. [ ] Create a `globals.tscn` and `globals.gd` autoload. 1 member variable. of a `GameState` type
3. [ ] Create the `GameState extends Node` class. and add the functionality to `globals.tscn`. with a function that accepts a dictionary as input (for now unused) and creates the `GameState` and adds as child. Will remove existing if instance is valid. i need `start_game(params: Dictionary) -> Dictionary` and `stop_game() -> Dictionary`.
4. [ ] Create `main_menu.tscn` and `pause_menu.tscn`. two UIs. ad an enum to `globals.tscn` that defines whether we're in-game or in the main menu. switching happens by a setter. Create a `game_level.tscn` as an empty level (don't use the pause menu yet). so we have something for the enum's setter to switch to (`start_game` should do the switching. call it from the setter)
5. [ ] Setup the parallax background with a proper infinite loop in `game_level.tscn`.
6. [ ] In `game_level.tscn`'s main script add the
built in `_unhandled_input_key` hook. don't forget to call set as handled. Add a `pause_menu` action to the project with the escape physical key configured for it. Make it bring up the `pause_menu.tscn`. `pause_menu.tscn` should set the scene tree to paused on apperance and set it to unpaused when it disappears.
don't forget the the hook of pause_menu should also use the same action to make itself disappear. and if it's not shown, the hoook needs to be disabled. you can use `is_visible_in_tree` hook in the process function to enable/disable the unhandled key input hook for it.
7. [ ] Create a UI element that uses a flow box that spawns a reusable element for a list of action name + description it is given. The reusable UI elements should detect the physical key from the built in input map, show the input + description in a compact form. If the action name is left empty, it will be just a description guide (example, Arrow keys to move.). Add a `shoot` action in the input map of the project. assign physical key of `space` to it. and with this the flow box will have 2 elements. put it at the bottom of the `game_level.tscn` by creating a `game_hud.tscn` `CanvasLayer` node and adding it to `game_level.tscn`

# Extra tasks
- TODO

# Documentation

## GameState
Should have an internal enum defined to set it's state. Whether the game is running, or ended.
and then a member variable with the enum type, defaulted to running.
`stop_game()` should be a local function here called by the global `stop_game()` and set it's state to ended.
`start_game()` should be a local function wrapped by the global `start_game`. global `start_game` will return the result of `stop_game()` if invalidating a previously running game.


## Input handling
when using unhandled hooks, use it like this

`is_action_type`
then
`is_action_pressed`. if true do the thing

get_viewport().set_action_as_handled( idk if it has typo. fix this line in this file) regardless of pressed.