extends PanelContainer
class_name ActionHint

@export var action_name: StringName = &""
@export var description := ""

@onready var _key_label: Label = $Content/KeyLabel
@onready var _description_label: Label = $Content/DescriptionLabel


func _ready() -> void:
	_description_label.text = description
	if action_name.is_empty():
		_key_label.hide()
		return

	var key_name := _get_action_key_name(action_name)
	_key_label.text = "[%s]" % key_name.to_upper()


func _get_action_key_name(action: StringName) -> String:
	for event in InputMap.action_get_events(action):
		var key_event := event as InputEventKey
		if key_event == null:
			continue

		var keycode := key_event.physical_keycode
		if keycode == KEY_NONE:
			keycode = key_event.keycode
		if keycode != KEY_NONE:
			return OS.get_keycode_string(keycode)

	return String(action)
