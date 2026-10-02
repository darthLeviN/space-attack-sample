extends Node
class_name GameTimer

var elapsed_time := 0.0
var running := true


func _enter_tree() -> void:
	add_to_group(&"game_timer")


func _process(delta: float) -> void:
	if running:
		elapsed_time += delta


func reset() -> void:
	elapsed_time = 0.0
