extends FlowContainer
class_name ControlsGuide

const ACTION_HINT_SCENE: PackedScene = preload("res://ui/action_hint.tscn")
const ACTION_HINTS: Array[Dictionary] = [
	{"action_name": &"", "description": "ARROW KEYS TO MOVE"},
	{"action_name": &"shoot", "description": "SHOOT"},
]


func _ready() -> void:
	for hint_data in ACTION_HINTS:
		var hint := ACTION_HINT_SCENE.instantiate() as ActionHint
		if hint == null:
			continue
		hint.action_name = hint_data["action_name"]
		hint.description = hint_data["description"]
		add_child(hint)
