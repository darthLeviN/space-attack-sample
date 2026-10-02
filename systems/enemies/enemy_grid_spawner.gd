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


func spawn_grid(difficulty: int) -> Array[Enemy]:
	var spawned_enemies: Array[Enemy] = []
	if not is_instance_valid(spawn_root):
		push_warning("EnemyGridSpawner needs a spawn_root before spawn_grid() is called.")
		return spawned_enemies

	var grid_size := _grid_size_for_difficulty(difficulty)
	var row_count := grid_size.x
	var column_count := grid_size.y
	for row in range(row_count):
		for column in range(column_count):
			var enemy := ENEMY_SCENE.instantiate() as Enemy
			if enemy == null:
				continue

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

	return spawned_enemies


func _grid_size_for_difficulty(difficulty: int) -> Vector2i:
	match clampi(difficulty, Difficulty.EASY, Difficulty.HARD):
		Difficulty.EASY:
			return Vector2i(2, 6)
		Difficulty.HARD:
			return Vector2i(4, 10)
		_:
			return Vector2i(3, 8)
