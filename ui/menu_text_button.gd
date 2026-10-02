extends Button
class_name MenuTextButton

signal highlighted(button: MenuTextButton)

const BUTTON_SFX_SCENE: PackedScene = preload("res://systems/audio/sfx_player.tscn")
const BUTTON_CLICK_SOUND: AudioStream = preload("res://assets/audio/ui/button-click.ogg")

var _label_text := ""


func _ready() -> void:
	_label_text = text
	focus_mode = Control.FOCUS_ALL
	flat = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for style_name in [&"normal", &"hover", &"pressed", &"focus", &"disabled"]:
		add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
	focus_entered.connect(_refresh_visual)
	focus_exited.connect(_refresh_visual)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_play_button_sfx)
	_refresh_visual()


func _on_mouse_entered() -> void:
	grab_focus()
	highlighted.emit(self)
	_refresh_visual()


func _on_mouse_exited() -> void:
	_refresh_visual()


func _refresh_visual() -> void:
	var is_highlighted := has_focus()
	text = ("›  " if is_highlighted else "   ") + _label_text
	add_theme_color_override(
		"font_color",
		Color(0.43, 0.91, 1, 1) if is_highlighted else Color(0.72, 0.84, 0.98, 1)
	)


func _play_button_sfx() -> void:
	var sfx := BUTTON_SFX_SCENE.instantiate() as AudioStreamPlayer
	sfx.stream = BUTTON_CLICK_SOUND
	get_tree().current_scene.add_child(sfx)
