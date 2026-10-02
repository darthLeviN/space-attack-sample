extends CanvasLayer

@onready var _main_panel: Control = $UI/MainPanel
@onready var _difficulty_panel: Control = $UI/DifficultyPanel
@onready var _start_game_button: MenuTextButton = $UI/MainPanel/MenuStack/StartGameButton
@onready var _quit_button: MenuTextButton = $UI/MainPanel/MenuStack/QuitButton
@onready var _decrease_button: MenuTextButton = $UI/DifficultyPanel/MenuStack/DifficultyRow/DecreaseButton
@onready var _increase_button: MenuTextButton = $UI/DifficultyPanel/MenuStack/DifficultyRow/IncreaseButton
@onready var _difficulty_value: Label = $UI/DifficultyPanel/MenuStack/DifficultyRow/DifficultyValue
@onready var _difficulty_start_button: MenuTextButton = $UI/DifficultyPanel/MenuStack/StartGameButton
@onready var _back_button: MenuTextButton = $UI/DifficultyPanel/MenuStack/BackButton

var _main_buttons: Array[MenuTextButton] = []
var _difficulty_buttons: Array[MenuTextButton] = []
var _active_buttons: Array[MenuTextButton] = []
var _focused_button_index := -1
var _showing_difficulty := false


func _enter_tree() -> void:
	get_tree().paused = false


func _ready() -> void:
	_quit_button.visible = not OS.has_feature("web")
	_main_buttons = [_start_game_button]
	if _quit_button.visible:
		_main_buttons.append(_quit_button)
	_difficulty_buttons = [_decrease_button, _increase_button, _difficulty_start_button, _back_button]

	_start_game_button.pressed.connect(_show_difficulty_page)
	_quit_button.pressed.connect(_quit_game)
	_decrease_button.pressed.connect(_change_difficulty.bind(-1))
	_increase_button.pressed.connect(_change_difficulty.bind(1))
	_difficulty_start_button.pressed.connect(_start_game)
	_back_button.pressed.connect(_show_main_page)

	for button in _main_buttons + _difficulty_buttons:
		button.highlighted.connect(_on_button_highlighted)

	_show_main_page()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		_move_focus(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		_move_focus(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left"):
		if _showing_difficulty:
			_decrease_button.pressed.emit()
		else:
			_move_focus(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		if _showing_difficulty:
			_increase_button.pressed.emit()
		else:
			_move_focus(1)
		get_viewport().set_input_as_handled()


func _show_main_page() -> void:
	_showing_difficulty = false
	_main_panel.show()
	_difficulty_panel.hide()
	_active_buttons = _main_buttons
	_focus_button(_start_game_button)


func _show_difficulty_page() -> void:
	_showing_difficulty = true
	_main_panel.hide()
	_difficulty_panel.show()
	_update_difficulty_display()
	_active_buttons = _difficulty_buttons
	_focus_button(_decrease_button)


func _move_focus(direction: int) -> void:
	if _active_buttons.is_empty():
		return
	_focused_button_index = posmod(_focused_button_index + direction, _active_buttons.size())
	_active_buttons[_focused_button_index].grab_focus()


func _focus_button(button: MenuTextButton) -> void:
	_focused_button_index = _active_buttons.find(button)
	button.grab_focus()


func _on_button_highlighted(button: MenuTextButton) -> void:
	var index := _active_buttons.find(button)
	if index >= 0:
		_focused_button_index = index


func _change_difficulty(amount: int) -> void:
	Globals.difficulty = clampi(Globals.difficulty + amount, 1, 10)
	_update_difficulty_display()


func _update_difficulty_display() -> void:
	_difficulty_value.text = str(Globals.difficulty)


func _start_game() -> void:
	# The game launch is intentionally a placeholder until the game scene is ready.
	pass


func _quit_game() -> void:
	get_tree().quit()
