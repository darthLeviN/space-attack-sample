extends Node2D
class_name PlayerShip

const MOVE_SPEED := 450.0
const MOVEMENT_MIN := Vector2(32.0, 720.0)
const MOVEMENT_MAX := Vector2(1888.0, 1016.0)
const MOVEMENT_ACTIONS: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"move_up",
	&"move_down",
]

var _held_actions := {
	&"move_left": false,
	&"move_right": false,
	&"move_up": false,
	&"move_down": false,
}


func _enter_tree() -> void:
	if is_instance_valid(Globals.game_state):
		Globals.game_state.player_ship = self


func _ready() -> void:
	set_process_unhandled_key_input(true)
	global_position = global_position.clamp(MOVEMENT_MIN, MOVEMENT_MAX)


func _unhandled_key_input(event: InputEvent) -> void:
	for action in MOVEMENT_ACTIONS:
		if event.is_action_pressed(action):
			_held_actions[action] = true
		elif event.is_action_released(action):
			_held_actions[action] = false

	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var direction := Vector2(
		float(_held_actions[&"move_right"]) - float(_held_actions[&"move_left"]),
		float(_held_actions[&"move_down"]) - float(_held_actions[&"move_up"]),
	)
	if direction.is_zero_approx():
		return

	global_position = (
		global_position + direction.normalized() * MOVE_SPEED * delta
	).clamp(MOVEMENT_MIN, MOVEMENT_MAX)
