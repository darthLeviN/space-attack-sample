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
const ENEMY_BULLET_SCENE: PackedScene = preload("res://systems/projectiles/enemy_bullet.tscn")
const ENEMY_HIT_SOUND: AudioStream = preload("res://assets/audio/game/player-hit.ogg")
const ENEMY_DESTROYED_SOUND: AudioStream = preload("res://assets/audio/game/enemy-destroyed.ogg")
const ENEMY_SHOOT_SOUND: AudioStream = preload("res://assets/audio/game/enemy-shoot.ogg")

@export var enemy_type: EnemyType = EnemyType.DEBUG
@export var movement_mode: MovementMode = MovementMode.IDLE
@export_range(1, 10, 1) var max_hp: int = 2
@export_range(0.0, 200.0, 1.0) var idle_sway_distance := 168.0
@export_range(0.0, 2.0, 0.05) var idle_sway_speed := 0.5
@export_range(30.0, 300.0, 10.0) var attack_speed := 120.0
@export_range(0.25, 60.0, 0.25) var shot_interval_min := 10.0
@export_range(0.25, 60.0, 0.25) var shot_interval_max := 24.0
@export_range(50.0, 1200.0, 1.0) var enemy_bullet_speed := 166.6667

var hp: int = 3
var slot_index := 0
var _defeated := false
var _has_idle_slot := false
var _idle_slot_position := Vector2.ZERO
var _game_timer: GameTimer
var _random := RandomNumberGenerator.new()
var _shot_cooldown := 0.0


func _ready() -> void:
	add_to_group(&"enemies")
	hp = 3 if enemy_type == EnemyType.DEBUG else max_hp
	if not _has_idle_slot:
		_idle_slot_position = position
	_game_timer = _find_game_timer()
	_random.seed = randi()
	_reset_initial_shot_cooldown()


func _process(delta: float) -> void:
	if _defeated:
		return
	_update_firing(delta)
	match movement_mode:
		MovementMode.IDLE:
			_update_idle_movement()
		MovementMode.ATTACKING:
			_update_attack_movement(delta)


func start_attack() -> void:
	if _defeated or movement_mode == MovementMode.ATTACKING:
		return

	movement_mode = MovementMode.ATTACKING


func can_start_attack() -> bool:
	return not _defeated and movement_mode == MovementMode.IDLE


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


func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group(&"player_hurtbox"):
		return

	var player := area.get_parent()
	if player != null and player.has_method("kill_from_enemy_attack"):
		player.call("kill_from_enemy_attack")
		despawn()


func _find_game_timer() -> GameTimer:
	return get_tree().get_first_node_in_group(&"game_timer") as GameTimer


func _update_idle_movement() -> void:
	if not is_instance_valid(_game_timer):
		_game_timer = _find_game_timer()
	if not is_instance_valid(_game_timer):
		return

	var sway := sin(_game_timer.elapsed_time * idle_sway_speed) * idle_sway_distance
	position = _idle_slot_position + Vector2(sway, 0.0)


func _update_attack_movement(delta: float) -> void:
	var direction := Vector2.DOWN
	var player := get_tree().get_first_node_in_group(&"player_ship") as Node2D
	if player != null:
		var to_player := player.global_position - global_position
		var downward_component := maxf(maxf(absf(to_player.x), to_player.y), 1.0)
		direction = Vector2(to_player.x, downward_component).normalized()

	global_position += direction * attack_speed * delta
	var screen_bounds := get_viewport_rect().grow(32.0)
	if not screen_bounds.has_point(global_position):
		despawn()


func _update_firing(delta: float) -> void:
	_shot_cooldown -= delta
	if _shot_cooldown > 0.0:
		return

	var bullet := ENEMY_BULLET_SCENE.instantiate() as EnemyBullet
	if bullet != null:
		bullet.speed = enemy_bullet_speed
		var bullet_parent: Node = get_tree().current_scene
		if bullet_parent == null:
			bullet_parent = get_tree().root
		bullet_parent.add_child(bullet)
		bullet.global_position = global_position + Vector2(0.0, 20.0)
		_play_sound(ENEMY_SHOOT_SOUND)

	_reset_shot_cooldown()


func _reset_shot_cooldown() -> void:
	_shot_cooldown = _random_shot_interval()


func _random_shot_interval() -> float:
	var interval_bounds := _scaled_shot_interval_bounds()
	return _random.randf_range(interval_bounds.x, interval_bounds.y)


func _scaled_shot_interval_bounds() -> Vector2:
	var low := minf(shot_interval_min, shot_interval_max)
	var high := maxf(shot_interval_min, shot_interval_max)
	var difficulty := clampi(Globals.difficulty, 1, 10)
	var difficulty_progress := float(difficulty - 1) / 9.0
	var fire_rate_multiplier := lerpf(1.0, 4.0, difficulty_progress)
	return Vector2(low, high) / fire_rate_multiplier


func _reset_initial_shot_cooldown() -> void:
	var interval_bounds := _scaled_shot_interval_bounds()
	_shot_cooldown = _random.randf_range(0.0, interval_bounds.y)
