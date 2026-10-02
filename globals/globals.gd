extends Node

signal player_ship_died

const GAME_LEVEL_SCENE := "res://systems/game_level.tscn"

var game_state: GameState

@export_range(1, 10, 1) var difficulty: int = 1:
	set(value):
		difficulty = clampi(value, 1, 10)


func start_game() -> void:
	if is_instance_valid(game_state):
		game_state.queue_free()
	game_state = null

	game_state = GameState.new()
	add_child(game_state)
	var error := get_tree().change_scene_to_file(GAME_LEVEL_SCENE)
	if error != OK:
		push_error("Could not start the game scene: %s" % error_string(error))
