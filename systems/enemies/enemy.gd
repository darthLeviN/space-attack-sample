extends Area2D
class_name Enemy

enum EnemyType {
	DEBUG,
	NORMAL,
	ELITE,
}

enum MovementMode {
	IDLE,
	ATTACKING,
}

const SFX_PLAYER_SCENE: PackedScene = preload("res://systems/audio/sfx_player.tscn")
const ENEMY_HIT_SOUND: AudioStream = preload("res://assets/audio/game/player-hit.ogg")
const ENEMY_DESTROYED_SOUND: AudioStream = preload("res://assets/audio/game/enemy-destroyed.ogg")

@export var enemy_type: EnemyType = EnemyType.DEBUG
@export var movement_mode: MovementMode = MovementMode.IDLE
@export_range(1, 10, 1) var max_hp: int = 3
@export_range(0.0, 200.0, 1.0) var idle_sway_distance := 56.0
@export_range(0.0, 2.0, 0.05) var idle_sway_speed := 0.5

var hp: int = 3
var slot_index := 0
var _defeated := false
var _has_idle_slot := false
var _idle_slot_position := Vector2.ZERO
var _game_timer: GameTimer


func _ready() -> void:
	add_to_group(&"enemies")
	hp = 3 if enemy_type == EnemyType.DEBUG else max_hp
	if not _has_idle_slot:
		_idle_slot_position = position
	_game_timer = _find_game_timer()


func _process(_delta: float) -> void:
	if movement_mode != MovementMode.IDLE:
		return
	if not is_instance_valid(_game_timer):
		_game_timer = _find_game_timer()
	if not is_instance_valid(_game_timer):
		return

	var sway := sin(_game_timer.elapsed_time * idle_sway_speed) * idle_sway_distance
	position = _idle_slot_position + Vector2(sway, 0.0)


func set_idle_slot(
	index: int,
	column_count: int,
	grid_center: Vector2,
	column_spacing: float,
	row_spacing: float,
) -> void:
	if column_count <= 0:
		return

	slot_index = index
	var row := floori(float(slot_index) / float(column_count))
	var column := slot_index % column_count
	var x_offset := (float(column) - float(column_count - 1) / 2.0) * column_spacing
	_idle_slot_position = grid_center + Vector2(x_offset, row * row_spacing)
	_has_idle_slot = true
	position = _idle_slot_position


func take_damage(amount: int = 1) -> void:
	if amount <= 0 or _defeated:
		return

	hp = maxi(0, hp - amount)
	if hp > 0:
		_play_sound(ENEMY_HIT_SOUND)
		return

	_defeated = true
	_play_sound(ENEMY_DESTROYED_SOUND)
	_add_score()
	queue_free()


func despawn() -> void:
	_defeated = true
	queue_free()


func _add_score() -> void:
	var game_state: GameState = Globals.game_state
	if not is_instance_valid(game_state):
		game_state = get_tree().get_first_node_in_group(&"game_state") as GameState
	if is_instance_valid(game_state):
		game_state.score += 1


func _play_sound(sound: AudioStream) -> void:
	var sfx := SFX_PLAYER_SCENE.instantiate() as AudioStreamPlayer
	if sfx == null:
		return

	sfx.stream = sound
	var sfx_parent := get_tree().current_scene
	if sfx_parent == null:
		sfx_parent = get_tree().root
	sfx_parent.add_child(sfx)


func _find_game_timer() -> GameTimer:
	return get_tree().get_first_node_in_group(&"game_timer") as GameTimer
