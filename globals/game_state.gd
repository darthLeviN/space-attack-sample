class_name GameState
extends Node

var player_ship: PlayerShip
var score: int = 0


func _enter_tree() -> void:
	add_to_group(&"game_state")
	if not is_instance_valid(Globals.game_state):
		Globals.game_state = self


func _exit_tree() -> void:
	if Globals.game_state == self:
		Globals.game_state = null
