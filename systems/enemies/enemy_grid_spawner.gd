extends Node
class_name EnemyGridSpawner

enum Difficulty {
	EASY,
	NORMAL,
	HARD,
}

const ENEMY_SCENE: PackedScene = preload("res://systems/enemies/enemy.tscn")

@export var spawn_root: Node
@export var grid_center := Vector2(960.0, 240.0)
@export_range(48.0, 240.0, 1.0) var column_spacing := 112.0
@export_range(48.0, 200.0, 1.0) var row_spacing := 88.0
@export_range(0.25, 60.0, 0.25) var attack_interval_min := 4.0
@export_range(0.25, 60.0, 0.25) var attack_interval_max := 8.0

var _spawned_enemies: Array[Enemy] = []
var _random := RandomNumberGenerator.new()
var _attack_cooldown := 0.0


func _ready() -> void:
	_random.randomize()


func _process(delta: float) -> void:
	if _spawned_enemies.is_empty():
		return

	_attack_cooldown -= delta
	if _attack_cooldown > 0.0:
		return

	_launch_next_attack()
	_reset_attack_cooldown()


func spawn_grid(difficulty: int) -> Array[Enemy]:
	var spawned_enemies: Array[Enemy] = []
	if not is_instance_valid(spawn_root):
		push_warning("EnemyGridSpawner needs a spawn_root before spawn_grid() is called.")
		return spawned_enemies

	var was_empty := _spawned_enemies.is_empty()
	var grid_size := _grid_size_for_difficulty(difficulty)
	var row_count := grid_size.x
	var column_count := grid_size.y
	for row in range(row_count):
		for column in range(column_count):
			var enemy := ENEMY_SCENE.instantiate() as Enemy
			if enemy == null:
				continue
			enemy.enemy_type = Enemy.EnemyType.NORMAL

			var slot_index := row * column_count + column
			enemy.set_idle_slot(
				slot_index,
				column_count,
				grid_center,
				column_spacing,
				row_spacing,
			)
			spawn_root.add_child(enemy)
			spawned_enemies.append(enemy)
			_spawned_enemies.append(enemy)

	if was_empty and not _spawned_enemies.is_empty():
		_reset_attack_cooldown()

	return spawned_enemies


func _launch_next_attack() -> void:
	var idle_enemies: Array[Enemy] = []
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy) and enemy.can_start_attack():
			idle_enemies.append(enemy)

	if idle_enemies.is_empty():
		return

	var random_index := _random.randi_range(0, idle_enemies.size() - 1)
	idle_enemies[random_index].start_attack()


func _reset_attack_cooldown() -> void:
	var low := minf(attack_interval_min, attack_interval_max)
	var high := maxf(attack_interval_min, attack_interval_max)
	_attack_cooldown = _random.randf_range(low, high)


func _grid_size_for_difficulty(difficulty: int) -> Vector2i:
	match clampi(difficulty, Difficulty.EASY, Difficulty.HARD):
		Difficulty.EASY:
			return Vector2i(2, 6)
		Difficulty.HARD:
			return Vector2i(4, 10)
		_:
			return Vector2i(3, 8)
