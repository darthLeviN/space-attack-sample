extends CanvasLayer
class_name ParallaxBackgroundSystem

const SCREEN_TILE_SIZE := 512.0
const BASE_ANIMATION_LENGTH := 240.0
const SPEED_TWEEN_DURATION := 1.5

@export_range(0.0, 0.5, 0.01) var speed_variation_range := 0.2
@export_range(1.0, 15.0, 0.5) var speed_change_interval_min := 2.5
@export_range(1.0, 15.0, 0.5) var speed_change_interval_max := 6.0
@export var big_stars_shift := Vector2.ZERO:
	set(value):
		big_stars_shift = value.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
		_apply_big_stars_shift()

@onready var _far_layer: Node2D = $Background/FarLayer
@onready var _big_stars_layer: Node2D = $Background/BigStarsLayer
@onready var _far_animation: AnimationPlayer = $Background/FarAnimationPlayer
@onready var _big_stars_animation: AnimationPlayer = $Background/BigStarsAnimationPlayer

var _rng := RandomNumberGenerator.new()
var _far_random_offset := Vector2.ZERO
var _big_stars_random_offset := Vector2.ZERO
var _far_speed_change_in := 0.0
var _big_stars_speed_change_in := 0.0
var _far_speed_tween: Tween
var _big_stars_speed_tween: Tween


func _ready() -> void:
	_rng.randomize()
	_far_random_offset = _random_tile_offset()
	_big_stars_random_offset = _random_tile_offset()
	_far_layer.position = _far_random_offset
	_apply_big_stars_shift()
	_randomize_animation_phase(_far_animation)
	_randomize_animation_phase(_big_stars_animation)
	_far_animation.speed_scale = _random_speed_scale()
	_big_stars_animation.speed_scale = _random_speed_scale()
	_far_speed_change_in = _random_speed_change_interval()
	_big_stars_speed_change_in = _random_speed_change_interval()
	get_viewport().size_changed.connect(_apply_big_stars_shift)


func _process(delta: float) -> void:
	_far_speed_change_in -= delta
	if _far_speed_change_in <= 0.0:
		_far_speed_tween = _tween_speed(_far_speed_tween, _far_animation)
		_far_speed_change_in = _random_speed_change_interval()

	_big_stars_speed_change_in -= delta
	if _big_stars_speed_change_in <= 0.0:
		_big_stars_speed_tween = _tween_speed(_big_stars_speed_tween, _big_stars_animation)
		_big_stars_speed_change_in = _random_speed_change_interval()


func _apply_big_stars_shift() -> void:
	if not is_node_ready():
		return
	var viewport_size := get_viewport().get_visible_rect().size
	_big_stars_layer.position = big_stars_shift * viewport_size + _big_stars_random_offset


func _random_tile_offset() -> Vector2:
	return Vector2(
		_rng.randf_range(-SCREEN_TILE_SIZE, SCREEN_TILE_SIZE),
		_rng.randf_range(-SCREEN_TILE_SIZE, SCREEN_TILE_SIZE)
	)


func _randomize_animation_phase(player: AnimationPlayer) -> void:
	player.play(&"drift")
	player.seek(_rng.randf_range(0.0, BASE_ANIMATION_LENGTH), true)


func _random_speed_scale() -> float:
	var variation := clampf(speed_variation_range, 0.0, 0.5)
	return _rng.randf_range(1.0 - variation, 1.0 + variation)


func _random_speed_change_interval() -> float:
	var lower := minf(speed_change_interval_min, speed_change_interval_max)
	var upper := maxf(speed_change_interval_min, speed_change_interval_max)
	return _rng.randf_range(lower, upper)


func _tween_speed(previous_tween: Tween, player: AnimationPlayer) -> Tween:
	if is_instance_valid(previous_tween) and previous_tween.is_running():
		previous_tween.kill()
	var tween := create_tween()
	var speed_tween := tween.tween_property(player, "speed_scale", _random_speed_scale(), SPEED_TWEEN_DURATION)
	speed_tween.set_trans(Tween.TRANS_SINE)
	speed_tween.set_ease(Tween.EASE_IN_OUT)
	return tween
