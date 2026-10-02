extends Control
class_name GameOver

@onready var _score_label: Label = $MenuStack/ScoreLabel
@onready var _main_menu_button: Button = $MenuStack/MainMenuButton


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true


func _ready() -> void:
	_score_label.text = "SCORE: %d" % _get_current_score()
	_main_menu_button.pressed.connect(_go_to_main_menu)
	_main_menu_button.grab_focus()
	set_process_unhandled_key_input(true)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_go_to_main_menu()
	get_viewport().set_input_as_handled()


func _get_current_score() -> int:
	var game_state := Globals.game_state
	if not is_instance_valid(game_state) or not game_state.is_inside_tree():
		game_state = get_tree().get_first_node_in_group(&"game_state") as GameState
	return game_state.score if is_instance_valid(game_state) else 0


func _go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
