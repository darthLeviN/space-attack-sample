class_name GameState
extends Node

enum State {
	RUNNING,
	ENDED,
}

enum EndReason {
	NONE,
	PLAYER_DIED,
	ENEMIES_CLEARED,
}

const GAME_TIMER_SCENE: PackedScene = preload("res://systems/game_timer.tscn")

var player_ship: PlayerShip
var score: int = 0
var game_timer: GameTimer
var state: State = State.RUNNING
var end_reason: EndReason = EndReason.NONE


func _enter_tree() -> void:
	add_to_group(&"game_state")
	if not is_instance_valid(Globals.game_state):
		Globals.game_state = self


func _exit_tree() -> void:
	if Globals.game_state == self:
		Globals.game_state = null


func _ready() -> void:
	game_timer = get_node_or_null("GameTimer") as GameTimer
	if is_instance_valid(game_timer):
		return

	game_timer = GAME_TIMER_SCENE.instantiate() as GameTimer
	if game_timer != null:
		add_child(game_timer)


func end_game(reason: EndReason) -> void:
	if state == State.ENDED:
		return
	state = State.ENDED
	end_reason = reason
	if is_instance_valid(game_timer):
		game_timer.running = false
