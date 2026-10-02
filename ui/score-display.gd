extends PanelContainer
class_name ScoreDisplay

@onready var _score_label: Label = $ScoreLabel

var _displayed_score := -1


func _process(_delta: float) -> void:
	var game_state: GameState = Globals.game_state
	if not is_instance_valid(game_state) or not game_state.is_inside_tree():
		game_state = get_tree().get_first_node_in_group(&"game_state") as GameState

	var current_score := game_state.score if is_instance_valid(game_state) else 0
	if current_score == _displayed_score:
		return

	_displayed_score = current_score
	_score_label.text = "Score: %d" % current_score
