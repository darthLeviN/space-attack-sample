extends Node2D

@onready var _background: CanvasLayer = $ParallaxBackground
@onready var _x_slider: HSlider = $PreviewControls/Panel/VBox/XRow/XSlider
@onready var _y_slider: HSlider = $PreviewControls/Panel/VBox/YRow/YSlider
@onready var _x_value: Label = $PreviewControls/Panel/VBox/XRow/XValue
@onready var _y_value: Label = $PreviewControls/Panel/VBox/YRow/YValue


func _ready() -> void:
	var shift: Vector2 = _background.get("big_stars_shift")
	_x_slider.set_value_no_signal(shift.x)
	_y_slider.set_value_no_signal(shift.y)
	_update_value_labels(shift)
	_x_slider.value_changed.connect(_on_x_slider_changed)
	_y_slider.value_changed.connect(_on_y_slider_changed)


func _on_x_slider_changed(value: float) -> void:
	_set_shift_axis(0, value)


func _on_y_slider_changed(value: float) -> void:
	_set_shift_axis(1, value)


func _set_shift_axis(axis: int, value: float) -> void:
	var shift: Vector2 = _background.get("big_stars_shift")
	if axis == 0:
		shift.x = value
	else:
		shift.y = value
	_background.set("big_stars_shift", shift)
	_update_value_labels(shift)


func _update_value_labels(shift: Vector2) -> void:
	_x_value.text = "%.2f" % shift.x
	_y_value.text = "%.2f" % shift.y
