extends Node2D
class_name PlayerShipExplosion

const PARTICLE_COUNT := 14
const LIFETIME := 0.7

var _elapsed := 0.0
var _rng := RandomNumberGenerator.new()
var _velocities: Array[Vector2] = []
var _sizes: Array[Vector2] = []
var _colors: Array[Color] = []
var _rotations: Array[float] = []
var _rotation_speeds: Array[float] = []


func _ready() -> void:
	_rng.randomize()
	var palette: Array[Color] = [
		Color(1.0, 0.96, 0.72),
		Color(1.0, 0.68, 0.22),
		Color(0.95, 0.32, 0.12),
	]
	for _index in PARTICLE_COUNT:
		var direction := Vector2.RIGHT.rotated(_rng.randf_range(0.0, TAU))
		_velocities.append(direction * _rng.randf_range(45.0, 155.0))
		var side := _rng.randf_range(5.0, 12.0)
		_sizes.append(Vector2(side * _rng.randf_range(0.7, 1.6), side))
		_colors.append(palette[_rng.randi_range(0, palette.size() - 1)])
		_rotations.append(_rng.randf_range(0.0, TAU))
		_rotation_speeds.append(_rng.randf_range(-7.0, 7.0))
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := clampf(_elapsed / LIFETIME, 0.0, 1.0)
	var fade := 1.0 - progress
	if progress < 0.55:
		var core_size := lerpf(24.0, 0.0, progress / 0.55)
		draw_rect(
			Rect2(Vector2(-core_size, -core_size), Vector2.ONE * core_size * 2.0),
			Color(1.0, 0.88, 0.35, fade),
		)

	for index in _velocities.size():
		var position := _velocities[index] * _elapsed
		var particle_size := _sizes[index] * (1.0 - progress * 0.4)
		var particle_color := _colors[index]
		particle_color.a = fade
		draw_set_transform(
			position,
			_rotations[index] + _rotation_speeds[index] * _elapsed,
			Vector2.ONE,
		)
		draw_rect(Rect2(-particle_size / 2.0, particle_size), particle_color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
