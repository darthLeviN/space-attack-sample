extends Node

signal player_ship_died

var game_state: GameState

@export_range(1, 10, 1) var difficulty: int = 1:
	set(value):
		difficulty = clampi(value, 1, 10)
