extends PanelContainer
class_name PlayerHealthDisplay

@onready var _health_label: Label = $HealthLabel

var _displayed_hp := -1


func _process(_delta: float) -> void:
	var player_ship := get_tree().get_first_node_in_group(&"player_ship") as PlayerShip
	var current_hp := player_ship.hp if player_ship != null else 0
	if current_hp == _displayed_hp:
		return

	_displayed_hp = current_hp
	_health_label.text = "HP: %d" % current_hp
